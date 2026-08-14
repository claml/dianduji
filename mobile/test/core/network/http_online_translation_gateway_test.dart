import 'dart:convert';
import 'dart:io';

import 'package:dian_du_ji/core/network/http_online_translation_gateway.dart';
import 'package:dian_du_ji/core/network/online_translation_gateway.dart';
import 'package:dian_du_ji/features/dictionary/domain/specialized_terms.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HttpServer server;
  late Uri baseUrl;

  String? lastBody;
  String? lastQueryKey;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    baseUrl = Uri.parse('http://127.0.0.1:${server.port}/translate');
    server.listen((request) async {
      lastQueryKey = request.uri.queryParameters['key'];
      lastBody = utf8.decode(
        await request.fold<List<int>>([], (a, b) => a..addAll(b)),
      );
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(const {
        'termTranslation': '随机森林',
        'sentenceTranslation': '随机森林对样本进行分类。',
        'domainGloss': '机器学习中的集成方法',
        'examples': [
          {'source': 'Random forests reduce variance.', 'translation': '随机森林降低方差。'},
        ],
        'sourceId': 'test-gateway',
        'cacheVersion': '1',
      }));
      await request.response.close();
    });
  });

  tearDown(() async {
    await server.close(force: true);
  });

  test('sends only the minimal fields and parses the structured result',
      () async {
    final gateway = HttpOnlineTranslationGateway(
      baseUrl: baseUrl,
      apiKey: 'secret',
    );

    final result = await gateway.translate(const OnlineTranslationRequest(
      term: 'random forest',
      sentence: 'A random forest classifies samples.',
      domain: SpecializedDomain.computerScience,
    ));

    expect(result.termTranslation, '随机森林');
    expect(result.sentenceTranslation, '随机森林对样本进行分类。');
    expect(result.domainGloss, '机器学习中的集成方法');
    expect(result.examples, hasLength(1));
    expect(result.sourceId, 'test-gateway');

    // Minimal disclosure: no document metadata, no page text, no device id.
    final sent = jsonDecode(lastBody!) as Map<String, Object?>;
    expect(sent.keys.toSet(), {'term', 'sentence', 'targetLanguage', 'domain'});
    expect(sent['term'], 'random forest');
    expect(sent['sentence'], 'A random forest classifies samples.');
    expect(sent['domain'], 'computerScience');
    expect(lastQueryKey, 'secret');
  });

  test('maps a non-2xx status to badResponse', () async {
    final bad = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    bad.listen((request) {
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.close();
    });
    addTearDown(() => bad.close(force: true));
    final gateway = HttpOnlineTranslationGateway(
      baseUrl: Uri.parse('http://127.0.0.1:${bad.port}/translate'),
    );

    expect(
      () => gateway.translate(const OnlineTranslationRequest(
        term: 'x',
        sentence: 'y',
      )),
      throwsA(isA<OnlineTranslationException>().having(
        (e) => e.error,
        'error',
        OnlineTranslationError.badResponse,
      )),
    );
  });

  test('maps a connection reset to offline', () async {
    // Accept the TCP connection and immediately reset it, which surfaces as
    // a socket/connection failure rather than a timeout.
    final raw = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    raw.listen((socket) => socket.destroy());
    addTearDown(() => raw.close());
    final gateway = HttpOnlineTranslationGateway(
      baseUrl: Uri.parse('http://127.0.0.1:${raw.port}/translate'),
      timeout: const Duration(seconds: 5),
    );

    expect(
      () => gateway.translate(const OnlineTranslationRequest(
        term: 'x',
        sentence: 'y',
      )),
      throwsA(
        isA<OnlineTranslationException>().having(
          (e) => e.error,
          'error',
          isIn(const [OnlineTranslationError.offline, OnlineTranslationError.unknown]),
        ),
      ),
    );
  });

  test('discards a malformed JSON response as badResponse', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final url = Uri.parse('http://127.0.0.1:${server.port}/translate');
    server.listen((request) {
      request.response.headers.contentType = ContentType.json;
      request.response.write('not json at all');
      request.response.close();
    });
    addTearDown(() => server.close(force: true));
    final gateway = HttpOnlineTranslationGateway(baseUrl: url);

    expect(
      () => gateway.translate(const OnlineTranslationRequest(
        term: 'x',
        sentence: 'y',
      )),
      throwsA(isA<OnlineTranslationException>().having(
        (e) => e.error,
        'error',
        OnlineTranslationError.badResponse,
      )),
    );
  });
}
