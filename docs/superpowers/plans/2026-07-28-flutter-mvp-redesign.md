# Flutter Mobile MVP Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a production-quality offline Flutter MVP for Android-first phone and tablet users that imports TXT, text PDF, and DOCX files, supports sentence-level tap translation, and persists reading and learning data.

**Architecture:** A feature-first MVVM Flutter app lives in `mobile/`. Widgets delegate to Riverpod view models, repositories own business writes, and services isolate Drift, files, and platform APIs. Parsing and dictionary engines expose pure Dart interfaces and run expensive work outside the UI isolate.

**Tech Stack:** Flutter 3.44.8, Dart 3.12.2, Riverpod, Drift/SQLite, go_router, Dart isolates, Android Kotlin platform channels, PDFBox Android, ECDICT.

## Global Constraints

- Android minimum API is 26; keep generated iOS code compatible with iOS 14.
- First delivery is Android-tested and iOS-compatible; iOS build/signing requires a later macOS verification pass.
- Do not migrate the legacy Web IndexedDB database.
- Do not delete or overwrite the legacy Web prototype; the new canonical app lives under `mobile/`.
- MVP parsing and dictionary lookup are fully offline.
- Supported input is TXT, text PDF, and DOCX. Scanned PDFs must return an explicit OCR-required error.
- Phone width `< 600dp` uses bottom navigation; width `>= 600dp` uses a navigation rail and multi-pane layouts.
- All interactive targets are at least 48×48dp and support screen-reader labels.
- Every behavior change follows red-green-refactor; no production behavior is added without a failing test.
- `flutter analyze` must have zero errors. Core parsing, dictionary, phrase, and learning-data coverage must be at least 90%.
- Use `D:\local_environment\Flutter\flutter\bin\flutter.bat` until the desktop process refreshes its PATH.
- Android APK/emulator verification remains blocked until Android SDK installation and `flutter doctor -v` reports a working Android toolchain.

---

### Task 1: Establish a Recoverable Baseline and Flutter Skeleton

**Files:**
- Create: `.gitignore`
- Create: `mobile/` via Flutter scaffolding
- Modify: `mobile/pubspec.yaml`
- Test: `mobile/test/app_smoke_test.dart`

**Interfaces:**
- Produces: a compilable `dian_du_ji` Flutter app with Android/iOS projects and a deterministic test command.

- [ ] **Step 1: Initialize version control and capture the untouched baseline**

Run:

```powershell
git init
git add .
git commit -m "chore: capture legacy web prototype"
```

Expected: one root commit containing the current Web prototype and approved design documents.

- [ ] **Step 2: Scaffold the isolated Flutter app**

Run:

```powershell
& 'D:\local_environment\Flutter\flutter\bin\flutter.bat' create --org com.dianduji --project-name dian_du_ji --platforms android,ios mobile
```

Expected: `mobile/lib/main.dart`, `mobile/android/`, `mobile/ios/`, and the stock test exist; no legacy file is removed.

- [ ] **Step 3: Replace the stock counter test with a failing product-shell test**

Create `mobile/test/app_smoke_test.dart`:

```dart
import 'package:dian_du_ji/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the document library shell', (tester) async {
    await tester.pumpWidget(const DianDuJiApp());
    expect(find.text('文档'), findsOneWidget);
    expect(find.text('导入文档'), findsOneWidget);
  });
}
```

- [ ] **Step 4: Run the test and verify RED**

Run: `flutter test test/app_smoke_test.dart`

Expected: FAIL because `lib/app/app.dart` and `DianDuJiApp` do not exist.

- [ ] **Step 5: Add the minimal app shell and dependencies**

Add `flutter_riverpod`, `go_router`, `drift`, `drift_flutter`, `path_provider`, `file_picker`, `archive`, `xml`, `crypto`, `uuid`, and development dependencies `build_runner`, `drift_dev`, `mocktail`, and `golden_toolkit`. Create `lib/app/app.dart` with `MaterialApp.router`, a document route, and an accessible `导入文档` button.

- [ ] **Step 6: Verify GREEN and baseline quality**

Run:

```powershell
flutter test test/app_smoke_test.dart
flutter analyze
```

Expected: test PASS and analyzer exit 0.

- [ ] **Step 7: Commit**

```powershell
git add .gitignore mobile
git commit -m "feat: scaffold Flutter mobile application"
```

---

### Task 2: Core Error Model and Drift Database

