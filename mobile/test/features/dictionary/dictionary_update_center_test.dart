import 'package:dian_du_ji/core/network/dictionary_enrichment_gateway.dart';
import 'package:dian_du_ji/features/dictionary/data/dictionary_repository.dart';
import 'package:dian_du_ji/features/dictionary/domain/user_dictionary_repository.dart';
import 'package:dian_du_ji/features/dictionary/presentation/dictionary_update_center.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('runEnrichment reports an error when no gateway is configured', () async {
    final center = DictionaryUpdateCenter(
      store: _MemoryStore(['one', 'two']),
      gateway: null,
    );

    final ran = await center.runEnrichment();

    expect(ran, isFalse);
    expect(center.error, contains('未配置'));
  });

  test('runEnrichment sends candidates and applies the results', () async {
    final gateway = _RecordingGateway();
    final store = _MemoryStore(['moment-to-moment', 'navigability']);
    final center = DictionaryUpdateCenter(store: store, gateway: gateway);

    final ran = await center.runEnrichment();

    expect(ran, isTrue);
    expect(gateway.received, ['moment-to-moment', 'navigability']);
    expect(store.applied, hasLength(2));
    expect(center.lastConfirmed, 1);
    expect(center.lastDropped, 1);
    expect(center.candidateCount, 0);
  });

  test('a failing gateway surfaces the error and leaves state consistent',
      () async {
    final store = _MemoryStore(['one']);
    final center = DictionaryUpdateCenter(
      store: store,
      gateway: _FailingGateway(),
    );

    final ran = await center.runEnrichment();

    expect(ran, isFalse);
    expect(center.error, isNotNull);
    expect(store.applied, isEmpty);
    expect(center.candidateCount, 1);
  });

  test('no candidates skips the network entirely', () async {
    final gateway = _RecordingGateway();
    final center = DictionaryUpdateCenter(
      store: _MemoryStore(const []),
      gateway: gateway,
    );

    final ran = await center.runEnrichment();

    expect(ran, isFalse);
    expect(gateway.received, isEmpty);
  });
}

class _MemoryStore implements UserDictionaryStore {
  _MemoryStore(List<String> candidates) : _candidates = [...candidates];

  final List<String> _candidates;
  final List<EnrichedDictionaryEntry> applied = [];

  @override
  Future<void> applyEnrichment(List<EnrichedDictionaryEntry> entries) async {
    applied.addAll(entries);
    _candidates.clear();
  }

  @override
  Future<void> clearCandidates() async => _candidates.clear();

  @override
  Future<void> collectCandidate(String surface, {String source = ''}) async {}

  @override
  Future<void> saveManualEntry(ManualDictionaryEntry entry) async {}

  @override
  Future<List<ManualDictionaryEntry>> listManualEntries() async => const [];

  @override
  Future<void> deleteManualEntry(String surface) async {}

  @override
  Future<DictionaryEntry?> lookupConfirmed(String surface) async => null;

  @override
  Future<int> pendingCandidateCount() async => _candidates.length;

  @override
  Future<List<UserDictionaryCandidate>> pendingCandidates() async => [
    for (final word in _candidates)
      UserDictionaryCandidate(
        lemma: word,
        surface: word,
        source: 'online-translation',
        createdAt: DateTime(2026, 8, 14),
      ),
  ];
}

class _RecordingGateway implements DictionaryEnrichmentGateway {
  final List<String> received = [];

  @override
  Future<DictionaryEnrichmentResult> enrich(List<String> words) async {
    received.addAll(words);
    return DictionaryEnrichmentResult(
      entries: [
        for (var i = 0; i < words.length; i++)
          EnrichedDictionaryEntry(
            surface: words[i],
            phonetic: '',
            partOfSpeech: 'n.',
            definitionEnglish: 'definition',
            definitionChinese: '释义',
            isValid: i == 0,
          ),
      ],
      sourceId: 'deepseek-v4-flash',
    );
  }
}

class _FailingGateway implements DictionaryEnrichmentGateway {
  @override
  Future<DictionaryEnrichmentResult> enrich(List<String> words) async {
    throw const OnlineEnrichmentException('boom');
  }
}
