import 'dart:convert';
import 'dart:io';

import 'package:dian_du_ji/core/platform/pdf_text_extractor.dart';
import 'package:dian_du_ji/core/platform/pdfrx_pdf_text_extractor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('extracts text and page numbering from a local PDF', () async {
    final directory = await Directory.systemTemp.createTemp('pdf-extract-');
    final file = File('${directory.path}${Platform.pathSeparator}paper.pdf');
    await file.writeAsBytes(_minimalTextPdf('Foundation Models'));
    addTearDown(() => directory.delete(recursive: true));

    const extractor = PdfrxPdfTextExtractor();
    final pages = await extractor
        .extract(file.path, cancellationToken: ParseCancellationToken())
        .toList();

    expect(pages, hasLength(1));
    expect(pages.single.pageNumber, 1);
    expect(pages.single.pageCount, 1);
    expect(pages.single.text, contains('Foundation Models'));
  });
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
