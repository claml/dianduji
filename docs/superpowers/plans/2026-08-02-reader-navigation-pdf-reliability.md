# Reader Navigation and PDF Reliability Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add direction-aware auto-hiding reader navigation and replace the per-word PDF overlay with tolerant, on-demand character hit testing.

**Architecture:** `ReaderChromeController` owns toolbar visibility and consumes normalized content-scroll deltas from reflow readers and `pdfrx`. PDF pages cache text geometry for at most eight pages; a tap resolves the nearest valid character and expands it into a word without creating permanent widgets for every word. The page overlay paints only the active selection.

**Tech Stack:** Flutter 3.x, Dart, Riverpod, GoRouter, `pdfrx` 2.4.7, Flutter unit/widget tests, Android integration tests.

## Global Constraints

- Preserve original PDF rendering; do not reflow PDF text.
- The navigation toolbar overlays the document and must not change PDF viewport dimensions when shown or hidden.
- Initial view and document top show the toolbar; downward reading hides after 24dp accumulated travel; upward reading reveals immediately.
- Word taps, translation-card drag, and pinch zoom must not change toolbar visibility.
- Toolbar motion duration is 180ms and becomes `Duration.zero` when `MediaQuery.disableAnimationsOf(context)` is true.
- Keep at most 8 pages of PDF text geometry and clear the cache when the document changes.
- A malformed character or fragment must not disable the rest of the page.
- Do not add OCR, network access, database migrations, or new third-party dependencies in this plan.
- Preserve documents, vocabulary, phrases, reading progress, and reader-card preferences.

---

## File Map

- Create `mobile/lib/features/reader/presentation/reader_chrome_controller.dart`: pure direction and threshold state machine.
- Create `mobile/lib/features/reader/presentation/widgets/reader_top_bar.dart`: overlay toolbar, hide animation, and top-edge reveal zone.
- Modify `mobile/lib/app/app.dart`: push reader routes instead of replacing the home route.
- Modify `mobile/lib/features/reader/presentation/reader_page.dart`: own chrome state, save-before-back, and normalize PDF pan deltas.
- Modify `mobile/lib/features/reader/presentation/reader_screen.dart`: remove fixed `AppBar`, install overlay toolbar, and report reflow scroll deltas.
- Create `mobile/lib/features/reader/domain/pdf_page_geometry.dart`: validated fragment-level mapping from PDF text to character rectangles.
- Replace `mobile/lib/features/reader/domain/pdf_word_geometry_builder.dart` with `mobile/lib/features/reader/domain/pdf_text_hit_tester.dart`: on-demand word and context resolution.
- Modify `mobile/lib/features/reader/domain/pdf_word_hit_target.dart`: retain a single tap result and its highlight rectangles.
- Create `mobile/lib/features/reader/presentation/widgets/pdf_page_text_store.dart`: bounded asynchronous page geometry cache.
- Modify `mobile/lib/features/reader/presentation/widgets/pdf_word_overlay.dart`: load geometry and paint only the selected word.
- Modify `mobile/lib/features/reader/presentation/widgets/pdf_document_view.dart`: character hit testing, selection state, and pan reporting.
- Update reader unit, widget, and Android integration tests listed in the tasks below.

---

### Task 1: Restore Navigation History and Reliable Back

**Files:**
- Modify: `mobile/lib/app/app.dart`
- Modify: `mobile/lib/features/reader/presentation/reader_page.dart`
- Modify: `mobile/lib/features/reader/presentation/reader_screen.dart`
- Test: `mobile/test/features/reader/reader_page_test.dart`

**Interfaces:**
- Produces: `ReaderScreen.onNavigateBack: Future<void> Function()?`
- Produces: `_ReaderPageState._leaveReader(): Future<void>`
- Consumes: existing `ReaderController.forceSave()` and GoRouter `/` route.

- [ ] **Step 1: Write failing navigation tests**

Add tests that open a reader from a previous route, tap the explicit `reader-back-button`, and verify both route return and progress save. Add a direct-entry test whose callback navigates to `/` when no route can pop.

