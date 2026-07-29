# Flutter Mobile MVP Remaining Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the verified Flutter shell and domain engines into an installable, offline Android MVP that imports real TXT, text PDF, and DOCX files, supports tap-to-translate reading on phones and tablets, persists learning data and reading position, accepts shared files, and passes the approved quality gates on the Huawei BTK-W00 reference tablet.

**Architecture:** Keep the approved feature-oriented MVVM boundaries. Riverpod owns the application-scoped database, dictionary, phrase catalog, repositories, and controllers; Drift repositories are the only writers of user data; Dart services own TXT/DOCX parsing and text structure; a narrow Android platform adapter owns PDFBox and shared-intent access. UI widgets render immutable state and dispatch explicit commands, with no database writes from widget rebuilds.

**Tech Stack:** Flutter 3.44.8, Dart 3.12.2, Riverpod 2.6, Drift/SQLite, `file_picker` 10.3.10, ECDICT SQLite, Kotlin/JDK 21, Android API 26+, PDFBox Android 2.0.27.0, Flutter `integration_test`.

## Global Constraints

- The approved requirements source is `docs/superpowers/specs/2026-07-28-flutter-mvp-redesign-design.md`; behavior in this plan must not weaken it.
- Android 8.0/API 26 is the minimum runtime; keep source compatibility for iOS 14+, but iOS signing and device acceptance remain a later macOS gate.
- Phone layout is `<600dp`; tablet layout is `>=600dp`. Tablets must use rail and multi-pane layouts rather than enlarged phone screens.
- The MVP supports TXT, text-based PDF, and DOCX. Scanned-PDF OCR is explicitly out of scope and must return `ocrRequired`.
- Documents, dictionary lookup, tokenization, phrase recognition, and learning storage remain fully offline. Do not add translation, analytics, or document-content network calls.
- Do not migrate legacy Web IndexedDB data and do not delete the retained Web prototype.
- Copy every selected/shared source into the application sandbox before parsing; never depend on a temporary external URI after intake.
- All persistent writes go through repositories/DAOs and transactions. A completed dictionary lookup records at most one vocabulary write per explicit user tap.
- Preserve learning assets when a source document is deleted. Show “原文档已删除” when a retained learning record no longer has a document.
- Persist a stable paragraph/sentence locator plus local offset, not a pixel scroll offset. Force-save on back navigation and app pause.
- Every interactive target is at least 48×48dp, icon-only actions have semantic labels, large text must not clip critical actions, and reduced-motion settings must be respected.
- Keep `file_picker` pinned to 10.3.10 until its AGP 9 built-in Kotlin regression is fixed. Keep `kotlin.incremental=false` while the workspace and Pub cache use different Windows drive roots.
- Use TDD for each behavior: focused RED, minimal GREEN, focused verification, full regression verification, then a focused commit.
- Run Flutter commands from the ASCII mapping `T:\mobile` with `D:\local_environment\Flutter\flutter\bin\flutter.bat`.
- Reference Android device for integration and performance gates: `26DYD24119408737`, Huawei BTK-W00, Android 12/API 31, arm64.

## Execution Baseline

Before Task 1, preserve the current verified working state. Review the dirty diff, then run:

```powershell
$flutter = 'D:\local_environment\Flutter\flutter\bin\flutter.bat'
Set-Location T:\mobile
& $flutter analyze
& $flutter test
& $flutter build apk --debug
```

Expected: analyzer reports no issues, all 63 current tests pass, and `build/app/outputs/flutter-apk/app-debug.apk` exists. Commit only the already-reviewed in-scope changes; do not include unrelated workspace files.

---

### Task 1: Transactional Document Persistence and Read Models

**Files:**
- Create: `mobile/lib/features/documents/domain/document_models.dart`
- Create: `mobile/lib/features/documents/domain/document_structure_builder.dart`
- Create: `mobile/lib/features/documents/data/drift_document_import_store.dart`
- Create: `mobile/lib/features/documents/data/drift_document_repository.dart`
- Modify: `mobile/lib/core/database/app_database.dart`
- Regenerate: `mobile/lib/core/database/app_database.g.dart`
- Test: `mobile/test/features/documents/drift_document_repository_test.dart`
- Test: `mobile/test/features/documents/document_structure_builder_test.dart`

**Interfaces:**
- Consumes: `ParsedBlock`, `splitSentences(String)`, `tokenize(String)`, `PhraseRecognizer`, `DictionaryLookup`, `DocumentImportStore`, and `ReadingProgressStore`.
- Produces:

```dart
class DocumentSummary {
  const DocumentSummary({
    required this.id,
    required this.title,
    required this.sourceName,
    required this.format,
    required this.status,
    required this.progress,
    required this.wordCount,
    required this.readProgress,
    this.failureCode,
    this.failureMessage,
  });
}

class StoredReaderDocument {
  const StoredReaderDocument({
    required this.id,
    required this.title,
    required this.sentences,
    required this.readProgress,
    this.lastLocator,
  });
}

abstract interface class DocumentRepository {
  Stream<List<DocumentSummary>> watchDocuments();
  Future<StoredReaderDocument> loadReaderDocument(String documentId);
  Future<void> deleteDocument(String documentId);
  Future<void> recoverInterruptedImports();
  Future<void> saveProgress(ReadingLocator locator, double progress);
}
```

- `DriftDocumentImportStore` implements the existing `DocumentImportStore`; `DriftDocumentRepository` implements `DocumentRepository` and `ReadingProgressStore`.

- [ ] **Step 1: Write failing structure-builder tests**

Create tests that build structure for two paragraphs containing repeated words and `look it up`. Assert exact paragraph/sentence/token offsets, unique stable IDs, canonical lemma values returned by the injected dictionary, and one `PhraseOccurrence` covering the expected token range. Cache lemma lookup by normalized token so repeated words call the dictionary once.

