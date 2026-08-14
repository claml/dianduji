import 'package:dian_du_ji/core/network/online_translation_gateway.dart';
import 'package:dian_du_ji/features/dictionary/data/dictionary_repository.dart';
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
