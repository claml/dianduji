import 'dart:async';

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
import 'package:go_router/go_router.dart';

/// Deep-link intake gate: a shared-file URI arriving as the initial route
/// (Android hands the launch intent's data URI to Flutter) must not throw a
/// GoException; it redirects to the library, and unknown internal paths show
/// the friendly fallback page.
void main() {
  Widget appWithRouter(GoRouter router) => ProviderScope(
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
    child: MaterialApp.router(routerConfig: router),
  );

  testWidgets('shared content URI initial route redirects to the library', (
    tester,
  ) async {
    final router = buildAppRouter(
      shell: ValueNotifier(const AppShellState(selectedIndex: 0)),
      onSelected: (_) {},
      onOpenDocument: (_) {},
    );

    await tester.pumpWidget(appWithRouter(router));
    router.go(
      'content://com.tencent.mm.external.fileprovider/c2c/opendata/'
      'paper.pdf?displayName=paper.pdf',
    );
    await tester.pumpAndSettle();

    expect(find.text('文档'), findsWidgets);
    expect(find.text('导入文档'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unknown internal path shows the fallback page', (tester) async {
    final router = buildAppRouter(
      shell: ValueNotifier(const AppShellState(selectedIndex: 0)),
      onSelected: (_) {},
      onOpenDocument: (_) {},
    );

    await tester.pumpWidget(appWithRouter(router));
    router.go('/does-not-exist');
    await tester.pumpAndSettle();

    expect(find.text('无法打开该页面，请返回文档库重试。'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('http(s) deep links redirect to the library', (tester) async {
    final router = buildAppRouter(
      shell: ValueNotifier(const AppShellState(selectedIndex: 0)),
      onSelected: (_) {},
      onOpenDocument: (_) {},
    );

    await tester.pumpWidget(appWithRouter(router));
    router.go('https://example.com/reader/doc-1');
    await tester.pumpAndSettle();

    // External links are not app routes; the library shows without crashing.
    expect(find.text('文档'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

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