```dart
test('builds offset-safe rows and resolves each unique lemma once', () async {
  final dictionary = CountingDictionary({'looked': 'look', 'up': 'up'});
  final result = await DocumentStructureBuilder(
    dictionary: dictionary,
    phraseRecognizer: testPhraseRecognizer,
  ).build(documentId: 'doc-1', blocks: const [
    ParsedBlock(text: 'She looked up. She looked again.'),
  ]);

  expect(result.sentences, hasLength(2));
  expect(result.tokens.where((token) => token.surface == 'looked'), hasLength(2));
  expect(result.tokens.where((token) => token.lemma == 'look'), hasLength(2));
  expect(dictionary.callsFor('looked'), 1);
});
```

- [ ] **Step 2: Run the focused RED test**

```powershell
& $flutter test test/features/documents/document_structure_builder_test.dart
```

Expected: FAIL because `DocumentStructureBuilder` and structured row models do not exist.

- [ ] **Step 3: Implement the minimal structure builder**

Build immutable row models in memory before opening a transaction. Use sentence offsets relative to paragraphs and token offsets relative to sentences. Resolve lemmas through `DictionaryLookup.lookup(normalized)` and fall back to `normalized` only when the dictionary has no row. Do not infer lemmas with handwritten suffix trimming.

- [ ] **Step 4: Verify the structure builder GREEN**

```powershell
& $flutter test test/features/documents/document_structure_builder_test.dart
```

Expected: all structure-builder tests pass.

- [ ] **Step 5: Write failing Drift adapter tests**

Cover `queued → parsing → completed`, atomic replacement of all document structure, accurate word/paragraph counts, failure cleanup, duplicate content hash, retry with the same document ID, interrupted `parsing` recovery, stable reader load order, progress save, and document deletion retaining vocabulary/saved phrases.

```dart
test('replaceStructure commits all rows and summary counts atomically', () async {
  await importStore.createQueued(testRecord);
  await importStore.markParsing('doc-1');
  await importStore.replaceStructure('doc-1', parsedBlocks);
  await importStore.markCompleted('doc-1');

  final reader = await repository.loadReaderDocument('doc-1');
  expect(reader.sentences.map((item) => item.ordinal), orderedEquals([0, 1]));
  expect(await database.documentsDao.countStructureFor('doc-1'), greaterThan(0));
});
```

- [ ] **Step 6: Implement DAO queries and repository adapters**

Add typed DAO methods rather than raw SQL in widgets. `replaceStructure` must call the structure builder before `transaction`, then delete old structure, insert bounded batches, update counts, and commit as one logical operation. `recoverInterruptedImports` changes stale `parsing` rows to `failed` with a retryable local message while retaining the sandbox file.

- [ ] **Step 7: Regenerate Drift code and verify Task 1**

```powershell
& $flutter pub run build_runner build --delete-conflicting-outputs
& $flutter test test/features/documents/document_structure_builder_test.dart
& $flutter test test/features/documents/drift_document_repository_test.dart
& $flutter analyze
```

Expected: focused tests pass and analyzer reports no issues.

- [ ] **Step 8: Commit Task 1**

```powershell
git add mobile/lib/core/database mobile/lib/features/documents mobile/test/features/documents
git commit -m "feat: persist structured document imports"
```

---

### Task 2: Application Runtime, Assets, and Riverpod Composition

**Files:**
- Create: `mobile/lib/app/providers.dart`
- Create: `mobile/lib/app/app_runtime.dart`
- Create: `mobile/lib/core/database/database_factory.dart`
- Create: `mobile/lib/features/dictionary/data/dictionary_asset_store.dart`
- Create: `mobile/lib/features/phrases/data/phrase_catalog_loader.dart`
- Create: `mobile/lib/features/settings/data/settings_repository.dart`
- Create: `mobile/lib/features/learning/data/drift_learning_repository.dart`
- Modify: `mobile/lib/main.dart`
- Modify: `mobile/lib/app/app.dart`
- Test: `mobile/test/app/providers_test.dart`
- Test: `mobile/test/features/dictionary/dictionary_asset_store_test.dart`
- Test: `mobile/test/features/settings/settings_repository_test.dart`

**Interfaces:**
- Consumes: the v1 Drift database, bundled ECDICT SQLite asset, bundled phrase JSON, `DriftDocumentRepository`, and `LearningDao`.
- Produces application-scoped Riverpod providers for `AppDatabase`, `DocumentRepository`, `ImportDocumentUseCase`, `DictionaryLookup`, `PhraseRecognizer`, `LearningRepository`, and `SettingsRepository`.

```dart
class AppRuntime {
  const AppRuntime({
    required this.database,
    required this.dictionary,
    required this.phraseRecognizer,
  });

  final AppDatabase database;
  final DictionaryRepository dictionary;
  final PhraseRecognizer phraseRecognizer;

  Future<void> close() async {
    dictionary.database.dispose();
    await database.close();
  }
}
```

```dart
abstract interface class SettingsRepository {
  Stream<ReadingSettings> watch();
  Future<ReadingSettings> load();
  Future<void> save(ReadingSettings settings);
}

abstract interface class LearningRepository {
  Future<void> recordLookup({
    required String surface,
    required DictionaryEntry entry,
    required LearningContext context,
  });
  Future<void> savePhrase(SavedPhraseDraft phrase);
}
```

- [ ] **Step 1: Write failing asset/runtime tests**

Test first-launch dictionary copy, hash-preserving reuse on subsequent launches, read-only SQLite opening, valid phrase JSON loading, malformed settings fallback, settings round-trip, and provider disposal closing databases.

