import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../dictionary/data/dictionary_repository.dart';
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
}
