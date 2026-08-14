import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'online_translation_gateway.dart';

/// Minimal JSON contract accepted by the gateway (see
/// docs/online-translation-gateway.md). The response must be structured; a
/// malformed response is discarded and never reaches the card.
const _kAcceptJson = 'application/json';

/// HTTP implementation of [OnlineTranslationGateway].
///
/// The base URL and API key are injected at build time via `--dart-define`
/// (`DIANDUJI_TRANSLATE_BASE_URL`, `DIANDUJI_TRANSLATE_API_KEY`); neither is
/// hard-coded into the package.
class HttpOnlineTranslationGateway implements OnlineTranslationGateway {
  HttpOnlineTranslationGateway({
    required this.baseUrl,
    this.apiKey,
    this.timeout = const Duration(seconds: 8),
    HttpClient Function()? clientFactory,
  }) : _clientFactory = clientFactory ?? HttpClient.new;

  final Uri baseUrl;
  final String? apiKey;
  final Duration timeout;
  final HttpClient Function() _clientFactory;

  @override
  Future<OnlineTranslationResult> translate(
    OnlineTranslationRequest request,
  ) async {
    final client = _clientFactory();
    try {
      final body = <String, Object?>{
        'term': request.term,
        'sentence': request.disclosedSentence,
        'targetLanguage': request.targetLanguage,
        if (request.domain != null) 'domain': request.domain!.name,
      };
      final uri = baseUrl.replace(
        queryParameters: apiKey == null ? null : {'key': apiKey},
      );
      final httpRequest = await client
          .postUrl(uri)
          .timeout(timeout);
      httpRequest.headers.contentType = ContentType(
        'application',
        'json',
        charset: 'utf-8',
      );
      httpRequest.headers.set(HttpHeaders.acceptHeader, _kAcceptJson);
      httpRequest.write(jsonEncode(body));

      final response = await httpRequest.close().timeout(timeout);
      final responseBody = await response
          .transform(utf8.decoder)
          .join()
          .timeout(timeout);

      if (response.statusCode == HttpStatus.unauthorized ||
          response.statusCode == HttpStatus.forbidden) {
        throw const OnlineTranslationException(
          OnlineTranslationError.unauthorized,
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw OnlineTranslationException(
          OnlineTranslationError.badResponse,
          'HTTP ${response.statusCode}',
        );
      }
      return _parse(responseBody);
    } on OnlineTranslationException {
      rethrow;
    } on TimeoutException {
      throw const OnlineTranslationException(OnlineTranslationError.timeout);
    } on SocketException catch (error) {
      throw OnlineTranslationException(
        OnlineTranslationError.offline,
        error.message,
      );
    } on HttpException catch (error) {
      throw OnlineTranslationException(
        OnlineTranslationError.offline,
        error.message,
      );
    } on Object catch (error) {
      throw OnlineTranslationException(
        OnlineTranslationError.unknown,
        error.toString(),
      );
    } finally {
      client.close(force: true);
    }
  }

  OnlineTranslationResult _parse(String responseBody) {
    Object? decoded;
    try {
      decoded = jsonDecode(responseBody);
    } on FormatException {
      throw const OnlineTranslationException(
        OnlineTranslationError.badResponse,
        'malformed JSON',
      );
    }
    if (decoded is! Map<String, Object?>) {
      throw const OnlineTranslationException(
        OnlineTranslationError.badResponse,
      );
    }
    final termTranslation = decoded['termTranslation'];
    final sentenceTranslation = decoded['sentenceTranslation'];
    if (termTranslation is! String || sentenceTranslation is! String) {
      throw const OnlineTranslationException(
        OnlineTranslationError.badResponse,
        'missing translations',
      );
    }
    final rawExamples = decoded['examples'];
    final examples = <OnlineExample>[];
    if (rawExamples is List<Object?>) {
      for (final raw in rawExamples) {
        if (raw is! Map<String, Object?>) continue;
        final source = raw['source'];
        final translation = raw['translation'];
        if (source is String && translation is String) {
          examples.add(OnlineExample(source: source, translation: translation));
        }
      }
    }
    return OnlineTranslationResult(
      termTranslation: termTranslation,
      sentenceTranslation: sentenceTranslation,
      domainGloss: decoded['domainGloss'] as String? ?? '',
      examples: examples,
      sourceId: decoded['sourceId'] as String? ?? 'gateway',
      cacheVersion: decoded['cacheVersion'] as String? ?? '1',
    );
  }
}
