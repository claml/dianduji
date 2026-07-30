import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/text/word_normalizer.dart';
import '../../dictionary/data/dictionary_repository.dart';
import '../../phrases/domain/phrase_type.dart';
import 'learning_repository.dart';

class DriftLearningRepository implements LearningRepository {
  DriftLearningRepository(this._dao, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final LearningDao _dao;
  final Uuid _uuid;

  @override
  Future<void> recordLookup({
    required String surface,
    required DictionaryEntry entry,
    required LearningContext context,
  }) {
    return _dao.recordLookup(
      LookupRecord(
        surface: surface,
        lemma: normalizeEnglishWord(entry.word),
        phonetic: entry.phonetic,
        partOfSpeech: entry.partOfSpeech,
        definition: entry.definitionChinese,
        sourceDocumentId: context.documentId,
        sourceDocumentTitle: context.documentTitle,
        contextSentence: context.sentence,
      ),
    );
  }

  @override
  Future<void> savePhrase(SavedPhraseDraft phrase) {
    return _dao.savePhrase(
      SavedPhraseRecord(
        id: _uuid.v4(),
        phraseKey: phrase.key,
        surface: phrase.surface,
        type: phrase.type.storageValue,
        meaning: phrase.meaning,
        contextSentence: phrase.contextSentence,
        sourceDocumentId: phrase.context.documentId,
        sourceDocumentTitle: phrase.context.documentTitle,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Stream<List<VocabularyListItem>> watchVocabulary(VocabularyQuery query) {
    final proficiency = switch (query.filter) {
      VocabularyFilter.all => null,
      VocabularyFilter.known => VocabularyProficiency.known.index,
      VocabularyFilter.vague => VocabularyProficiency.vague.index,
      VocabularyFilter.unknown => VocabularyProficiency.unknown.index,
    };
    final sort = switch (query.sort) {
      VocabularySort.recent => LearningVocabularySort.recent,
      VocabularySort.alphabetical => LearningVocabularySort.alphabetical,
      VocabularySort.lookupCount => LearningVocabularySort.lookupCount,
    };
    return _dao
        .watchVocabularyEntries(
          proficiency: proficiency,
          search: query.search,
          sort: sort,
        )
        .map((rows) {
          final items = rows.map((row) {
            final entry = row.entry;
            return VocabularyListItem(
              lemma: entry.lemma,
              displayWord: entry.displayWord,
              phonetic: entry.phonetic,
              partOfSpeech: entry.partOfSpeech,
              definition: entry.definition,
              proficiency: VocabularyProficiency.values[entry.proficiency],
              lookupCount: entry.lookupCount,
              context: entry.contextSentence,
              sourceAvailability: row.sourceExists
                  ? SourceAvailability.available
                  : SourceAvailability.deleted,
              sourceTitle: entry.sourceDocumentTitle,
              lastLookupAt: entry.lastLookupAt,
            );
          }).toList();
          return items;
        });
  }

  @override
  Stream<List<SavedPhraseListItem>> watchSavedPhrases(SavedPhraseQuery query) {
    return _dao
        .watchSavedPhraseEntries(
          type: query.type?.storageValue,
          search: query.search,
        )
        .map((rows) {
          final values = rows.map((row) {
            final entry = row.entry;
            return SavedPhraseListItem(
              phraseKey: entry.phraseKey,
              surface: entry.surface,
              meaning: entry.meaning,
              type: PhraseTypeCodec.fromStorage(entry.type),
              context: entry.contextSentence,
              createdAt: entry.createdAt,
              sourceAvailability: row.sourceExists
                  ? SourceAvailability.available
                  : SourceAvailability.deleted,
              sourceTitle: entry.sourceDocumentTitle,
            );
          }).toList();
          return values;
        });
  }

  @override
  Future<void> addManualVocabulary(ManualVocabularyDraft draft) async {
    final displayWord = draft.word.trim();
    final lemma = normalizeEnglishWord(displayWord);
    final definition = draft.definition.trim();
    if (lemma.isEmpty || definition.isEmpty) {
      throw ArgumentError('Word and definition must not be blank.');
    }
    await _dao.addManualVocabulary(
      lemma: lemma,
      displayWord: displayWord,
      phonetic: draft.phonetic.trim(),
      partOfSpeech: draft.partOfSpeech.trim(),
      definition: definition,
      proficiency: draft.proficiency.index,
    );
  }

  @override
  Future<void> updateProficiency(String lemma, VocabularyProficiency value) =>
      _dao.updateVocabularyProficiency(lemma, value.index);

  @override
  Future<void> deleteVocabulary(String lemma) => _dao.deleteVocabulary(lemma);

  @override
  Future<void> deleteSavedPhrase(String phraseKey) =>
      _dao.deleteSavedPhrase(phraseKey);
}