```dart
expect(find.byKey(const Key('reader-back-button')), findsOneWidget);
await tester.tap(find.byKey(const Key('reader-back-button')));
await tester.pumpAndSettle();
expect(find.byKey(const Key('home-route-marker')), findsOneWidget);
expect(documents.saved, isNotEmpty);
```

- [ ] **Step 2: Run the focused tests and verify failure**

Run:

```powershell
D:\local_environment\Flutter\flutter\bin\flutter.bat test test/features/reader/reader_page_test.dart
```

Expected: FAIL because the fixed reader back button and `onNavigateBack` callback do not exist.

- [ ] **Step 3: Preserve the route stack and implement save-before-back**

Change document opening to push:

```dart
void _openDocument(String documentId) {
  _router.push('/reader/$documentId');
}
```

Add the callback in `ReaderPage`:

```dart
Future<void> _leaveReader() async {
  await _controller.forceSave();
  if (!mounted) return;
  final router = GoRouter.of(context);
  if (router.canPop()) {
    router.pop();
  } else {
    router.go('/');
  }
}
```

Pass it to `ReaderScreen` and, in this task, bind it to an explicit `AppBar.leading` `IconButton` keyed `reader-back-button`. Task 2 will move that same keyed button into the overlay toolbar. Keep `PopScope` so Android system back still saves progress.

- [ ] **Step 4: Run focused tests**

Run the command from Step 2.

Expected: PASS, including the existing system-back save test.

- [ ] **Step 5: Commit**

```powershell
git add mobile/lib/app/app.dart mobile/lib/features/reader/presentation/reader_page.dart mobile/lib/features/reader/presentation/reader_screen.dart mobile/test/features/reader/reader_page_test.dart
git commit -m "fix: restore reader back navigation"
```

---

### Task 2: Direction-Aware Overlay Toolbar

**Files:**
- Create: `mobile/lib/features/reader/presentation/reader_chrome_controller.dart`
- Create: `mobile/lib/features/reader/presentation/widgets/reader_top_bar.dart`
- Modify: `mobile/lib/features/reader/presentation/reader_page.dart`
- Modify: `mobile/lib/features/reader/presentation/reader_screen.dart`
- Test: `mobile/test/features/reader/reader_chrome_controller_test.dart`
- Test: `mobile/test/features/reader/reader_interaction_test.dart`

**Interfaces:**
- Produces: `ReaderChromeController({double hideThreshold = 24})`
- Produces: `void handleContentScroll(double delta, {bool atTop = false})`
- Produces: `void reveal()` and `bool get visible`
- Produces: `ReaderTopBar(title, visible, onBack, onReveal, onSettings)`.
- Consumes: `ReaderScreen.onNavigateBack` from Task 1.

- [ ] **Step 1: Write failing state-machine tests**

Cover initial visibility, accumulated downward travel, immediate upward reveal, top reset, and no repeated notifications:

```dart
final chrome = ReaderChromeController(hideThreshold: 24);
expect(chrome.visible, isTrue);
chrome.handleContentScroll(10);
chrome.handleContentScroll(13);
expect(chrome.visible, isTrue);
chrome.handleContentScroll(2);
expect(chrome.visible, isFalse);
chrome.handleContentScroll(-1);
expect(chrome.visible, isTrue);
chrome.handleContentScroll(100, atTop: true);
expect(chrome.visible, isTrue);
```

- [ ] **Step 2: Run the controller test and verify failure**

```powershell
D:\local_environment\Flutter\flutter\bin\flutter.bat test test/features/reader/reader_chrome_controller_test.dart
```

Expected: FAIL because `ReaderChromeController` is missing.

- [ ] **Step 3: Implement the minimal controller**

Implement a `ChangeNotifier` with this behavior:

```dart
void handleContentScroll(double delta, {bool atTop = false}) {
  if (atTop || delta < 0) {
    _downwardTravel = 0;
    _setVisible(true);
    return;
  }
  if (delta <= 0 || !_visible) return;
  _downwardTravel += delta;
  if (_downwardTravel >= hideThreshold) _setVisible(false);
}
```

`reveal()` resets accumulated travel and shows the toolbar. Ignore non-finite deltas.

- [ ] **Step 4: Write failing toolbar widget tests**

