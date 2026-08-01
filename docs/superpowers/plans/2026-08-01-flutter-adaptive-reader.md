# Flutter Adaptive Document Reader Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the sentence-card reader with a document-first TXT/DOCX reader and the approved phone, tablet-side-pane, and draggable-tablet-card translation interactions.

**Architecture:** Extend the stored reader aggregate with ordered styled blocks while retaining sentence and token identities for dictionary and progress behavior. Split the presentation into a document canvas, adaptive translation surface, and persisted card preferences so PDF can reuse the same shell in the next plan.

**Tech Stack:** Flutter 3.44.8, Dart 3.12.2, Riverpod 2.6, Drift/SQLite, existing ECDICT and pronunciation channel.

## Global Constraints

- Phone layout is `<600dp`; tablet layout is `>=600dp`.
- Preserve at least 48×48dp interaction targets.
- Titles, subtitles/headings, and body words are clickable; metadata, page numbers, charts, and images are not.
- Document content and dictionary lookups remain offline.
- Do not migrate or delete existing user documents.

---

### Task 1: Ordered Styled Reader Blocks

**Files:**
- Modify: `mobile/lib/features/documents/domain/document_models.dart`
- Modify: `mobile/lib/core/database/app_database.dart`
- Modify: `mobile/lib/features/documents/data/drift_document_repository.dart`
- Test: `mobile/test/features/documents/drift_document_repository_test.dart`

**Interfaces:**
- Produces: `StoredReaderBlock(id, ordinal, text, style, sentences)` and `StoredReaderDocument(format, localPath, blocks, sentences)`.
- Preserves: `StoredReaderDocument.sentences` as a flattened compatibility getter ordered by sentence ordinal.

- [ ] **Step 1: Write a failing repository test**

Insert one heading paragraph and one body paragraph with sentences/tokens. Load the document and assert `format`, `localPath`, block order, block styles, sentence membership, and flattened sentence order.

- [ ] **Step 2: Run the focused test and verify RED**

Run: `flutter test test/features/documents/drift_document_repository_test.dart`

Expected: compilation fails because `StoredReaderBlock`, `format`, `localPath`, and `blocks` do not exist.

- [ ] **Step 3: Add paragraph loading and the aggregate model**

Add `DocumentsDao.loadParagraphs(String documentId)` ordered by `ordinal`. Add `StoredReaderBlock` and make the repository group each stored sentence by `paragraphId`. Populate `format` and `localPath` from the document row. Keep `sentences` as a getter that expands blocks and sorts by sentence ordinal.

- [ ] **Step 4: Verify GREEN and regression tests**

Run: `flutter test test/features/documents/drift_document_repository_test.dart test/features/reader/reader_controller_test.dart`

Expected: all tests pass.

- [ ] **Step 5: Commit**

```text
git add mobile/lib/features/documents mobile/lib/core/database mobile/test/features/documents
git commit -m "feat: load styled reader blocks"
```

### Task 2: Unified Reader Selection

**Files:**
- Create: `mobile/lib/features/reader/domain/reader_selection.dart`
- Modify: `mobile/lib/features/reader/presentation/reader_controller.dart`
- Test: `mobile/test/features/reader/reader_controller_test.dart`

**Interfaces:**
- Produces: `ReaderSelection(surface, normalized, contextText, sentenceId, tokenId)`.
- Produces: `ReaderController.selectStoredToken(...)` and `ReaderController.selectExternalWord(ReaderSelection selection)`.

- [ ] **Step 1: Write failing controller tests**

Assert that a stored token selection and an external word selection both update the selected surface, invoke dictionary lookup with sentence/page context, and keep phrase saving available only when a stored sentence exists.

- [ ] **Step 2: Run the focused test and verify RED**

Run: `flutter test test/features/reader/reader_controller_test.dart`

Expected: compilation fails because `ReaderSelection` and `selectExternalWord` do not exist.

- [ ] **Step 3: Implement the unified selection state**

Store `ReaderSelection? selection` in `ReaderState`. Adapt the existing stored-token method to construct it. External PDF words supply a one-token `TokenSpan` and their visible page text as `LearningContext.sentence`. Closing translation clears selection without clearing the document or restored locator.

- [ ] **Step 4: Verify GREEN**

Run: `flutter test test/features/reader/reader_controller_test.dart`

Expected: all controller tests pass.

- [ ] **Step 5: Commit**

```text
git add mobile/lib/features/reader mobile/test/features/reader/reader_controller_test.dart
git commit -m "refactor: unify reader word selection"
```

### Task 3: Document-First TXT and DOCX Canvas

**Files:**
- Create: `mobile/lib/features/reader/presentation/widgets/reflow_document_view.dart`
- Create: `mobile/lib/features/reader/presentation/widgets/clickable_text_block.dart`
- Modify: `mobile/lib/features/reader/presentation/reader_page.dart`
- Test: `mobile/test/features/reader/reflow_document_view_test.dart`

**Interfaces:**
- Consumes: `List<StoredReaderBlock>`, selected token ID, font size, line height, and `onTokenTap`.
- Produces: a semantic document tree with heading/list/body styling and token tap callbacks.

- [ ] **Step 1: Write failing widget tests**

Build heading, list, and body blocks. Assert the heading has header semantics and larger type, list markers render, no sentence card background exists, and tapping a heading token and body token calls the supplied IDs.

