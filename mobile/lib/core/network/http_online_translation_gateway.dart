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
///
/// The paid gateway endpoints require a login session: [tokenProvider]
/// supplies the current bearer token (null when logged out, in which case
/// every call fails with [OnlineTranslationError.unauthorized]).
class HttpOnlineTranslationGateway implements OnlineTranslationGateway {
  HttpOnlineTranslationGateway({
    required this.baseUrl,
    this.apiKey,
    this.timeout = const Duration(seconds: 8),
    String? Function()? tokenProvider,
    HttpClient Function()? clientFactory,
  })  :
        // ignore: prefer_initializing_formals — private field, public name.
        _tokenProvider = tokenProvider,
        _clientFactory = clientFactory ?? HttpClient.new;

  final Uri baseUrl;
  final String? apiKey;
  final Duration timeout;
  final String? Function()? _tokenProvider;
  final HttpClient Function() _clientFactory;

  @override
  Future<OnlineTranslationResult> translate(
    OnlineTranslationRequest request,
  ) async {
    final token = _tokenProvider?.call();
    if (token == null) {
      throw const OnlineTranslationException(
        OnlineTranslationError.unauthorized,
        'login required',
      );
    }
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
      httpRequest.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      // Explicit Content-Length: Dart's HttpClient otherwise streams the body
      // with chunked transfer encoding, which simple reference gateways that
      // read Content-Length (e.g. Python http.server) reject with 400.
      final bodyBytes = utf8.encode(jsonEncode(body));
      httpRequest.contentLength = bodyBytes.length;
      httpRequest.add(bodyBytes);

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
