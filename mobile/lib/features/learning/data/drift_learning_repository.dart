import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
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
        lemma: entry.word,
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
    return _dao.watchVocabularyEntries().map((rows) {
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
      final search = query.search.trim().toLowerCase();
      final filtered = items.where((item) {
        final matchesFilter = switch (query.filter) {
          VocabularyFilter.all => true,
          VocabularyFilter.known =>
            item.proficiency == VocabularyProficiency.known,
          VocabularyFilter.vague =>
            item.proficiency == VocabularyProficiency.vague,
          VocabularyFilter.unknown =>
            item.proficiency == VocabularyProficiency.unknown,
        };
        return matchesFilter &&
            (search.isEmpty ||
                item.lemma.toLowerCase().contains(search) ||
                item.displayWord.toLowerCase().contains(search) ||
                item.definition.toLowerCase().contains(search));
      }).toList();
      switch (query.sort) {
        case VocabularySort.alphabetical:
          filtered.sort((a, b) => a.lemma.compareTo(b.lemma));
        case VocabularySort.lookupCount:
          filtered.sort((a, b) => b.lookupCount.compareTo(a.lookupCount));
        case VocabularySort.recent:
          filtered.sort((a, b) {
            final byTime = b.lastLookupAt.compareTo(a.lastLookupAt);
            return byTime == 0 ? a.lemma.compareTo(b.lemma) : byTime;
          });
      }
      return filtered;
    });
  }

  @override
  Stream<List<SavedPhraseListItem>> watchSavedPhrases(SavedPhraseQuery query) {
    return _dao.watchSavedPhraseEntries().map((rows) {
      final search = query.search.trim().toLowerCase();
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
      return values
          .where(
            (item) =>
                (query.type == null || item.type == query.type) &&
                (search.isEmpty ||
                    item.surface.toLowerCase().contains(search) ||
                    item.meaning.toLowerCase().contains(search)),
          )
          .toList();
    });
  }

  @override
  Future<void> addManualVocabulary(ManualVocabularyDraft draft) async {
    final word = draft.word.trim();
    final definition = draft.definition.trim();
    if (word.isEmpty || definition.isEmpty) {
      throw ArgumentError('Word and definition must not be blank.');
    }
    await _dao.addManualVocabulary(
      lemma: word.toLowerCase(),
      displayWord: word,
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
