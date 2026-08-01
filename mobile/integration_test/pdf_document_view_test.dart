import 'dart:convert';
import 'dart:io';

import 'package:dian_du_ji/features/reader/domain/reader_selection.dart';
import 'package:dian_du_ji/features/reader/presentation/widgets/pdf_document_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pdfrx/pdfrx.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'renders an original PDF page and taps its transparent word layer',
    (tester) async {
      await pdfrxFlutterInitialize();
      final directory = await Directory.systemTemp.createTemp('dianduji-pdf-');
      final file = File('${directory.path}${Platform.pathSeparator}sample.pdf');
      await file.writeAsBytes(_minimalTextPdf('Foundation Models'));
      addTearDown(() => directory.delete(recursive: true));
      final selections = <ReaderSelection>[];
      final controller = PdfViewerController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PdfDocumentView(
              localPath: file.path,
              initialPageNumber: 99,
              controller: controller,
              onWordTap: selections.add,
            ),
          ),
        ),
      );
      await _pumpUntilFound(tester, find.byKey(const Key('pdf-word-hit-1-0')));

      expect(find.byType(PdfViewer), findsOneWidget);
      expect(find.byKey(const Key('pdf-page-overlay-1')), findsOneWidget);
      await tester.pump();
      final wordCenter = tester.getCenter(
        find.byKey(const Key('pdf-word-hit-1-0')),
      );
      await tester.tapAt(wordCenter);
      await tester.pump(const Duration(milliseconds: 400));

      expect(selections.single.surface, 'Foundation');
      expect(selections.single.pageNumber, 1);

      await controller.zoomUpOnLocalPosition(
        localPosition: controller.globalToLocal(wordCenter)!,
        duration: Duration.zero,
      );
      await tester.pump(const Duration(milliseconds: 100));
      final zoomedWordCenter = tester.getCenter(
        find.byKey(const Key('pdf-word-hit-1-0')),
      );
      await tester.tapAt(zoomedWordCenter);
      await tester.pump(const Duration(milliseconds: 400));

      expect(selections, hasLength(2));
      expect(selections.last.surface, 'Foundation');
    },
  );
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 80 && finder.evaluate().isEmpty; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(finder, findsOneWidget);
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
