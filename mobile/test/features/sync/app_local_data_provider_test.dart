import 'dart:async';

import 'package:dian_du_ji/features/dictionary/data/dictionary_repository.dart';
import 'package:dian_du_ji/features/dictionary/domain/user_dictionary_repository.dart';
import 'package:dian_du_ji/features/learning/data/learning_repository.dart';
import 'package:dian_du_ji/features/phrases/domain/phrase_type.dart';
import 'package:dian_du_ji/features/settings/data/reading_settings.dart';
import 'package:dian_du_ji/features/settings/data/settings_repository.dart';
import 'package:dian_du_ji/features/sync/domain/app_local_data_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLocalDataProvider', () {
    test('collect serializes vocabulary, phrases, custom definitions and settings', () async {
      final learning = _MemoryLearning()
        ..vocabulary.add(
          VocabularyListItem(
            lemma: 'cell',
            displayWord: 'cell',
            phonetic: '/sel/',
            partOfSpeech: 'n.',
            definition: '细胞',
            proficiency: VocabularyProficiency.unknown,
            lookupCount: 1,
            context: '',
            sourceAvailability: SourceAvailability.available,
            sourceTitle: 'paper',
            lastLookupAt: DateTime.fromMillisecondsSinceEpoch(1000),
          ),
        )
        ..phrases.add(
          SavedPhraseListItem(
            phraseKey: 'look-up',
            surface: 'look up',
            meaning: '查阅',
            type: PhraseType.phrasalVerb,
            context: '',
            createdAt: DateTime.fromMillisecondsSinceEpoch(2000),
            sourceAvailability: SourceAvailability.available,
            sourceTitle: '',
          ),
        );
      final userDictionary = _MemoryUserDictionary()
        ..manual.add(
          const ManualDictionaryEntry(
            surface: 'MEC',
            phonetic: '',
            partOfSpeech: 'n.',
            definitionEnglish: 'Mobile Edge Computing',
            definitionChinese: '移动边缘计算',
          ),
        );
      final provider = AppLocalDataProvider(
        learning: learning,
        settings: _MemorySettings(),
        userDictionary: userDictionary,
      );

      final snapshot = await provider.collect();

      expect(snapshot.data['version'], 1);
      final vocabulary = snapshot.data['vocabulary'] as List<Object?>;
      expect(vocabulary.single, {
        'lemma': 'cell',
        'definition': '细胞',
        'proficiency': 'unknown',
      });
      final phrases = snapshot.data['phrases'] as List<Object?>;
      expect(phrases.single, {
        'surface': 'look up',
        'meaning': '查阅',
        'type': 'phrasalVerb',
      });
      final custom = snapshot.data['customDefinitions'] as List<Object?>;
      expect(custom.single, {
        'surface': 'MEC',
        'phonetic': '',
        'partOfSpeech': 'n.',
        'definitionEnglish': 'Mobile Edge Computing',
        'definitionChinese': '移动边缘计算',
      });
      expect(snapshot.updatedAt, greaterThanOrEqualTo(2000));
    });

    test('apply rebuilds vocabulary, phrases and custom definitions',
        () async {
      final learning = _MemoryLearning()
        ..vocabulary.add(_word('stale', 500))
        ..phrases.add(
          _phrase('old-phrase', 'old phrase', '旧短语', PhraseType.idiom, 500),
        );
      final userDictionary = _MemoryUserDictionary()
        ..manual.add(
          const ManualDictionaryEntry(
            surface: 'Old',
            phonetic: '',
            partOfSpeech: '',
            definitionEnglish: '',
            definitionChinese: '旧定义',
          ),
        );
      final provider = AppLocalDataProvider(
        learning: learning,
        settings: _MemorySettings(),
        userDictionary: userDictionary,
      );

      await provider.apply(
        {
          'version': 1,
          'vocabulary': [
            {'lemma': 'gene', 'definition': '基因', 'proficiency': 'known'},
          ],
          'phrases': [
            {'surface': 'look up', 'meaning': '查阅', 'type': 'phrasalVerb'},
          ],
          'customDefinitions': [
            {
              'surface': 'MEC',
              'phonetic': '',
              'partOfSpeech': 'n.',
              'definitionEnglish': 'Mobile Edge Computing',
              'definitionChinese': '移动边缘计算',
            },
          ],
        },
        9999,
      );

      final words = await learning.watchVocabulary(const VocabularyQuery()).first;
      expect(words.map((w) => w.lemma), ['gene']);
      expect(words.single.proficiency, VocabularyProficiency.known);
      final saved = await learning
          .watchSavedPhrases(const SavedPhraseQuery())
          .first;
      expect(saved.map((p) => p.surface), ['look up']);
      expect(saved.single.type, PhraseType.phrasalVerb);
      final manual = await userDictionary.listManualEntries();
      expect(manual.map((e) => e.surface), ['MEC']);
      expect(manual.single.definitionChinese, '移动边缘计算');
    });

    test('apply clamps remote font sizes and ignores unknown versions',
        () async {
      final learning = _MemoryLearning();
      final settings = _MemorySettings();
      final provider = AppLocalDataProvider(
        learning: learning,
        settings: settings,
        userDictionary: _MemoryUserDictionary(),
      );

      await provider.apply(
        {
          'version': 1,
          'settings': {'theme': 'night', 'fontSize': 99, 'lineHeight': 0.1},
        },
        1,
      );
      expect(settings.value.theme, ReaderTheme.night);
      expect(settings.value.fontSize, 24);
      expect(settings.value.lineHeight, 1.4);

      await provider.apply({'version': 999}, 1);
      expect(settings.value.theme, ReaderTheme.night); // unchanged
    });
  });
}

