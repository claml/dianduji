import 'package:dian_du_ji/app/app.dart';
import 'package:dian_du_ji/app/providers.dart';
import 'package:dian_du_ji/core/platform/pdf_text_extractor.dart';
import 'package:dian_du_ji/features/documents/data/drift_document_repository.dart';
import 'package:dian_du_ji/features/documents/data/file_picker_document_picker.dart';
import 'package:dian_du_ji/features/documents/data/services/file_intake_service.dart';
import 'package:dian_du_ji/features/documents/domain/document_models.dart';
import 'package:dian_du_ji/features/documents/domain/import_document_use_case.dart';
import 'package:dian_du_ji/features/documents/presentation/document_import_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the document library shell', (tester) async {
    await tester.pumpWidget(_app());

    expect(find.text('文档'), findsWidgets);
    expect(find.text('导入文档'), findsWidgets);
  });

  testWidgets('bottom navigation opens learning and settings screens', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app());

    await tester.tap(find.text('生词').last);
    await tester.pumpAndSettle();
    expect(find.text('生词本'), findsOneWidget);

    await tester.tap(find.text('设置').last);
    await tester.pumpAndSettle();
    expect(find.text('阅读外观'), findsOneWidget);
  });

  testWidgets('settings change the application theme immediately', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app());
    await tester.tap(find.text('设置').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('夜间'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });
}

Widget _app() => ProviderScope(
  overrides: [
    documentImportControllerProvider.overrideWith((ref) {
      final controller = DocumentImportController(
        picker: const _Picker(),
        importer: const _Importer(),
        repository: const _Repository(),
      );
      return controller;
    }),
  ],
  child: const DianDuJiApp(),
);

class _Picker implements DocumentPicker {
  const _Picker();
  @override
  Future<SelectedFile?> pickDocument() async => null;
}

class _Importer implements DocumentImporter {
  const _Importer();
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
  const _Repository();
  @override
  Future<void> deleteDocument(String id) async {}
  @override
  Future<StoredReaderDocument> loadReaderDocument(String id) =>
      throw UnimplementedError();
  @override
  Future<void> recoverInterruptedImports() async {}
  @override
  Future<void> saveProgress(locator, double progress) async {}
  @override
  Stream<List<DocumentSummary>> watchDocuments() => const Stream.empty();
}
