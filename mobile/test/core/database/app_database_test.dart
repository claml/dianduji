import 'package:dian_du_ji/core/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('records one vocabulary row per lemma and increments once per lookup',
      () async {
    await database.learningDao.recordLookup(
      const LookupRecord(
        surface: 'walking',
        lemma: 'walk',
        phonetic: '/wɔːk/',
        partOfSpeech: 'v.',
        definition: '走；步行',
      ),
    );
    await database.learningDao.recordLookup(
      const LookupRecord(
        surface: 'walked',
        lemma: 'walk',
        phonetic: '/wɔːk/',
        partOfSpeech: 'v.',
        definition: '走；步行',
      ),
    );

    final entry = await database.learningDao.findByLemma('walk');

    expect(entry, isNotNull);
    expect(entry!.displayWord, 'walking');
    expect(entry.lookupCount, 2);
    expect(await database.learningDao.countVocabulary(), 1);
  });
}
