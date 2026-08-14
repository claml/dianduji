import 'package:dian_du_ji/features/dictionary/data/dictionary_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Database database;
  late DictionaryRepository repository;

  setUp(() {
    database = sqlite3.openInMemory();
    database.execute('''
CREATE TABLE entries (
  word TEXT PRIMARY KEY,
  phonetic TEXT NOT NULL,
  part_of_speech TEXT NOT NULL,
  definition_english TEXT NOT NULL,
  definition_chinese TEXT NOT NULL
);
CREATE TABLE lemmas (form TEXT PRIMARY KEY, lemma TEXT NOT NULL);
INSERT INTO entries VALUES
  ('look', 'lʊk', 'v./n.', 'direct one''s gaze', '看；寻找'),
  ('study', 'ˈstʌdi', 'v./n.', 'learn about a subject', '学习；研究'),
  ('walk', 'wɔːk', 'v./n.', 'move on foot', '步行'),
  ('language', 'ˈlæŋɡwɪdʒ', 'n.', 'a system of communication', '语言');
INSERT INTO lemmas VALUES
  ('looked', 'look'), ('studies', 'study'), ('walking', 'walk');
''');
    repository = DictionaryRepository(database);
  });

  tearDown(() {
    database.close();
  });

  test('resolves exact, normalized and lemma-related forms', () async {
    expect((await repository.lookup('LANGUAGE'))?.word, 'language');
    expect((await repository.lookup('looked'))?.word, 'look');
    expect((await repository.lookup('studies'))?.word, 'study');
    expect((await repository.lookup('walking'))?.word, 'walk');
    expect(await repository.lookup('notaword'), isNull);
  });

  test('falls back to the joined form for a merged soft-wrap word', () async {
    // A dehyphenation merge produces a hyphenated surface (true hyphenated
    // compounds keep the hyphen); the joined form is checked as a fallback.
    final entry = await repository.lookup('lan-guage');

    expect(entry?.word, 'language');
    expect(entry?.definitionChinese, '语言');
  });

  test('returns the fields required by the translation card', () async {
    final entry = await repository.lookup('language');

    expect(entry, isNotNull);
    expect(entry!.phonetic, 'ˈlæŋɡwɪdʒ');
    expect(entry.partOfSpeech, 'n.');
    expect(entry.definitionEnglish, 'a system of communication');
    expect(entry.definitionChinese, '语言');
  });

  test(
    'performs one thousand indexed lookups within the desktop test budget',
    () async {
      final stopwatch = Stopwatch()..start();
      for (var index = 0; index < 1000; index++) {
        await repository.lookup(index.isEven ? 'walking' : 'language');
      }
      stopwatch.stop();

      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 2)));
    },
  );
}