- [ ] **Step 2: Run the focused test and verify RED**

Run: `flutter test test/features/reader/reflow_document_view_test.dart`

Expected: compilation fails because `ReflowDocumentView` does not exist.

- [ ] **Step 3: Implement block rendering**

Render one continuous scroll view with page-like horizontal margins. Use block style to choose typography and spacing. Reconstruct spaces and punctuation from token offsets inside each sentence; use transparent `WidgetSpan` hit targets with a 48dp semantic/touch envelope while keeping the visible glyph style faithful to its block.

- [ ] **Step 4: Wire ReaderPage and verify GREEN**

Pass blocks from `ReaderController.state.document` into the new canvas. Retain sentence/token keys for position restore. Run the focused test plus existing reader tests.

Run: `flutter test test/features/reader`

Expected: all reader tests pass after updating obsolete sentence-card assertions to document-first behavior.

- [ ] **Step 5: Commit**

```text
git add mobile/lib/features/reader mobile/test/features/reader
git commit -m "feat: render styled tappable documents"
```

### Task 4: Persisted Tablet Card Preferences

**Files:**
- Create: `mobile/lib/features/reader/data/reader_card_preferences.dart`
- Modify: `mobile/lib/features/settings/data/settings_repository.dart`
- Modify: `mobile/lib/app/providers.dart`
- Test: `mobile/test/features/reader/reader_card_preferences_test.dart`

**Interfaces:**
- Produces: `ReaderCardMode { sidePane, floating }`.
- Produces: `ReaderCardPreferences(mode, relativeX, relativeY)` with each coordinate clamped to `0..1`.
- Produces: `ReaderCardPreferencesRepository.load()` and `save(...)` using AppSettings key `reader-card-preferences-v1`.

- [ ] **Step 1: Write failing serialization and repository tests**

Assert default side pane, JSON round-trip, invalid JSON fallback, coordinate clamping, and database persistence.

- [ ] **Step 2: Run focused tests and verify RED**

Run: `flutter test test/features/reader/reader_card_preferences_test.dart`

Expected: compilation fails because the preference types do not exist.

- [ ] **Step 3: Implement the preference repository and provider**

Store compact JSON in the existing settings table. Keep reader card preferences separate from font/theme settings so changing one does not overwrite the other.

- [ ] **Step 4: Verify GREEN**

Run: `flutter test test/features/reader/reader_card_preferences_test.dart test/features/settings`

Expected: all tests pass.

- [ ] **Step 5: Commit**

```text
git add mobile/lib/features/reader/data mobile/lib/features/settings mobile/lib/app/providers.dart mobile/test/features/reader/reader_card_preferences_test.dart
git commit -m "feat: persist tablet reader card layout"
```

### Task 5: Adaptive Translation Surface and Bounded Drag

**Files:**
- Create: `mobile/lib/features/reader/presentation/widgets/adaptive_translation_surface.dart`
- Create: `mobile/lib/features/reader/presentation/widgets/draggable_translation_card.dart`
- Modify: `mobile/lib/features/reader/presentation/reader_screen.dart`
- Modify: `mobile/lib/features/reader/presentation/reader_page.dart`
- Test: `mobile/test/features/reader/adaptive_translation_surface_test.dart`
- Test: `mobile/test/features/reader/reader_interaction_test.dart`

**Interfaces:**
- Consumes: selected word, translation state, card preferences, document viewport, close/save/speak callbacks.
- Produces: phone bottom card, tablet side pane, tablet floating card, dock/float mode commands, and normalized drag position updates.

- [ ] **Step 1: Write failing responsive widget tests**

At 412×915 assert bottom card. At 1280×800 assert side pane. Switch to floating and drag beyond all four edges; assert the card remains inside the document viewport. Resize to 800×1280 and assert it is clamped again. Assert dock restores the side pane and close hides the surface.

- [ ] **Step 2: Run focused tests and verify RED**

Run: `flutter test test/features/reader/adaptive_translation_surface_test.dart test/features/reader/reader_interaction_test.dart`

Expected: tests fail because floating mode and bounded drag controls are absent.

- [ ] **Step 3: Implement adaptive surfaces**

Keep the phone card at 40% viewport height with safe-area padding. Use a 360dp tablet side pane. Size the floating card between 320–400dp wide and no more than 70% of the document viewport height. Convert drag offsets to relative coordinates after clamping and save on drag end/mode change.

- [ ] **Step 4: Verify GREEN and reader regression**

Run: `flutter test test/features/reader`

Expected: all tests pass with no overflow exceptions.

- [ ] **Step 5: Commit**

```text
git add mobile/lib/features/reader mobile/test/features/reader
git commit -m "feat: add adaptive draggable translation card"
```

### Task 6: Flutter Quality Gate

**Files:**
- Modify only files required by analyzer or existing regression failures.

- [ ] **Step 1: Format and analyze**

Run: `dart format lib test && flutter analyze`

Expected: formatting succeeds and analyzer reports no issues.

- [ ] **Step 2: Run all non-PDF tests**

Run: `flutter test --exclude-tags pdf-integration`

Expected: all tests pass.

- [ ] **Step 3: Build Android debug APK**

Run: `flutter build apk --debug`

Expected: `build/app/outputs/flutter-apk/app-debug.apk` is produced.

- [ ] **Step 4: Commit any verification-only corrections**

```text
git add mobile
git commit -m "test: verify adaptive document reader"
```
