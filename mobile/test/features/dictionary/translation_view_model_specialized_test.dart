import 'package:dian_du_ji/features/dictionary/data/dictionary_repository.dart';
import 'package:dian_du_ji/features/dictionary/data/specialized_term_catalog.dart';
import 'package:dian_du_ji/features/dictionary/domain/specialized_terms.dart';
import 'package:dian_du_ji/features/dictionary/presentation/translation_view_model.dart';
import 'package:dian_du_ji/features/documents/domain/models/parsed_block.dart';
import 'package:dian_du_ji/features/learning/data/learning_repository.dart';
import 'package:dian_du_ji/features/phrases/domain/phrase_recognizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final specialized = SpecializedTermCatalog.load('''
{
  "version": "1", "source": "t", "license": "MIT",
  "terms": [
    {"term": "random forest", "domain": "computerScience", "definition": "随机森林"},
    {"term": "mitochondria", "domain": "biology", "definition": "线粒体"}
  ]
}
''');

  List<TokenSpan> tokensOf(String sentence) => sentence
      .split(' ')
      .where((word) => word.isNotEmpty)
      .toList()
      .asMap()
      .entries
      .map((entry) => TokenSpan(
        surface: entry.value,
        normalized: entry.value.toLowerCase(),
        start: entry.key,
        end: entry.key + 1,
      ))
      .toList();

  test('multi-word specialized hit surfaces on the translation state', () async {
    final viewModel = TranslationViewModel(
      dictionary: const _General({}),
      learning: const _Learning(),
      phraseRecognizer: PhraseRecognizer(const []),
      specializedIndex: specialized,
    );

    await viewModel.lookup(
      tokens: tokensOf('a random forest classifies samples'),
      selectedTokenOrdinal: 1,
    );

    expect(viewModel.state.status, TranslationStatus.found);
    expect(viewModel.state.specializedTerm?.term, 'random forest');
    expect(viewModel.state.matchedCandidate?.surface, 'random forest');
    expect(viewModel.state.displaySurface, 'random forest');
    expect(viewModel.state.sentence, 'a random forest classifies samples');
  });

  test('specialized-only word hit has no matched candidate', () async {
    final viewModel = TranslationViewModel(
      dictionary: const _General({}),
      learning: const _Learning(),
      phraseRecognizer: PhraseRecognizer(const []),
      specializedIndex: specialized,
    );

    await viewModel.lookup(
      tokens: tokensOf('the mitochondria divide'),
      selectedTokenOrdinal: 1,
    );

    expect(viewModel.state.status, TranslationStatus.found);
    expect(viewModel.state.specializedTerm?.term, 'mitochondria');
    expect(viewModel.state.matchedCandidate, isNull);
    expect(viewModel.state.displaySurface, 'mitochondria');
  });

  test('no specialized index keeps the legacy general-only behavior', () async {
    final viewModel = TranslationViewModel(
      dictionary: const _General({'cell': DictionaryEntry(
        word: 'cell',
        phonetic: '',
        partOfSpeech: 'n',
        definitionEnglish: 'basic unit',
        definitionChinese: '细胞',
      )}),
      learning: const _Learning(),
      phraseRecognizer: PhraseRecognizer(const []),
    );

    await viewModel.lookup(
      tokens: tokensOf('the cell divides'),
      selectedTokenOrdinal: 1,
    );

    expect(viewModel.state.status, TranslationStatus.found);
    expect(viewModel.state.entry?.word, 'cell');
    expect(viewModel.state.specializedTerm, isNull);
  });
}

class _General implements DictionaryLookup {
  const _General(this.entries);

  final Map<String, DictionaryEntry> entries;

  @override
  Future<DictionaryEntry?> lookup(String surface) async =>
      entries[surface.toLowerCase()];
}

class _Learning implements LearningRepository {
  const _Learning();

  @override
  Future<void> recordLookup({
    required String surface,
    required DictionaryEntry entry,
    required LearningContext context,
  }) async {}

  @override
  Future<void> savePhrase(SavedPhraseDraft phrase) async {}

  @override
  Stream<List<VocabularyListItem>> watchVocabulary(VocabularyQuery query) =>
      const Stream.empty();

  @override
  Stream<List<SavedPhraseListItem>> watchSavedPhrases(
    SavedPhraseQuery query,
  ) => const Stream.empty();

  @override
  Future<void> addManualVocabulary(ManualVocabularyDraft draft) async {}

  @override
  Future<void> updateProficiency(
    String lemma,
    VocabularyProficiency value,
  ) async {}

  @override
  Future<void> deleteVocabulary(String lemma) async {}

  @override
  Future<void> deleteSavedPhrase(String phraseKey) async {}
}
