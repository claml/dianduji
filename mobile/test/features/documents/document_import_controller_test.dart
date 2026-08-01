import 'dart:async';

import 'package:dian_du_ji/core/errors/app_failure.dart';
import 'package:dian_du_ji/core/platform/pdf_text_extractor.dart';
import 'package:dian_du_ji/features/documents/data/drift_document_repository.dart';
import 'package:dian_du_ji/features/documents/data/file_picker_document_picker.dart';
import 'package:dian_du_ji/features/documents/data/services/file_intake_service.dart';
import 'package:dian_du_ji/features/documents/domain/document_models.dart';
import 'package:dian_du_ji/features/documents/domain/import_document_use_case.dart';
import 'package:dian_du_ji/features/documents/presentation/document_import_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeRepository repository;
  late _FakeImporter importer;

  setUp(() {
    repository = _FakeRepository();
    importer = _FakeImporter();
  });

  test('picker cancellation leaves the library unchanged', () async {
    final controller = DocumentImportController(
      picker: _FakePicker(),
      importer: importer,
      repository: repository,
    );
    addTearDown(controller.dispose);

    await controller.pickAndImport();

    expect(controller.state.errorMessage, isNull);
    expect(importer.startCalls, 0);
    expect(controller.state.documents, isEmpty);
  });

  test('each import request invokes the picker once', () async {
    final picker = _FakePicker(
      result: const SelectedFile(
        path: '/incoming/lesson.txt',
        originalName: 'lesson.txt',
      ),
    );
    final controller = DocumentImportController(
      picker: picker,
      importer: importer,
      repository: repository,
    );
    addTearDown(controller.dispose);

    await controller.pickAndImport();
    await controller.pickAndImport();

    expect(picker.calls, 2);
    expect(importer.startCalls, 2);
  });

  test(
    'forwards queued parsing and completed states from the importer',
    () async {
      importer.startEvents = const [
        ImportState(documentId: 'doc-1', status: ImportStatus.queued),
        ImportState(
          documentId: 'doc-1',
          status: ImportStatus.parsing,
          progress: .5,
        ),
        ImportState(
          documentId: 'doc-1',
          status: ImportStatus.completed,
          progress: 1,
        ),
      ];
      final controller = DocumentImportController(
        picker: _FakePicker(
          result: const SelectedFile(
            path: '/incoming/lesson.txt',
            originalName: 'lesson.txt',
          ),
        ),
        importer: importer,
        repository: repository,
      );
      addTearDown(controller.dispose);
      final statuses = <ImportStatus>[];
      controller.addListener(() {
        final state = controller.state.imports['doc-1'];
        if (state != null) statuses.add(state.status);
      });

      await controller.pickAndImport();

      expect(statuses, [
        ImportStatus.queued,
        ImportStatus.parsing,
        ImportStatus.completed,
      ]);
    },
  );

  test('duplicate import selects the existing document', () async {
    importer.startEvents = const [
      ImportState(
        documentId: 'existing',
        status: ImportStatus.duplicate,
        progress: 1,
      ),
    ];
    final controller = DocumentImportController(
      picker: _FakePicker(
        result: const SelectedFile(
          path: '/incoming/copy.txt',
          originalName: 'copy.txt',
        ),
      ),
      importer: importer,
      repository: repository,
    );
    addTearDown(controller.dispose);

    await controller.pickAndImport();

    expect(controller.state.selectedDocumentId, 'existing');
    expect(controller.state.errorMessage, contains('已导入'));
  });

  test('cancel propagates the active cancellation token', () async {
    importer.holdStart = true;
    final controller = DocumentImportController(
      picker: _FakePicker(
        result: const SelectedFile(
          path: '/incoming/lesson.txt',
          originalName: 'lesson.txt',
        ),
      ),
      importer: importer,
      repository: repository,
    );
    addTearDown(controller.dispose);

    unawaited(controller.pickAndImport());
    await importer.started.future;
    await controller.cancel('doc-1');

    expect(importer.startCancellation!.isCancelled, isTrue);
    await importer.finishStart();
  });

  test(
    'cancel with an unknown id leaves another active import running',
    () async {
      importer.holdStart = true;
      final controller = DocumentImportController(
        picker: _FakePicker(
          result: const SelectedFile(
            path: '/incoming/lesson.txt',
            originalName: 'lesson.txt',
          ),
        ),
        importer: importer,
        repository: repository,
      );
      addTearDown(controller.dispose);

      unawaited(controller.pickAndImport());
      await importer.started.future;
      await controller.cancel('not-the-active-document');

      expect(importer.startCancellation!.isCancelled, isFalse);
      await importer.finishStart();
    },
  );

  test('retry uses the sandbox copy and preserves the document id', () async {
    final controller = DocumentImportController(
      picker: _FakePicker(),
      importer: importer,
      repository: repository,
    );
    addTearDown(controller.dispose);
    repository.emit([
      _summary(
        id: 'doc-1',
        localPath: '/sandbox/hash.bin',
        sourceName: 'lesson.txt',
      ),
    ]);
    await Future<void>.delayed(Duration.zero);

    await controller.retry('doc-1');

    expect(importer.retryDocumentId, 'doc-1');
    expect(importer.retryFile?.path, '/sandbox/hash.bin');
    expect(importer.retryFile?.originalName, 'lesson.txt');
  });

  test('delete delegates to the repository', () async {
    final controller = DocumentImportController(
      picker: _FakePicker(),
      importer: importer,
      repository: repository,
    );
    addTearDown(controller.dispose);

    await controller.delete('doc-1');

    expect(repository.deletedIds, ['doc-1']);
  });

  test('completed documents use reading progress while parsing uses parse progress', () async {
    final controller = DocumentImportController(
      picker: _FakePicker(),
      importer: importer,
      repository: repository,
    );
    addTearDown(controller.dispose);

    repository.emit([
      _summary(
        id: 'completed-1',
        localPath: '/sandbox/completed-1',
        sourceName: 'completed.txt',
        status: 'completed',
        progress: 1,
        readProgress: 0,
      ),
      _summary(
        id: 'parsing-1',
        localPath: '/sandbox/parsing-1',
        sourceName: 'parsing.txt',
        status: 'parsing',
        progress: .5,
        readProgress: 0,
      ),
    ]);
    await Future<void>.delayed(Duration.zero);

    final documents = {
      for (final document in controller.state.documents) document.id: document,
    };
    expect(documents['completed-1']!.progress, 0);
    expect(documents['parsing-1']!.progress, .5);
  });

  test(
    'unsupported and revoked files show actionable Chinese errors',
    () async {
      final controller = DocumentImportController(
        picker: _FakePicker(
          failure: const AppFailure(AppFailureCode.unsupportedFormat, 'raw'),
        ),
        importer: importer,
        repository: repository,
      );
      addTearDown(controller.dispose);

      await controller.pickAndImport();
      expect(controller.state.errorMessage, '不支持该文件格式，请选择 TXT、PDF 或 DOCX。');

      final revokedController = DocumentImportController(
        picker: _FakePicker(
          failure: const AppFailure(AppFailureCode.fileUnavailable, 'raw'),
        ),
        importer: importer,
        repository: repository,
      );
      addTearDown(revokedController.dispose);
      await revokedController.pickAndImport();
      expect(revokedController.state.errorMessage, '无法读取该文件，请重新选择。');
    },
  );
}

