import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_failure.dart';
import '../domain/document_structure_builder.dart';
import '../domain/import_document_use_case.dart';
import '../domain/models/parsed_block.dart';

class DriftDocumentImportStore implements DocumentImportStore {
  const DriftDocumentImportStore({
    required this.database,
    required this.builder,
  });

  final AppDatabase database;
  final DocumentStructureBuilder builder;

  @override
  Future<String?> findByContentHash(String hash) async {
    return (await database.documentsDao.findByContentHash(hash))?.id;
  }

  @override
  Future<void> createQueued(ImportDocumentRecord record) {
    final now = DateTime.now();
    return database.documentsDao.insertQueued(
      DocumentsCompanion.insert(
        id: record.id,
        title: record.title,
        format: record.format.name,
        sourceName: record.intake.originalName,
        localPath: record.intake.localPath,
        contentHash: record.intake.sha256,
        fileSize: record.intake.byteSize,
        parseStatus: 'queued',
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  @override
  Future<void> markParsing(String documentId) {
    return database.documentsDao.updateImportStatus(
      documentId,
      status: 'parsing',
      progress: 0,
      clearFailure: true,
    );
  }

  @override
  Future<void> replaceStructure(
    String documentId,
    List<ParsedBlock> parsedBlocks,
  ) async {
    final structure = await builder.build(
      documentId: documentId,
      blocks: parsedBlocks,
    );
    await database.documentsDao.replaceStructure(
      documentId: documentId,
      paragraphRows: structure.paragraphs
          .map(
            (row) => ParagraphsCompanion.insert(
              id: row.id,
              documentId: row.documentId,
              ordinal: row.ordinal,
              body: row.text,
              style: Value(row.style),
            ),
          )
          .toList(growable: false),
      sentenceRows: structure.sentences
          .map(
            (row) => SentencesCompanion.insert(
              id: row.id,
              documentId: row.documentId,
              paragraphId: row.paragraphId,
              ordinal: row.ordinal,
              body: row.text,
              startOffset: row.startOffset,
              endOffset: row.endOffset,
            ),
          )
          .toList(growable: false),
      tokenRows: structure.tokens
          .map(
            (row) => TokensCompanion.insert(
              id: row.id,
              documentId: row.documentId,
              sentenceId: row.sentenceId,
              ordinal: row.ordinal,
              surface: row.surface,
              normalized: row.normalized,
              lemma: row.lemma,
              partOfSpeech: Value(row.partOfSpeech),
              startOffset: row.startOffset,
              endOffset: row.endOffset,
            ),
          )
          .toList(growable: false),
      phraseRows: structure.phraseOccurrences
          .map(
            (row) => PhraseOccurrencesCompanion.insert(
              id: row.id,
              documentId: row.documentId,
              sentenceId: row.sentenceId,
              phraseKey: row.phraseKey,
              surface: row.surface,
              type: row.type,
              meaning: row.meaning,
              confidence: row.confidence,
              startTokenOrdinal: row.startTokenOrdinal,
              endTokenOrdinal: row.endTokenOrdinal,
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  Future<void> markCompleted(String documentId) {
    return database.documentsDao.updateImportStatus(
      documentId,
      status: 'completed',
      progress: 1,
      clearFailure: true,
    );
  }

  @override
  Future<void> markFailed(String documentId, AppFailure failure) {
    return database.documentsDao.updateImportStatus(
      documentId,
      status: 'failed',
      failureCode: failure.code.name,
      failureMessage: failure.message,
    );
  }

  @override
  Future<void> markCancelled(String documentId) {
    return database.documentsDao.updateImportStatus(
      documentId,
      status: 'cancelled',
    );
  }

  @override
  Future<void> clearStructure(String documentId) {
    return database.documentsDao.clearStructure(documentId);
  }
}
