import 'package:dian_du_ji/app/app_runtime.dart';
import 'package:dian_du_ji/app/providers.dart';
import 'package:dian_du_ji/core/database/app_database.dart';
import 'package:dian_du_ji/features/dictionary/data/dictionary_repository.dart';
import 'package:dian_du_ji/features/dictionary/presentation/translation_view_model.dart';
import 'package:dian_du_ji/features/documents/data/drift_document_repository.dart';
import 'package:dian_du_ji/features/documents/domain/document_models.dart';
import 'package:dian_du_ji/features/learning/data/learning_repository.dart';
import 'package:dian_du_ji/features/reader/data/reader_card_preferences.dart';
import 'package:dian_du_ji/features/reader/domain/reading_locator.dart';
import 'package:dian_du_ji/features/reader/presentation/reader_controller.dart';
import 'package:dian_du_ji/features/reader/presentation/reader_page.dart';
import 'package:dian_du_ji/features/settings/data/reading_settings.dart';
import 'package:dian_du_ji/features/settings/presentation/persisted_settings_controller.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

/// Device flow for the scientific translation enhancement: the bundled
/// four-domain dictionary must be loaded by the real runtime, and tapping a
/// multi-word term inside a sentence must surface the specialized gloss with
/// its domain tag on the reader card.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('specialized term surfaces on the reader card', (tester) async {
    final supportDirectory = await getApplicationSupportDirectory();
    final runId = DateTime.now().microsecondsSinceEpoch;
    final runtime = await initializeAppRuntime(
      databaseFactory: () => AppDatabase(
        driftDatabase(name: 'dianduji_sci_flow_$runId'),
      ),
      supportDirectoryProvider: () async => supportDirectory,
    );
    addTearDown(runtime.close);
    expect(runtime.specializedIndex, isNotNull);

    final controller = ReaderController(
      documents: _ScientificDocuments(),
      translation: TranslationViewModel(
        dictionary: runtime.dictionary,
        learning: const _NoopLearning(),
        phraseRecognizer: runtime.phraseRecognizer,
        specializedIndex: runtime.specializedIndex,
      ),
      settings: ReadingSettings(),
      progressDelay: Duration.zero,
    );
    await controller.open('doc-1');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          readingSettingsProvider.overrideWithValue(
            PersistedSettingsState(
              settings: ReadingSettings(),
              isLoading: false,
            ),
          ),
          readerCardPreferencesRepositoryProvider.overrideWithValue(
            _MemoryCardPreferences(ReaderCardPreferences.defaults),
          ),
        ],
        child: MaterialApp(
          home: ReaderPage(documentId: 'doc-1', controller: controller),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('s0-t1')));
    await tester.pumpAndSettle();

    expect(find.text('专业释义'), findsOneWidget);
    expect(find.text('随机森林'), findsOneWidget);
    expect(find.text('计算机'), findsOneWidget); // domain label
    // The tapped word plus the recognized term are both present.
    expect(find.text('random forest'), findsWidgets);
  });
}

class _ScientificDocuments implements DocumentRepository {
  @override
  Future<void> deleteDocument(String id) async {}

  @override
  Future<StoredReaderDocument> loadReaderDocument(String id) async {
    const sentenceText = 'A random forest classifies the samples robustly.';
    const tokens = [
      StoredReaderToken(
        id: 's0-t0',
        ordinal: 0,
        surface: 'A',
        normalized: 'a',
        lemma: 'a',
        startOffset: 0,
        endOffset: 1,
      ),
      StoredReaderToken(
        id: 's0-t1',
        ordinal: 1,
        surface: 'random',
        normalized: 'random',
        lemma: 'random',
        startOffset: 2,
        endOffset: 8,
      ),
      StoredReaderToken(
        id: 's0-t2',
        ordinal: 2,
        surface: 'forest',
        normalized: 'forest',
        lemma: 'forest',
        startOffset: 9,
        endOffset: 15,
      ),
      StoredReaderToken(
        id: 's0-t3',
        ordinal: 3,
        surface: 'classifies',
        normalized: 'classifies',
        lemma: 'classify',
        startOffset: 16,
        endOffset: 26,
      ),
    ];
    return const StoredReaderDocument(
      id: 'doc-1',
      title: 'Scientific Sample',
      readProgress: 0,
      sentences: [
        StoredReaderSentence(
          id: 's0',
          paragraphId: 'p0',
          ordinal: 0,
          text: sentenceText,
          startOffset: 0,
          endOffset: 26,
          tokens: tokens,
        ),
      ],
    );  }

  @override
  Future<void> recoverInterruptedImports() async {}

  @override
  Future<void> saveProgress(ReadingLocator locator, double progress) async {}

  @override
  Stream<List<DocumentSummary>> watchDocuments() => const Stream.empty();
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
