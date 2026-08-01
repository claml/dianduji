import 'package:dian_du_ji/core/database/app_database.dart';
import 'package:dian_du_ji/core/errors/app_failure.dart';
import 'package:dian_du_ji/features/dictionary/data/dictionary_repository.dart';
import 'package:dian_du_ji/features/documents/data/drift_document_import_store.dart';
import 'package:dian_du_ji/features/documents/data/drift_document_repository.dart';
import 'package:dian_du_ji/features/documents/domain/document_structure_builder.dart';
import 'package:dian_du_ji/features/documents/domain/file_format.dart';
import 'package:dian_du_ji/features/documents/domain/import_document_use_case.dart';
import 'package:dian_du_ji/features/documents/domain/models/parsed_block.dart';
import 'package:dian_du_ji/features/documents/data/services/file_intake_service.dart';
import 'package:dian_du_ji/features/phrases/domain/phrase_recognizer.dart';
import 'package:dian_du_ji/features/reader/domain/reading_locator.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftDocumentImportStore importStore;
  late DriftDocumentRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    final builder = DocumentStructureBuilder(
      dictionary: const _Dictionary(),
      phraseRecognizer: PhraseRecognizer(const []),
    );
    importStore = DriftDocumentImportStore(
      database: database,
      builder: builder,
    );
    repository = DriftDocumentRepository(database);
  });

  tearDown(() => database.close());

  test(
    'persists queued parsing completed and atomically replaces structure',
    () async {
      await importStore.createQueued(_record());
      await importStore.markParsing('doc-1');
      await importStore.replaceStructure('doc-1', const [
        ParsedBlock(text: 'First sentence. Second sentence.'),
        ParsedBlock(text: 'Third sentence.'),
      ]);
      await importStore.markCompleted('doc-1');

      final summary = await repository.watchDocuments().first;
      final reader = await repository.loadReaderDocument('doc-1');

      expect(summary.single.status, 'completed');
      expect(summary.single.wordCount, 6);
      expect(
        reader.sentences.map((item) => item.ordinal),
        orderedEquals([0, 1, 2]),
      );
      expect(reader.sentences.map((item) => item.text), [
        'First sentence.',
        'Second sentence.',
        'Third sentence.',
      ]);
      expect(await database.documentsDao.countStructureFor('doc-1'), 11);

      await importStore.replaceStructure('doc-1', const [
        ParsedBlock(text: 'Replacement only.'),
      ]);

      expect(await database.documentsDao.countStructureFor('doc-1'), 4);
      expect(
        (await repository.loadReaderDocument('doc-1')).sentences.single.text,
        'Replacement only.',
      );
    },
  );

  test('loads reader blocks without losing document structure', () async {
    await importStore.createQueued(_record());
    await importStore.markParsing('doc-1');
    await importStore.replaceStructure('doc-1', const [
      ParsedBlock(text: 'Foundation Models', style: ParsedBlockStyle.heading),
      ParsedBlock(
        text: 'First finding. Second finding.',
        style: ParsedBlockStyle.listItem,
      ),
    ]);
    await importStore.markCompleted('doc-1');

    final reader = await repository.loadReaderDocument('doc-1');

    expect(reader.format, 'txt');
    expect(reader.localPath, 'sandbox/source.txt');
    expect(reader.blocks, hasLength(2));
    expect(reader.blocks.first.ordinal, 0);
    expect(reader.blocks.first.style, ParsedBlockStyle.heading);
    expect(reader.blocks.first.text, 'Foundation Models');
    expect(reader.blocks.first.sentences.map((sentence) => sentence.text), [
      'Foundation Models',
    ]);
    expect(reader.blocks.last.ordinal, 1);
    expect(reader.blocks.last.style, ParsedBlockStyle.listItem);
    expect(reader.blocks.last.sentences.map((sentence) => sentence.text), [
      'First finding.',
      'Second finding.',
    ]);
    expect(reader.sentences.map((sentence) => sentence.text), [
      'Foundation Models',
      'First finding.',
      'Second finding.',
    ]);
  });

  test(
    'finds duplicate content, retries with the same id, and cleans failures',
    () async {
      await importStore.createQueued(_record());
      expect(await importStore.findByContentHash('content-hash'), 'doc-1');

      await importStore.markParsing('doc-1');
      await importStore.replaceStructure('doc-1', const [
        ParsedBlock(text: 'Partial.'),
      ]);
      await importStore.clearStructure('doc-1');
      await importStore.markFailed(
        'doc-1',
        const AppFailure(AppFailureCode.unknownEncoding, 'Unreadable file.'),
      );
      await importStore.markParsing('doc-1');
      await importStore.replaceStructure('doc-1', const [
        ParsedBlock(text: 'Retry works.'),
      ]);
      await importStore.markCompleted('doc-1');

      final summary = (await repository.watchDocuments().first).single;
      expect(summary.id, 'doc-1');
      expect(summary.status, 'completed');
      expect(summary.failureCode, isNull);
      expect(summary.failureMessage, isNull);
      expect(
        (await repository.loadReaderDocument('doc-1')).sentences.single.text,
        'Retry works.',
      );
    },
  );

  test(
    'recovers interrupted parsing while retaining the sandbox document row',
    () async {
      await importStore.createQueued(_record());
      await importStore.markParsing('doc-1');
      await importStore.replaceStructure('doc-1', const [
        ParsedBlock(text: 'Partially persisted sentence.'),
      ]);
      expect(await database.documentsDao.countStructureFor('doc-1'), 5);

      await repository.recoverInterruptedImports();

      final summary = (await repository.watchDocuments().first).single;
      expect(summary.status, 'failed');
      expect(summary.failureCode, 'storage');
      expect(
        summary.failureMessage,
        'Import interrupted locally. Retry to continue.',
      );
      expect(await importStore.findByContentHash('content-hash'), 'doc-1');
      expect(await database.documentsDao.countStructureFor('doc-1'), 0);
    },
  );

  test(
    'saves progress and deleting a document retains learning assets',
    () async {
      await importStore.createQueued(_record());
      await importStore.markParsing('doc-1');
      await importStore.replaceStructure('doc-1', const [
        ParsedBlock(text: 'Read this.'),
      ]);
      await importStore.markCompleted('doc-1');
      await database.learningDao.recordLookup(
        const LookupRecord(
          surface: 'read',
          lemma: 'read',
          phonetic: '',
          partOfSpeech: '',
          definition: '',
        ),
      );
      await database.learningDao.savePhrase(
        SavedPhraseRecord(
          id: 'saved-1',
          phraseKey: 'read-this',
          surface: 'read this',
          type: 'collocation',
          meaning: 'read this',
          contextSentence: 'Read this.',
          sourceDocumentId: 'doc-1',
          sourceDocumentTitle: 'Source',
          createdAt: DateTime.utc(2026, 7, 29),
        ),
      );
      const locator = ReadingLocator(
        documentId: 'doc-1',
        paragraphId: 'doc-1-paragraph-0',
        sentenceId: 'doc-1-sentence-0',
        localOffset: 2,
      );

      await repository.saveProgress(locator, 0.6);
      final saved = await repository.loadReaderDocument('doc-1');
      expect(saved.readProgress, 0.6);
      expect(saved.lastLocator, locator);

      await repository.deleteDocument('doc-1');

      expect(await database.documentsDao.countDocuments(), 0);
      expect(await database.learningDao.countVocabulary(), 1);
      expect(await database.learningDao.countSavedPhrases(), 1);
    },
  );
}

ImportDocumentRecord _record() => ImportDocumentRecord(
  id: 'doc-1',
  title: 'Source',
  format: FileFormat.txt,
  intake: const IntakeFile(
    originalName: 'source.txt',
    localPath: 'sandbox/source.txt',
    sha256: 'content-hash',
    byteSize: 42,
    wasDuplicate: false,
  ),
);

class _Dictionary implements DictionaryLookup {
  const _Dictionary();

  @override
  Future<DictionaryEntry?> lookup(String surface) async => null;
}