DocumentSummary _summary({
  required String id,
  required String localPath,
  required String sourceName,
  String status = 'failed',
  double progress = 0,
  double readProgress = 0,
}) => DocumentSummary(
  id: id,
  title: 'Lesson',
  sourceName: sourceName,
  localPath: localPath,
  format: 'txt',
  status: status,
  progress: progress,
  wordCount: 0,
  readProgress: readProgress,
);

class _FakePicker implements DocumentPicker {
  _FakePicker({this.result, this.failure});

  final SelectedFile? result;
  final AppFailure? failure;
  var calls = 0;

  @override
  Future<SelectedFile?> pickDocument() async {
    calls++;
    if (failure != null) throw failure!;
    return result;
  }
}

class _FakeImporter implements DocumentImporter {
  List<ImportState> startEvents = const [];
  var startCalls = 0;
  bool holdStart = false;
  ParseCancellationToken? startCancellation;
  String? retryDocumentId;
  SelectedFile? retryFile;
  final started = Completer<void>();
  final _heldEvents = Completer<void>();

  @override
  Stream<ImportState> start(
    SelectedFile selectedFile, {
    ParseCancellationToken? cancellationToken,
  }) async* {
    startCalls++;
    startCancellation = cancellationToken;
    if (!started.isCompleted) started.complete();
    if (holdStart) {
      yield const ImportState(documentId: 'doc-1', status: ImportStatus.queued);
      await _heldEvents.future;
    }
    yield* Stream.fromIterable(
      startEvents.isEmpty
          ? const [
              ImportState(
                documentId: 'doc-1',
                status: ImportStatus.completed,
                progress: 1,
              ),
            ]
          : startEvents,
    );
  }

  @override
  Stream<ImportState> retry(
    String documentId,
    SelectedFile selectedFile, {
    ParseCancellationToken? cancellationToken,
  }) async* {
    retryDocumentId = documentId;
    retryFile = selectedFile;
    yield ImportState(
      documentId: documentId,
      status: ImportStatus.completed,
      progress: 1,
    );
  }

  Future<void> finishStart() async {
    if (!_heldEvents.isCompleted) _heldEvents.complete();
  }
}

class _FakeRepository implements DocumentRepository {
  final _documents = StreamController<List<DocumentSummary>>.broadcast();
  final deletedIds = <String>[];

  void emit(List<DocumentSummary> documents) => _documents.add(documents);

  @override
  Future<void> deleteDocument(String documentId) async =>
      deletedIds.add(documentId);

  @override
  Future<StoredReaderDocument> loadReaderDocument(String documentId) =>
      throw UnimplementedError();

  @override
  Future<void> recoverInterruptedImports() async {}

  @override
  Future<void> saveProgress(locator, double progress) async {}

  @override
  Stream<List<DocumentSummary>> watchDocuments() => _documents.stream;
}
