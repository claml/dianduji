import 'dart:io';

import 'package:dian_du_ji/app/app_runtime.dart';
import 'package:dian_du_ji/core/database/app_database.dart';
import 'package:dian_du_ji/features/dictionary/presentation/translation_view_model.dart';
import 'package:dian_du_ji/features/documents/data/default_document_parser_resolver.dart';
import 'package:dian_du_ji/features/documents/data/default_import_intake.dart';
import 'package:dian_du_ji/features/documents/data/drift_document_import_store.dart';
import 'package:dian_du_ji/features/documents/data/drift_document_repository.dart';
import 'package:dian_du_ji/features/documents/data/services/file_intake_service.dart';
import 'package:dian_du_ji/features/documents/domain/document_structure_builder.dart';
import 'package:dian_du_ji/features/documents/domain/import_document_use_case.dart';
import 'package:dian_du_ji/features/learning/data/drift_learning_repository.dart';
import 'package:dian_du_ji/features/learning/data/learning_repository.dart';
import 'package:dian_du_ji/features/phrases/domain/phrase_type.dart';
import 'package:dian_du_ji/features/reader/presentation/reader_controller.dart';
import 'package:dian_du_ji/features/settings/data/reading_settings.dart';
import 'package:dian_du_ji/features/settings/data/settings_repository.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

/// Full Android learning-flow gate on the reference tablet:
///
/// import a real TXT -> read and tap a known word -> exactly one vocabulary
/// record -> save a covering phrase -> persist reading position and settings
/// -> restart the runtime -> verify document, locator, vocabulary, phrase,
/// and settings survive -> delete the source document -> verify learning
/// assets remain and are labelled as source-deleted.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('core learning flow survives restart and source deletion', (
    tester,
  ) async {
    final supportDirectory = await getApplicationSupportDirectory();
    final runId = DateTime.now().microsecondsSinceEpoch;
    final fixtureDirectory = Directory(
      '${supportDirectory.path}${Platform.pathSeparator}learning-flow-$runId',
    );
    await fixtureDirectory.create(recursive: true);
    addTearDown(() => fixtureDirectory.delete(recursive: true));
    final databaseName = 'dianduji_learning_flow_$runId';
    AppDatabase databaseFactory() =>
        AppDatabase(driftDatabase(name: databaseName));

    // ---- First runtime: import, read, tap, save ----
    final runtime = await initializeAppRuntime(
      databaseFactory: databaseFactory,
      supportDirectoryProvider: () async => supportDirectory,
    );
    addTearDown(runtime.close);
    final repository = DriftDocumentRepository(runtime.database);
    final learning = DriftLearningRepository(runtime.database.learningDao);
    final settingsRepository = DriftSettingsRepository(
      runtime.database.settingsDao,
    );

    String? documentId;
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
      createId: () => documentId ??= 'flow-$runId',
    );

    final sourceFile = File(
      '${fixtureDirectory.path}${Platform.pathSeparator}sample_utf8.txt',
    );
    await sourceFile.writeAsBytes(
      (await rootBundle.load(
        'integration_test/fixtures/sample_utf8.txt',
      )).buffer.asUint8List(),
    );

    ImportStatus? importStatus;
    await for (final state in importer.start(
      SelectedFile(path: sourceFile.path, originalName: 'sample_utf8.txt'),
    )) {
      importStatus = state.status;
    }
    expect(importStatus, ImportStatus.completed);

    final reader = ReaderController(
      documents: repository,
      translation: TranslationViewModel(
        dictionary: runtime.dictionary,
        learning: learning,
        phraseRecognizer: runtime.phraseRecognizer,
      ),
      settings: ReadingSettings(),
      progressDelay: Duration.zero,
    );
    await reader.open(documentId!);
    final sentence = reader.state.sentences.firstWhere(
      (candidate) => candidate.text.contains('Hello'),
    );
    final helloToken = sentence.tokens.firstWhere(
      (token) => token.normalized == 'hello',
    );

    await reader.selectToken(
      sentenceId: sentence.id,
      tokenId: helloToken.id,
    );
    final helloRecord = await _waitForHelloLookup(learning);

    expect(reader.state.selectedTokenId, helloToken.id);
    expect(reader.state.selection?.surface, 'Hello');
    expect(helloRecord.lookupCount, 1);
    expect(helloRecord.definition, isNotEmpty);

    await learning.savePhrase(
      SavedPhraseDraft(
        key: 'hello-from-$runId',
        surface: 'Hello from',
        type: PhraseType.collocation,
        meaning: '来自……的问候',
        contextSentence: sentence.text,
        context: LearningContext(
          documentId: documentId,
          documentTitle: 'sample_utf8',
          sentence: sentence.text,
        ),
      ),
    );

    reader.updateReadingPosition(
      sentenceId: sentence.id,
      localOffset: 5,
      progress: 0.5,
    );
    await reader.forceSave();
    await settingsRepository.save(
      ReadingSettings(theme: ReaderTheme.night, fontSize: 18),
    );
    reader.dispose();

    // ---- Restart: everything must survive ----
    await runtime.close();
    final restarted = await initializeAppRuntime(
      databaseFactory: databaseFactory,
      supportDirectoryProvider: () async => supportDirectory,
    );
    addTearDown(restarted.close);
    final restartedRepository = DriftDocumentRepository(restarted.database);
    final restartedLearning = DriftLearningRepository(
      restarted.database.learningDao,
    );
    final restartedSettings = DriftSettingsRepository(
      restarted.database.settingsDao,
    );

    final restored = await restartedRepository.loadReaderDocument(documentId!);
    expect(restored.sentences, isNotEmpty);
    expect(restored.lastLocator?.sentenceId, sentence.id);
    expect(restored.lastLocator?.localOffset, 5);
    expect(
      restored.sentences.map((item) => item.text).join('\n'),
      contains('Hello from UTF-8.'),
    );

    final restoredVocabulary = await restartedLearning
        .watchVocabulary(const VocabularyQuery())
        .first;
    expect(
      restoredVocabulary.where((item) => item.lemma == 'hello'),
      hasLength(1),
    );
    final restoredPhrases = await restartedLearning
        .watchSavedPhrases(const SavedPhraseQuery())
        .first;
    expect(
      restoredPhrases.where((item) => item.surface == 'Hello from'),
      hasLength(1),
    );
    final restoredSettings = await restartedSettings.load();
    expect(restoredSettings.theme, ReaderTheme.night);
    expect(restoredSettings.fontSize, 18);

    // ---- Delete the source: learning assets remain, labelled deleted ----
    await restartedRepository.deleteDocument(documentId!);
    final keptVocabulary = await restartedLearning
        .watchVocabulary(const VocabularyQuery())
        .first;
    final keptHello = keptVocabulary
        .where((item) => item.lemma == 'hello')
        .single;
    expect(keptHello.sourceAvailability, SourceAvailability.deleted);
    final keptPhrase = (await restartedLearning
            .watchSavedPhrases(const SavedPhraseQuery())
            .first)
        .where((item) => item.surface == 'Hello from')
        .single;
    expect(keptPhrase.sourceAvailability, SourceAvailability.deleted);
  });
}

Future<VocabularyListItem> _waitForHelloLookup(
  LearningRepository learning,
) async {
  final deadline = DateTime.now().add(const Duration(seconds: 15));
  while (DateTime.now().isBefore(deadline)) {
    final items = await learning.watchVocabulary(const VocabularyQuery()).first;
    final matches = items.where((item) => item.lemma == 'hello').toList();
    if (matches.isNotEmpty) return matches.single;
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  fail('hello lookup record never appeared in the learning repository');
}
