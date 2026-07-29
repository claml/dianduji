import '../../dictionary/data/dictionary_repository.dart';
import '../../phrases/domain/phrase_type.dart';

enum VocabularyProficiency { known, vague, unknown }

enum VocabularyFilter { all, known, vague, unknown }

enum VocabularySort { recent, alphabetical, lookupCount }

enum SourceAvailability { available, deleted }

class VocabularyQuery {
  const VocabularyQuery({
    this.filter = VocabularyFilter.all,
    this.sort = VocabularySort.recent,
    this.search = '',
  });

  final VocabularyFilter filter;
  final VocabularySort sort;
  final String search;
}

class VocabularyListItem {
  const VocabularyListItem({
    required this.lemma,
    required this.displayWord,
    required this.phonetic,
    required this.partOfSpeech,
    required this.definition,
    required this.proficiency,
    required this.lookupCount,
    required this.context,
    required this.sourceAvailability,
    required this.sourceTitle,
    required this.lastLookupAt,
  });

  final String lemma;
  final String displayWord;
  final String phonetic;
  final String partOfSpeech;
  final String definition;
  final VocabularyProficiency proficiency;
  final int lookupCount;
  final String context;
  final SourceAvailability sourceAvailability;
  final String sourceTitle;
  final DateTime lastLookupAt;
}

class ManualVocabularyDraft {
  const ManualVocabularyDraft({
    required this.word,
    required this.definition,
    this.phonetic = '',
    this.partOfSpeech = '',
    this.proficiency = VocabularyProficiency.unknown,
  });

  final String word;
  final String definition;
  final String phonetic;
  final String partOfSpeech;
  final VocabularyProficiency proficiency;
}

class SavedPhraseQuery {
  const SavedPhraseQuery({this.type, this.search = ''});

  final PhraseType? type;
  final String search;
}

class SavedPhraseListItem {
  const SavedPhraseListItem({
    required this.phraseKey,
    required this.surface,
    required this.meaning,
    required this.type,
    required this.context,
    required this.createdAt,
    required this.sourceAvailability,
    required this.sourceTitle,
  });

  final String phraseKey;
  final String surface;
  final String meaning;
  final PhraseType type;
  final String context;
  final DateTime createdAt;
  final SourceAvailability sourceAvailability;
  final String sourceTitle;
}

class LearningContext {
  const LearningContext({
    this.documentId,
    this.documentTitle = '',
    this.sentence = '',
  });

  final String? documentId;
  final String documentTitle;
  final String sentence;
}

class SavedPhraseDraft {
  const SavedPhraseDraft({
    required this.key,
    required this.surface,
    required this.type,
    required this.meaning,
    required this.contextSentence,
    required this.context,
  });

  final String key;
  final String surface;
  final PhraseType type;
  final String meaning;
  final String contextSentence;
  final LearningContext context;
}

abstract interface class LearningRepository {
  Future<void> recordLookup({
    required String surface,
    required DictionaryEntry entry,
    required LearningContext context,
  });

  Future<void> savePhrase(SavedPhraseDraft phrase);
  Stream<List<VocabularyListItem>> watchVocabulary(VocabularyQuery query);
  Stream<List<SavedPhraseListItem>> watchSavedPhrases(SavedPhraseQuery query);
  Future<void> addManualVocabulary(ManualVocabularyDraft draft);
  Future<void> updateProficiency(String lemma, VocabularyProficiency value);
  Future<void> deleteVocabulary(String lemma);
  Future<void> deleteSavedPhrase(String phraseKey);
}
