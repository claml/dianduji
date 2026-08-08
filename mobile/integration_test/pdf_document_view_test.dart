import 'dart:convert';
import 'dart:io';

import 'package:dian_du_ji/features/reader/domain/reader_selection.dart';
import 'package:dian_du_ji/features/reader/presentation/widgets/pdf_document_view.dart';
import 'package:dian_du_ji/features/reader/presentation/widgets/pdf_page_text_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pdfrx/pdfrx.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('maps PDF text taps before and after zoom without word widgets', (
    tester,
  ) async {
    await pdfrxFlutterInitialize();
    final directory = await Directory.systemTemp.createTemp('dianduji-pdf-');
    final file = File('${directory.path}${Platform.pathSeparator}sample.pdf');
    await file.writeAsBytes(_minimalTextPdf('Foundation Models'));
    addTearDown(() => directory.delete(recursive: true));
    final selections = <ReaderSelection>[];
    final controller = PdfViewerController();
    final store = PdfPageTextStore();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PdfDocumentView(
            localPath: file.path,
            initialPageNumber: 99,
            controller: controller,
            textStore: store,
            onWordTap: selections.add,
          ),
        ),
      ),
    );
    await _pumpUntil(tester, () => store.get(1) != null);

    expect(find.byType(PdfViewer), findsOneWidget);
    expect(controller.pageNumber, 1);
    expect(_pdfWordHitWidgets(), findsNothing);
    final overlay = find.byKey(const Key('pdf-page-overlay-1'));
    expect(overlay, findsOneWidget);
    expect(overlay, paintsNothing);

    final page = controller.pages.first;
    final text = await page.loadStructuredText();
    final pageRect = controller.layout.pageLayouts.first;
    final documentPoint = text.charRects.first.center.toOffsetInDocument(
      page: page,
      pageRect: pageRect,
    );
    await tester.tapAt(controller.documentToLocal(documentPoint));
    await tester.pump(const Duration(milliseconds: 400));

    expect(selections.single.surface, 'Foundation');
    expect(selections.single.pageNumber, 1);
    expect(overlay, paints..rect());
    expect(_pdfWordHitWidgets(), findsNothing);

    await controller.zoomUpOnLocalPosition(
      localPosition: controller.documentToLocal(documentPoint),
      duration: Duration.zero,
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tapAt(controller.documentToLocal(documentPoint));
    await tester.pump(const Duration(milliseconds: 400));

    expect(selections, hasLength(2));
    expect(selections.last.surface, 'Foundation');
    expect(_pdfWordHitWidgets(), findsNothing);
  });
}

Finder _pdfWordHitWidgets() => find.byWidgetPredicate((widget) {
  final key = widget.key;
  return key is ValueKey<String> && key.value.startsWith('pdf-word-hit-');
});

Future<void> _pumpUntil(WidgetTester tester, bool Function() condition) async {
  for (var attempt = 0; attempt < 80 && !condition(); attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(condition(), isTrue);
}

List<int> _minimalTextPdf(String text) {
  final content = 'BT /F1 18 Tf 72 720 Td ($text) Tj ET';
  final objects = <String>[
    '<< /Type /Catalog /Pages 2 0 R >>',
    '<< /Type /Pages /Kids [3 0 R] /Count 1 >>',
    '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] '
        '/Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>',
    '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>',
    '<< /Length ${ascii.encode(content).length} >>\nstream\n$content\nendstream',
  ];
  final buffer = StringBuffer('%PDF-1.4\n');
  final offsets = <int>[0];
  for (var index = 0; index < objects.length; index++) {
    offsets.add(ascii.encode(buffer.toString()).length);
    buffer.write('${index + 1} 0 obj\n${objects[index]}\nendobj\n');
  }
  final xrefOffset = ascii.encode(buffer.toString()).length;
  buffer
    ..write('xref\n0 ${objects.length + 1}\n')
    ..write('0000000000 65535 f \n');
  for (final offset in offsets.skip(1)) {
    buffer.write('${offset.toString().padLeft(10, '0')} 00000 n \n');
  }
  buffer
    ..write('trailer\n<< /Size ${objects.length + 1} /Root 1 0 R >>\n')
    ..write('startxref\n$xrefOffset\n%%EOF');
  return ascii.encode(buffer.toString());
}
