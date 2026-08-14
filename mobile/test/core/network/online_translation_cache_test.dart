import 'package:dian_du_ji/core/network/online_translation_cache.dart';
import 'package:dian_du_ji/core/network/online_translation_gateway.dart';
import 'package:dian_du_ji/features/dictionary/domain/specialized_terms.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('read-through: cache miss fetches then stores; hit is served locally',
      () async {
    final inner = _CountingGateway();
    final cache = _MemoryCache();
    final gateway = CachedOnlineTranslationGateway(
      inner: inner,
      cache: cache,
    );
    const request = OnlineTranslationRequest(
      term: 'random forest',
      sentence: 'a random forest classifies',
      domain: SpecializedDomain.computerScience,
    );

    final first = await gateway.translate(request);
    final second = await gateway.translate(request);

    expect(first.termTranslation, '随机森林');
    expect(second.termTranslation, '随机森林');
    expect(inner.calls, 1); // second request never touches the network
    expect(cache.entries, hasLength(1));
  });

  test('a failed network call is not cached', () async {
    final inner = _FailingGateway();
    final cache = _MemoryCache();
    final gateway = CachedOnlineTranslationGateway(inner: inner, cache: cache);

    await expectLater(
      () => gateway.translate(const OnlineTranslationRequest(
        term: 'x',
        sentence: 'y',
      )),
      throwsA(isA<OnlineTranslationException>()),
    );
    expect(cache.entries, isEmpty);
  });
}

class _CountingGateway implements OnlineTranslationGateway {
  var calls = 0;

  @override
  Future<OnlineTranslationResult> translate(
    OnlineTranslationRequest request,
  ) async {
    calls++;
    return const OnlineTranslationResult(
      termTranslation: '随机森林',
      sentenceTranslation: '一个随机森林进行分类。',
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

class _MemoryCache implements OnlineTranslationCacheStore {
  final entries = <String, OnlineTranslationResult>{};

  @override
  Future<void> clear() async => entries.clear();

  @override
  Future<OnlineTranslationResult?> read(String cacheKey) async =>
      entries[cacheKey];

  @override
  Future<void> write(
    String cacheKey,
    String term,
    OnlineTranslationResult result,
  ) async {
    entries[cacheKey] = result;
  }
}