```dart
test('copies the bundled dictionary once and opens it read-only', () async {
  final store = DictionaryAssetStore(
    supportDirectory: tempDirectory,
    assetReader: fakeAssetReader,
  );
  final first = await store.open();
  final second = await store.open();
  expect(fakeAssetReader.readCount, 1);
  expect(first.lookup('language'), isNotNull);
  expect(() => second.database.execute('DELETE FROM entries'), throwsA(anything));
});
```

- [ ] **Step 2: Verify RED**

```powershell
& $flutter test test/app/providers_test.dart test/features/dictionary/dictionary_asset_store_test.dart test/features/settings/settings_repository_test.dart
```

Expected: FAIL because the runtime factories and repositories are absent.

- [ ] **Step 3: Implement database and asset factories**

Open the user database once with `driftDatabase(name: 'dianduji')`. Copy `assets/dictionary/ecdict.sqlite` into application support storage using a `.part` file and atomic rename, validate its metadata/hash, and open it with `OpenMode.readOnly`. Load `assets/phrases/phrases.json` once and construct one `PhraseRecognizer`.

- [ ] **Step 4: Implement explicit Riverpod providers**

Use manual providers—no new code generation dependency. Providers must use `ref.onDispose` for database handles and must not create a new `GoRouter`, database, or dictionary connection during widget rebuilds.

```dart
final appRuntimeProvider = Provider<AppRuntime>((ref) {
  throw StateError('main.dart must override appRuntimeProvider');
});
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return ref.watch(appRuntimeProvider).database;
});
final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DriftDocumentRepository(ref.watch(appDatabaseProvider));
});
final readingSettingsProvider = StreamProvider<ReadingSettings>((ref) {
  return ref.watch(settingsRepositoryProvider).watch();
});
```

At startup, initialize assets before `runApp`, override only concrete resource providers, call `recoverInterruptedImports`, and render a Chinese actionable startup error if initialization fails.

- [ ] **Step 5: Verify Task 2**

```powershell
& $flutter test test/app/providers_test.dart test/features/dictionary/dictionary_asset_store_test.dart test/features/settings/settings_repository_test.dart
& $flutter analyze
```

- [ ] **Step 6: Commit Task 2**

```powershell
git add mobile/lib/app mobile/lib/core/database mobile/lib/features/dictionary mobile/lib/features/phrases/data mobile/lib/features/settings/data mobile/lib/features/learning/data mobile/lib/main.dart mobile/test
git commit -m "feat: compose persistent offline runtime"
```

---

### Task 3: Real File Picker and Recoverable TXT/DOCX Import Flow

**Files:**
- Create: `mobile/lib/features/documents/data/file_picker_document_picker.dart`
- Create: `mobile/lib/features/documents/data/default_document_parser_resolver.dart`
- Create: `mobile/lib/features/documents/data/default_import_intake.dart`
- Create: `mobile/lib/features/documents/presentation/document_import_controller.dart`
- Create: `mobile/lib/features/documents/presentation/document_library_page.dart`
- Modify: `mobile/lib/features/documents/presentation/document_library_screen.dart`
- Modify: `mobile/lib/app/app.dart`
- Test: `mobile/test/features/documents/document_import_controller_test.dart`
- Test: `mobile/test/features/documents/document_library_page_test.dart`
- Create: `mobile/integration_test/fixtures/sample_utf8.txt`
- Create: `mobile/integration_test/fixtures/sample_gb18030.txt`
- Create: `mobile/integration_test/fixtures/sample.docx`
- Create: `mobile/integration_test/txt_docx_import_test.dart`

**Interfaces:**
- Consumes: `ImportDocumentUseCase`, `DocumentRepository.watchDocuments()`, `FileIntakeService`, TXT/DOCX parsers, and the existing presentation-only `DocumentLibraryScreen`.
- Produces:

```dart
abstract interface class DocumentPicker {
  Future<SelectedFile?> pickDocument();
}

class DocumentImportController extends ChangeNotifier {
  Future<void> pickAndImport();
  Future<void> retry(String documentId);
  Future<void> cancel(String documentId);
  Future<void> delete(String documentId);
}
```

- [ ] **Step 1: Write failing controller tests**

Cover user cancellation without an error, one picker invocation per button press, queued/parsing/completed state forwarding, duplicate-file navigation to the existing document, cancellation-token propagation, retry from the sandbox copy with the same ID, delete confirmation delegation, and Chinese error messages for unsupported/revoked files.

```dart
test('picker cancellation leaves the library unchanged', () async {
  final controller = DocumentImportController(
    picker: FakePicker(result: null),
    importer: fakeImporter,
    repository: fakeRepository,
  );
  await controller.pickAndImport();
  expect(controller.state.errorMessage, isNull);
  expect(fakeImporter.startCalls, 0);
});
```

- [ ] **Step 2: Verify RED**

```powershell
& $flutter test test/features/documents/document_import_controller_test.dart test/features/documents/document_library_page_test.dart
```

- [ ] **Step 3: Implement the picker, resolver, and intake adapter**

Call `FilePicker.platform.pickFiles` with one file and extensions `txt`, `pdf`, `docx`. Treat a null result as user cancellation. Reject a missing `PlatformFile.path` with `fileUnavailable`. `DefaultImportIntake.prepare` must copy first, read magic bytes from the sandbox copy, detect the real format, and only then load parser bytes. The resolver returns one parser per `FileFormat`; PDF uses the platform extractor added in Task 6 and may temporarily return a clear `unsupportedPlatform` failure before that task.

```dart
final result = await FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: const ['txt', 'pdf', 'docx'],
  allowMultiple: false,
  withData: false,
);
if (result == null) return null;
final file = result.files.single;
final path = file.path;
if (path == null) {
  throw const AppFailure(
    AppFailureCode.fileUnavailable,
    '系统没有提供可读取的文件路径，请重新选择文件。',
  );
}
return SelectedFile(path: path, originalName: file.name);
```

- [ ] **Step 4: Implement the controller and reactive library page**

