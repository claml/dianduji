import '../../dictionary/data/dictionary_repository.dart';
import '../../phrases/domain/phrase_type.dart';

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
}
