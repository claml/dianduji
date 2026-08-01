import '../../../core/database/app_database.dart';
import '../../reader/domain/reading_locator.dart';
import '../../reader/presentation/reader_view_model.dart';
import '../domain/document_models.dart';
import '../domain/models/parsed_block.dart';

abstract interface class DocumentRepository {
  Stream<List<DocumentSummary>> watchDocuments();
  Future<StoredReaderDocument> loadReaderDocument(String documentId);
  Future<void> deleteDocument(String documentId);
  Future<void> recoverInterruptedImports();
  Future<void> saveProgress(ReadingLocator locator, double progress);
}

class DriftDocumentRepository
    implements DocumentRepository, ReadingProgressStore {
  const DriftDocumentRepository(this.database);

  final AppDatabase database;

  @override
  Stream<List<DocumentSummary>> watchDocuments() {
    return database.documentsDao.watchAllDocuments().map(
      (documents) => documents
          .map(
            (document) => DocumentSummary(
              id: document.id,
              title: document.title,
              sourceName: document.sourceName,
              localPath: document.localPath,
              format: document.format,
              status: document.parseStatus,
              progress: document.parseProgress,
              wordCount: document.wordCount,
              readProgress: document.readProgress,
              failureCode: document.failureCode,
              failureMessage: document.failureMessage,
              importedAt: document.createdAt,
              lastOpenedAt: document.updatedAt,
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  Future<StoredReaderDocument> loadReaderDocument(String documentId) async {
    final document = await database.documentsDao.findDocument(documentId);
    if (document == null) {
      throw StateError('Document not found: $documentId');
    }
    final paragraphs = await database.documentsDao.loadParagraphs(documentId);
    final sentences = await database.documentsDao.loadSentences(documentId);
    final tokens = await database.documentsDao.loadTokens(documentId);
    final tokensBySentence = <String, List<Token>>{};
    for (final token in tokens) {
      tokensBySentence.putIfAbsent(token.sentenceId, () => []).add(token);
    }
    final lastLocator = document.lastReadLocator == null
        ? null
        : ReadingLocator.decode(document.lastReadLocator!);
    final storedSentences = sentences
        .map(
          (sentence) => StoredReaderSentence(
            id: sentence.id,
            paragraphId: sentence.paragraphId,
            ordinal: sentence.ordinal,
            text: sentence.body,
            startOffset: sentence.startOffset,
            endOffset: sentence.endOffset,
            tokens: (tokensBySentence[sentence.id] ?? const [])
                .map(
                  (token) => StoredReaderToken(
                    id: token.id,
                    ordinal: token.ordinal,
                    surface: token.surface,
                    normalized: token.normalized,
                    lemma: token.lemma,
                    startOffset: token.startOffset,
                    endOffset: token.endOffset,
                  ),
                )
                .toList(growable: false),
          ),
        )
        .toList(growable: false);
    final sentencesByParagraph = <String, List<StoredReaderSentence>>{};
    for (final sentence in storedSentences) {
      sentencesByParagraph
          .putIfAbsent(sentence.paragraphId, () => [])
          .add(sentence);
    }
    return StoredReaderDocument(
      id: document.id,
      title: document.title,
      format: document.format,
      localPath: document.localPath,
      readProgress: document.readProgress,
      lastLocator: lastLocator,
      sentences: storedSentences,
      blocks: paragraphs
          .map(
            (paragraph) => StoredReaderBlock(
              id: paragraph.id,
              ordinal: paragraph.ordinal,
              text: paragraph.body,
              style: ParsedBlockStyle.values.firstWhere(
                (style) => style.name == paragraph.style,
                orElse: () => ParsedBlockStyle.body,
              ),
              sentences: sentencesByParagraph[paragraph.id] ?? const [],
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  Future<void> deleteDocument(String documentId) {
    return database.documentsDao.deleteDocument(documentId);
  }

  @override
  Future<void> recoverInterruptedImports() {
    return database.documentsDao.recoverInterruptedImports(
      failureCode: 'storage',
      failureMessage: 'Import interrupted locally. Retry to continue.',
    );
  }

  @override
  Future<void> save(ReadingLocator locator, double progress) {
    return saveProgress(locator, progress);
  }

  @override
  Future<void> saveProgress(ReadingLocator locator, double progress) {
    return database.documentsDao.saveReadingProgress(
      documentId: locator.documentId,
      encodedLocator: locator.encode(),
      progress: progress.clamp(0, 1),
    );
  }
}