Subscribe once to `watchDocuments`, map domain summaries to `LibraryDocument`, and pass explicit callbacks into the existing responsive screen. Keep controller state independent from widgets so rebuilds cannot restart imports. Present duplicate, failure, cancel, retry, and delete-confirmation outcomes with actionable Chinese copy and semantic announcements.

Add title/filename search and last-opened/title/import-time sort to controller state; perform filtering outside the widget so phone and tablet receive the same ordered list.

- [ ] **Step 5: Verify focused GREEN**

```powershell
& $flutter test test/features/documents/document_import_controller_test.dart test/features/documents/document_library_page_test.dart
& $flutter analyze
```

- [ ] **Step 6: Add a device integration seam and run real TXT/DOCX fixtures**

Add `integration_test` from the Flutter SDK to `dev_dependencies`. The integration test copies fixture bytes to the test app support directory, invokes the same controller path after the picker boundary, waits for `completed`, opens the document, and verifies persisted text after app restart. Do not automate the system picker by screen coordinates.

```powershell
& $flutter test integration_test/txt_docx_import_test.dart -d 26DYD24119408737
```

Expected: UTF-8, GB18030, and DOCX imports complete and remain visible after restart.

- [ ] **Step 7: Commit Task 3**

```powershell
git add mobile/lib/features/documents mobile/lib/app/app.dart mobile/integration_test mobile/test mobile/pubspec.yaml mobile/pubspec.lock
git commit -m "feat: import TXT and DOCX on Android"
```

---

### Task 4: Persisted Reader, Tap Translation, and Reading Position

**Files:**
- Create: `mobile/lib/features/reader/presentation/reader_page.dart`
- Create: `mobile/lib/features/reader/presentation/reader_controller.dart`
- Create: `mobile/lib/core/platform/pronunciation_service.dart`
- Create: `mobile/lib/core/platform/android_pronunciation_service.dart`
- Create: `mobile/android/app/src/main/kotlin/com/dianduji/dian_du_ji/PronunciationChannel.kt`
- Modify: `mobile/android/app/src/main/kotlin/com/dianduji/dian_du_ji/MainActivity.kt`
- Modify: `mobile/lib/features/reader/presentation/reader_screen.dart`
- Modify: `mobile/lib/features/reader/presentation/widgets/token_text.dart`
- Modify: `mobile/lib/features/dictionary/presentation/translation_detail.dart`
- Modify: `mobile/lib/features/dictionary/presentation/translation_view_model.dart`
- Modify: `mobile/lib/app/app.dart`
- Test: `mobile/test/features/reader/reader_controller_test.dart`
- Test: `mobile/test/features/reader/reader_page_test.dart`
- Test: `mobile/test/features/dictionary/translation_detail_test.dart`
- Test: `mobile/test/core/platform/pronunciation_service_test.dart`

**Interfaces:**
- Consumes: `DocumentRepository.loadReaderDocument`, `ReaderProgressController`, `TranslationViewModel`, `ReadingSettings`, and `go_router`.
- Produces route `/reader/:documentId`, a controller-owned selected token/sentence, a live `TranslationState`, and lifecycle-safe progress persistence.
- Produces an offline pronunciation entry through Android `TextToSpeech`; missing local English voice data is an explicit `unavailable` result rather than a network fallback.

- [ ] **Step 1: Write failing reader-controller tests**

Cover ordered stored-sentence loading, restoration to a locator after font-size change, one selected token ID, drag-not-tap behavior, immediate selection before dictionary completion, one lookup command per tap, throttled save, forced save on back/pause, and no save after dispose.

```dart
test('tap selects immediately and dispatches exactly one lookup', () async {
  await controller.open('doc-1');
  final future = controller.selectToken(sentenceId: 's1', tokenId: 't2');
  expect(controller.state.selectedTokenId, 't2');
  expect(fakeTranslation.lookupCalls, 1);
  await future;
});
```

- [ ] **Step 2: Verify RED**

```powershell
& $flutter test test/features/reader/reader_controller_test.dart test/features/reader/reader_page_test.dart test/features/dictionary/translation_detail_test.dart
```

- [ ] **Step 3: Implement the persisted reader route and controller**

Create the router once, outside rebuild-driven settings state. Load reader rows by document ID, render sentence/token IDs from Drift, and apply font size/line height from persisted settings. Use `WidgetsBindingObserver.didChangeAppLifecycleState` and `PopScope` to call `forceSave`. Restore by locator and calibrate the target sentence into view with a keyed list item; do not persist pixels.

```dart
Future<void> selectToken({required String sentenceId, required String tokenId}) async {
  final selected = state.requireToken(sentenceId, tokenId);
  state = state.copyWith(selectedSentenceId: sentenceId, selectedTokenId: tokenId);
  await translation.lookup(
    tokens: state.tokensFor(sentenceId),
    selectedTokenOrdinal: selected.ordinal,
    context: state.learningContextFor(sentenceId),
    autoSaveVocabulary: settings.autoSaveVocabulary,
  );
}
```

- [ ] **Step 4: Render all translation states**

`TranslationDetail` must render `loading`, `found`, `notFound`, and `failed`; show surface, phonetic, POS, Chinese definition, relevant phrases, explicit save-phrase feedback, and a semantic pronunciation action. Implement `PronunciationChannel` with Android `TextToSpeech`, set `Locale.US` or the first installed English locale, and never request voice data from the network. If initialization or language support fails, return `unavailable` and show “本机未安装英文语音”。

Change `TranslationViewModel.lookup` to accept `LearningContext` and `autoSaveVocabulary`. Call `learning.recordLookup` only after a nonblank local definition and only when the setting is enabled.

```kotlin
channel.setMethodCallHandler { call, result ->
    when (call.method) {
        "speak" -> speaker.speak(call.argument<String>("text").orEmpty(), result)
        "stop" -> { speaker.stop(); result.success(null) }
        else -> result.notImplemented()
    }
}
```