**Files:**
- Create: `mobile/lib/core/errors/app_failure.dart`
- Create: `mobile/lib/core/database/app_database.dart`
- Create: `mobile/lib/core/database/tables/*.dart`
- Create: `mobile/lib/core/database/daos/*.dart`
- Test: `mobile/test/core/database/app_database_test.dart`

**Interfaces:**
- Produces: `AppDatabase`, typed tables for documents, paragraphs, sentences, tokens, phrase occurrences, vocabulary, saved phrases, and settings.
- Produces: `Future<VocabularyEntry> recordLookup(LookupRecord record)` with a unique lemma constraint.

- [ ] **Step 1: Write failing in-memory database tests**

Cover these independent behaviors:

```dart
test('vocabulary lemma is unique and lookup count increments once', () async {
  final db = testDatabase();
  await db.learningDao.recordLookup(record('walking', lemma: 'walk'));
  await db.learningDao.recordLookup(record('walked', lemma: 'walk'));
  final row = await db.learningDao.findByLemma('walk');
  expect(row.lookupCount, 2);
  expect(await db.learningDao.countVocabulary(), 1);
});

test('deleting a document removes structure but retains learning assets', () async {
  final db = testDatabase();
  final ids = await seedDocumentGraph(db);
  await db.documentsDao.deleteDocument(ids.documentId);
  expect(await db.tokensDao.countForDocument(ids.documentId), 0);
  expect(await db.learningDao.countVocabulary(), 1);
});
```

- [ ] **Step 2: Run tests and verify RED**

Run: `flutter test test/core/database/app_database_test.dart`

Expected: FAIL because database and DAOs do not exist.

- [ ] **Step 3: Implement schema version 1 and DAOs**

Use Drift foreign keys, unique indexes on `vocabulary.lemma` and `saved_phrases.phrase_key`, and one transaction for document graph deletion. Store phrase type as the stable strings `phrasalVerb`, `prepositionalPhrase`, `collocation`, and `idiom`.

- [ ] **Step 4: Generate Drift code and verify GREEN**

Run:

```powershell
dart run build_runner build --delete-conflicting-outputs
flutter test test/core/database/app_database_test.dart
flutter analyze
```

Expected: all database tests PASS and generated queries type-check.

- [ ] **Step 5: Commit**

```powershell
git add mobile/lib/core mobile/test/core
git commit -m "feat: add transactional local data model"
```

---

### Task 3: Text Structure, Tokenization, and Sentence-Level Offsets

**Files:**
- Create: `mobile/lib/features/documents/domain/models/parsed_block.dart`
- Create: `mobile/lib/features/documents/domain/text/sentence_splitter.dart`
- Create: `mobile/lib/features/documents/domain/text/tokenizer.dart`
- Test: `mobile/test/features/documents/domain/text_structure_test.dart`

**Interfaces:**
- Produces: `List<SentenceSpan> splitSentences(String paragraph)`.
- Produces: `List<TokenSpan> tokenize(String sentence)` where every offset slices back to the exact surface string.

- [ ] **Step 1: Write failing offset tests**

```dart
test('offsets survive whitespace, contractions, and unicode punctuation', () {
  const text = '  Don’t stop.  It\'s working! ';
  final sentences = splitSentences(text);
  expect(sentences.map((s) => text.substring(s.start, s.end)),
      ['Don’t stop.', "It's working!"]);
  final tokens = tokenize(sentences.last.text);
  expect(tokens.map((t) => sentences.last.text.substring(t.start, t.end)),
      ["It's", 'working']);
});
```

- [ ] **Step 2: Verify RED**

Run: `flutter test test/features/documents/domain/text_structure_test.dart`

Expected: FAIL for missing functions.

- [ ] **Step 3: Implement minimal deterministic splitters**

Preserve source offsets, normalize curly apostrophes only for lookup, keep original surface text, and never derive offsets from trimmed strings.

- [ ] **Step 4: Verify GREEN and add regression cases**

Add abbreviations (`Mr.`, `e.g.`), repeated words, possessives, line breaks, hyphens, and empty paragraphs. Run the focused test and `flutter analyze`.

- [ ] **Step 5: Commit**

```powershell
git add mobile/lib/features/documents/domain mobile/test/features/documents/domain
git commit -m "feat: add offset-safe text structure engine"
```

---

### Task 4: File Intake and Format Detection