In `reader_interaction_test.dart`, pass a controller to `ReaderScreen`, scroll the document down past 24dp, and verify the toolbar slide becomes hidden. Scroll upward and tap the hidden top-edge reveal zone to verify both reveal paths. Verify the document viewport rectangle is identical before and after hide.

```dart
final before = tester.getRect(find.byKey(const Key('reader-document-viewport')));
chrome.handleContentScroll(30);
await tester.pump(const Duration(milliseconds: 180));
expect(find.byKey(const Key('reader-top-bar')), findsOneWidget);
expect(tester.getRect(find.byKey(const Key('reader-document-viewport'))), before);
await tester.tap(find.byKey(const Key('reader-top-reveal-zone')));
await tester.pump(const Duration(milliseconds: 180));
expect(chrome.visible, isTrue);
```

- [ ] **Step 5: Build the overlay toolbar and wire reflow scroll**

Replace `Scaffold.appBar` with a body `Stack`:

```dart
Stack(
  children: [
    Positioned.fill(child: documentSurface),
    ReaderTopBar(
      title: widget.title,
      visible: widget.chromeController.visible,
      onBack: widget.onNavigateBack,
      onReveal: widget.chromeController.reveal,
    ),
  ],
)
```

`ReaderTopBar` uses `AnimatedSlide(offset: visible ? Offset.zero : const Offset(0, -1))`, a `SafeArea`, a 180ms duration, and an `IconButton` keyed `reader-back-button`. Only while hidden, add a translucent `Positioned` top-edge gesture region keyed `reader-top-reveal-zone`; its height is `max(MediaQuery.paddingOf(context).top, 24)`.

Keep the existing reading-settings action in the toolbar. Bind toolbar visibility through `AnimatedBuilder(animation: widget.chromeController, ...)` so chrome changes rebuild only the toolbar stack, not the document widget.

Wrap only the reflow/TXT document scrollable—not the translation card—in `NotificationListener<ScrollUpdateNotification>`. Report `notification.scrollDelta ?? 0` and pass `atTop: notification.metrics.pixels <= notification.metrics.minScrollExtent`.

- [ ] **Step 6: Run controller and interaction tests**

```powershell
D:\local_environment\Flutter\flutter\bin\flutter.bat test test/features/reader/reader_chrome_controller_test.dart test/features/reader/reader_interaction_test.dart test/features/reader/reader_page_test.dart
```

Expected: PASS. Existing word taps, phone bottom sheet, tablet side pane, floating card, and system-back behavior remain green.

- [ ] **Step 7: Commit**

```powershell
git add mobile/lib/features/reader/presentation/reader_chrome_controller.dart mobile/lib/features/reader/presentation/widgets/reader_top_bar.dart mobile/lib/features/reader/presentation/reader_page.dart mobile/lib/features/reader/presentation/reader_screen.dart mobile/test/features/reader/reader_chrome_controller_test.dart mobile/test/features/reader/reader_interaction_test.dart mobile/test/features/reader/reader_page_test.dart
git commit -m "feat: auto-hide reader navigation"
```

---

### Task 3: Fragment-Tolerant PDF Geometry and On-Demand Hit Testing

**Files:**
- Create: `mobile/lib/features/reader/domain/pdf_page_geometry.dart`
- Create: `mobile/lib/features/reader/domain/pdf_text_hit_tester.dart`
- Modify: `mobile/lib/features/reader/domain/pdf_word_hit_target.dart`
- Delete: `mobile/lib/features/reader/domain/pdf_word_geometry_builder.dart`
- Create: `mobile/test/features/reader/pdf_text_hit_tester_test.dart`
- Delete: `mobile/test/features/reader/pdf_word_geometry_builder_test.dart`

**Interfaces:**
- Produces: `PdfPageGeometry.fromStructured(PdfPageText text)`
- Produces: `PdfPageGeometry.fromRaw(int pageNumber, PdfPageRawText text)`
- Produces: `PdfPageGeometry({required int pageNumber, required String fullText, required List<PdfTextGeometryRun> runs})` and `PdfTextGeometryRun(textStart, rects)` for deterministic fragmented-geometry tests.
- Produces: `PdfRect? rectAt(int textIndex)` and validated text runs.
- Produces: `PdfWordHitTarget? hitTestPdfText(PdfPageGeometry page, PdfPoint point, {double margin = 12})`.
- Produces: `PdfWordHitTarget` with `surface`, normalized text, source offsets, context sentence, and selected PDF rectangles.

