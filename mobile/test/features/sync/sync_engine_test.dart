import 'dart:convert';
import 'dart:io';

import 'package:dian_du_ji/features/sync/domain/sync_api_client.dart';
import 'package:dian_du_ji/features/sync/domain/sync_engine.dart';
import 'package:dian_du_ji/features/sync/domain/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// Routes: path -> handler(method, headers, body) -> (status, jsonBody).
typedef _RouteHandler =
    (int, Map<String, Object?>) Function(
      String method,
      Map<String, String> headers,
      Map<String, Object?> body,
    );

void main() {
  group('SyncApiClient', () {
    test('register returns token and user', () async {
      final server = await _startServer({
        '/auth/register': (method, headers, body) => (
          201,
          {'token': 't1', 'user': {'id': 1, 'username': 'alice'}},
        ),
      });
      addTearDown(server.close);
      final api = SyncApiClient(
        baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
      );
      final result = await api.register('alice', 'secret1');
      expect(result.token, 't1');
      expect(result.user.username, 'alice');
    });

    test('login maps 401 to invalidCredentials', () async {
      final server = await _startServer({
        '/auth/login': (method, headers, body) => (
          401,
          {'error': 'invalid credentials'},
        ),
      });
      addTearDown(server.close);
      final api = SyncApiClient(
        baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
      );
      await expectLater(
        api.login('alice', 'wrong'),
        throwsA(isA<SyncApiException>().having(
          (e) => e.error,
          'error',
          SyncApiError.invalidCredentials,
        )),
      );
    });

    test('register maps 409 to usernameTaken', () async {
      final server = await _startServer({
        '/auth/register': (method, headers, body) => (
          409,
          {'error': 'username already taken'},
        ),
      });
      addTearDown(server.close);
      final api = SyncApiClient(
        baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
      );
      await expectLater(
        api.register('alice', 'secret1'),
        throwsA(isA<SyncApiException>().having(
          (e) => e.error,
          'error',
          SyncApiError.usernameTaken,
        )),
      );
    });

    test('fetch returns null when no remote data exists', () async {
      final server = await _startServer({
        '/sync/get': (method, headers, body) => (
          200,
          {'data': null, 'updatedAt': 0},
        ),
      });
      addTearDown(server.close);
      final api = SyncApiClient(
        baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
      );
      expect(await api.fetch('tok'), isNull);
    });

    test('push sends the Authorization header and parses accepted', () async {
      String? seenAuth;
      final server = await _startServer({
        '/sync/put': (method, headers, body) {
          seenAuth = headers['authorization'];
          return (
            200,
            {'data': {'vocabulary': ['cell']}, 'updatedAt': 100, 'accepted': true},
          );
        },
      });
      addTearDown(server.close);
      final api = SyncApiClient(
        baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
      );
      final result = await api.push('tok', {'vocabulary': ['cell']}, 100);
      expect(result.accepted, isTrue);
      expect(seenAuth, 'Bearer tok');
    });
  });

  group('SyncEngine', () {
    test('login stores the token and syncNow pushes a newer local snapshot',
        () async {
      final server = await _startServer({
        '/auth/login': (method, headers, body) => (
          200,
          {'token': 't1', 'user': {'id': 1, 'username': 'alice'}},
        ),
        '/sync/get': (method, headers, body) => (
          200,
          {'data': {'vocabulary': ['old']}, 'updatedAt': 50},
        ),
        '/sync/put': (method, headers, body) => (
          200,
          {'data': {'vocabulary': ['new']}, 'updatedAt': 100, 'accepted': true},
        ),
      });
      addTearDown(server.close);
      final api = SyncApiClient(
        baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
      );
      final storage = MemoryTokenStorage();
      final local = _MemoryLocalData(
        data: {'vocabulary': ['new']},
        updatedAt: 100,
      );
      final engine = SyncEngine(api: api, storage: storage, local: local);

      await engine.login('alice', 'secret1');
      expect(engine.isLoggedIn, isTrue);
      expect((await storage.read())?.token, 't1');
      expect((await storage.read())?.username, 'alice');

      final outcome = await engine.syncNow();
      expect(outcome.pushedLocal, isTrue);
      expect(local.applied, isNull);
    });

    test('a newer remote snapshot is applied locally', () async {
      final server = await _startServer({
        '/auth/login': (method, headers, body) => (
          200,
          {'token': 't1', 'user': {'id': 1, 'username': 'alice'}},
        ),
        '/sync/get': (method, headers, body) => (
          200,
          {'data': {'vocabulary': ['remote']}, 'updatedAt': 200},
        ),
      });
      addTearDown(server.close);
      final api = SyncApiClient(
        baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
      );
      final local = _MemoryLocalData(
        data: {'vocabulary': ['local']},
        updatedAt: 100,
      );
      final engine = SyncEngine(
        api: api,
        storage: MemoryTokenStorage(),
        local: local,
      );
      await engine.login('alice', 'secret1');

      final outcome = await engine.syncNow();
      expect(outcome.appliedRemote, isTrue);
      expect(local.applied, isNotNull);
      expect(local.applied!.data['vocabulary'], ['remote']);
    });

    test('a rejected token clears the session', () async {
      final server = await _startServer({
        '/auth/login': (method, headers, body) => (
          200,
          {'token': 'expired', 'user': {'id': 1, 'username': 'alice'}},
        ),
        '/sync/get': (method, headers, body) => (
          401,
          {'error': 'invalid or expired token'},
        ),
      });
      addTearDown(server.close);
      final api = SyncApiClient(
        baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
      );
      final storage = MemoryTokenStorage();
      final engine = SyncEngine(
        api: api,
        storage: storage,
        local: _MemoryLocalData(data: const {}, updatedAt: 1),
      );
      await engine.login('alice', 'secret1');

      await expectLater(engine.syncNow(), throwsA(isA<SyncApiException>()));
      expect(engine.isLoggedIn, isFalse);
      expect(await storage.read(), isNull);
    });

    test('logout clears the stored token', () async {
      final server = await _startServer({
        '/auth/login': (method, headers, body) => (
          200,
          {'token': 't1', 'user': {'id': 1, 'username': 'alice'}},
        ),
      });
      addTearDown(server.close);
      final api = SyncApiClient(
        baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
      );
      final storage = MemoryTokenStorage();
      final engine = SyncEngine(
        api: api,
        storage: storage,
        local: _MemoryLocalData(data: const {}, updatedAt: 0),
      );
      await engine.login('alice', 'secret1');
      await engine.logout();
      expect(engine.isLoggedIn, isFalse);
      expect(await storage.read(), isNull);
    });

    test('restores the username on a fresh engine', () async {
      final server = await _startServer({
        '/auth/login': (method, headers, body) => (
          200,
          {'token': 't1', 'user': {'id': 1, 'username': 'alice'}},
        ),
      });
      addTearDown(server.close);
      final api = SyncApiClient(
        baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
      );
      final storage = MemoryTokenStorage();
      final engine = SyncEngine(
        api: api,
        storage: storage,
        local: _MemoryLocalData(data: const {}, updatedAt: 0),
      );
      await engine.login('alice', 'secret1');

      // A fresh engine over the same storage restores token and username.
      final restored = SyncEngine(
        api: api,
        storage: storage,
        local: _MemoryLocalData(data: const {}, updatedAt: 0),
      );
      expect(await restored.restoreSession(), isTrue);
      expect(restored.isLoggedIn, isTrue);
      expect(restored.user?.username, 'alice');
    });
  });
}

