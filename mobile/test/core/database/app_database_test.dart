import 'package:dian_du_ji/core/database/app_database.dart';
import 'package:drift/drift.dart' show Value;
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

  test(
    'records one vocabulary row per lemma and increments once per lookup',
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
    },
  );

  test(
    'deleting a document removes structure but retains learning assets',
    () async {
      const documentId = 'doc-1';
      final now = DateTime.utc(2026, 7, 28);

      await database
          .into(database.documents)
          .insert(
            DocumentsCompanion.insert(
              id: documentId,
              title: 'The Little Prince',
              format: 'txt',
              sourceName: 'prince.txt',
              localPath: 'documents/prince.txt',
              contentHash: 'hash-1',
              fileSize: 128,
              parseStatus: 'completed',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await database
          .into(database.paragraphs)
          .insert(
            ParagraphsCompanion.insert(
              id: 'paragraph-1',
              documentId: documentId,
              ordinal: 0,
              body: 'It is only with the heart that one can see rightly.',
            ),
          );
      await database
          .into(database.sentences)
          .insert(
            SentencesCompanion.insert(
              id: 'sentence-1',
              documentId: documentId,
              paragraphId: 'paragraph-1',
              ordinal: 0,
              body: 'It is only with the heart that one can see rightly.',
              startOffset: 0,
              endOffset: 52,
            ),
          );
      await database
          .into(database.tokens)
          .insert(
            TokensCompanion.insert(
              id: 'token-1',
              documentId: documentId,
              sentenceId: 'sentence-1',
              ordinal: 0,
              surface: 'It',
              normalized: 'it',
              lemma: 'it',
              startOffset: 0,
              endOffset: 2,
            ),
          );
      await database
          .into(database.phraseOccurrences)
          .insert(
            PhraseOccurrencesCompanion.insert(
              id: 'occurrence-1',
              documentId: documentId,
              sentenceId: 'sentence-1',
              phraseKey: 'with-the-heart',
              surface: 'with the heart',
              type: 'prepositionalPhrase',
              meaning: '用心',
              confidence: 1,
              startTokenOrdinal: 3,
              endTokenOrdinal: 5,
            ),
          );
      await database.learningDao.recordLookup(
        const LookupRecord(
          surface: 'heart',
          lemma: 'heart',
          phonetic: '/hɑːt/',
          partOfSpeech: 'n.',
          definition: '心；内心',
        ),
      );
      await database
          .into(database.savedPhrases)
          .insert(
            SavedPhrasesCompanion.insert(
              id: 'saved-1',
              phraseKey: 'with-the-heart',
              surface: 'with the heart',
              type: 'prepositionalPhrase',
              meaning: '用心',
              contextSentence:
                  'It is only with the heart that one can see rightly.',
              sourceDocumentId: const Value(documentId),
              sourceDocumentTitle: 'The Little Prince',
              createdAt: now,
            ),
          );

      await database.documentsDao.deleteDocument(documentId);

      expect(await database.documentsDao.countDocuments(), 0);
      expect(await database.documentsDao.countStructureFor(documentId), 0);
      expect(await database.learningDao.countVocabulary(), 1);
      expect(await database.learningDao.countSavedPhrases(), 1);
    },
  );

  test('settings upsert replaces one key without duplicating rows', () async {
    await database.settingsDao.setValue('reader.theme', 'day');
    await database.settingsDao.setValue('reader.theme', 'eyeCare');

    expect(await database.settingsDao.getValue('reader.theme'), 'eyeCare');
    expect(await database.settingsDao.countSettings(), 1);
  });

  test('saved phrase key stays unique when its context is refreshed', () async {
    final first = DateTime.utc(2026, 7, 28);
    final later = DateTime.utc(2026, 7, 29);
    await database.learningDao.savePhrase(
      SavedPhraseRecord(
        id: 'phrase-1',
        phraseKey: 'look-up',
        surface: 'look up',
        type: 'phrasalVerb',
        meaning: '查阅',
        contextSentence: 'Look it up.',
        sourceDocumentTitle: 'Lesson one',
        createdAt: first,
      ),
    );
    await database.learningDao.savePhrase(
      SavedPhraseRecord(
        id: 'phrase-2',
        phraseKey: 'look-up',
        surface: 'look up',
        type: 'phrasalVerb',
        meaning: '查阅；抬头看',
        contextSentence: 'She looked up at the sky.',
        sourceDocumentTitle: 'Lesson two',
        createdAt: later,
      ),
    );

    expect(await database.learningDao.countSavedPhrases(), 1);
    final phrase = await database.learningDao.findPhrase('look-up');
    expect(phrase?.meaning, '查阅；抬头看');
    expect(phrase?.contextSentence, 'She looked up at the sky.');
    expect(
      phrase?.createdAt.millisecondsSinceEpoch,
      first.millisecondsSinceEpoch,
    );
  });
}
