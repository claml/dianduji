import 'dart:async';

import 'package:dian_du_ji/core/platform/pdf_text_extractor.dart';
import 'package:dian_du_ji/app/providers.dart';
import 'package:dian_du_ji/features/documents/data/drift_document_repository.dart';
import 'package:dian_du_ji/features/documents/data/file_picker_document_picker.dart';
import 'package:dian_du_ji/features/documents/data/services/file_intake_service.dart';
import 'package:dian_du_ji/features/documents/domain/document_models.dart';
import 'package:dian_du_ji/features/documents/domain/import_document_use_case.dart';
import 'package:dian_du_ji/features/documents/presentation/document_import_controller.dart';
import 'package:dian_du_ji/features/documents/presentation/document_library_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'page binds import and retry callbacks without rebuilding the controller',
    (tester) async {
      final importer = _PageImporter();
      final controller = DocumentImportController(
        picker: _PagePicker(),
        importer: importer,
        repository: _PageRepository(),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(home: DocumentLibraryPage(controller: controller)),
      );
      await tester.tap(find.byTooltip('导入文档'));
      await tester.pump();

      expect(importer.startCalls, 1);
    },
  );

  testWidgets(
    'a later successful import does not reopen a historic duplicate',
    (tester) async {
      final controller = DocumentImportController(
        picker: _SequencePagePicker(),
        importer: _SequencePageImporter(),
        repository: _PageRepository(),
      );
      addTearDown(controller.dispose);
      final opened = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: DocumentLibraryPage(controller: controller, onOpen: opened.add),
        ),
      );

      await tester.tap(find.byTooltip('导入文档'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('导入文档'));
      await tester.pumpAndSettle();

      expect(opened, ['doc-duplicate']);
    },
  );

  testWidgets('page asks for delete confirmation before delegating', (
    tester,
  ) async {
    final repository = _PageRepository();
    final controller = DocumentImportController(
      picker: _PagePicker(),
      importer: _PageImporter(),
      repository: repository,
    );
    addTearDown(controller.dispose);
    repository.emit(const [
      DocumentSummary(
        id: 'doc-1',
        title: 'Lesson',
        sourceName: 'lesson.txt',
        localPath: '/sandbox/hash.bin',
        format: 'txt',
        status: 'failed',
        progress: 0,
        wordCount: 0,
        readProgress: 0,
      ),
    ]);
    await tester.pumpWidget(
      MaterialApp(home: DocumentLibraryPage(controller: controller)),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('删除文档'));
    await tester.pumpAndSettle();
    expect(find.text('删除这篇文档？'), findsOneWidget);
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();

    expect(repository.deleted, ['doc-1']);
  });

  testWidgets(
    'page creates its controller on first display and shows watched documents',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = _PageRepository();
      final controller = DocumentImportController(
        picker: _PagePicker(),
        importer: _PageImporter(),
        repository: repository,
      );
      addTearDown(controller.dispose);
      var loaderCalls = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: DocumentLibraryPage(
            controllerLoader: () {
              loaderCalls++;
              return controller;
            },
          ),
        ),
      );
      repository.emit([_pageSummary('doc-1', 'Imported lesson')]);
      await tester.pump();

      expect(loaderCalls, 1);
      expect(find.text('Imported lesson'), findsOneWidget);
    },
  );

  testWidgets(
    'production provider keeps listening after its first document rebuild',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = _PageRepository();
      final controller = DocumentImportController(
        picker: _PagePicker(),
        importer: _PageImporter(),
        repository: repository,
      );
      String? openedId;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            documentImportControllerProvider.overrideWith((ref) => controller),
          ],
          child: MaterialApp(
            home: DocumentLibraryPage(onOpen: (id) => openedId = id),
          ),
        ),
      );
      repository.emit([_pageSummary('pdf-1', 'Existing PDF')]);
      await tester.pump();
      await tester.pump();

      repository.emit([
        _pageSummary('pdf-1', 'Existing PDF'),
        _pageSummary('docx-1', 'Imported Word'),
      ]);
      await tester.pump();
      await tester.pump();

      expect(find.text('Imported Word'), findsOneWidget);
      await tester.tap(find.text('Imported Word'));
      expect(openedId, 'docx-1');
    },
  );

  testWidgets('tablet tap selects for the detail pane instead of opening', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _PageRepository();
    final controller = DocumentImportController(
      picker: _PagePicker(),
      importer: _PageImporter(),
      repository: repository,
    );
    addTearDown(controller.dispose);
    String? openedId;
    repository.emit([_pageSummary('doc-1', 'Lesson')]);

    await tester.pumpWidget(
      MaterialApp(
        home: DocumentLibraryPage(
          controller: controller,
          onOpen: (id) => openedId = id,
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Lesson'));
    await tester.pump();

    // Selecting must not open the reader on tablets; the right pane shows
    // the document details and its explicit open action enters the reader.
    expect(openedId, isNull);
    expect(find.byKey(const Key('document-detail-pane')), findsOneWidget);
    expect(find.text('继续阅读'), findsOneWidget);

    await tester.tap(find.text('继续阅读'));
    await tester.pump();
    expect(openedId, 'doc-1');
  });

  testWidgets('completed document menu offers open and delete actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _PageRepository();
    final controller = DocumentImportController(
      picker: _PagePicker(),
      importer: _PageImporter(),
      repository: repository,
    );
    addTearDown(controller.dispose);
    String? openedId;
    repository.emit([_pageSummary('doc-1', 'Lesson')]);

    await tester.pumpWidget(
      MaterialApp(
        home: DocumentLibraryPage(
          controller: controller,
          onOpen: (id) => openedId = id,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('更多操作'));
    await tester.pumpAndSettle();
    expect(find.text('打开文档'), findsOneWidget);
    expect(find.text('删除文档'), findsOneWidget);

    await tester.tap(find.text('打开文档'));
    await tester.pumpAndSettle();
    expect(openedId, 'doc-1');
  });

  testWidgets(
    'page exposes search and sort controls and opens a selected document',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = _PageRepository();
      final controller = DocumentImportController(
        picker: _PagePicker(),
        importer: _PageImporter(),
        repository: repository,
      );
      addTearDown(controller.dispose);
      String? openedId;
      repository.emit([
        _pageSummary('doc-1', 'Zulu lesson'),
        _pageSummary('doc-2', 'Alpha lesson'),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: DocumentLibraryPage(
            controller: controller,
            onOpen: (id) => openedId = id,
          ),
        ),
      );
      await tester.pump();
      await tester.enterText(find.byKey(const Key('document-search')), 'Alpha');
      await tester.pump();
      expect(find.text('Zulu lesson'), findsNothing);
      expect(find.text('Alpha lesson'), findsOneWidget);
      await tester.tap(find.byTooltip('排序文档'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('按标题排序'));
      await tester.pump();
      expect(controller.state.sort.name, 'title');
      await tester.tap(find.text('Alpha lesson'));
      await tester.pump();
      expect(openedId, 'doc-2');
    },
  );
}

DocumentSummary _pageSummary(String id, String title) => DocumentSummary(
  id: id,
  title: title,
  sourceName: '$title.txt',
  localPath: '/sandbox/$id',
  format: 'txt',
  status: 'completed',
  progress: 1,
  wordCount: 1,
  readProgress: 0,
);

class _PagePicker implements DocumentPicker {
  @override
  Future<SelectedFile?> pickDocument() async => const SelectedFile(
    path: '/incoming/lesson.txt',
    originalName: 'lesson.txt',
  );
}

class _PageImporter implements DocumentImporter {
  var startCalls = 0;

  @override
  Stream<ImportState> start(
    SelectedFile selectedFile, {
    ParseCancellationToken? cancellationToken,
  }) async* {
    startCalls++;
    yield const ImportState(
      documentId: 'doc-1',
      status: ImportStatus.completed,
      progress: 1,
    );
  }

  @override
  Stream<ImportState> retry(
    String documentId,
    SelectedFile selectedFile, {
    ParseCancellationToken? cancellationToken,
  }) async* {}
}

class _SequencePagePicker implements DocumentPicker {
  var _next = 0;

  @override
  Future<SelectedFile?> pickDocument() async => SelectedFile(
    path: '/incoming/lesson-${_next++}.txt',
    originalName: 'lesson.txt',
  );
}

class _SequencePageImporter implements DocumentImporter {
  var _next = 0;

  @override
  Stream<ImportState> start(
    SelectedFile selectedFile, {
    ParseCancellationToken? cancellationToken,
  }) async* {
    if (_next++ == 0) {
      yield const ImportState(
        documentId: 'doc-duplicate',
        status: ImportStatus.duplicate,
        progress: 1,
      );
      return;
    }
    yield const ImportState(
      documentId: 'doc-new',
      status: ImportStatus.completed,
      progress: 1,
    );
  }

  @override
  Stream<ImportState> retry(
    String documentId,
    SelectedFile selectedFile, {
    ParseCancellationToken? cancellationToken,
  }) async* {}
}

class _PageRepository implements DocumentRepository {
  final _documents = StreamController<List<DocumentSummary>>.broadcast();
  final deleted = <String>[];
  void emit(List<DocumentSummary> value) => _documents.add(value);
  @override
  Future<void> deleteDocument(String documentId) async =>
      deleted.add(documentId);
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