Future<HttpServer> _startServer(
  Map<String, _RouteHandler> routes,
) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((request) async {
    final body = await utf8.decoder.bind(request).join();
    Map<String, Object?> parsed = {};
    if (body.isNotEmpty) {
      try {
        parsed = (jsonDecode(body) as Map).cast<String, Object?>();
      } on FormatException {
        // leave empty
      }
    }
    final handler = routes[request.uri.path];
    if (handler == null) {
      request.response.statusCode = 404;
      request.response.write('{"error":"not found"}');
    } else {
      final headers = <String, String>{};
      request.headers.forEach((name, values) => headers[name] = values.join(','));
      final (status, json) = handler(request.method, headers, parsed);
      request.response.statusCode = status;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(json));
    }
    await request.response.close();
  });
  return server;
}

class _MemoryLocalData implements LocalDataProvider {
  _MemoryLocalData({required this.data, required this.updatedAt});

  Map<String, Object?> data;
  int updatedAt;
  ({Map<String, Object?> data, int updatedAt})? applied;

  @override
  Future<({Map<String, Object?> data, int updatedAt})> collect() async =>
      (data: data, updatedAt: updatedAt);

  @override
  Future<void> apply(Map<String, Object?> data, int updatedAt) async {
    this.data = data;
    this.updatedAt = updatedAt;
    applied = (data: data, updatedAt: updatedAt);
  }
}