- [ ] **Step 5: Verify Task 4 and profile the reader on the tablet**

```powershell
& $flutter test test/features/reader test/features/dictionary
& $flutter analyze
& $flutter run -d 26DYD24119408737 --profile
```

On BTK-W00, verify portrait/landscape, 200% text, tap/drag distinction, bottom card on narrow width, right pane on tablet width, background/resume, and locator restoration.

- [ ] **Step 6: Commit Task 4**

```powershell
git add mobile/lib/app mobile/lib/features/reader mobile/lib/features/dictionary mobile/test/features/reader mobile/test/features/dictionary
git commit -m "feat: read persisted documents with offline translation"
```

---

### Task 5: Persistent Vocabulary, Phrase Book, Settings, and CSV Export

**Files:**
- Modify: `mobile/lib/core/database/app_database.dart`
- Regenerate: `mobile/lib/core/database/app_database.g.dart`
- Expand: `mobile/lib/features/learning/data/drift_learning_repository.dart`
- Create: `mobile/lib/features/learning/presentation/learning_controllers.dart`
- Modify: `mobile/lib/features/learning/presentation/vocabulary_screen.dart`
- Modify: `mobile/lib/features/learning/presentation/phrase_book_screen.dart`
- Create: `mobile/lib/features/learning/data/csv_export_service.dart`
- Modify: `mobile/lib/features/settings/presentation/settings_screen.dart`
- Modify: `mobile/lib/app/app.dart`
- Test: `mobile/test/features/learning/drift_learning_repository_test.dart`
- Test: `mobile/test/features/learning/learning_pages_test.dart`
- Test: `mobile/test/features/settings/persisted_settings_test.dart`

**Interfaces:**
- Consumes: `LearningDao`, `SettingsRepository`, existing `CsvExporter`, `PhraseType`, and the app navigation shell.
- Produces reactive vocabulary/phrase streams, explicit mutation commands, persisted reader settings, and RFC-compatible CSV bytes written through a user-selected destination.

- [ ] **Step 1: Write failing repository tests**

Cover all/known/vague/unknown filters; time/alphabet/lookup-count sorting; Chinese and English search; proficiency update; unique manual add; confirmed delete; source-deleted display; phrase type/search/delete; and saved-phrase created-at preservation.

```dart
test('deleting a source keeps vocabulary and marks its source deleted', () async {
  await seedVocabularyWithSource(database, documentId: 'doc-1');
  await documents.deleteDocument('doc-1');
  final item = await learning.watchVocabulary(const VocabularyQuery()).first;
  expect(item.single.sourceAvailability, SourceAvailability.deleted);
});
```

- [ ] **Step 2: Run repository tests to verify RED**

```powershell
& $flutter test test/features/learning/drift_learning_repository_test.dart
```

Expected: FAIL because the reactive queries and mutations do not exist.

- [ ] **Step 3: Implement typed queries and mutation commands**

Keep query/filter values in domain objects. Mutations are explicit repository calls and never inferred from widget lifecycle. Manual add uses normalized lemma uniqueness and rejects blank definitions. Deletion requires a UI confirmation result before repository invocation.

- [ ] **Step 4: Write failing page/settings tests**

Test responsive empty/list/detail states, search and filters, sort menus, manual-add validation, delete confirmation, CSV content with quotes/commas/CRLF/Chinese, phrase filters, theme persistence across restart, font range 12–24, line height 1.4–2.0, auto-save toggle, privacy text, licenses, and local-cache cleanup confirmation.

- [ ] **Step 5: Run page/settings tests to verify RED**

```powershell
& $flutter test test/features/learning/learning_pages_test.dart test/features/settings/persisted_settings_test.dart
```

Expected: FAIL because screens still receive in-memory lists/settings and export actions are not connected.

- [ ] **Step 6: Implement persisted screens and export service**

Replace empty arrays in `app.dart` with Riverpod streams. Write UTF-8 CSV without a BOM to a path chosen by the platform save dialog, preserving the existing RFC escaping behavior. Cache cleanup removes only rebuildable dictionary/parser caches; “clear all local data” is a separate destructive confirmation and must retain no ambiguity about document and learning deletion.

```dart
Future<CsvExportResult> exportVocabulary(List<VocabularyListItem> entries) async {
  final path = await destinationPicker.saveCsv(suggestedName: '点读机生词.csv');
  if (path == null) return CsvExportResult.cancelled;
  final bytes = exporter.export(entries);
  await File(path).writeAsBytes(bytes, flush: true);
  return CsvExportResult.saved(path);
}
```

- [ ] **Step 7: Verify Task 5**

```powershell
& $flutter pub run build_runner build --delete-conflicting-outputs
& $flutter test test/features/learning test/features/settings
& $flutter analyze
```

- [ ] **Step 8: Commit Task 5**

```powershell
git add mobile/lib/core/database mobile/lib/features/learning mobile/lib/features/settings mobile/lib/app/app.dart mobile/test/features/learning mobile/test/features/settings
git commit -m "feat: persist learning library and reader settings"
```

---

### Task 6: Android PDFBox Text Extraction Adapter

**Files:**
- Create: `mobile/lib/core/platform/android_pdf_text_extractor.dart`
- Create: `mobile/android/app/src/main/kotlin/com/dianduji/dian_du_ji/PdfTextExtractorChannel.kt`
- Modify: `mobile/android/app/src/main/kotlin/com/dianduji/dian_du_ji/MainActivity.kt`
- Modify: `mobile/android/app/build.gradle.kts`
- Create: `mobile/docs/third-party-notices.md`
- Test: `mobile/test/core/platform/android_pdf_text_extractor_test.dart`
- Test: `mobile/android/app/src/androidTest/kotlin/com/dianduji/dian_du_ji/PdfTextExtractorChannelTest.kt`
- Create: `mobile/integration_test/pdf_parser_android_test.dart`
- Create: `mobile/integration_test/fixtures/text-two-pages.pdf`
- Create: `mobile/integration_test/fixtures/encrypted.pdf`
- Create: `mobile/integration_test/fixtures/scanned-two-pages.pdf`
- Create: `mobile/integration_test/fixtures/corrupt.pdf`
- Create: `mobile/integration_test/fixtures/PDF_FIXTURES.md`

