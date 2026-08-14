// Generates `integration_test/fixtures/thousand-pages.pdf`: a 1,000-page
// text-only PDF with one line of text per page, used by the import
// performance gate. The output is deterministic (fixed page text), so its
// SHA-256 is stable and recorded in PDF_FIXTURES.md.
//
// Usage:
//   dart run tool/generate_thousand_page_pdf.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

void main() {
  const pageCount = 1000;
  final outputPath =
      'integration_test${Platform.pathSeparator}fixtures'
      '${Platform.pathSeparator}thousand-pages.pdf';

  final bytes = BytesBuilder();
  final offsets = <int>[];
  void object(String body) {
    offsets.add(bytes.length);
    bytes.add(ascii.encode(body));
  }

  bytes.add(ascii.encode('%PDF-1.4\n'));
  object('1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n');
  final pagesKids = List.generate(
    pageCount,
    (index) => '${3 + index * 2} 0 R',
  ).join(' ');
  object(
    '2 0 obj\n<< /Type /Pages /Kids [$pagesKids] /Count $pageCount >>\nendobj\n',
  );
  for (var page = 1; page <= pageCount; page++) {
    final pageObject = 3 + (page - 1) * 2;
    final contentObject = pageObject + 1;
    final stream =
        'BT /F1 24 Tf 72 720 Td (Page $page of $pageCount) Tj ET\n';
    object(
      '$pageObject 0 obj\n'
      '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] '
      '/Contents $contentObject 0 R '
      '/Resources << /Font << /F1 1000 0 R >> >> >>\n'
      'endobj\n',
    );
    object(
      '$contentObject 0 obj\n'
      '<< /Length ${stream.length} >>\n'
      'stream\n$stream'
      'endstream\n'
      'endobj\n',
    );
  }
  object(
    '1000 0 obj\n'
    '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\n'
    'endobj\n',
  );

  final xrefOffset = bytes.length;
  bytes.add(ascii.encode('xref\n0 1001\n0000000000 65535 f \n'));
  for (final offset in offsets) {
    bytes.add(
      ascii.encode(
        '${offset.toString().padLeft(10, '0')} 00000 n \n',
      ),
    );
  }
  bytes.add(
    ascii.encode(
      'trailer\n'
      '<< /Size 1001 /Root 1 0 R >>\n'
      'startxref\n$xrefOffset\n'
      '%%EOF\n',
    ),
  );

  final file = File(outputPath);
  file.writeAsBytesSync(bytes.toBytes(), flush: true);
  stdout.writeln(
    'wrote $outputPath (${file.lengthSync()} bytes, $pageCount pages)',
  );
}
