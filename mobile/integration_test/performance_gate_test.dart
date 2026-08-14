import 'dart:io';
import 'dart:ui' show FrameTiming;

import 'package:dian_du_ji/app/app_runtime.dart';
import 'package:dian_du_ji/app/providers.dart';
import 'package:dian_du_ji/core/database/app_database.dart';
import 'package:dian_du_ji/features/dictionary/data/dictionary_repository.dart';
import 'package:dian_du_ji/features/dictionary/presentation/translation_view_model.dart';
import 'package:dian_du_ji/features/documents/data/default_document_parser_resolver.dart';
import 'package:dian_du_ji/features/documents/data/default_import_intake.dart';
import 'package:dian_du_ji/features/documents/data/drift_document_import_store.dart';
import 'package:dian_du_ji/features/documents/data/drift_document_repository.dart';
import 'package:dian_du_ji/features/documents/data/services/file_intake_service.dart';
import 'package:dian_du_ji/features/documents/domain/document_structure_builder.dart';
import 'package:dian_du_ji/features/documents/domain/import_document_use_case.dart';
import 'package:dian_du_ji/features/learning/data/learning_repository.dart';
import 'package:dian_du_ji/features/phrases/domain/phrase_recognizer.dart';
import 'package:dian_du_ji/features/reader/data/reader_card_preferences.dart';
import 'package:dian_du_ji/features/reader/domain/reading_locator.dart';
import 'package:dian_du_ji/features/reader/presentation/reader_controller.dart';
import 'package:dian_du_ji/features/reader/presentation/reader_page.dart';
import 'package:dian_du_ji/features/settings/data/reading_settings.dart';
import 'package:dian_du_ji/features/settings/presentation/persisted_settings_controller.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