**Interfaces:**
- Consumes: existing `PdfTextExtractor`, `PdfPageText`, `ParseCancellationToken`, and `PdfDocumentParser`.
- Produces `AndroidPdfTextExtractor` over method channel `com.dianduji/pdf/methods` and event channel `com.dianduji/pdf/events`.

**Pinned native dependency:** `implementation("com.tom-roush:pdfbox-android:2.0.27.0")`, Apache-2.0. This is the version currently published in Maven Central and required by the approved design.

- [ ] **Step 1: Write failing Dart channel tests**

Use Flutter binary messenger mocks to assert one request ID per extraction, ordered page decoding, unrelated-event filtering, cancellation invoking `cancel`, native error-code mapping, and stream closure.

```dart
test('maps encrypted native failure to PdfExtractionError.encrypted', () async {
  nativeEvents.add({'requestId': 'r1', 'type': 'error', 'code': 'encrypted'});
  await expectLater(
    extractor.extract('/sandbox/encrypted.pdf'),
    emitsError(isA<PdfExtractionException>().having(
      (error) => error.error,
      'error',
      PdfExtractionError.encrypted,
    )),
  );
});
```

- [ ] **Step 2: Verify Dart RED and implement the Dart adapter**

```powershell
& $flutter test test/core/platform/android_pdf_text_extractor_test.dart
```

Implement request filtering and cleanup without assuming that event order from unrelated simultaneous imports is serialized.

Re-run the same command after implementation. Expected: all Dart channel tests pass before native code is added.

- [ ] **Step 3: Write failing Kotlin tests for native extraction**

Create Android instrumented tests for two-page text order, encrypted failure, corrupt failure, scanned-page empty text, cancellation between pages, file-size cap, page-count cap, and diagnostic messages without document body text. Add `androidTestImplementation("androidx.test.ext:junit:1.3.0")` and use the existing AndroidX test runner.

- [ ] **Step 4: Implement the PDFBox channel**

Initialize `PDFBoxResourceLoader` once. Run extraction on one bounded executor, keep `requestId → AtomicBoolean` cancellation flags, load only sandbox paths supplied by Dart, and emit maps with `requestId`, `type`, `pageNumber`, `pageCount`, and `text`. Map `InvalidPasswordException` to `encrypted`, malformed load to `corrupt`, cancellation to `cancelled`, missing file to `unavailable`, and all other exceptions to `unknown`. Always close `PDDocument` in `use`/`finally`.

```kotlin
PDDocument.load(file).use { document ->
    val pageCount = document.numberOfPages
    require(pageCount <= MAX_PAGE_COUNT) { "page_limit" }
    val stripper = PDFTextStripper()
    for (page in 1..pageCount) {
        if (cancelled.get()) throw CancellationException("cancelled")
        stripper.startPage = page
        stripper.endPage = page
        emitPage(requestId, page, pageCount, stripper.getText(document))
    }
}
```

- [ ] **Step 5: Document and hash committed fixtures**

`PDF_FIXTURES.md` must record how each fixture was generated, its license/provenance, SHA-256, page count, encryption password used only to generate the locked fixture, and expected result. Fixtures must contain no personal or copyrighted document content.

- [ ] **Step 6: Run Android PDF integration tests**

```powershell
& $flutter test integration_test/pdf_parser_android_test.dart -d 26DYD24119408737
```

Expected: page text is ordered; encrypted, scanned, corrupt, cancel, and timeout outcomes match exact `AppFailureCode` values.

- [ ] **Step 7: Commit Task 6**

```powershell
git add mobile/lib/core/platform mobile/android/app mobile/integration_test mobile/docs/third-party-notices.md
git commit -m "feat: extract PDF text on Android"
```

---

### Task 7: Android Shared-File Intake for Cold and Warm Starts

**Files:**
- Create: `mobile/lib/core/platform/shared_file_receiver.dart`
- Create: `mobile/lib/core/platform/android_shared_file_receiver.dart`
- Create: `mobile/android/app/src/main/kotlin/com/dianduji/dian_du_ji/SharedFileChannel.kt`
- Modify: `mobile/android/app/src/main/kotlin/com/dianduji/dian_du_ji/MainActivity.kt`
- Modify: `mobile/android/app/src/main/AndroidManifest.xml`
- Modify: `mobile/lib/features/documents/presentation/document_import_controller.dart`
- Test: `mobile/test/core/platform/shared_file_receiver_test.dart`
- Create: `mobile/integration_test/shared_file_import_test.dart`

**Interfaces:**
- Consumes: Android `ACTION_SEND`, `ACTION_VIEW`, `Intent.EXTRA_STREAM`, content URIs, and `DocumentImportController`.
- Produces a broadcast stream of sandbox-ready `SelectedFile` values routed through the same intake/import use case as the file picker.

```dart
abstract interface class SharedFileReceiver {
  Stream<SelectedFile> get files;
  Future<void> initialize();
}
```

- [ ] **Step 1: Write failing receiver/controller tests**

Cover cold-start event replay exactly once, warm-start delivery, duplicate intent fingerprint suppression, unsupported MIME, missing display name fallback, revoked URI permission, multiple rapid intents, and receiver disposal.

- [ ] **Step 2: Verify RED**

```powershell
& $flutter test test/core/platform/shared_file_receiver_test.dart test/features/documents/document_import_controller_test.dart
```

