import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/models/parsed_block.dart';
import '../../domain/parsers/document_parser.dart';

class DocxDocumentParser implements DocumentParser {
  const DocxDocumentParser({
    this.maxEntries = 2048,
    this.maxEntryBytes = 16 * 1024 * 1024,
    this.maxExpandedBytes = 64 * 1024 * 1024,
  });

  final int maxEntries;
  final int maxEntryBytes;
  final int maxExpandedBytes;

  @override
  Stream<ParseEvent> parse(ParseRequest request) async* {
    yield const ParseProgress(0);
    try {
      final archive = ZipDecoder().decodeBytes(request.bytes, verify: true);
      _validateArchive(archive);
      final documentEntry = archive.files
          .where((entry) => entry.name == 'word/document.xml')
          .firstOrNull;
      if (documentEntry == null) {
        throw const AppFailure(
          AppFailureCode.corruptArchive,
          'DOCX 中缺少 word/document.xml。',
        );
      }

      final xmlBytes = documentEntry.readBytes();
      if (xmlBytes == null) {
        throw const AppFailure(AppFailureCode.corruptArchive, '无法读取 DOCX 正文。');
      }
      final document = XmlDocument.parse(
        utf8.decode(xmlBytes, allowMalformed: false),
      );
      final paragraphs = document.descendants
          .whereType<XmlElement>()
          .where((element) => element.name.local == 'p')
          .toList(growable: false);
      var blockCount = 0;
      for (var index = 0; index < paragraphs.length; index++) {
        final paragraph = paragraphs[index];
        final text = paragraph.descendants
            .whereType<XmlElement>()
            .where((element) => element.name.local == 't')
            .map((element) => element.innerText)
            .join();
        if (text.trim().isNotEmpty) {
          yield ParsedBlockEvent(
            ParsedBlock(
              text: text,
              style: _styleOf(paragraph),
              sourceIndex: index,
            ),
          );
          blockCount++;
        }
        yield ParseProgress((index + 1) / paragraphs.length);
      }
      if (paragraphs.isEmpty) yield const ParseProgress(1);
      yield ParseSucceeded(blockCount: blockCount);
    } on AppFailure catch (failure) {
      yield ParseFailed(failure);
    } on Object catch (error) {
      yield ParseFailed(
        AppFailure(
          AppFailureCode.corruptArchive,
          'DOCX 文件损坏或结构无效。',
          cause: error,
        ),
      );
    }
  }

  void _validateArchive(Archive archive) {
    if (archive.length > maxEntries) {
      throw const AppFailure(
        AppFailureCode.archiveLimitExceeded,
        'DOCX 条目数量超过安全上限。',
      );
    }
    var total = 0;
    for (final entry in archive.files) {
      if (entry.size > maxEntryBytes) {
        throw const AppFailure(
          AppFailureCode.archiveLimitExceeded,
          'DOCX 单个条目超过安全上限。',
        );
      }
      total += entry.size;
      if (total > maxExpandedBytes) {
        throw const AppFailure(
          AppFailureCode.archiveLimitExceeded,
          'DOCX 解压后体积超过安全上限。',
        );
      }
    }
  }
}

ParsedBlockStyle _styleOf(XmlElement paragraph) {
  final descendants = paragraph.descendants.whereType<XmlElement>();
  if (descendants.any((element) => element.name.local == 'numPr')) {
    return ParsedBlockStyle.listItem;
  }
  final styleElement = descendants
      .where((element) => element.name.local == 'pStyle')
      .firstOrNull;
  final styleName = styleElement?.attributes
      .where((attribute) => attribute.name.local == 'val')
      .firstOrNull
      ?.value
      .toLowerCase();
  if (styleName?.startsWith('heading') ?? false) {
    return ParsedBlockStyle.heading;
  }
  return ParsedBlockStyle.body;
}
