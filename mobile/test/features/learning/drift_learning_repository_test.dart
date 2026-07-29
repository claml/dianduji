import 'package:dian_du_ji/core/database/app_database.dart';
import 'package:dian_du_ji/features/dictionary/data/dictionary_repository.dart';
import 'package:dian_du_ji/features/learning/data/drift_learning_repository.dart';
import 'package:dian_du_ji/features/learning/data/learning_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftLearningRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftLearningRepository(database.learningDao);
  });

  tearDown(() => database.close());

  test('records lookup context alongside the dictionary entry', () async {
    await repository.recordLookup(
      surface: 'Languages',
      entry: const DictionaryEntry(
        word: 'language',
        phonetic: 'ˈlæŋɡwɪdʒ',
        partOfSpeech: 'n.',
        definitionEnglish: 'communication system',
        definitionChinese: '语言',
      ),
      context: const LearningContext(
        documentId: 'document-1',
        documentTitle: 'A Lesson',
        sentence: 'Languages connect people.',
      ),
    );

    final stored = await database.learningDao.findByLemma('language');

    expect(stored?.sourceDocumentId, 'document-1');
    expect(stored?.sourceDocumentTitle, 'A Lesson');
    expect(stored?.contextSentence, 'Languages connect people.');
  });
}
