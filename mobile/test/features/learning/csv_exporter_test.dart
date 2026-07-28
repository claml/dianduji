import 'dart:convert';

import 'package:dian_du_ji/features/learning/domain/csv_exporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exports UTF-8 CSV with RFC escaping for punctuation and newlines', () {
    final bytes = exportVocabularyCsv([
      const VocabularyExportRow(
        word: 'language',
        phonetic: 'ˈlæŋɡwɪdʒ',
        partOfSpeech: 'n.',
        definition: '语言, "表达"\r\n交流工具',
        proficiency: '模糊',
        lookupCount: 3,
        source: 'The Little Prince',
      ),
    ]);

    expect(bytes.take(3), [0xef, 0xbb, 0xbf]);
    expect(
      utf8.decode(bytes.skip(3).toList()),
      '单词,音标,词性,释义,熟练度,查询次数,来源\r\n'
      'language,ˈlæŋɡwɪdʒ,n.,"语言, ""表达""\r\n交流工具",模糊,3,The Little Prince\r\n',
    );
  });
}
