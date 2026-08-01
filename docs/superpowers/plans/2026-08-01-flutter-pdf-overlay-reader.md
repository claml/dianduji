# Flutter PDF Overlay Reader Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Render each PDF in its original page layout and make English words tappable through a transparent, zoom-aware hit layer.

**Architecture:** Use `pdfrx` as the single PDF renderer and text geometry source. Build page-local word ranges from `PdfPageText`, convert them through viewer coordinates at interaction time, and send a format-neutral selection to the adaptive translation shell from the first plan.

**Tech Stack:** Flutter 3.44.8, Dart 3.12.2, `pdfrx` 2.4.7/PDFium, existing Riverpod, Drift, ECDICT, and Android API 26+.

## Global Constraints

- PDF pages must not be reflowed or reconstructed from extracted text.
- Word hit regions must stay aligned after zoom, scroll, rotation, and viewport resize.
- Titles and subtitles are naturally clickable when they are selectable PDF text; page numbers, chart/image content, and non-English text are ignored.
- Scanned PDFs remain unsupported and return `ocrRequired`.
- All processing remains local and offline.

---

### Task 1: Add and Smoke-Test pdfrx

**Files:**
- Modify: `mobile/pubspec.yaml`
- Modify: `mobile/lib/main.dart`
- Create: `mobile/test/core/platform/pdf_document_loader_test.dart`

**Interfaces:**
- Produces: initialized `pdfrx` runtime and a testable local-file document loader seam.

- [ ] **Step 1: Add a failing loader test**

Create a tiny generated text PDF fixture and assert a local document opens, reports one page, and exposes non-empty `PdfPageText` with geometry.

- [ ] **Step 2: Run the test and verify RED**

Run: `flutter test test/core/platform/pdf_document_loader_test.dart`

Expected: compilation fails because `pdfrx` and the loader seam are absent.

- [ ] **Step 3: Add `pdfrx: 2.4.7` and initialize it**

Add the dependency, refresh packages, call `pdfrxFlutterInitialize()` after `WidgetsFlutterBinding.ensureInitialized()`, and implement the local-file loader seam.

- [ ] **Step 4: Verify GREEN**

Run: `flutter test test/core/platform/pdf_document_loader_test.dart`

Expected: the fixture opens and yields text geometry.

- [ ] **Step 5: Commit**

```text
git add mobile/pubspec.yaml mobile/pubspec.lock mobile/lib/main.dart mobile/test/core/platform
git commit -m "build: add pdfrx document engine"
```

### Task 2: Word Geometry Builder

**Files:**
- Create: `mobile/lib/features/reader/domain/pdf_word_hit_target.dart`
- Create: `mobile/lib/features/reader/domain/pdf_word_geometry_builder.dart`
- Test: `mobile/test/features/reader/pdf_word_geometry_builder_test.dart`

**Interfaces:**
- Produces: `PdfWordHitTarget(pageNumber, surface, normalized, start, end, bounds, contextText)`.
- Produces: `List<PdfWordHitTarget> buildPdfWordTargets(PdfPageText pageText)`.

- [ ] **Step 1: Write failing pure-Dart geometry tests**

Cover punctuation, apostrophes, hyphens, line wrapping, multiple fragment rectangles, headings, page numbers, non-English text, and empty pages. Assert only English lexical words produce targets and page-number-only runs are ignored.

- [ ] **Step 2: Run the focused test and verify RED**

Run: `flutter test test/features/reader/pdf_word_geometry_builder_test.dart`

Expected: compilation fails because the builder does not exist.

- [ ] **Step 3: Implement range tokenization and bounds**

Tokenize `PdfPageText.fullText` with Unicode-aware English word boundaries. Create `PdfPageTextRange` for each match and use `enumerateFragmentBoundingRects()` so wrapped/hyphenated ranges retain every clickable rectangle. Derive nearby line text for dictionary context.

- [ ] **Step 4: Verify GREEN**

Run: `flutter test test/features/reader/pdf_word_geometry_builder_test.dart`

Expected: all geometry tests pass.

- [ ] **Step 5: Commit**

```text
git add mobile/lib/features/reader/domain mobile/test/features/reader/pdf_word_geometry_builder_test.dart
git commit -m "feat: derive PDF word hit geometry"
```

### Task 3: Original-Page PDF Canvas and Transparent Hit Layer

**Files:**
- Create: `mobile/lib/features/reader/presentation/widgets/pdf_document_view.dart`
- Create: `mobile/lib/features/reader/presentation/widgets/pdf_word_overlay.dart`
- Modify: `mobile/lib/features/reader/presentation/reader_page.dart`
- Test: `mobile/test/features/reader/pdf_document_view_test.dart`

**Interfaces:**
- Consumes: PDF `localPath`, restored page, selected word, and `onWordTap(ReaderSelection)`.
- Produces: original PDF pages, lazy visible-page targets, selection highlight, page progress callback, and recoverable load errors.

- [ ] **Step 1: Write failing viewer tests**

Use an injectable fake page/document adapter to assert: original page widget is present; visible pages request text once; a target tap sends the correct word/context; page number and image regions do not emit taps; changing zoom/viewport rebuilds coordinate mapping without re-extracting text.