**Files:**
- Create: `mobile/lib/features/documents/data/services/file_intake_service.dart`
- Create: `mobile/lib/features/documents/domain/file_format.dart`
- Create: `mobile/lib/features/documents/domain/detect_file_format.dart`
- Test: `mobile/test/features/documents/file_intake_test.dart`

**Interfaces:**
- Produces: `FileFormat detectFileFormat(Uint8List header, String fileName)`.
- Produces: `Future<IntakeFile> copyIntoSandbox(SelectedFile input)` with SHA-256 hash and byte size.

- [ ] **Step 1: Write failing magic-byte tests**

Test PDF `%PDF-`, DOCX ZIP plus `[Content_Types].xml`, UTF text, mismatched extension, unsupported binary, duplicate hash, and a source file removed after sandbox copy.

- [ ] **Step 2: Verify RED**

Run: `flutter test test/features/documents/file_intake_test.dart`

Expected: FAIL for missing detector and service.

- [ ] **Step 3: Implement detector and sandbox service**

Read only the required header for detection, stream file hashing/copying, use a temporary filename, then atomically rename into the application documents directory.

- [ ] **Step 4: Verify GREEN**

Run focused tests and `flutter analyze`.

- [ ] **Step 5: Commit**

```powershell
git add mobile/lib/features/documents mobile/test/features/documents
git commit -m "feat: add safe local file intake"
```

---

### Task 5: TXT and DOCX Parsers

**Files:**
- Create: `mobile/lib/features/documents/domain/parsers/document_parser.dart`
- Create: `mobile/lib/features/documents/data/parsers/txt_document_parser.dart`
- Create: `mobile/lib/features/documents/data/parsers/docx_document_parser.dart`
- Create: `mobile/test/fixtures/documents/*`
- Test: `mobile/test/features/documents/parsers/txt_parser_test.dart`
- Test: `mobile/test/features/documents/parsers/docx_parser_test.dart`

**Interfaces:**
- Produces: `Stream<ParseEvent> DocumentParser.parse(ParseRequest request)`.
- `ParseEvent` is one of progress, parsed block, or terminal result.

- [ ] **Step 1: Add licensed fixtures and failing TXT tests**

Assert UTF-8, UTF-8 BOM, GB18030, paragraph boundaries, ambiguous encoding failure, and no replacement-character corruption.

- [ ] **Step 2: Verify TXT RED, implement, then verify GREEN**

Run: `flutter test test/features/documents/parsers/txt_parser_test.dart`

Implementation must return `AppFailure.unknownEncoding` instead of silently decoding bad input.

- [ ] **Step 3: Write failing DOCX tests**

Assert heading styles, lists, paragraph order, absence of XML markup, corrupt ZIP failure, and archive expansion limit rejection.

- [ ] **Step 4: Verify DOCX RED, implement, then verify GREEN**

Run: `flutter test test/features/documents/parsers/docx_parser_test.dart`

Read `word/document.xml` and styles/numbering relationships only as needed; enforce entry count, entry size, and total expanded byte ceilings before materializing content.

- [ ] **Step 5: Run the parser suite and commit**

```powershell
flutter test test/features/documents/parsers
flutter analyze
git add mobile
git commit -m "feat: parse TXT and DOCX offline"
```

---

### Task 6: Android PDF Text Extraction Adapter

**Files:**
- Create: `mobile/lib/features/documents/data/parsers/pdf_document_parser.dart`
- Create: `mobile/lib/core/platform/pdf_text_extractor.dart`
- Modify: `mobile/android/app/src/main/kotlin/com/dianduji/dian_du_ji/MainActivity.kt`
- Modify: `mobile/android/app/build.gradle.kts`
- Test: `mobile/test/features/documents/parsers/pdf_parser_contract_test.dart`
- Test: `mobile/integration_test/pdf_parser_android_test.dart`

**Interfaces:**
- Produces: `PdfTextExtractor.extract(path, onPage)` with page-indexed text and cancellation.

- [ ] **Step 1: Write a failing Dart contract test using a fake platform extractor**

Verify per-page progress, page ordering, encrypted PDF mapping, empty-page/scanned PDF mapping, cancellation, and parser timeout.

- [ ] **Step 2: Verify RED and implement the Dart adapter**

Run the contract test until it passes without Android.

- [ ] **Step 3: Add the Kotlin platform implementation**

Wrap PDFBox Android behind one method channel, initialize resources once, stream page results, close every document in `finally`, and map native failures to stable codes.

