import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:dian_du_ji/core/errors/app_failure.dart';
import 'package:dian_du_ji/features/documents/data/parsers/docx_document_parser.dart';
import 'package:dian_du_ji/features/documents/domain/models/parsed_block.dart';
import 'package:dian_du_ji/features/documents/domain/parsers/document_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'extracts paragraph order, heading and list styles without XML',
    () async {
      final parser = const DocxDocumentParser();
      final events = await parser
          .parse(
            ParseRequest(
              bytes: _docxBytes('''
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    <w:p><w:pPr><w:pStyle w:val="Heading1"/></w:pPr><w:r><w:t>Chapter One</w:t></w:r></w:p>
    <w:p><w:pPr><w:numPr><w:numId w:val="1"/></w:numPr></w:pPr><w:r><w:t>First item</w:t></w:r></w:p>
    <w:p><w:r><w:t>Hello </w:t></w:r><w:r><w:t>world.</w:t></w:r></w:p>
  </w:body>
</w:document>
'''),
              sourceName: 'lesson.docx',
            ),
          )
          .toList();

      final blocks = events
          .whereType<ParsedBlockEvent>()
          .map((event) => event.block)
          .toList();
      expect(blocks.map((block) => block.text), [
        'Chapter One',
        'First item',
        'Hello world.',
      ]);
      expect(blocks.map((block) => block.style), [
        ParsedBlockStyle.heading,
        ParsedBlockStyle.listItem,
        ParsedBlockStyle.body,
      ]);
      expect(blocks.any((block) => block.text.contains('<w:')), isFalse);
      expect(events.last, isA<ParseSucceeded>());
    },
  );

  test('maps a corrupt ZIP to a stable failure', () async {
    final events = await const DocxDocumentParser()
        .parse(
          ParseRequest(
            bytes: Uint8List.fromList([0x50, 0x4b, 1, 2, 3]),
            sourceName: 'broken.docx',
          ),
        )
        .toList();

    expect(
      (events.last as ParseFailed).failure.code,
      AppFailureCode.corruptArchive,
    );
  });

  test('rejects archives beyond the expanded byte limit', () async {
    final parser = DocxDocumentParser(maxExpandedBytes: 20);
    final events = await parser
        .parse(
          ParseRequest(
            bytes: _docxBytes(
              '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body/></w:document>',
            ),
            sourceName: 'oversized.docx',
          ),
        )
        .toList();

    expect(
      (events.last as ParseFailed).failure.code,
      AppFailureCode.archiveLimitExceeded,
    );
  });
}

Uint8List _docxBytes(String documentXml) {
  final archive = Archive()
    ..addFile(ArchiveFile('[Content_Types].xml', 8, utf8.encode('<Types/>')))
    ..addFile(
      ArchiveFile(
        'word/document.xml',
        utf8.encode(documentXml).length,
        utf8.encode(documentXml),
      ),
    );
  return Uint8List.fromList(ZipEncoder().encode(archive));
}
