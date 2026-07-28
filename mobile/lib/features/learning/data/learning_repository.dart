import '../../dictionary/data/dictionary_repository.dart';

abstract interface class LearningRepository {
  Future<void> recordLookup({
    required String surface,
    required DictionaryEntry entry,
  });
}
