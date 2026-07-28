import 'dart:typed_data';

import '../../../core/errors/app_failure.dart';
import '../../../core/platform/pdf_text_extractor.dart';
import '../data/services/file_intake_service.dart';
import 'file_format.dart';
import 'models/parsed_block.dart';
import 'parsers/document_parser.dart';

enum ImportStatus { queued, parsing, completed, failed, cancelled, duplicate }

class ImportState {
  const ImportState({
    required this.documentId,
    required this.status,
    this.progress = 0,
    this.failure,
  });

  final String documentId;
  final ImportStatus status;
  final double progress;
  final AppFailure? failure;
}

class PreparedImportFile {
  const PreparedImportFile({
    required this.intake,
    required this.format,
    required this.bytes,
  });

  final IntakeFile intake;
  final FileFormat format;
  final Uint8List bytes;
}

class ImportDocumentRecord {
  const ImportDocumentRecord({
    required this.id,
    required this.title,
    required this.format,
    required this.intake,
  });

  final String id;
  final String title;
  final FileFormat format;
  final IntakeFile intake;
}

abstract interface class ImportIntake {
  Future<PreparedImportFile> prepare(SelectedFile selectedFile);
}

abstract interface class DocumentParserResolver {
  DocumentParser forFormat(FileFormat format);
}

abstract interface class DocumentImportStore {
  Future<String?> findByContentHash(String hash);

  Future<void> createQueued(ImportDocumentRecord record);

  Future<void> markParsing(String documentId);

  Future<void> replaceStructure(
    String documentId,
    List<ParsedBlock> parsedBlocks,
  );

  Future<void> markCompleted(String documentId);

  Future<void> markFailed(String documentId, AppFailure failure);

  Future<void> markCancelled(String documentId);

  Future<void> clearStructure(String documentId);
}

class ImportDocumentUseCase {
  const ImportDocumentUseCase({
    required this.intake,
    required this.parsers,
    required this.store,
    required this.createId,
  });

  final ImportIntake intake;
  final DocumentParserResolver parsers;
  final DocumentImportStore store;
  final String Function() createId;

  Stream<ImportState> start(
    SelectedFile selectedFile, {
    ParseCancellationToken? cancellationToken,
  }) {
    return _run(selectedFile, cancellationToken: cancellationToken);
  }

  Stream<ImportState> retry(
    String documentId,
    SelectedFile selectedFile, {
    ParseCancellationToken? cancellationToken,
  }) {
    return _run(
      selectedFile,
      existingDocumentId: documentId,
      cancellationToken: cancellationToken,
    );
  }

  Stream<ImportState> _run(
    SelectedFile selectedFile, {
    String? existingDocumentId,
    ParseCancellationToken? cancellationToken,
  }) async* {
    String? documentId = existingDocumentId;
    try {
      final prepared = await intake.prepare(selectedFile);
      if (documentId == null) {
        final duplicate = await store.findByContentHash(prepared.intake.sha256);
        if (duplicate != null) {
          yield ImportState(
            documentId: duplicate,
            status: ImportStatus.duplicate,
            progress: 1,
          );
          return;
        }
        documentId = createId();
        await store.createQueued(
          ImportDocumentRecord(
            id: documentId,
            title: _titleFrom(selectedFile.originalName),
            format: prepared.format,
            intake: prepared.intake,
          ),
        );
      }
      yield ImportState(documentId: documentId, status: ImportStatus.queued);
      await store.markParsing(documentId);

      final cancellation = cancellationToken ?? ParseCancellationToken();
      final blocks = <ParsedBlock>[];
      ParseTerminalEvent? terminal;
      final parser = parsers.forFormat(prepared.format);
      await for (final event in parser.parse(
        ParseRequest(
          bytes: prepared.bytes,
          sourceName: prepared.intake.originalName,
          localPath: prepared.intake.localPath,
          cancellationToken: cancellation,
        ),
      )) {
        if (cancellation.isCancelled) {
          await store.clearStructure(documentId);
          await store.markCancelled(documentId);
          yield ImportState(
            documentId: documentId,
            status: ImportStatus.cancelled,
          );
          return;
        }
        switch (event) {
          case ParsedBlockEvent():
            blocks.add(event.block);
          case ParseProgress():
            yield ImportState(
              documentId: documentId,
              status: ImportStatus.parsing,
              progress: event.progress.clamp(0, 1),
            );
          case ParseTerminalEvent():
            terminal = event;
        }
      }

      switch (terminal) {
        case ParseSucceeded():
          await store.replaceStructure(documentId, blocks);
          await store.markCompleted(documentId);
          yield ImportState(
            documentId: documentId,
            status: ImportStatus.completed,
            progress: 1,
          );
        case ParseFailed(:final failure):
          await store.clearStructure(documentId);
          await store.markFailed(documentId, failure);
          yield ImportState(
            documentId: documentId,
            status: ImportStatus.failed,
            failure: failure,
          );
        case null:
          final failure = const AppFailure(
            AppFailureCode.unknown,
            '解析器未返回完成状态。',
          );
          await store.clearStructure(documentId);
          await store.markFailed(documentId, failure);
          yield ImportState(
            documentId: documentId,
            status: ImportStatus.failed,
            failure: failure,
          );
      }
    } on AppFailure catch (failure) {
      if (documentId == null) rethrow;
      await store.clearStructure(documentId);
      await store.markFailed(documentId, failure);
      yield ImportState(
        documentId: documentId,
        status: ImportStatus.failed,
        failure: failure,
      );
    } on Object catch (error) {
      if (documentId == null) rethrow;
      final failure = AppFailure(
        AppFailureCode.unknown,
        '导入文档失败。',
        cause: error,
      );
      await store.clearStructure(documentId);
      await store.markFailed(documentId, failure);
      yield ImportState(
        documentId: documentId,
        status: ImportStatus.failed,
        failure: failure,
      );
    }
  }
}

String _titleFrom(String fileName) {
  final separator = fileName.lastIndexOf('.');
  return separator <= 0 ? fileName : fileName.substring(0, separator);
}