- [ ] **Step 4: Configure Android SDK and verify the toolchain**

Install Android Studio/SDK into `D:\local_environment\Android\Sdk`, create an AVD named `DianDuJi_API_36`, then run:

```powershell
flutter config --android-sdk 'D:\local_environment\Android\Sdk'
flutter doctor -v
flutter doctor --android-licenses
& 'D:\local_environment\Android\Sdk\emulator\emulator.exe' -avd DianDuJi_API_36
```

Expected: Android toolchain is green and at least one emulator or device appears in `flutter devices`.

- [ ] **Step 5: Run Android integration RED/GREEN and commit**

Run: `flutter test integration_test/pdf_parser_android_test.dart -d emulator-5554`

Expected: text PDF extracts in page order; encrypted, scanned, and corrupt fixtures return their exact error codes.

```powershell
git add mobile
git commit -m "feat: extract PDF text on Android"
```

---

### Task 7: Import Pipeline and Recovery State Machine

**Files:**
- Create: `mobile/lib/features/documents/domain/import_document_use_case.dart`
- Create: `mobile/lib/features/documents/data/document_repository.dart`
- Create: `mobile/lib/features/documents/presentation/document_import_view_model.dart`
- Test: `mobile/test/features/documents/import_document_use_case_test.dart`

**Interfaces:**
- Consumes: file intake, parsers, text engine, database.
- Produces: observable `ImportState` and idempotent `start`, `cancel`, and `retry` commands.

- [ ] **Step 1: Write failing state-machine tests**

Cover queued → parsing → completed, parser failure cleanup, cancellation cleanup, retry reuse of the document ID, duplicate hash handling, process-restart recovery, and batched transaction writes.

- [ ] **Step 2: Verify RED**

Run the focused test and confirm failures come from missing pipeline behavior.

- [ ] **Step 3: Implement the minimal pipeline**

Persist state before work begins, write structure in bounded batches, clean structure on terminal failure, and never catch an exception without mapping and logging it.

- [ ] **Step 4: Verify GREEN and commit**

```powershell
flutter test test/features/documents/import_document_use_case_test.dart
flutter analyze
git add mobile
git commit -m "feat: add recoverable document import pipeline"
```

---

### Task 8: ECDICT Asset and Dictionary Repository

**Files:**
- Create: `mobile/tool/dictionary_builder/bin/build_dictionary.dart`
- Create: `mobile/assets/dictionary/ecdict.sqlite`
- Create: `mobile/assets/dictionary/LICENSE-ECDICT`
- Create: `mobile/lib/features/dictionary/data/dictionary_repository.dart`
- Test: `mobile/test/features/dictionary/dictionary_repository_test.dart`

**Interfaces:**
- Produces: `Future<DictionaryEntry?> lookup(String surface)`.
- Lookup order: exact lowercase, normalized form, ECDICT lemma relation, missing.

- [ ] **Step 1: Write failing dictionary tests**

Test `looked → look`, `studies → study`, `walking → walk`, `language`, unknown words, required phonetic/POS/Chinese fields, and 1,000-query timing.

- [ ] **Step 2: Verify RED**

Run the focused test; it must fail because no repository/asset exists.

- [ ] **Step 3: Implement the deterministic builder**

Read the pinned ECDICT source, preserve its MIT license, rank by frequency/exam tags, emit at least 50,000 headwords plus lemma relations into a compact indexed SQLite file, and record source commit/hash in metadata.

- [ ] **Step 4: Implement read-only asset lookup and verify GREEN**

Copy the asset into a readable local location on first launch, open read-only, use indexed prepared queries, and never mix dictionary tables into the user database.

- [ ] **Step 5: Verify size, count, timing, and commit**

Run dictionary tests plus a tool command that prints entry count and asset hash. Expected: count ≥ 50,000 and median/maximum lookup stays under the documented 10ms test threshold on the reference environment.

---

### Task 9: Phrase Recognition Engine

**Files:**
- Create: `mobile/lib/features/phrases/domain/phrase_type.dart`
- Create: `mobile/lib/features/phrases/domain/phrase_recognizer.dart`
- Create: `mobile/assets/phrases/phrases.json`
- Test: `mobile/test/features/phrases/phrase_recognizer_test.dart`

**Interfaces:**
- Produces: `List<PhraseMatch> recognize(List<TokenSpan> sentenceTokens)` with token ranges and confidence.

