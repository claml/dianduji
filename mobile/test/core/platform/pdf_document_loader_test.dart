import 'dart:convert';
import 'dart:typed_data';

import 'package:dian_du_ji/core/platform/pdf_document_loader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('opens a local text PDF with character geometry', () async {
    const loader = PdfDocumentLoader();
    final document = await loader.openData(_minimalTextPdf('Foundation Models'));
    addTearDown(document.dispose);

    expect(document.pages, hasLength(1));
    final pageText = await loader.loadPageText(document.pages.single);
    expect(pageText.fullText, contains('Foundation Models'));
    expect(pageText.charRects, hasLength(pageText.fullText.length));
    expect(
      pageText.charRects.where((rect) => rect.width > 0 && rect.height > 0),
      isNotEmpty,
    );
  });
}

Uint8List _minimalTextPdf(String text) {
  final escaped = text.replaceAll(r'\', r'\\').replaceAll('(', r'\(').replaceAll(')', r'\)');
  final content = 'BT /F1 18 Tf 72 720 Td ($escaped) Tj ET';
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
  return Uint8List.fromList(ascii.encode(buffer.toString()));
}
