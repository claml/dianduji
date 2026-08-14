import 'package:dian_du_ji/core/network/online_translation_gateway.dart';
import 'package:dian_du_ji/features/dictionary/data/dictionary_repository.dart';
import 'package:dian_du_ji/features/dictionary/domain/user_dictionary_repository.dart';
import 'package:dian_du_ji/features/dictionary/presentation/translation_view_model.dart';
import 'package:dian_du_ji/features/documents/domain/models/parsed_block.dart';
import 'package:dian_du_ji/features/learning/data/learning_repository.dart';
import 'package:dian_du_ji/features/phrases/domain/phrase_recognizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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

  TranslationViewModel viewModel({
    OnlineTranslationGateway? gateway,
    bool onlineEnabled = false,
  }) => TranslationViewModel(
    dictionary: const _General({}),
    learning: const _Learning(),
    phraseRecognizer: PhraseRecognizer(const []),
    onlineGateway: gateway,
    onlineEnabled: onlineEnabled,
  );

  test('local miss falls back to online when enabled', () async {
    final gateway = _RecordingGateway();
    final vm = viewModel(gateway: gateway, onlineEnabled: true);

    await vm.lookup(
      tokens: tokensOf('an unknown phrase here'),
      selectedTokenOrdinal: 1,
    );

    expect(vm.state.status, TranslationStatus.found);
    expect(vm.state.onlineStatus, OnlineTranslationStatus.available);
    expect(vm.state.onlineResult?.termTranslation, '未知词');
    expect(gateway.calls, 1);
    expect(gateway.lastRequest?.term, 'unknown');
  });

  test('online is never called when the switch is off', () async {
    final gateway = _RecordingGateway();
    final vm = viewModel(gateway: gateway, onlineEnabled: false);

    await vm.lookup(
      tokens: tokensOf('an unknown phrase here'),
      selectedTokenOrdinal: 1,
    );

    expect(vm.state.status, TranslationStatus.notFound);
    expect(vm.state.onlineStatus, OnlineTranslationStatus.none);
    expect(gateway.calls, 0);
  });

  test('online failure keeps the local not-found with unavailable status',
      () async {
    final gateway = _FailingGateway();
    final vm = viewModel(gateway: gateway, onlineEnabled: true);

    await vm.lookup(
      tokens: tokensOf('an unknown phrase here'),
      selectedTokenOrdinal: 1,
    );

    expect(vm.state.status, TranslationStatus.notFound);
    expect(vm.state.onlineStatus, OnlineTranslationStatus.unavailable);
  });

  test('a local hit does not trigger the network', () async {
    final gateway = _RecordingGateway();
    final vm = TranslationViewModel(
      dictionary: const _General({
        'known': DictionaryEntry(
          word: 'known',
          phonetic: '',
          partOfSpeech: 'adj',
          definitionEnglish: 'known',
          definitionChinese: '已知的',
        ),
      }),
      learning: const _Learning(),
      phraseRecognizer: PhraseRecognizer(const []),
      onlineGateway: gateway,
      onlineEnabled: true,
    );

    await vm.lookup(
      tokens: tokensOf('a known word'),
      selectedTokenOrdinal: 1,
    );

    expect(vm.state.status, TranslationStatus.found);
    expect(vm.state.onlineResult, isNull);
    expect(gateway.calls, 0);
  });

  test('a successful online translation collects a dictionary candidate', (
  ) async {
    final gateway = _RecordingGateway();
    final dictionary = _MemoryUserDictionary();
    final vm = TranslationViewModel(
      dictionary: const _General({}),
      learning: const _Learning(),
      phraseRecognizer: PhraseRecognizer(const []),
      onlineGateway: gateway,
      onlineEnabled: true,
      userDictionary: dictionary,
    );

    await vm.lookup(
      tokens: tokensOf('an unknown phrase here'),
      selectedTokenOrdinal: 1,
    );

    expect(vm.state.status, TranslationStatus.found);
    expect(dictionary.collected, ['unknown']);
    expect(dictionary.collectedSources.single, 'online-translation');
  });

  test('a confirmed user entry wins over the general dictionary', () async {
    final dictionary = _MemoryUserDictionary()
      ..confirmed['word'] = const DictionaryEntry(
        word: 'word',
        phonetic: 'wɜːd',
        partOfSpeech: 'n.',
        definitionEnglish: 'a single unit of language',
        definitionChinese: '词语（用户词典）',
      );
    final vm = TranslationViewModel(
      dictionary: const _General({
        'word': DictionaryEntry(
          word: 'word',
          phonetic: '',
          partOfSpeech: 'n.',
          definitionEnglish: 'general',
          definitionChinese: '通用释义',
        ),
      }),
      learning: const _Learning(),
      phraseRecognizer: PhraseRecognizer(const []),
      userDictionary: dictionary,
    );

    await vm.lookup(tokens: tokensOf('a word here'), selectedTokenOrdinal: 1);

    expect(vm.state.status, TranslationStatus.found);
    expect(vm.state.entry?.definitionChinese, '词语（用户词典）');
    expect(vm.state.fromUserDictionary, isTrue);
  });
}

class _MemoryUserDictionary implements UserDictionaryStore {
  final collected = <String>[];
  final collectedSources = <String>[];
  final confirmed = <String, DictionaryEntry>{};

  @override
  Future<void> applyEnrichment(List<EnrichedDictionaryEntry> entries) async {}

  @override
  Future<void> clearCandidates() async {}

  @override
  Future<void> collectCandidate(String surface, {String source = ''}) async {
    collected.add(surface);
    collectedSources.add(source);
  }

  @override
  Future<DictionaryEntry?> lookupConfirmed(String surface) async =>
      confirmed[normalizeUserLemma(surface)];

  @override
  Future<int> pendingCandidateCount() async => 0;

  @override
  Future<List<UserDictionaryCandidate>> pendingCandidates() async => const [];
}

class _RecordingGateway implements OnlineTranslationGateway {
  var calls = 0;
  OnlineTranslationRequest? lastRequest;

  @override
  Future<OnlineTranslationResult> translate(
    OnlineTranslationRequest request,
  ) async {
    calls++;
    lastRequest = request;
    return const OnlineTranslationResult(
      termTranslation: '未知词',
      sentenceTranslation: '未知短语的译文。',
      sourceId: 'g',
      cacheVersion: '1',
    );
  }
}

class _FailingGateway implements OnlineTranslationGateway {
  @override
  Future<OnlineTranslationResult> translate(
    OnlineTranslationRequest request,
  ) async {
    throw const OnlineTranslationException(OnlineTranslationError.offline);
  }
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
