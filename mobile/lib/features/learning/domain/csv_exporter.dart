import 'dart:convert';
import 'dart:typed_data';

class VocabularyExportRow {
  const VocabularyExportRow({
    required this.word,
    required this.phonetic,
    required this.partOfSpeech,
    required this.definition,
    required this.proficiency,
    required this.lookupCount,
    required this.source,
  });

  final String word;
  final String phonetic;
  final String partOfSpeech;
  final String definition;
  final String proficiency;
  final int lookupCount;
  final String source;
}

Uint8List exportVocabularyCsv(Iterable<VocabularyExportRow> rows) {
  final output = StringBuffer()..writeln('单词,音标,词性,释义,熟练度,查询次数,来源');
  for (final row in rows) {
    output
      ..write(_escape(row.word))
      ..write(',')
      ..write(_escape(row.phonetic))
      ..write(',')
      ..write(_escape(row.partOfSpeech))
      ..write(',')
      ..write(_escape(row.definition))
      ..write(',')
      ..write(_escape(row.proficiency))
      ..write(',')
      ..write(row.lookupCount)
      ..write(',')
      ..write(_escape(row.source))
      ..write('\r\n');
  }
  final body = output.toString().replaceFirst('\n', '\r\n');
  return Uint8List.fromList([0xef, 0xbb, 0xbf, ...utf8.encode(body)]);
}

String _escape(String value) {
  if (!value.contains(RegExp('[",\r\n]'))) return value;
  return '"${value.replaceAll('"', '""')}"';
}