- [ ] **Step 1: Write failing geometry tests**

Add tests for normal words, apostrophes, true compound hyphens, soft line-break hyphens, two-column coordinates, metadata exclusion, and malformed geometry. The malformed test must prove that a bad fragment does not hide a later valid fragment. Metadata exclusion is local to the clicked visual line: author lists, affiliations, and page-number lines are not interactive, while titles and section headings are.

```dart
expect(hit('context-sensitive').surface, 'context-sensitive');
expect(hit('mecha-\nnisms').surface, 'mechanisms');
expect(hit("model's").surface, "model's");
expect(hitFromRuns([badRun, validRun], pointInValidRun)?.surface, 'wayfinding');
expect(hitLine('Department of Computer Science'), isNull);
expect(hitLine('2. Methods')?.surface, 'Methods');
```

Also assert that sentence context collapses soft line breaks:

```dart
expect(result.contextText, 'It explains mechanisms at scale.');
```

- [ ] **Step 2: Run the new tests and verify failure**

```powershell
D:\local_environment\Flutter\flutter\bin\flutter.bat test test/features/reader/pdf_text_hit_tester_test.dart
```

Expected: FAIL because `PdfPageGeometry` and `hitTestPdfText` do not exist.

- [ ] **Step 3: Implement validated page geometry**

Represent page geometry as immutable runs containing `textStart` and character rectangles. If `fullText.length == charRects.length`, create one run. Otherwise, accept only fragments satisfying all conditions below:

```dart
fragment.index >= 0 &&
fragment.end <= text.fullText.length &&
fragment.length == fragment.charRects.length
```

Skip empty, non-finite, or inverted rectangles in `rectAt`; never shift later text indices to compensate for a missing middle rectangle. `fromRaw` creates a run only when raw text length exactly equals raw rectangle count because PDFium defines one rectangle per character; if that contract is broken, return an empty geometry instead of guessing.

- [ ] **Step 4: Implement tap-to-word expansion**

Find the containing character rectangle first, then the nearest rectangle within `margin`. Expand from that character across `[A-Za-z]`, apostrophes, and same-line hyphens. Detect `-` followed by whitespace containing a newline and another alphabetic segment; remove that soft hyphen and whitespace from `surface`, while retaining source offsets and both highlight rectangle groups. Extract context between sentence punctuation boundaries, collapse line breaks to spaces, and dehyphenate soft wraps.

Before returning, classify only the visual line containing the clicked index. Return `null` for page-number lines, author-list lines, and affiliation lines; do not inspect or reject the rest of the page. Return `null` when no valid alphabetic word or no highlight rectangle exists.

- [ ] **Step 5: Run geometry tests**

Run the command from Step 2.

Expected: PASS for normal, two-column, wrapped, and partially malformed pages.

- [ ] **Step 6: Commit**

```powershell
git add mobile/lib/features/reader/domain/pdf_page_geometry.dart mobile/lib/features/reader/domain/pdf_text_hit_tester.dart mobile/lib/features/reader/domain/pdf_word_hit_target.dart mobile/test/features/reader/pdf_text_hit_tester_test.dart
git rm mobile/lib/features/reader/domain/pdf_word_geometry_builder.dart mobile/test/features/reader/pdf_word_geometry_builder_test.dart
git commit -m "feat: hit-test PDF words on demand"
```

---

### Task 4: Bounded Page Text Store and Selection-Only Overlay

**Files:**
- Create: `mobile/lib/features/reader/presentation/widgets/pdf_page_text_store.dart`
- Modify: `mobile/lib/features/reader/presentation/widgets/pdf_word_overlay.dart`
- Modify: `mobile/lib/features/reader/presentation/widgets/pdf_document_view.dart`
- Test: `mobile/test/features/reader/pdf_word_overlay_test.dart`

