import 'dart:convert';
import 'dart:typed_data';

import 'package:dian_du_ji/core/errors/app_failure.dart';
import 'package:dian_du_ji/features/documents/data/parsers/txt_document_parser.dart';
import 'package:dian_du_ji/features/documents/domain/parsers/document_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late TxtDocumentParser parser;

  setUp(() {
    parser = const TxtDocumentParser();
  });

  test('parses UTF-8 BOM and preserves paragraph boundaries', () async {
    final bytes = Uint8List.fromList([
      0xef,
      0xbb,
      0xbf,
      ...utf8.encode('First line.\r\ncontinued\r\n\r\n第二段。'),
    ]);

    final events = await parser
        .parse(ParseRequest(bytes: bytes, sourceName: 'lesson.txt'))
        .toList();

    expect(
      events.whereType<ParsedBlockEvent>().map((event) => event.block.text),
      ['First line.\ncontinued', '第二段。'],
    );
    expect(events.last, isA<ParseSucceeded>());
    expect(events.whereType<ParseProgress>().last.progress, 1);
  });

  test('decodes the GB18030 two-byte compatibility range', () async {
    final bytes = Uint8List.fromList([
      0xc4,
      0xe3,
      0xba,
      0xc3,
      0x0a,
      0x0a,
      0xca,
      0xc0,
      0xbd,
      0xe7,
    ]);

    final events = await parser
        .parse(ParseRequest(bytes: bytes, sourceName: 'gb18030.txt'))
        .toList();

    expect(
      events.whereType<ParsedBlockEvent>().map((event) => event.block.text),
      ['你好', '世界'],
    );
    expect(events.last, isA<ParseSucceeded>());
  });

  test(
    'reports unknown encoding instead of inserting replacement text',
    () async {
      final events = await parser
          .parse(
            ParseRequest(
              bytes: Uint8List.fromList([0xff, 0xff, 0xff]),
              sourceName: 'broken.txt',
            ),
          )
          .toList();

      final failure = events.last as ParseFailed;
      expect(failure.failure.code, AppFailureCode.unknownEncoding);
      expect(
        events.whereType<ParsedBlockEvent>().any(
          (event) => event.block.text.contains('\uFFFD'),
        ),
        isFalse,
      );
    },
  );
}
