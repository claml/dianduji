import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../features/dictionary/domain/specialized_terms.dart';
import 'online_translation_gateway.dart';

/// Deterministic cache key for an online translation: normalized term, a
/// digest of the disclosed sentence, target language, domain and service
/// version. The full sentence is not stored in the key.
String onlineTranslationCacheKey({
  required String term,
  required String sentence,
  required String targetLanguage,
  required SpecializedDomain? domain,
  required String serviceVersion,
}) {
  final normalizedTerm = term.trim().toLowerCase().replaceAll('’', "'");
  final sentenceDigest = sha256.convert(utf8.encode(sentence)).toString();
  return [
    normalizedTerm,
    sentenceDigest,
    targetLanguage,
    domain?.name ?? '',
    serviceVersion,
  ].join('|');
}

/// Read/write surface for cached online translation results.
abstract interface class OnlineTranslationCacheStore {
  Future<OnlineTranslationResult?> read(String cacheKey);

  Future<void> write(String cacheKey, String term, OnlineTranslationResult result);

  Future<void> clear();
}

/// Online translation gateway that reads-through a local cache: a repeat query
/// is served locally without any network round-trip.
class CachedOnlineTranslationGateway implements OnlineTranslationGateway {
  CachedOnlineTranslationGateway({
    required this.inner,
    required this.cache,
    this.serviceVersion = '1',
  });

  final OnlineTranslationGateway inner;
  final OnlineTranslationCacheStore cache;
  final String serviceVersion;

  @override
  Future<OnlineTranslationResult> translate(
    OnlineTranslationRequest request,
  ) async {
    final key = onlineTranslationCacheKey(
      term: request.term,
      sentence: request.disclosedSentence,
      targetLanguage: request.targetLanguage,
      domain: request.domain,
      serviceVersion: serviceVersion,
    );
    final cached = await cache.read(key);
    if (cached != null) return cached;
    final result = await inner.translate(request);
    await cache.write(key, request.term, result);
    return result;
  }
}
