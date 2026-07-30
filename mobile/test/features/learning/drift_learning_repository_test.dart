import 'package:dian_du_ji/core/database/app_database.dart';
import 'package:dian_du_ji/features/dictionary/data/dictionary_repository.dart';
import 'package:dian_du_ji/features/learning/data/drift_learning_repository.dart';
import 'package:dian_du_ji/features/learning/data/learning_repository.dart';
import 'package:dian_du_ji/features/phrases/domain/phrase_type.dart';
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

  test(
    'filters, searches and sorts vocabulary through the repository',
    () async {
      await repository.addManualVocabulary(
        const ManualVocabularyDraft(
          word: 'Language',
          definition: '语言',
          proficiency: VocabularyProficiency.known,
        ),
      );
      await repository.addManualVocabulary(
        const ManualVocabularyDraft(
          word: 'apple',
          definition: '苹果',
          proficiency: VocabularyProficiency.unknown,
        ),
      );
      await repository.addManualVocabulary(
        const ManualVocabularyDraft(
          word: 'memory',
          definition: '记忆',
          proficiency: VocabularyProficiency.vague,
        ),
      );
      await repository.recordLookup(
        surface: 'apple',
        entry: const DictionaryEntry(
          word: 'apple',
          phonetic: '',
          partOfSpeech: 'n.',
          definitionEnglish: 'fruit',
          definitionChinese: '苹果',
        ),
        context: const LearningContext(),
      );

      final chineseSearch = await repository
          .watchVocabulary(const VocabularyQuery(search: '语言'))
          .first;
      final alphabetical = await repository
          .watchVocabulary(
            const VocabularyQuery(sort: VocabularySort.alphabetical),
          )
          .first;

      expect(chineseSearch.single.lemma, 'language');
      expect(alphabetical.map((item) => item.lemma), [
        'apple',
        'language',
        'memory',
      ]);
      for (final filter in [
        VocabularyFilter.known,
        VocabularyFilter.vague,
        VocabularyFilter.unknown,
      ]) {
        expect(
          await repository
              .watchVocabulary(VocabularyQuery(filter: filter))
              .first,
          hasLength(1),
        );
      }
      expect(
        (await repository
                .watchVocabulary(
                  const VocabularyQuery(sort: VocabularySort.lookupCount),
                )
                .first)
            .first
            .lemma,
        'apple',
      );
      expect(
        (await repository
                .watchVocabulary(
                  const VocabularyQuery(sort: VocabularySort.recent),
                )
                .first)
            .first
            .lemma,
        'apple',
      );
    },
  );

  test(
    'manual vocabulary uses normalized uniqueness and rejects blank definitions',
    () async {
      await repository.addManualVocabulary(
        const ManualVocabularyDraft(word: 'Language', definition: '语言'),
      );

      await expectLater(
        repository.addManualVocabulary(
          const ManualVocabularyDraft(word: ' language ', definition: '语言'),
        ),
        throwsA(isA<StateError>()),
      );
      await expectLater(
        repository.addManualVocabulary(
          const ManualVocabularyDraft(word: 'word', definition: '  '),
        ),
        throwsA(isA<ArgumentError>()),
      );
      await repository.addManualVocabulary(
        const ManualVocabularyDraft(word: 'don’t', definition: '不要'),
      );
      await expectLater(
        repository.addManualVocabulary(
          const ManualVocabularyDraft(word: "don't", definition: '不要'),
        ),
        throwsA(isA<StateError>()),
      );
    },
  );

  test(
    'DAO applies typed filter search and stable sort in its SQL query',
    () async {
      await repository.addManualVocabulary(
        const ManualVocabularyDraft(
          word: 'zebra',
          definition: '斑马',
          proficiency: VocabularyProficiency.known,
        ),
      );
      await repository.addManualVocabulary(
        const ManualVocabularyDraft(
          word: 'apple',
          definition: '苹果',
          proficiency: VocabularyProficiency.known,
        ),
      );
      await repository.addManualVocabulary(
        const ManualVocabularyDraft(
          word: 'unknown',
          definition: '未知',
          proficiency: VocabularyProficiency.unknown,
        ),
      );

      final rows = await database.learningDao
          .watchVocabularyEntries(
            proficiency: VocabularyProficiency.known.index,
            search: '果',
            sort: LearningVocabularySort.alphabetical,
          )
          .first;
      expect(rows.map((row) => row.entry.lemma), ['apple']);

      final stable = await database.learningDao
          .watchVocabularyEntries(sort: LearningVocabularySort.lookupCount)
          .first;
      expect(stable.map((row) => row.entry.lemma), [
        'apple',
        'unknown',
        'zebra',
      ]);
    },
  );

  test(
    'updates proficiency and keeps phrase created time on updates',
    () async {
      await repository.addManualVocabulary(
        const ManualVocabularyDraft(word: 'word', definition: '词'),
      );
      await repository.updateProficiency('word', VocabularyProficiency.known);
      await repository.savePhrase(
        SavedPhraseDraft(
          key: 'look-up',
          surface: 'look up',
          type: PhraseType.phrasalVerb,
          meaning: '查阅',
          contextSentence: 'Look it up.',
          context: const LearningContext(),
        ),
      );
      final original = await database.learningDao.findPhrase('look-up');
      await repository.savePhrase(
        SavedPhraseDraft(
          key: 'look-up',
          surface: 'look up',
          type: PhraseType.phrasalVerb,
          meaning: '查询',
          contextSentence: 'Look it up now.',
          context: const LearningContext(),
        ),
      );

      final vocabulary = await repository
          .watchVocabulary(const VocabularyQuery())
          .first;
      final phrase = await repository
          .watchSavedPhrases(const SavedPhraseQuery())
          .first;
      expect(vocabulary.single.proficiency, VocabularyProficiency.known);
      expect(phrase.single.meaning, '查询');
      expect(phrase.single.createdAt, original!.createdAt);
    },
  );

  test(
    'deleting a source reactively retains vocabulary and marks it deleted',
    () async {
      final now = DateTime.utc(2026, 7, 29);
      await database
          .into(database.documents)
          .insert(
            DocumentsCompanion.insert(
              id: 'doc-1',
              title: 'A Lesson',
              format: 'txt',
              sourceName: 'lesson.txt',
              localPath: 'documents/lesson.txt',
              contentHash: 'learning-source',
              fileSize: 10,
              parseStatus: 'completed',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await repository.recordLookup(
        surface: 'Language',
        entry: const DictionaryEntry(
          word: 'language',
          phonetic: '',
          partOfSpeech: 'n.',
          definitionEnglish: 'communication',
          definitionChinese: '语言',
        ),
        context: const LearningContext(
          documentId: 'doc-1',
          documentTitle: 'A Lesson',
          sentence: 'Language matters.',
        ),
      );

      final events = repository
          .watchVocabulary(const VocabularyQuery())
          .take(2)
          .toList();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await database.documentsDao.deleteDocument('doc-1');
      final values = await events.timeout(const Duration(seconds: 2));

      expect(
        values.first.single.sourceAvailability,
        SourceAvailability.available,
      );
      expect(values.last.single.sourceAvailability, SourceAvailability.deleted);
      expect(values.last.single.sourceTitle, 'A Lesson');
    },
  );

  test('filters and searches phrases then deletes explicitly', () async {
    await repository.savePhrase(
      SavedPhraseDraft(
        key: 'look-up',
        surface: 'look up',
        type: PhraseType.phrasalVerb,
        meaning: '查阅',
        contextSentence: 'Look it up.',
        context: const LearningContext(),
      ),
    );
    await repository.savePhrase(
      SavedPhraseDraft(
        key: 'in-time',
        surface: 'in time',
        type: PhraseType.prepositionalPhrase,
        meaning: '及时',
        contextSentence: 'We arrived in time.',
        context: const LearningContext(),
      ),
    );

    final byType = await repository
        .watchSavedPhrases(const SavedPhraseQuery(type: PhraseType.phrasalVerb))
        .first;
    final byChinese = await repository
        .watchSavedPhrases(const SavedPhraseQuery(search: '及时'))
        .first;
    expect(byType.single.phraseKey, 'look-up');
    expect(byChinese.single.phraseKey, 'in-time');

    await repository.deleteSavedPhrase('look-up');
    expect(
      await repository.watchSavedPhrases(const SavedPhraseQuery()).first,
      hasLength(1),
    );
  });
}