**Interfaces:**
- Produces: `PdfPageTextSource` with `pageNumber`, `loadStructuredText()`, and `loadRawText()`.
- Produces: `PdfPageTextStore({int maxPages = 8})`, `Future<PdfPageGeometry?> load(source)`, `PdfPageGeometry? get(pageNumber)`, and `clear()`.
- Consumes: `hitTestPdfText` and `PdfWordHitTarget` from Task 3.
- Produces: `PdfWordOverlay(page, selectedTarget, store)` that paints zero or one selection.

- [ ] **Step 1: Write failing cache and overlay tests**

Test LRU eviction, duplicate in-flight load coalescing, structured-to-raw fallback, error isolation, and document cache clearing. Replace the old per-word semantic target test with a constant-widget-count test:

```dart
expect(find.byKey(const Key('pdf-page-overlay-1')), findsOneWidget);
expect(find.byKey(const Key('pdf-word-hit-1-0')), findsNothing);
expect(
  find.descendant(
    of: find.byKey(const Key('pdf-page-overlay-1')),
    matching: find.byType(Positioned),
  ),
  findsNothing,
);
expect(source.structuredLoadCount, 1);
```

After passing one selected target, assert only its rectangles are painted and no transparent widgets exist for the remaining page words.

- [ ] **Step 2: Run overlay tests and verify failure**

```powershell
D:\local_environment\Flutter\flutter\bin\flutter.bat test test/features/reader/pdf_word_overlay_test.dart
```

Expected: FAIL because the old overlay still builds one widget per word.

- [ ] **Step 3: Implement the bounded asynchronous store**

Use access-order `LinkedHashMap<int, PdfPageGeometry>` plus an in-flight future map. `get` refreshes recency. `load` first tries structured geometry; when it has no valid runs, call `loadRawText`. Catch page-local extraction failures, remove the in-flight entry in `finally`, and return `null` without poisoning other pages. Evict the oldest entries until length is at most 8.

- [ ] **Step 4: Replace the word overlay with selection painting**

`PdfWordOverlay` starts page loading in `initState`/`didUpdateWidget` and returns a full-size `CustomPaint`. Its painter maps and draws only `selectedTarget.bounds` when the selected target belongs to this page. It must never iterate all page words or create per-word `Positioned`, `GestureDetector`, `Semantics`, or `ColoredBox` widgets.

- [ ] **Step 5: Wire tap handling in `PdfDocumentView`**

Hold a `PdfPageTextStore` and the last `PdfWordHitTarget`. Add an optional `PdfPageTextStore? textStore` constructor argument for deterministic tests; create and own a store when none is injected. In `onGeneralTap`, retrieve the tapped page geometry, calculate `margin: 24 / controller.currentZoom.clamp(0.1, 100)`, call `hitTestPdfText`, update only the selected target, then emit `ReaderSelection`. Clear both cache and selected target when `localPath` changes; clear selected highlight when parent selection becomes null.

Remove the old target-list cache and `buildPdfWordTargets` path.

- [ ] **Step 6: Run overlay, reader-page, and interaction tests**

```powershell
D:\local_environment\Flutter\flutter\bin\flutter.bat test test/features/reader/pdf_word_overlay_test.dart test/features/reader/pdf_text_hit_tester_test.dart test/features/reader/reader_page_test.dart test/features/reader/reader_interaction_test.dart
```

Expected: PASS with a constant-sized PDF overlay.

- [ ] **Step 7: Commit**

```powershell
git add mobile/lib/features/reader/presentation/widgets/pdf_page_text_store.dart mobile/lib/features/reader/presentation/widgets/pdf_word_overlay.dart mobile/lib/features/reader/presentation/widgets/pdf_document_view.dart mobile/test/features/reader/pdf_word_overlay_test.dart
git commit -m "perf: remove per-word PDF overlay widgets"
```

---

### Task 5: PDF Pan Reporting and Android Integration Verification

**Files:**
- Modify: `mobile/lib/features/reader/presentation/widgets/pdf_document_view.dart`
- Modify: `mobile/lib/features/reader/presentation/reader_page.dart`
- Modify: `mobile/test/features/reader/reader_page_test.dart`
- Modify: `mobile/integration_test/pdf_document_view_test.dart`

**Interfaces:**
- Produces: `PdfDocumentView.onContentScroll: ValueChanged<double>?` where positive means reading downward and negative means reading upward.
- Consumes: `ReaderChromeController.handleContentScroll` from Task 2.

