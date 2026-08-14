import 'dart:async';
import 'dart:io';

import 'package:dian_du_ji/app/providers.dart';
import 'package:dian_du_ji/core/platform/pdf_text_extractor.dart';
import 'package:dian_du_ji/features/dictionary/data/dictionary_repository.dart';
import 'package:dian_du_ji/features/dictionary/presentation/translation_view_model.dart';
import 'package:dian_du_ji/features/documents/data/drift_document_repository.dart';
import 'package:dian_du_ji/features/documents/data/file_picker_document_picker.dart';
import 'package:dian_du_ji/features/documents/data/services/file_intake_service.dart';
import 'package:dian_du_ji/features/documents/domain/document_models.dart';
import 'package:dian_du_ji/features/documents/domain/import_document_use_case.dart';
import 'package:dian_du_ji/features/documents/presentation/document_import_controller.dart';
import 'package:dian_du_ji/features/documents/presentation/document_library_page.dart';
import 'package:dian_du_ji/features/learning/data/learning_repository.dart';
import 'package:dian_du_ji/features/phrases/domain/phrase_recognizer.dart';
import 'package:dian_du_ji/features/reader/data/reader_card_preferences.dart';
import 'package:dian_du_ji/features/reader/domain/reading_locator.dart';
import 'package:dian_du_ji/features/reader/presentation/reader_controller.dart';
import 'package:dian_du_ji/features/reader/presentation/reader_page.dart';
import 'package:dian_du_ji/features/settings/data/cache_cleanup_service.dart';
import 'package:dian_du_ji/features/settings/data/reading_settings.dart';
import 'package:dian_du_ji/features/settings/data/settings_repository.dart';
import 'package:dian_du_ji/features/settings/presentation/persisted_settings_controller.dart';
import 'package:dian_du_ji/features/settings/presentation/persisted_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Deterministic visual evidence for the approved responsive layouts.
///
/// The harness pins device pixel ratio, surface size, and animation state,
/// and loads the system Chinese font so text renders with real glyphs.
/// Regenerate with `flutter test test/goldens --update-goldens` and review
/// every changed PNG visually before accepting it.
void main() {
  setUpAll(_loadChineseFont);

  testWidgets('document library phone golden', (tester) async {
    await _pumpGolden(
      tester,
      size: const Size(390, 844),
      widget: DocumentLibraryPage(
        controller: _emptyLibraryController(),
      ),
    );
    await expectLater(
      find.byType(DocumentLibraryPage),
      matchesGoldenFile('document_library_phone.png'),
    );
  });

  testWidgets('document library tablet golden', (tester) async {
    await _pumpGolden(
      tester,
      size: const Size(1024, 768),
      widget: DocumentLibraryPage(
        controller: _emptyLibraryController(),
      ),
    );
    await expectLater(
      find.byType(DocumentLibraryPage),
      matchesGoldenFile('document_library_tablet.png'),
    );
  });

  testWidgets('reader phone golden with bottom translation sheet', (
    tester,
  ) async {
    await _pumpGolden(
      tester,
      size: const Size(390, 844),
      widget: _readerPage(),
    );
    await tester.tap(find.byKey(const Key('t1')));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(ReaderPage),
      matchesGoldenFile('reader_phone.png'),
    );
  });

  testWidgets('reader tablet golden with side translation pane', (tester) async {
    await _pumpGolden(
      tester,
      size: const Size(1024, 768),
      widget: _readerPage(),
    );
    await tester.tap(find.byKey(const Key('t1')));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(ReaderPage),
      matchesGoldenFile('reader_tablet.png'),
    );
  });

  testWidgets('settings day theme golden', (tester) async {
    await _pumpGolden(
      tester,
      size: const Size(390, 844),
      widget: const PersistedSettingsPage(),
      overrides: _settingsOverrides(ReadingSettings()),
    );
    await expectLater(
      find.byType(PersistedSettingsPage),
      matchesGoldenFile('learning_themes.png'),
    );
  });

  testWidgets('settings night and eye-care theme goldens', (tester) async {
    await _pumpGolden(
      tester,
      size: const Size(390, 844),
      widget: const PersistedSettingsPage(),
      overrides: _settingsOverrides(
        ReadingSettings(theme: ReaderTheme.night),
      ),
      brightness: Brightness.dark,
      // Night surfaces must stay dark, mirroring the app's darkTheme
      // (scaffold 0xFF16191E); a light surface here produced a white
      // background with white text in the golden.
      surface: const Color(0xFF16191E),
    );
    await expectLater(
      find.byType(PersistedSettingsPage),
      matchesGoldenFile('learning_themes_night.png'),
    );

    await _pumpGolden(
      tester,
      size: const Size(390, 844),
      widget: const PersistedSettingsPage(),
      overrides: _settingsOverrides(
        ReadingSettings(theme: ReaderTheme.eyeCare),
      ),
      seedColor: const Color(0xFF6D7D47),
      surface: const Color(0xFFF5F3E8),
    );
    await expectLater(
      find.byType(PersistedSettingsPage),
      matchesGoldenFile('learning_themes_eyecare.png'),
    );
  });
}

