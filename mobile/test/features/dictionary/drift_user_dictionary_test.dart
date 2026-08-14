import 'package:dian_du_ji/core/database/app_database.dart';
import 'package:dian_du_ji/features/dictionary/data/drift_user_dictionary.dart';
import 'package:dian_du_ji/features/dictionary/domain/user_dictionary_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftUserDictionary store;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    store = DriftUserDictionary(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('candidates are not visible to lookup until confirmed', () async {
    await store.collectCandidate('Moment-to-moment', source: 'online');
    expect(await store.pendingCandidateCount(), 1);
    expect(await store.lookupConfirmed('moment-to-moment'), isNull);

    await store.applyEnrichment(const [
      EnrichedDictionaryEntry(
        surface: 'moment-to-moment',
        phonetic: 'ˌməʊmənt tə ˈməʊmənt',
        partOfSpeech: 'adj.',
        definitionEnglish: 'happening from one moment to the next',
        definitionChinese: '每时每刻的；持续不断的',
        isValid: true,
      ),
    ]);

    expect(await store.pendingCandidateCount(), 0);
    final entry = await store.lookupConfirmed('Moment-To-Moment');
    expect(entry, isNotNull);
    expect(entry!.definitionChinese, '每时每刻的；持续不断的');
    expect(entry.word, 'moment-to-moment');
  });

  test('invalid entries are dropped instead of confirmed', () async {
    await store.collectCandidate('notawordxyz');
    await store.applyEnrichment(const [
      EnrichedDictionaryEntry(
        surface: 'notawordxyz',
        phonetic: '',
        partOfSpeech: '',
        definitionEnglish: '',
        definitionChinese: '',
        isValid: false,
      ),
    ]);

    expect(await store.pendingCandidateCount(), 0);
    expect(await store.lookupConfirmed('notawordxyz'), isNull);
  });

  test('collectCandidate de-duplicates on the normalized lemma', () async {
    await store.collectCandidate('Wayfinding');
    await store.collectCandidate('wayfinding');
    expect(await store.pendingCandidateCount(), 1);

    final candidates = await store.pendingCandidates();
    expect(candidates.single.lemma, 'wayfinding');
  });

  test('collecting again never downgrades a confirmed entry', () async {
    await store.collectCandidate('navigability');
    await store.applyEnrichment(const [
      EnrichedDictionaryEntry(
        surface: 'navigability',
        phonetic: '',
        partOfSpeech: 'n.',
        definitionEnglish: 'the quality of being navigable',
        definitionChinese: '可航行性；可导航性',
        isValid: true,
      ),
    ]);
    // A later tap collects the same word again as a candidate.
    await store.collectCandidate('navigability');
    expect(await store.pendingCandidateCount(), 0);
    final entry = await store.lookupConfirmed('navigability');
    expect(entry, isNotNull);
  });

  test('clearCandidates removes only candidates', () async {
    await store.collectCandidate('one');
    await store.applyEnrichment(const [
      EnrichedDictionaryEntry(
        surface: 'two',
        phonetic: '',
        partOfSpeech: '',
        definitionEnglish: '',
        definitionChinese: '二',
        isValid: true,
      ),
    ]);
    await store.collectCandidate('three');

    await store.clearCandidates();
    expect(await store.pendingCandidateCount(), 0);
    expect(await store.lookupConfirmed('two'), isNotNull);
  });

  test('normalizeUserLemma collapses case and apostrophes', () {
    expect(normalizeUserLemma("  Don'T  "), "don't");
    expect(normalizeUserLemma('Don’t'), "don't");
    expect(normalizeUserLemma(''), '');
  });
}
