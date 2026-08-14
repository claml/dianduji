import 'dart:async';

import 'package:dian_du_ji/core/platform/pdf_text_extractor.dart';
import 'package:dian_du_ji/features/documents/data/drift_document_repository.dart';
import 'package:dian_du_ji/features/documents/data/file_picker_document_picker.dart';
import 'package:dian_du_ji/features/documents/data/services/file_intake_service.dart';
import 'package:dian_du_ji/features/documents/domain/document_models.dart';
import 'package:dian_du_ji/features/documents/domain/import_document_use_case.dart';
import 'package:dian_du_ji/features/documents/presentation/document_import_controller.dart';
import 'package:dian_du_ji/features/documents/presentation/document_library_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('keyboard on tablet does not overflow the library', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(2200, 1440);
    tester.view.devicePixelRatio = 1.0;
    tester.view.viewInsets = const FakeViewPadding(bottom: 700);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    final controller = DocumentImportController(
      picker: const _Picker(),
      importer: _Importer(),
      repository: _Repository(),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(home: DocumentLibraryPage(controller: controller)),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('document-search')));
    await tester.pumpAndSettle();

    final exception = tester.takeException();
    expect(exception, isNull, reason: 'keyboard must not overflow layout: '
        '$exception');
  });

  testWidgets('keyboard with documents and detail pane does not overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(2200, 1440);
    tester.view.devicePixelRatio = 1.0;
    // A large on-screen keyboard (e.g. Huawei split/landscape keyboards) can
    // leave the detail pane with less height than its fixed content.
    tester.view.viewInsets = const FakeViewPadding(bottom: 1100);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    final repository = _Repository();
    final controller = DocumentImportController(
      picker: const _Picker(),
      importer: _Importer(),
      repository: repository,
    );
    addTearDown(controller.dispose);
    repository.emit([
      _summary('doc-1', 'A long document title that wraps onto two lines'),
      _summary('doc-2', 'Another document'),
    ]);

    await tester.pumpWidget(
      MaterialApp(home: DocumentLibraryPage(controller: controller)),
    );
    await tester.pump();

    // Select a document so the tablet detail pane is visible.
    await tester.tap(find.text('A long document title that wraps onto two lines'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('document-detail-pane')), findsOneWidget);

    await tester.tap(find.byKey(const Key('document-search')));
    await tester.pumpAndSettle();

    final exception = tester.takeException();
    expect(exception, isNull, reason: 'keyboard must not overflow layout: '
        '$exception');
  });
}

DocumentSummary _summary(String id, String title) => DocumentSummary(
  id: id,
  title: title,
  sourceName: '$title.txt',
  localPath: '/sandbox/$id',
  format: 'pdf',
  status: 'completed',
  progress: 1,
  wordCount: 100,
  readProgress: 0.2,
);

class _Picker implements DocumentPicker {
  const _Picker();
  @override
  Future<SelectedFile?> pickDocument() async => null;
}

class _Importer implements DocumentImporter {
  @override
  Stream<ImportState> start(
    SelectedFile file, {
    ParseCancellationToken? cancellationToken,
  }) => const Stream.empty();
  @override
  Stream<ImportState> retry(
    String id,
    SelectedFile file, {
    ParseCancellationToken? cancellationToken,
  }) => const Stream.empty();
}

class _Repository implements DocumentRepository {
  final _documents = StreamController<List<DocumentSummary>>.broadcast();

  void emit(List<DocumentSummary> documents) => _documents.add(documents);

  @override
  Stream<List<DocumentSummary>> watchDocuments() => _documents.stream;

  @override
  Future<void> deleteDocument(String id) async {}

  @override
  Future<StoredReaderDocument> loadReaderDocument(String id) =>
      throw UnimplementedError();

  @override
  Future<void> recoverInterruptedImports() async {}

  @override
  Future<void> saveProgress(locator, double progress) async {}
}