Future<void> _loadChineseFont() async {
  final candidates = [
    'C:/Windows/Fonts/msyh.ttc',
    'C:/Windows/Fonts/simhei.ttf',
    'C:/Windows/Fonts/simsun.ttc',
  ];
  for (final path in candidates) {
    final file = File(path);
    if (!await file.exists()) continue;
    final bytes = await file.readAsBytes();
    final loader = FontLoader('GoldenCJK')
      ..addFont(Future.value(ByteData.sublistView(bytes)));
    await loader.load();
    return;
  }
}

Future<void> _pumpGolden(
  WidgetTester tester, {
  required Size size,
  required Widget widget,
  List<Override> overrides = const [],
  Brightness brightness = Brightness.light,
  Color seedColor = const Color(0xFF3D7AED),
  Color surface = const Color(0xFFFBFCFE),
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'GoldenCJK',
          colorScheme: ColorScheme.fromSeed(
            seedColor: seedColor,
            surface: surface,
            brightness: brightness,
          ),
          scaffoldBackgroundColor: surface,
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              minimumSize: const Size(48, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        home: widget,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

DocumentImportController _emptyLibraryController() => DocumentImportController(
  picker: const _NoopPicker(),
  importer: _NoopImporter(),
  repository: _EmptyRepository(),
);

Widget _readerPage() {
  final documents = _ReaderDocuments();
  final controller = ReaderController(
    documents: documents,
    translation: TranslationViewModel(
      dictionary: const _FoundDictionary(),
      learning: const _NoopLearning(),
      phraseRecognizer: PhraseRecognizer(const []),
    ),
    settings: ReadingSettings(),
    progressDelay: const Duration(days: 1),
  );
  return ProviderScope(
    overrides: [
      readingSettingsProvider.overrideWithValue(
        PersistedSettingsState(settings: ReadingSettings(), isLoading: false),
      ),
      readerCardPreferencesRepositoryProvider.overrideWithValue(
        _MemoryCardPreferences(ReaderCardPreferences.defaults),
      ),
    ],
    child: ReaderPage(documentId: 'doc-1', controller: controller),
  );
}

List<Override> _settingsOverrides(ReadingSettings settings) => [
  settingsRepositoryProvider.overrideWithValue(_FakeSettingsRepository(settings)),
  cacheCleanupServiceProvider.overrideWithValue(_NoopCacheCleanup()),
];

class _NoopPicker implements DocumentPicker {
  const _NoopPicker();

  @override
  Future<SelectedFile?> pickDocument() async => null;
}

class _NoopImporter implements DocumentImporter {
  @override
  Stream<ImportState> start(
    SelectedFile selectedFile, {
    ParseCancellationToken? cancellationToken,
  }) => const Stream.empty();

  @override
  Stream<ImportState> retry(
    String documentId,
    SelectedFile selectedFile, {
    ParseCancellationToken? cancellationToken,
  }) => const Stream.empty();
}

class _EmptyRepository implements DocumentRepository {
  final _documents = StreamController<List<DocumentSummary>>.broadcast();

  @override
  Stream<List<DocumentSummary>> watchDocuments() => _documents.stream;

  @override
  Future<void> deleteDocument(String documentId) async {}

  @override
  Future<StoredReaderDocument> loadReaderDocument(String documentId) =>
      throw UnimplementedError();

  @override
  Future<void> recoverInterruptedImports() async {}

  @override
  Future<void> saveProgress(ReadingLocator locator, double progress) async {}
}

class _ReaderDocuments implements DocumentRepository {
  final saved = <(ReadingLocator, double)>[];

  @override
  Future<void> deleteDocument(String id) async {}

  @override
  Future<StoredReaderDocument> loadReaderDocument(String id) async =>
      StoredReaderDocument(
        id: 'doc-1',
        title: 'The Scientific Method',
        readProgress: 0,
        sentences: const [
          StoredReaderSentence(
            id: 's1',
            paragraphId: 'p1',
            ordinal: 0,
            text: 'Science begins with observation.',
            startOffset: 0,
            endOffset: 31,
            tokens: [
              StoredReaderToken(
                id: 't0',
                ordinal: 0,
                surface: 'Science',
                normalized: 'science',
                lemma: 'science',
                startOffset: 0,
                endOffset: 7,
              ),
              StoredReaderToken(
                id: 't1',
                ordinal: 1,
                surface: 'begins',
                normalized: 'begins',
                lemma: 'begin',
                startOffset: 8,
                endOffset: 14,
              ),
              StoredReaderToken(
                id: 't2',
                ordinal: 2,
                surface: 'with',
                normalized: 'with',
                lemma: 'with',
                startOffset: 15,
                endOffset: 19,
              ),
              StoredReaderToken(
                id: 't3',
                ordinal: 3,
                surface: 'observation',
                normalized: 'observation',
                lemma: 'observation',
                startOffset: 20,
                endOffset: 31,
              ),
            ],
          ),
        ],
      );

  @override
  Future<void> recoverInterruptedImports() async {}

  @override
  Future<void> saveProgress(ReadingLocator locator, double progress) async =>
      saved.add((locator, progress));

  @override
  Stream<List<DocumentSummary>> watchDocuments() => const Stream.empty();
}

class _FoundDictionary implements DictionaryLookup {
  const _FoundDictionary();

  @override
  Future<DictionaryEntry?> lookup(String surface) async => DictionaryEntry(
    word: surface,
    phonetic: '/bɪˈɡɪn/',
    partOfSpeech: 'v.',
    definitionEnglish: 'to start doing something',
    definitionChinese: '开始；着手',
  );
}

class _NoopLearning implements LearningRepository {
  const _NoopLearning();

  @override
  Future<void> recordLookup({
    required String surface,
    required DictionaryEntry entry,
    required LearningContext context,
  }) async {}

  @override
  Future<void> savePhrase(SavedPhraseDraft phrase) async {}

  @override
  Stream<List<VocabularyListItem>> watchVocabulary(VocabularyQuery query) =>
      const Stream.empty();

  @override
  Stream<List<SavedPhraseListItem>> watchSavedPhrases(
    SavedPhraseQuery query,
  ) => const Stream.empty();

  @override
  Future<void> addManualVocabulary(ManualVocabularyDraft draft) async {}

  @override
  Future<void> updateProficiency(
    String lemma,
    VocabularyProficiency value,
  ) async {}

  @override
  Future<void> deleteVocabulary(String lemma) async {}

  @override
  Future<void> deleteSavedPhrase(String phraseKey) async {}
}

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this.value);

  final ReadingSettings value;

  @override
  Future<ReadingSettings> load() async => value;

  @override
  Future<void> save(ReadingSettings settings) async {}

  @override
  Stream<ReadingSettings> watch() => Stream.value(value);
}

class _NoopCacheCleanup implements CacheCleanupService {
  @override
  Future<void> clearRebuildableCaches() async {}
}

class _MemoryCardPreferences implements ReaderCardPreferencesStore {
  _MemoryCardPreferences(this.value);

  ReaderCardPreferences value;

  @override
  Future<ReaderCardPreferences> load() async => value;

  @override
  Future<void> save(ReaderCardPreferences preferences) async {
    value = preferences;
  }
}