- [ ] **Step 1: Write failing PDF interaction tests**

Capture the callback from a configured `PdfDocumentView`. Verify a one-finger upward pan emits a positive reading delta, a downward pan emits a negative delta, and a pinch update emits nothing:

```dart
configuredView!.onContentScroll!(30);
expect(chrome.visible, isFalse);
configuredView!.onContentScroll!(-1);
expect(chrome.visible, isTrue);
```

At the widget boundary, exercise `PdfViewerParams.onInteractionUpdate` with `ScaleUpdateDetails`; only updates with `pointerCount == 1` and `scale` approximately 1.0 may report `-focalPointDelta.dy`.

- [ ] **Step 2: Run the reader-page test and verify failure**

```powershell
D:\local_environment\Flutter\flutter\bin\flutter.bat test test/features/reader/reader_page_test.dart
```

Expected: FAIL because `PdfDocumentView.onContentScroll` is absent.

- [ ] **Step 3: Wire normalized PDF pan deltas**

Add `onContentScroll` and configure `PdfViewerParams.onInteractionUpdate`:

```dart
if (details.pointerCount != 1 || (details.scale - 1).abs() > 0.01) return;
final delta = -details.focalPointDelta.dy;
if (delta.isFinite && delta != 0) widget.onContentScroll?.call(delta);
```

Pass the callback from `ReaderPage` to `ReaderChromeController.handleContentScroll`. Translation-card gestures never reach this callback because the card is outside `PdfViewer`.

- [ ] **Step 4: Rewrite Android integration taps without word widgets**

Inject a `PdfPageTextStore`, wait until `store.get(1)` is non-null, then load the first page text through the controller. Take the center of the first character rectangle, map it through `pageRect` and `controller.documentToLocal`, and call `tester.tapAt`. Repeat after zoom. Assert both taps select `Foundation`, the overlay contains no `pdf-word-hit-*` widgets, and the selection painter appears.

```dart
final page = controller.pages.first;
final text = await page.loadStructuredText();
final pageRect = controller.layout.pageLayouts.first;
final documentPoint = text.charRects.first.center.toOffsetInDocument(
  page: page,
  pageRect: pageRect,
);
await tester.tapAt(controller.documentToLocal(documentPoint));
```

- [ ] **Step 5: Run all Flutter tests and static analysis**

```powershell
D:\local_environment\Flutter\flutter\bin\flutter.bat test
D:\local_environment\Flutter\flutter\bin\dart.bat analyze
```

Expected: all tests PASS and analysis reports no issues.

- [ ] **Step 6: Run Android emulator integration test**

```powershell
D:\local_environment\Flutter\flutter\bin\flutter.bat test integration_test/pdf_document_view_test.dart -d emulator-5554
```

Expected: PASS for initial-page fallback, tap before zoom, tap after zoom, and selection-only overlay.

- [ ] **Step 7: Build and install the debug APK for tablet experience**

```powershell
D:\local_environment\Flutter\flutter\bin\flutter.bat build apk --debug
D:\Android\sdk\platform-tools\adb.exe install -r build\app\outputs\flutter-apk\app-debug.apk
```

Expected: APK builds, installs, launches, and preserves existing app data. Manually verify long dual-column PDF scrolling, toolbar hide/reveal, back navigation, title/body taps, pinch zoom, and floating-card drag.

- [ ] **Step 8: Commit**

```powershell
git add mobile/lib/features/reader/presentation/widgets/pdf_document_view.dart mobile/lib/features/reader/presentation/reader_page.dart mobile/test/features/reader/reader_page_test.dart mobile/integration_test/pdf_document_view_test.dart
git commit -m "test: verify responsive PDF reader interactions"
```

---

## Completion Gate

Before claiming this plan complete:

- Confirm the toolbar never changes the `reader-document-viewport` rectangle.
- Confirm no per-word transparent widgets remain in a rendered PDF page.
- Confirm malformed fragment tests retain hits in valid fragments.
- Confirm existing learning, phrase, settings, document import, and progress tests remain green.
- Record Android integration output and final APK path.
- Stop for user tablet experience before starting the separate scientific-dictionary and online-translation plan.