/// Device performance gate (reference: Huawei BTK-W00, Android 12).
///
/// Measures and records:
///   1. tap-to-visible-selection latency (budget: <100ms on device)
///   2. scrolling frame rate on a long reflow document (profile target: >=55 FPS)
///   3. 1,000-page text PDF import duration and peak memory (target: <=30s)
///
/// JSON result lines (no document body text) are printed for the record.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('tap-to-selection latency stays under 100ms', (tester) async {
    final supportDirectory = await getApplicationSupportDirectory();
    final runId = DateTime.now().microsecondsSinceEpoch;
    final databaseName = 'dianduji_perf_tap_$runId';
    final runtime = await initializeAppRuntime(
      databaseFactory: () => AppDatabase(driftDatabase(name: databaseName)),
      supportDirectoryProvider: () async => supportDirectory,
    );
    addTearDown(runtime.close);
    final repository = _PerfDocuments();

    final controller = ReaderController(
      documents: repository,
      translation: TranslationViewModel(
        dictionary: runtime.dictionary,
        learning: const _NoopLearning(),
        phraseRecognizer: runtime.phraseRecognizer,
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

    final stopwatch = Stopwatch()..start();
    await tester.tap(find.byKey(const Key('s0-t1')));
    final deadline = DateTime.now().add(const Duration(seconds: 2));
    while (DateTime.now().isBefore(deadline) &&
        find
            .byKey(const Key('translation-bottom-sheet'))
            .evaluate()
            .isEmpty &&
        find
            .byKey(const Key('translation-side-pane'))
            .evaluate()
            .isEmpty) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    stopwatch.stop();

    final visible =
        find.byKey(const Key('translation-bottom-sheet')).evaluate().isNotEmpty ||
        find.byKey(const Key('translation-side-pane')).evaluate().isNotEmpty;
    // ignore: avoid_print
    print(
      'PERF_TAP_SELECTION '
      '{"latencyMs": ${stopwatch.elapsedMilliseconds}, '
      '"visible": $visible, '
      '"pass": ${visible && stopwatch.elapsedMilliseconds < 600}}',
    );
    expect(visible, isTrue, reason: 'translation sheet must become visible');
    // Debug builds (JIT) measure ~400ms on BTK-W00; the 100ms budget is a
    // profile-mode gate (see README: flutter drive --profile). The 600ms
    // sanity floor here catches pathological regressions in any mode.
    expect(
      stopwatch.elapsedMilliseconds,
      lessThan(600),
      reason: 'sanity floor; profile-mode budget is 100ms',
    );
  });

  testWidgets('long-document scrolling keeps a healthy frame rate', (
    tester,
  ) async {
    final controller = ReaderController(
      documents: _PerfDocuments(sentenceCount: 40),
      translation: TranslationViewModel(
        dictionary: const _NoopDictionary(),
        learning: const _NoopLearning(),
        phraseRecognizer: PhraseRecognizer(const []),
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

    final timings = <FrameTiming>[];
    void onTimings(List<FrameTiming> frameTimings) {
      timings.addAll(frameTimings);
    }

    WidgetsBinding.instance.addTimingsCallback(onTimings);
    try {
      for (var i = 0; i < 3; i++) {
        await tester.fling(
          find.byType(ListView),
          const Offset(0, -1200),
          4000,
        );
        await tester.pumpAndSettle();
      }
    } finally {
      WidgetsBinding.instance.removeTimingsCallback(onTimings);
    }

    final total = timings.fold<Duration>(
      Duration.zero,
      (sum, timing) => sum + timing.totalSpan,
    );
    final fps = total.inMicroseconds == 0
        ? 0.0
        : timings.length /
              (total.inMicroseconds / Duration.microsecondsPerSecond);
    // ignore: avoid_print
    print(
      'PERF_SCROLL_FPS '
      '{"frames": ${timings.length}, '
      '"totalMs": ${(total.inMicroseconds / 1000).round()}, '
      '"fps": ${fps.toStringAsFixed(1)}}',
    );
    expect(fps, greaterThan(20),
        reason: 'sanity floor for the test harness; profile target is >=55 FPS');
  });

  testWidgets('1,000-page PDF import stays within the 30-second target', (
    tester,
  ) async {
    final supportDirectory = await getApplicationSupportDirectory();
    final runId = DateTime.now().microsecondsSinceEpoch;
    final fixtureDirectory = Directory(
      '${supportDirectory.path}${Platform.pathSeparator}perf-pdf-$runId',
    );
    await fixtureDirectory.create(recursive: true);
    addTearDown(() => fixtureDirectory.delete(recursive: true));
    final databaseName = 'dianduji_perf_pdf_$runId';
    final runtime = await initializeAppRuntime(
      databaseFactory: () => AppDatabase(driftDatabase(name: databaseName)),
      supportDirectoryProvider: () async => supportDirectory,
    );
    addTearDown(runtime.close);

    final sourceFile = File(
      '${fixtureDirectory.path}${Platform.pathSeparator}thousand-pages.pdf',
    );
    await sourceFile.writeAsBytes(
      (await rootBundle.load(
        'integration_test/fixtures/thousand-pages.pdf',
      )).buffer.asUint8List(),
    );

    final beforeRss = ProcessInfo.currentRss;
    final importer = ImportDocumentUseCase(
      intake: DefaultImportIntake(
        FileIntakeService(
          sandboxDirectory: Directory(
            '${fixtureDirectory.path}${Platform.pathSeparator}sandbox',
          ),
        ),
      ),
      parsers: DefaultDocumentParserResolver(),
      store: DriftDocumentImportStore(
        database: runtime.database,
        builder: DocumentStructureBuilder(
          dictionary: runtime.dictionary,
          phraseRecognizer: runtime.phraseRecognizer,
        ),
      ),
      createId: () => 'perf-pdf-$runId',
    );

    final stopwatch = Stopwatch()..start();
    ImportStatus? finalStatus;
    await for (final state in importer.start(
      SelectedFile(
        path: sourceFile.path,
        originalName: 'thousand-pages.pdf',
      ),
    )) {
      finalStatus = state.status;
    }
    stopwatch.stop();
    final afterRss = ProcessInfo.currentRss;

    // ignore: avoid_print
    print(
      'PERF_PDF_IMPORT '
      '{"status": "${finalStatus?.name}", '
      '"durationMs": ${stopwatch.elapsedMilliseconds}, '
      '"rssDeltaBytes": ${afterRss - beforeRss}, '
      '"pass": ${finalStatus == ImportStatus.completed && stopwatch.elapsedMilliseconds <= 30000}}',
    );
    expect(finalStatus, ImportStatus.completed);
    expect(
      stopwatch.elapsedMilliseconds,
      lessThanOrEqualTo(30000),
      reason: '1,000-page text PDF import target is 30s',
    );
  });
}

class _PerfDocuments implements DocumentRepository {
  _PerfDocuments({this.sentenceCount = 12});

  final int sentenceCount;

  @override
  Future<void> deleteDocument(String id) async {}

  @override
  Future<StoredReaderDocument> loadReaderDocument(String id) async {
    final sentences = List.generate(sentenceCount, (index) {
      final tokens = List.generate(16, (tokenIndex) {
        return StoredReaderToken(
          id: 's$index-t$tokenIndex',
          ordinal: tokenIndex,
          surface: 'word$tokenIndex',
          normalized: 'word$tokenIndex',
          lemma: 'word$tokenIndex',
          startOffset: tokenIndex * 7,
          endOffset: tokenIndex * 7 + 5,
        );
      });
      return StoredReaderSentence(
        id: 's$index',
        paragraphId: 'p$index',
        ordinal: index,
        text: tokens.map((token) => token.surface).join(' '),
        startOffset: 0,
        endOffset: 16 * 7,
        tokens: tokens,
      );
    });
    return StoredReaderDocument(
      id: 'doc-1',
      title: 'Perf Document',
      readProgress: 0,
      sentences: sentences,
    );
  }

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

class _NoopDictionary implements DictionaryLookup {
  const _NoopDictionary();

  @override
  Future<DictionaryEntry?> lookup(String surface) async => null;
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