- [ ] **Step 3: Add narrow Android intent filters**

Declare exported `singleTop` handling only for `text/plain`, `application/pdf`, and `application/vnd.openxmlformats-officedocument.wordprocessingml.document`. Include `CATEGORY_DEFAULT`, accept `content:` URIs, and do not request broad storage permissions.

- [ ] **Step 4: Implement safe native URI copying and event delivery**

Use `ContentResolver.openInputStream`, copy into the app cache with a generated temporary name, close every stream, and pass only the resulting private path/name/MIME to Dart. Check `FLAG_GRANT_READ_URI_PERMISSION`; map `SecurityException` to a revoked-permission error. Fingerprint action + URI + size + last-modified where available and suppress only repeated delivery of the same intent, not repeated user imports.

```kotlin
contentResolver.openInputStream(uri).use { input ->
    requireNotNull(input) { "shared_uri_unavailable" }
    FileOutputStream(destination).use { output -> input.copyTo(output) }
}
eventSink.success(mapOf(
    "path" to destination.absolutePath,
    "name" to displayName,
    "mime" to intent.type,
))
```

- [ ] **Step 5: Route shared files through the existing controller and verify**

```powershell
& $flutter test test/core/platform/shared_file_receiver_test.dart test/features/documents/document_import_controller_test.dart
& $flutter test integration_test/shared_file_import_test.dart -d 26DYD24119408737
```

Also manually share one TXT, PDF, and DOCX from the Huawei file manager into 点读机 in both stopped and already-running states.

- [ ] **Step 6: Commit Task 7**

```powershell
git add mobile/lib/core/platform mobile/lib/features/documents/presentation mobile/android/app/src/main mobile/test/core/platform mobile/integration_test/shared_file_import_test.dart
git commit -m "feat: import Android shared documents"
```

---

### Task 8: Accessibility, Responsive Goldens, and Full Android Learning Flow

**Files:**
- Create: `mobile/test/accessibility/accessibility_test.dart`
- Create: `mobile/test/goldens/document_library_phone.png`
- Create: `mobile/test/goldens/document_library_tablet.png`
- Create: `mobile/test/goldens/reader_phone.png`
- Create: `mobile/test/goldens/reader_tablet.png`
- Create: `mobile/test/goldens/learning_themes.png`
- Create: `mobile/integration_test/core_learning_flow_test.dart`
- Modify: `mobile/lib/features/documents/presentation/document_library_screen.dart`
- Modify: `mobile/lib/features/reader/presentation/reader_screen.dart`
- Modify: `mobile/lib/features/dictionary/presentation/translation_detail.dart`
- Modify: `mobile/lib/features/learning/presentation/vocabulary_screen.dart`
- Modify: `mobile/lib/features/learning/presentation/phrase_book_screen.dart`
- Modify: `mobile/lib/features/settings/presentation/settings_screen.dart`

**Interfaces:**
- Consumes: the complete import, reader, dictionary, learning, settings, PDF, and shared-file paths from Tasks 1–7.
- Produces reproducible visual/accessibility evidence and one complete Android end-to-end test.

- [ ] **Step 1: Write failing accessibility tests**

Assert named icon buttons, async status live regions, selected token semantics, 48dp minimum hit targets, critical-label visibility at 200% text, reduced-motion duration zero, and contrast tokens used by day/night/eye-care themes.

```dart
testWidgets('all icon-only actions expose Chinese semantic labels', (tester) async {
  await tester.pumpWidget(testApp(const DocumentLibraryPage()));
  final semantics = tester.getSemantics(find.byIcon(Icons.add_rounded));
  expect(semantics.label, contains('导入文档'));
});
```

- [ ] **Step 2: Verify RED, repair only demonstrated gaps, verify GREEN**

```powershell
& $flutter test test/accessibility/accessibility_test.dart
```

- [ ] **Step 3: Add deterministic goldens**

Capture 390×844 and 1024×768 layouts for empty, importing, failed, reader-selected, vocabulary, phrase, and settings states. Run day/night/eye-care variants and 200% text. Fix fonts, device pixel ratio, locale, and animation clock in the golden harness.

```powershell
& $flutter test test/goldens --update-goldens
```

Review each changed PNG visually, then run the same tests without `--update-goldens` and require a clean pass.

- [ ] **Step 4: Write the full Android end-to-end test**

Flow: reset test database → import real TXT → wait for completed → open → tap a known word → verify immediate selection → verify local definition → verify exactly one vocabulary record → save a covering phrase → scroll → background/restart → verify document, locator, vocabulary, phrase, and settings survive → delete source → verify learning assets remain with deleted-source label.

- [ ] **Step 5: Run the full device gate**

```powershell
& $flutter test test/accessibility
& $flutter test test
& $flutter test integration_test/core_learning_flow_test.dart -d 26DYD24119408737
```

Review every updated golden visually before accepting it. Do not update goldens merely to make a regression pass.

- [ ] **Step 6: Commit Task 8**

```powershell
git add mobile/lib mobile/test/accessibility mobile/test/goldens mobile/integration_test/core_learning_flow_test.dart
git commit -m "test: verify responsive Android learning flow"
```

---

### Task 9: Performance, Privacy, Documentation, and Release Candidate

**Files:**
- Create: `mobile/tool/check_coverage.dart`
- Create: `mobile/tool/benchmarks/dictionary_benchmark.dart`
- Create: `mobile/integration_test/performance_gate_test.dart`
- Create: `mobile/README.md`
- Complete: `mobile/docs/third-party-notices.md`
- Create: `mobile/android/key.properties.example`
- Modify: `mobile/android/app/build.gradle.kts`
- Modify: `mobile/android/.gitignore`
- Modify: `mobile/pubspec.yaml`

