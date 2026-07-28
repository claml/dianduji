import 'package:sqlite3/sqlite3.dart';

class DictionaryEntry {
  const DictionaryEntry({
    required this.word,
    required this.phonetic,
    required this.partOfSpeech,
    required this.definitionEnglish,
    required this.definitionChinese,
  });

  final String word;
  final String phonetic;
  final String partOfSpeech;
  final String definitionEnglish;
  final String definitionChinese;
}

class DictionaryRepository {
  const DictionaryRepository(this.database);

  final Database database;

  Future<DictionaryEntry?> lookup(String surface) async {
    final normalized = surface.trim().replaceAll('’', "'").toLowerCase();
    if (normalized.isEmpty) return null;

    final exact = _findEntry(normalized);
    if (exact != null) return exact;

    final lemmaRows = database.select(
      'SELECT lemma FROM lemmas WHERE form = ? LIMIT 1',
      [normalized],
    );
    if (lemmaRows.isEmpty) return null;
    return _findEntry(lemmaRows.single['lemma'] as String);
  }

  DictionaryEntry? _findEntry(String word) {
    final rows = database.select(
      '''
SELECT word, phonetic, part_of_speech, definition_english,
       definition_chinese
FROM entries
WHERE word = ?
LIMIT 1
''',
      [word],
    );
    if (rows.isEmpty) return null;
    final row = rows.single;
    return DictionaryEntry(
      word: row['word'] as String,
      phonetic: row['phonetic'] as String,
      partOfSpeech: row['part_of_speech'] as String,
      definitionEnglish: row['definition_english'] as String,
      definitionChinese: row['definition_chinese'] as String,
    );
  }
}