- [ ] **Step 2: Run the focused test and verify RED**

Run: `flutter test test/features/reader/pdf_document_view_test.dart`

Expected: compilation fails because `PdfDocumentView` and the adapter do not exist.

- [ ] **Step 3: Implement viewer and hit overlay**

Open `PdfViewer.file(File(localPath))`. Disable the default long-press text-selection UI while retaining page text extraction. Register pointer-transparent word regions through the viewer overlay/hit-test APIs and map page rectangles using the viewer coordinate converter. Cache targets only for active pages and paint a translucent underline/background for the selected target.

- [ ] **Step 4: Route PDF documents through the PDF canvas**

In `ReaderPage`, select `PdfDocumentView` when `document.format == 'pdf'`; TXT/DOCX keep `ReflowDocumentView`. Translate taps via `ReaderController.selectExternalWord` and keep the shared adaptive translation surface.

- [ ] **Step 5: Verify GREEN**

Run: `flutter test test/features/reader/pdf_document_view_test.dart test/features/reader/adaptive_translation_surface_test.dart`

Expected: all tests pass.

- [ ] **Step 6: Commit**

```text
git add mobile/lib/features/reader mobile/test/features/reader
git commit -m "feat: add original-layout PDF tap reader"
```

### Task 4: Replace the Unavailable PDF Import Extractor

**Files:**
- Create: `mobile/lib/core/platform/pdfrx_text_extractor.dart`
- Modify: `mobile/lib/features/documents/data/default_document_parser_resolver.dart`
- Modify: `mobile/lib/app/providers.dart`
- Test: `mobile/test/features/documents/parsers/pdf_parser_contract_test.dart`
- Test: `mobile/test/features/documents/default_document_parser_resolver_test.dart`

**Interfaces:**
- Produces: `PdfrxTextExtractor implements PdfTextExtractor` with page-order streaming, cancellation, and stable error mapping.

- [ ] **Step 1: Write failing extractor and resolver tests**

Assert page-order output, progress-compatible page count, cancellation, encrypted error, corrupt error, missing-file error, empty/scanned result, and that the default resolver returns the real extractor for PDF.

- [ ] **Step 2: Run tests and verify RED**

Run: `flutter test test/features/documents/parsers/pdf_parser_contract_test.dart test/features/documents/default_document_parser_resolver_test.dart`

Expected: the resolver still produces the unavailable extractor and new cases fail.

- [ ] **Step 3: Implement the pdfrx extractor**

Open the sandbox path with `PdfDocument.openFile`, iterate pages from 1 through `pageCount`, load page text, yield `PdfPageText(pageNumber, pageCount, text)`, check cancellation before and after each page, and close the document in `finally`. Map password, malformed document, missing path, and engine failures to the existing `PdfExtractionError` values.

- [ ] **Step 4: Verify GREEN**

Run: `flutter test test/features/documents/parsers/pdf_parser_contract_test.dart test/features/documents/default_document_parser_resolver_test.dart`

Expected: all PDF import contract tests pass.

- [ ] **Step 5: Commit**

```text
git add mobile/lib/core/platform mobile/lib/features/documents mobile/lib/app/providers.dart mobile/test/features/documents
git commit -m "feat: import text PDFs with pdfrx"
```

### Task 5: PDF Progress, Device Test, and Quality Gate

**Files:**
- Modify: `mobile/lib/features/reader/domain/reading_locator.dart`
- Modify: `mobile/lib/features/reader/presentation/reader_controller.dart`
- Modify: `mobile/lib/features/reader/presentation/reader_page.dart`
- Test: `mobile/test/features/reader/reading_progress_test.dart`
- Create: `mobile/integration_test/pdf_overlay_reader_test.dart`

**Interfaces:**
- Produces: backward-compatible PDF locator encoding with page number and page-local offset.

- [ ] **Step 1: Write failing locator and restore tests**

Assert PDF page/offset round-trip, old locator decode compatibility, page restore, debounced progress save, and fallback to page one when the stored page is invalid.

- [ ] **Step 2: Run focused tests and verify RED**

Run: `flutter test test/features/reader/reading_progress_test.dart`

Expected: PDF page locator cases fail because the fields are absent.

- [ ] **Step 3: Implement PDF progress and restore**

Extend locator JSON with optional `pageNumber`; leave existing keys unchanged. Save current page plus selected/local text offset from the PDF viewer and restore through `PdfViewerController.goToPage` after ready.

- [ ] **Step 4: Verify automated tests**

Run: `dart format lib test integration_test && flutter analyze && flutter test`

Expected: no analyzer issues and all tests pass.

- [ ] **Step 5: Build and run on Android emulator/tablet**

Run: `flutter build apk --debug`, install the APK, then exercise a generated two-page PDF. Verify original layout, title/body tap accuracy before and after zoom, phone bottom card, tablet side/floating modes, drag bounds, pronunciation, close, and progress restore.

- [ ] **Step 6: Commit**

```text
git add mobile
git commit -m "test: verify PDF overlay reader on Android"
```
