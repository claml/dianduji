import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../features/dictionary/domain/user_dictionary_repository.dart';

/// Enriched entries returned by the LLM gateway.
class DictionaryEnrichmentResult {
  const DictionaryEnrichmentResult({
    required this.entries,
    required this.sourceId,
  });

  final List<EnrichedDictionaryEntry> entries;
  final String sourceId;
}

/// Sends candidate words to the LLM gateway for lexicographic enrichment.
/// Only the words themselves leave the device; no sentences or documents.
abstract interface class DictionaryEnrichmentGateway {
  Future<DictionaryEnrichmentResult> enrich(List<String> words);
}

/// HTTP implementation calling the gateway's `/enrich` endpoint.
class HttpDictionaryEnrichmentGateway implements DictionaryEnrichmentGateway {
  HttpDictionaryEnrichmentGateway({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 90),
    HttpClient Function()? clientFactory,
  }) : _clientFactory = clientFactory ?? HttpClient.new;

  final Uri baseUrl;
  final Duration timeout;
  final HttpClient Function() _clientFactory;

  @override
  Future<DictionaryEnrichmentResult> enrich(List<String> words) async {
    final client = _clientFactory();
    try {
      final uri = baseUrl.resolve('/enrich');
      final bodyBytes = utf8.encode(
        jsonEncode({'words': words}),
      );
      final request = await client.postUrl(uri).timeout(timeout);
      request.headers.contentType = ContentType(
        'application',
        'json',
        charset: 'utf-8',
      );
      request.contentLength = bodyBytes.length;
      request.add(bodyBytes);
      final response = await request.close().timeout(timeout);
      final responseBody = await response
          .transform(utf8.decoder)
          .join()
          .timeout(timeout);
      if (response.statusCode == 503) {
        throw const OnlineEnrichmentException(
          '整理服务未配置：请检查网关 keys.env 中的 DeepSeek API Key',
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'enrich failed with HTTP ${response.statusCode}',
        );
      }
      final decoded = jsonDecode(responseBody);
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('enrich response is not an object');
      }
      final rawEntries = decoded['entries'];
      if (rawEntries is! List<Object?>) {
        throw const FormatException('enrich response has no entries list');
      }
      final entries = <EnrichedDictionaryEntry>[];
      for (final raw in rawEntries) {
        if (raw is! Map<String, Object?>) continue;
        final surface = raw['surface'];
        if (surface is! String || surface.trim().isEmpty) continue;
        entries.add(
          EnrichedDictionaryEntry(
            surface: surface,
            phonetic: raw['phonetic'] as String? ?? '',
            partOfSpeech: raw['partOfSpeech'] as String? ?? '',
            definitionEnglish: raw['definitionEnglish'] as String? ?? '',
            definitionChinese: raw['definitionChinese'] as String? ?? '',
            isValid: raw['isValid'] as bool? ?? true,
          ),
        );
      }
      return DictionaryEnrichmentResult(
        entries: entries,
        sourceId: decoded['sourceId'] as String? ?? 'gateway',
      );
    } on TimeoutException {
      throw const OnlineEnrichmentException('整理超时，请重试');
    } on SocketException {
      throw const OnlineEnrichmentException('网络不可用，请检查网关');
    } finally {
      client.close(force: true);
    }
  }
}

class OnlineEnrichmentException implements Exception {
  const OnlineEnrichmentException(this.message);

  final String message;

  @override
  String toString() => 'OnlineEnrichmentException: $message';
}