**Interfaces:**
- Consumes: the complete MVP and the approved thresholds.
- Produces coverage/performance reports, privacy/license evidence, reproducible setup instructions, a debug APK, and a release AAB signed only from external credentials.

- [ ] **Step 1: Add a deterministic core-coverage gate**

Parse `coverage/lcov.info` and calculate line coverage only for document parsing/structure, dictionary, phrase, import state, learning repository, and reader-controller paths. Exit nonzero below 90%; print included files and uncovered lines.

```powershell
& $flutter test --coverage
dart run tool/check_coverage.dart coverage/lcov.info --minimum 90
```

- [ ] **Step 2: Add and run performance gates**

Measure and record:

- 1,000 indexed dictionary lookups: each under the documented 10ms reference budget.
- Tap-to-visible-selection latency: under 100ms.
- Long-reader profile frames on BTK-W00: at least 55 FPS during the fixed scroll trace.
- Fixed 1,000-page text PDF: report duration and peak memory; claim the 30-second target only if measured at or below 30 seconds.

Write JSON results containing device model, OS, build mode, fixture SHA-256, duration, frame count, and pass/fail. Store no document body text in results or logs.

- [ ] **Step 3: Audit privacy and licenses**

Verify ECDICT MIT attribution, PDFBox Android/Apache-2.0 attribution, Dart/Flutter package notices, zero translation network calls, no document text in diagnostic logs, and no broad storage permission. Add a user-facing privacy page that states all document and lookup processing is local.

- [ ] **Step 4: Configure release signing without secrets in Git**

Read `DIANDUJI_STORE_FILE`, `DIANDUJI_STORE_PASSWORD`, `DIANDUJI_KEY_ALIAS`, and `DIANDUJI_KEY_PASSWORD` from Gradle properties/environment for release builds. Fail release configuration with an actionable message when any is missing. Commit only `key.properties.example`; ignore real keystores and property files. Remove the current debug signing assignment from the release build type.

```kotlin
val releaseValues = listOf(
    "DIANDUJI_STORE_FILE",
    "DIANDUJI_STORE_PASSWORD",
    "DIANDUJI_KEY_ALIAS",
    "DIANDUJI_KEY_PASSWORD",
).associateWith { key -> providers.gradleProperty(key).orNull ?: System.getenv(key) }

val missingReleaseValues = releaseValues.filterValues { it.isNullOrBlank() }.keys
val releaseRequested = gradle.startParameter.taskNames.any { it.contains("Release") }
if (releaseRequested && missingReleaseValues.isNotEmpty()) {
    error("Missing release signing values: ${missingReleaseValues.joinToString()}")
}

signingConfigs {
    create("release") {
        storeFile = releaseValues.getValue("DIANDUJI_STORE_FILE")?.let(::file)
        storePassword = releaseValues.getValue("DIANDUJI_STORE_PASSWORD")
        keyAlias = releaseValues.getValue("DIANDUJI_KEY_ALIAS")
        keyPassword = releaseValues.getValue("DIANDUJI_KEY_PASSWORD")
    }
}
```

- [ ] **Step 5: Write exact operator documentation**

`mobile/README.md` must include Flutter/JDK/SDK/NDK versions, the `T:` path mapping, why Kotlin incremental compilation is disabled, device setup, dictionary rebuild command and hashes, fixture provenance, all test commands, database migration rules, privacy behavior, the current `file_picker` pin, iOS verification limitation, signing variables, and artifact locations.

- [ ] **Step 6: Run final verification from a clean build**

```powershell
$flutter = 'D:\local_environment\Flutter\flutter\bin\flutter.bat'
Set-Location T:\mobile
& $flutter clean
& $flutter pub get
& $flutter pub run build_runner build --delete-conflicting-outputs
& $flutter analyze
& $flutter test --coverage
dart run tool/check_coverage.dart coverage/lcov.info --minimum 90
& $flutter test integration_test -d 26DYD24119408737
& $flutter build apk --debug
& $flutter build appbundle --release
```

Expected: all commands exit 0. The release command is run only after the four signing values are supplied; never fall back to debug signing for a release artifact.

- [ ] **Step 7: Install the final APK and record evidence**

```powershell
$adb = 'C:\Users\24439\AppData\Local\Android\sdk\platform-tools\adb.exe'
& $adb -s 26DYD24119408737 install -r build\app\outputs\flutter-apk\app-debug.apk
& $adb -s 26DYD24119408737 shell monkey -p com.dianduji.dian_du_ji -c android.intent.category.LAUNCHER 1
& $adb -s 26DYD24119408737 shell pidof com.dianduji.dian_du_ji
Get-FileHash build\app\outputs\flutter-apk\app-debug.apk -Algorithm SHA256
```

Expected: install succeeds, the application PID is returned, and the final SHA-256 is copied into the release evidence section of the README.

- [ ] **Step 8: Commit Task 9**

```powershell
git add mobile
git commit -m "chore: verify Flutter MVP release candidate"
```

## Requirements Traceability

| Approved requirement | Implemented/verified by |
|---|---|
| Real TXT/DOCX import, sandbox copy, retry/cancel/dedupe | Tasks 1–3 |
| Text PDF, encryption/corruption/OCR-required mapping | Task 6 |
| Phone/tablet document library and reader | Tasks 3, 4, 8 |
| Tap selection, offline definition, covering phrases | Task 4 |
| Exactly one vocabulary write per explicit tap | Tasks 2, 4, 8 |
| Vocabulary, phrase book, CSV, settings | Task 5 |
| Stable reading-position recovery | Tasks 1, 4, 8 |
| Android shared-file cold/warm import | Task 7 |
| Accessibility, large text, reduced motion | Task 8 |
| Offline privacy, licenses, performance, release evidence | Task 9 |
| No OCR, accounts, cloud sync, AI explanation, or Web-data migration | Global constraints and Task 9 audit |
