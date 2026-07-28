import 'dart:convert';

import 'package:charset/charset.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/models/parsed_block.dart';
import '../../domain/parsers/document_parser.dart';

class TxtDocumentParser implements DocumentParser {
  const TxtDocumentParser();

  @override
  Stream<ParseEvent> parse(ParseRequest request) async* {
    yield const ParseProgress(0);
    final text = _decode(request.bytes);
    if (text == null) {
      yield const ParseFailed(
        AppFailure(
          AppFailureCode.unknownEncoding,
          '无法确定 TXT 文件编码，请另存为 UTF-8 或 GB18030 后重试。',
        ),
      );
      return;
    }

    final normalized = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final paragraphs = normalized
        .split(RegExp(r'\n[ \t]*\n+'))
        .map((paragraph) => paragraph.trim())
        .where((paragraph) => paragraph.isNotEmpty)
        .toList(growable: false);

    for (var index = 0; index < paragraphs.length; index++) {
      yield ParsedBlockEvent(
        ParsedBlock(text: paragraphs[index], sourceIndex: index),
      );
      yield ParseProgress((index + 1) / paragraphs.length);
    }
    if (paragraphs.isEmpty) yield const ParseProgress(1);
    yield ParseSucceeded(blockCount: paragraphs.length);
  }
}

String? _decode(List<int> input) {
  final bytes =
      input.length >= 3 &&
          input[0] == 0xef &&
          input[1] == 0xbb &&
          input[2] == 0xbf
      ? input.sublist(3)
      : input;
  try {
    return utf8.decode(bytes, allowMalformed: false);
  } on FormatException {
    try {
      final decoded = const GbkCodec(allowMalformed: false).decode(bytes);
      return decoded.contains('\uFFFD') ? null : decoded;
    } on FormatException {
      return null;
    }
  }
}
