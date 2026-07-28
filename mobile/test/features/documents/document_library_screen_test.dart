import 'package:dian_du_ji/features/documents/presentation/document_library_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('phone uses bottom navigation and one-column empty state', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: DocumentLibraryScreen(state: DocumentLibraryState()),
      ),
    );

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('还没有文档'), findsOneWidget);
    expect(find.text('导入文档'), findsOneWidget);
  });

  testWidgets('tablet uses rail plus document and detail panes', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1024, 768));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    const document = LibraryDocument(
      id: 'doc-1',
      title: 'The Little Prince',
      sourceName: 'prince.txt',
      formatLabel: 'TXT',
      progress: 0.42,
      status: LibraryDocumentStatus.completed,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: DocumentLibraryScreen(
          state: DocumentLibraryState(
            documents: [document],
            selectedDocumentId: 'doc-1',
          ),
        ),
      ),
    );

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byKey(const Key('document-list-pane')), findsOneWidget);
    expect(find.byKey(const Key('document-detail-pane')), findsOneWidget);
    expect(find.text('The Little Prince'), findsNWidgets(2));
    expect(find.text('继续阅读'), findsOneWidget);
  });

  testWidgets('failed document exposes retry and delete actions', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var retried = false;
    var deleted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: DocumentLibraryScreen(
          state: const DocumentLibraryState(
            documents: [
              LibraryDocument(
                id: 'failed',
                title: 'Broken document',
                sourceName: 'broken.docx',
                formatLabel: 'DOCX',
                progress: 0.3,
                status: LibraryDocumentStatus.failed,
                failureMessage: '文件损坏',
              ),
            ],
          ),
          onRetry: (_) => retried = true,
          onDelete: (_) => deleted = true,
        ),
      ),
    );

    expect(find.text('文件损坏'), findsOneWidget);
    await tester.tap(find.byTooltip('重试导入'));
    await tester.tap(find.byTooltip('删除文档'));
    expect(retried, isTrue);
    expect(deleted, isTrue);
  });
}