- [ ] **Step 1: Write failing positive and negative corpus tests**

Include `look up`, `give up`, `in addition to`, `take advantage of`, `piece of cake`, punctuation variants, and sentences where the same adjacent words are not a valid phrase.

- [ ] **Step 2: Verify RED, implement longest-match-first, verify GREEN**

Use one enum across engine, database, filters, and labels. Discard matches below the display threshold and only return phrases covering the selected token when queried by the reader.

- [ ] **Step 3: Commit**

```powershell
git add mobile
git commit -m "feat: add typed offline phrase recognition"
```

---

### Task 10: Responsive Document Library and Import UI

**Files:**
- Create: `mobile/lib/features/documents/presentation/document_library_screen.dart`
- Create: `mobile/lib/features/documents/presentation/widgets/*`
- Create: `mobile/test/features/documents/document_library_screen_test.dart`
- Create: `mobile/test/goldens/document_library_*`

**Interfaces:**
- Consumes: document repository stream and import view model commands.
- Produces: phone bottom-nav and tablet navigation-rail layouts.

- [ ] **Step 1: Write failing phone/tablet widget tests**

At 390×844 expect bottom navigation and one document column. At 1024×768 expect navigation rail and document/detail panes. Verify empty, importing, failed, search, sort, retry, cancel, and delete-confirmation states.

- [ ] **Step 2: Verify RED, implement the smallest responsive shell, verify GREEN**

Use `LayoutBuilder`/window size, not platform-name checks. Every icon-only action gets a semantic label and 48dp target.

- [ ] **Step 3: Add and review Goldens, then commit**

Run widget tests at day, night, eye-care, and 200% text scale before committing.

---

### Task 11: Sentence-Level Reader, Selection, and Progress

**Files:**
- Create: `mobile/lib/features/reader/presentation/reader_screen.dart`
- Create: `mobile/lib/features/reader/presentation/widgets/token_text.dart`
- Create: `mobile/lib/features/reader/presentation/reader_view_model.dart`
- Create: `mobile/lib/features/reader/domain/reading_locator.dart`
- Test: `mobile/test/features/reader/reader_interaction_test.dart`

**Interfaces:**
- Produces: one selected `tokenId`, one selected `sentenceId`, and a stable reading locator.

- [ ] **Step 1: Write failing interaction tests**

Verify tapping the second occurrence selects only that token, the containing sentence gets context highlight, dragging does not select, closing the card restores progress controls, phone uses a bottom sheet, tablet uses a right pane, and saved locator restores after text-scale change.

- [ ] **Step 2: Verify RED and implement token rendering**

Render sentence chunks lazily, key spans by token ID, provide immediate local selection state, and defer dictionary/database work until after first-frame feedback.

- [ ] **Step 3: Implement throttled and lifecycle-forced progress persistence**

Save a sentence/paragraph locator plus local offset; force save on back navigation and app pause.

- [ ] **Step 4: Verify GREEN, profile long-document scrolling, and commit**

Run focused tests, analyzer, and Flutter performance overlay on an Android reference device once available.

---

### Task 12: Translation Detail and Single Vocabulary Upsert

**Files:**
- Create: `mobile/lib/features/dictionary/presentation/translation_view_model.dart`
- Create: `mobile/lib/features/dictionary/presentation/translation_detail.dart`
- Create: `mobile/lib/features/learning/data/learning_repository.dart`
- Test: `mobile/test/features/dictionary/translation_flow_test.dart`

**Interfaces:**
- Consumes: selected token/sentence, dictionary repository, phrase repository, learning repository.
- Produces: `TranslationState` and explicit `savePhrase` command.

- [ ] **Step 1: Write failing lookup/upsert tests**

Assert immediate loading state, resolved definition, exactly one vocabulary write per user tap, no blank definition write, repeated tap increments once, unknown word remains displayable, and only phrases covering the selected token appear.

- [ ] **Step 2: Verify RED, implement event-driven lookup, verify GREEN**

Trigger the write from one completed lookup command, never from Widget rebuilds or reactive dependency changes.

- [ ] **Step 3: Add compact/expanded phone and tablet detail Widget tests**

Verify 35–50% compact target, 65% expanded target, internal scroll, save feedback, pronunciation semantic label, and large-font wrapping.

- [ ] **Step 4: Commit**

```powershell
git add mobile
git commit -m "feat: add reliable tap translation flow"
```

---