VocabularyListItem _word(String lemma, int epochMs) => VocabularyListItem(
  lemma: lemma,
  displayWord: lemma,
  phonetic: '',
  partOfSpeech: '',
  definition: '定义',
  proficiency: VocabularyProficiency.unknown,
  lookupCount: 0,
  context: '',
  sourceAvailability: SourceAvailability.available,
  sourceTitle: '',
  lastLookupAt: DateTime.fromMillisecondsSinceEpoch(epochMs),
);

SavedPhraseListItem _phrase(
  String key,
  String surface,
  String meaning,
  PhraseType type,
  int epochMs,
) => SavedPhraseListItem(
  phraseKey: key,
  surface: surface,
  meaning: meaning,
  type: type,
  context: '',
  createdAt: DateTime.fromMillisecondsSinceEpoch(epochMs),
  sourceAvailability: SourceAvailability.available,
  sourceTitle: '',
);

class _MemoryLearning implements LearningRepository {
  final vocabulary = <VocabularyListItem>[];
  final phrases = <SavedPhraseListItem>[];

  @override
  Future<void> recordLookup({
    required String surface,
    required DictionaryEntry entry,
    required LearningContext context,
  }) async {}

  @override
  Future<void> savePhrase(SavedPhraseDraft phrase) async {
    phrases.removeWhere((p) => p.phraseKey == phrase.key);
    phrases.add(
      SavedPhraseListItem(
        phraseKey: phrase.key,
        surface: phrase.surface,
        meaning: phrase.meaning,
        type: phrase.type,
        context: phrase.contextSentence,
        createdAt: DateTime.now(),
        sourceAvailability: SourceAvailability.available,
        sourceTitle: '',
      ),
    );
  }

  @override
  Stream<List<VocabularyListItem>> watchVocabulary(VocabularyQuery query) =>
      Stream.value(List.of(vocabulary));

  @override
  Stream<List<SavedPhraseListItem>> watchSavedPhrases(
    SavedPhraseQuery query,
  ) => Stream.value(List.of(phrases));

  @override
  Future<void> addManualVocabulary(ManualVocabularyDraft draft) async {
    vocabulary.removeWhere((w) => w.lemma == draft.word);
    vocabulary.add(
      VocabularyListItem(
        lemma: draft.word,
        displayWord: draft.word,
        phonetic: draft.phonetic,
        partOfSpeech: draft.partOfSpeech,
        definition: draft.definition,
        proficiency: draft.proficiency,
        lookupCount: 0,
        context: '',
        sourceAvailability: SourceAvailability.available,
        sourceTitle: '',
        lastLookupAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> updateProficiency(
    String lemma,
    VocabularyProficiency value,
  ) async {}

  @override
  Future<void> deleteVocabulary(String lemma) async {
    vocabulary.removeWhere((w) => w.lemma == lemma);
  }

  @override
  Future<void> deleteSavedPhrase(String phraseKey) async {
    phrases.removeWhere((p) => p.phraseKey == phraseKey);
  }
}

class _MemoryUserDictionary implements UserDictionaryStore {
  final manual = <ManualDictionaryEntry>[];

  @override
  Future<void> applyEnrichment(List<EnrichedDictionaryEntry> entries) async {}

  @override
  Future<void> clearCandidates() async {}

  @override
  Future<void> collectCandidate(String surface, {String source = ''}) async {}

  @override
  Future<void> saveManualEntry(ManualDictionaryEntry entry) async {
    manual.removeWhere((e) => normalizeUserLemma(e.surface) == normalizeUserLemma(entry.surface));
    manual.add(entry);
  }

  @override
  Future<List<ManualDictionaryEntry>> listManualEntries() async =>
      List.of(manual);

  @override
  Future<void> deleteManualEntry(String surface) async {
    manual.removeWhere(
      (e) => normalizeUserLemma(e.surface) == normalizeUserLemma(surface),
    );
  }

  @override
  Future<DictionaryEntry?> lookupConfirmed(String surface) async => null;

  @override
  Future<int> pendingCandidateCount() async => 0;

  @override
  Future<List<UserDictionaryCandidate>> pendingCandidates() async => const [];
}

class _MemorySettings implements SettingsRepository {
  ReadingSettings value = ReadingSettings();
  final saved = <ReadingSettings>[];

  @override
  Future<ReadingSettings> load() async => value;

  @override
  Future<void> save(ReadingSettings settings) async {
    value = settings;
    saved.add(settings);
  }

  @override
  Stream<ReadingSettings> watch() => Stream.value(value);
}
