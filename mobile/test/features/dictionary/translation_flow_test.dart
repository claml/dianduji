import 'dart:async';

import 'package:dian_du_ji/features/dictionary/data/dictionary_repository.dart';
import 'package:dian_du_ji/features/learning/data/learning_repository.dart';
import 'package:dian_du_ji/features/dictionary/presentation/translation_view_model.dart';
import 'package:dian_du_ji/features/documents/domain/text/tokenizer.dart';
import 'package:dian_du_ji/features/phrases/domain/phrase_recognizer.dart';
import 'package:dian_du_ji/features/phrases/domain/phrase_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeDictionary dictionary;
  late _RecordingLearningRepository learning;
  late TranslationViewModel viewModel;

  setUp(() {
    dictionary = _FakeDictionary();
    learning = _RecordingLearningRepository();
    viewModel = TranslationViewModel(
      dictionary: dictionary,
      learning: learning,
      phraseRecognizer: PhraseRecognizer([
        const PhraseDefinition(
          key: 'look-up',
          words: ['look', 'up'],
          type: PhraseType.phrasalVerb,
          meaning: '查阅',
        ),
      ]),
    );
  });

  test(
    'shows loading immediately then writes vocabulary exactly once',
    () async {
      dictionary.pending = Completer<DictionaryEntry?>();
      final tokens = tokenize('Please look up this word.');

      final future = viewModel.lookup(tokens: tokens, selectedTokenOrdinal: 1);

      expect(viewModel.state.status, TranslationStatus.loading);
      expect(viewModel.state.surface, 'look');
      dictionary.pending!.complete(
        const DictionaryEntry(
          word: 'look',
          phonetic: 'lʊk',
          partOfSpeech: 'v.',
          definitionEnglish: 'direct one\'s gaze',
          definitionChinese: '看；查找',
        ),
      );
      await future;

      expect(viewModel.state.status, TranslationStatus.found);
      expect(viewModel.state.entry?.definitionChinese, '看；查找');
      expect(learning.records, [('look', 'look')]);
      expect(viewModel.state.phrases.map((phrase) => phrase.key), ['look-up']);

      expect(viewModel.state.entry?.word, 'look');
      expect(viewModel.state.entry?.word, 'look');
      expect(learning.records, hasLength(1));
    },
  );

  test('one repeated user lookup creates one additional write', () async {
    dictionary.result = const DictionaryEntry(
      word: 'look',
      phonetic: 'lʊk',
      partOfSpeech: 'v.',
      definitionEnglish: 'direct one\'s gaze',
      definitionChinese: '看；查找',
    );
    final tokens = tokenize('Look up.');

    await viewModel.lookup(tokens: tokens, selectedTokenOrdinal: 0);
    await viewModel.lookup(tokens: tokens, selectedTokenOrdinal: 0);

    expect(learning.records, hasLength(2));
  });

  test(
    'unknown or blank definitions remain visible without being saved',
    () async {
      final tokens = tokenize('Mystery blank.');

      dictionary.result = null;
      await viewModel.lookup(tokens: tokens, selectedTokenOrdinal: 0);
      expect(viewModel.state.status, TranslationStatus.notFound);
      expect(viewModel.state.surface, 'Mystery');

      dictionary.result = const DictionaryEntry(
        word: 'blank',
        phonetic: '',
        partOfSpeech: '',
        definitionEnglish: '',
        definitionChinese: '   ',
      );
      await viewModel.lookup(tokens: tokens, selectedTokenOrdinal: 1);
      expect(viewModel.state.status, TranslationStatus.found);
      expect(learning.records, isEmpty);
    },
  );
}

class _FakeDictionary implements DictionaryLookup {
  DictionaryEntry? result;
  Completer<DictionaryEntry?>? pending;

  @override
  Future<DictionaryEntry?> lookup(String surface) {
    return pending?.future ?? Future.value(result);
  }
}

class _RecordingLearningRepository implements LearningRepository {
  final records = <(String surface, String lemma)>[];

  @override
  Future<void> recordLookup({
    required String surface,
    required DictionaryEntry entry,
    required LearningContext context,
  }) async {
    records.add((surface, entry.word));
  }

  @override
  Future<void> savePhrase(SavedPhraseDraft phrase) async {}
  @override Stream<List<VocabularyListItem>> watchVocabulary(VocabularyQuery query) => const Stream.empty();
  @override Stream<List<SavedPhraseListItem>> watchSavedPhrases(SavedPhraseQuery query) => const Stream.empty();
  @override Future<void> addManualVocabulary(ManualVocabularyDraft draft) async {}
  @override Future<void> updateProficiency(String lemma, VocabularyProficiency value) async {}
  @override Future<void> deleteVocabulary(String lemma) async {}
  @override Future<void> deleteSavedPhrase(String phraseKey) async {}
}
