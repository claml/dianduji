import 'dart:typed_data';

import 'package:dian_du_ji/core/errors/app_failure.dart';
import 'package:dian_du_ji/core/platform/pdf_text_extractor.dart';
import 'package:dian_du_ji/features/documents/data/services/file_intake_service.dart';
import 'package:dian_du_ji/features/documents/domain/file_format.dart';
import 'package:dian_du_ji/features/documents/domain/import_document_use_case.dart';
import 'package:dian_du_ji/features/documents/domain/models/parsed_block.dart';
import 'package:dian_du_ji/features/documents/domain/parsers/document_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeIntake intake;
  late _FakeStore store;

  setUp(() {
    intake = _FakeIntake();
    store = _FakeStore();
  });

  test(
    'runs queued parsing completed and writes blocks in one batch',
    () async {
      final useCase = ImportDocumentUseCase(
        intake: intake,
        parsers: _FakeParsers(
          _EventParser([
            const ParseProgress(0),
            const ParsedBlockEvent(ParsedBlock(text: 'First paragraph.')),
            const ParseProgress(1),
            const ParseSucceeded(blockCount: 1),
          ]),
        ),
        store: store,
        createId: () => 'doc-new',
      );

      final states = await useCase
          .start(
            const SelectedFile(path: 'source.txt', originalName: 'source.txt'),
          )
          .toList();

      expect(states.map((state) => state.status), [
        ImportStatus.queued,
        ImportStatus.parsing,
        ImportStatus.parsing,
        ImportStatus.completed,
      ]);
      expect(store.createdIds, ['doc-new']);
      expect(store.blocks.single.map((block) => block.text), [
        'First paragraph.',
      ]);
      expect(store.completedIds, ['doc-new']);
    },
  );

  test(
    'cleans partial structure and persists a mapped parser failure',
    () async {
      final useCase = ImportDocumentUseCase(
        intake: intake,
        parsers: _FakeParsers(
          _EventParser([
            const ParsedBlockEvent(ParsedBlock(text: 'partial')),
            const ParseFailed(
              AppFailure(AppFailureCode.unknownEncoding, '编码未知'),
            ),
          ]),
        ),
        store: store,
        createId: () => 'doc-failed',
      );

      final states = await useCase
          .start(const SelectedFile(path: 'bad.txt', originalName: 'bad.txt'))
          .toList();

      expect(states.last.status, ImportStatus.failed);
      expect(states.last.failure?.code, AppFailureCode.unknownEncoding);
      expect(store.clearedIds, ['doc-failed']);
      expect(store.failedIds, ['doc-failed']);
    },
  );

  test('cancellation cleans structure and retry reuses document id', () async {
    final cancellation = ParseCancellationToken();
    final parser = _CancellingParser(cancellation);
    final useCase = ImportDocumentUseCase(
      intake: intake,
      parsers: _FakeParsers(parser),
      store: store,
      createId: () => 'must-not-be-used-for-retry',
    );

    final states = await useCase
        .retry(
          'doc-existing',
          const SelectedFile(path: 'source.txt', originalName: 'source.txt'),
          cancellationToken: cancellation,
        )
        .toList();

    expect(states.last.status, ImportStatus.cancelled);
    expect(states.every((state) => state.documentId == 'doc-existing'), isTrue);
    expect(store.createdIds, isEmpty);
    expect(store.clearedIds, ['doc-existing']);
    expect(store.cancelledIds, ['doc-existing']);
  });

  test(
    'returns the existing document instead of parsing a duplicate hash',
    () async {
      store.existingDocumentId = 'doc-existing';
      final parser = _EventParser([const ParseSucceeded(blockCount: 0)]);
      final useCase = ImportDocumentUseCase(
        intake: intake,
        parsers: _FakeParsers(parser),
        store: store,
        createId: () => 'doc-new',
      );

      final states = await useCase
          .start(const SelectedFile(path: 'same.txt', originalName: 'same.txt'))
          .toList();

      expect(states.single.status, ImportStatus.duplicate);
      expect(states.single.documentId, 'doc-existing');
      expect(parser.parseCount, 0);
    },
  );
}

class _FakeIntake implements ImportIntake {
  @override
  Future<PreparedImportFile> prepare(SelectedFile selectedFile) async {
    return PreparedImportFile(
      intake: IntakeFile(
        originalName: selectedFile.originalName,
        localPath: 'sandbox/${selectedFile.originalName}',
        sha256: 'same-hash',
        byteSize: 4,
        wasDuplicate: false,
      ),
      format: FileFormat.txt,
      bytes: Uint8List.fromList([116, 101, 120, 116]),
    );
  }
}

class _FakeParsers implements DocumentParserResolver {
  _FakeParsers(this.parser);

  final DocumentParser parser;

  @override
  DocumentParser forFormat(FileFormat format) => parser;
}

class _EventParser implements DocumentParser {
  _EventParser(this.events);

  final List<ParseEvent> events;
  int parseCount = 0;

  @override
  Stream<ParseEvent> parse(ParseRequest request) async* {
    parseCount++;
    yield* Stream.fromIterable(events);
  }
}

class _CancellingParser implements DocumentParser {
  _CancellingParser(this.cancellation);

  final ParseCancellationToken cancellation;

  @override
  Stream<ParseEvent> parse(ParseRequest request) async* {
    yield const ParsedBlockEvent(ParsedBlock(text: 'partial'));
    cancellation.cancel();
    yield const ParseProgress(0.5);
  }
}

class _FakeStore implements DocumentImportStore {
  String? existingDocumentId;
  final createdIds = <String>[];
  final completedIds = <String>[];
  final failedIds = <String>[];
  final cancelledIds = <String>[];
  final clearedIds = <String>[];
  final blocks = <List<ParsedBlock>>[];

  @override
  Future<String?> findByContentHash(String hash) async => existingDocumentId;

  @override
  Future<void> createQueued(ImportDocumentRecord record) async {
    createdIds.add(record.id);
  }

  @override
  Future<void> markParsing(String documentId) async {}

  @override
  Future<void> replaceStructure(
    String documentId,
    List<ParsedBlock> parsedBlocks,
  ) async {
    blocks.add(List.of(parsedBlocks));
  }

  @override
  Future<void> markCompleted(String documentId) async {
    completedIds.add(documentId);
  }

  @override
  Future<void> markFailed(String documentId, AppFailure failure) async {
    failedIds.add(documentId);
  }

  @override
  Future<void> markCancelled(String documentId) async {
    cancelledIds.add(documentId);
  }

  @override
  Future<void> clearStructure(String documentId) async {
    clearedIds.add(documentId);
  }
}