### Task 13: Vocabulary, Phrase Book, Settings, and CSV Export

**Files:**
- Create: `mobile/lib/features/learning/presentation/vocabulary_screen.dart`
- Create: `mobile/lib/features/learning/presentation/phrase_book_screen.dart`
- Create: `mobile/lib/features/learning/domain/csv_exporter.dart`
- Create: `mobile/lib/features/settings/presentation/settings_screen.dart`
- Test: `mobile/test/features/learning/*_test.dart`
- Test: `mobile/test/features/settings/settings_test.dart`

**Interfaces:**
- Produces: reactive filters/sorts, proficiency updates, deletion, manual add, phrase filtering, settings persistence, RFC-compatible CSV bytes.

- [ ] **Step 1: Write failing repository and CSV tests**

Test filters, sort orders, source-deleted labels, unique manual add, phrase types, and CSV values containing quotes, commas, CR/LF, and Chinese characters.

- [ ] **Step 2: Verify RED, implement domain/repository behavior, verify GREEN**

- [ ] **Step 3: Write failing responsive Widget tests and implement screens**

Cover empty states, search, filters, delete confirmation, theme switching, font 12–24, line height 1.4–2.0, and automatic vocabulary toggle.

- [ ] **Step 4: Run Goldens and commit**

```powershell
flutter test test/features/learning test/features/settings
flutter analyze
git add mobile
git commit -m "feat: add local learning library and settings"
```

---

### Task 14: Share Import, Accessibility, and End-to-End Android Flow

**Files:**
- Modify: `mobile/android/app/src/main/AndroidManifest.xml`
- Create: `mobile/lib/core/platform/shared_file_receiver.dart`
- Create: `mobile/integration_test/core_learning_flow_test.dart`
- Test: `mobile/test/accessibility/accessibility_test.dart`

**Interfaces:**
- Produces: cold-start and warm-start shared-file events routed into the same import pipeline.

- [ ] **Step 1: Write failing shared-file adapter tests**

Verify cold start, warm start, duplicate intent de-duplication, unsupported MIME error, and revoked URI permission handling.

- [ ] **Step 2: Implement Android intent filters and adapter, then verify GREEN**

- [ ] **Step 3: Write and pass accessibility tests**

Use semantics inspection to verify all icon buttons are named, async statuses are announced, targets meet 48dp, large text does not clip critical actions, and reduced-motion mode removes nonessential transitions.

- [ ] **Step 4: Write and run the Android end-to-end test**

Flow: launch → import real TXT/PDF/DOCX fixtures → wait for completed status → open → tap a known word → verify translation → verify one vocabulary record → save phrase → background/restart → verify reading position and learning data.

- [ ] **Step 5: Commit**

```powershell
git add mobile
git commit -m "feat: complete Android offline learning flow"
```

---

### Task 15: Final Quality, Performance, and Release Evidence

**Files:**
- Create: `mobile/README.md`
- Create: `mobile/tool/benchmarks/*`
- Create: `mobile/docs/third-party-notices.md`
- Modify: `mobile/pubspec.yaml`

**Interfaces:**
- Produces: reproducible verification commands, dependency notices, benchmark output, and an Android debug/release candidate.

- [ ] **Step 1: Run the complete static and automated suite**

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test --coverage
flutter test integration_test -d emulator-5554
```

Expected: zero analyzer errors, zero failing tests, core logic coverage ≥ 90%.

- [ ] **Step 2: Run performance gates**

Measure 1,000 dictionary lookups, point-to-first-frame latency, long-reader scrolling, and fixed 1000-page PDF parsing. Record device model, OS, build mode, fixture hash, duration, peak memory, and pass/fail against the approved thresholds.

- [ ] **Step 3: Audit licenses and privacy behavior**

Verify ECDICT MIT attribution, PDFBox Apache-2.0 notice, package licenses, zero translation network calls, and logs without document body content.

- [ ] **Step 4: Build Android artifacts**

```powershell
flutter build apk --debug
flutter build appbundle --release
```

Expected: both builds succeed after signing configuration is supplied for release.

- [ ] **Step 5: Update README with exact setup and verification commands**

Document Flutter path, Android SDK requirement, fixtures, dictionary rebuild command, database migration rules, test commands, current iOS verification limitation, and artifact locations.

- [ ] **Step 6: Final commit**

```powershell
git add mobile
git commit -m "chore: verify Flutter MVP release candidate"
```
