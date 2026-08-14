import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Account & cloud-sync API client for the self-hosted gateway.
///
/// Contract: mobile/docs/gateway-reference/sync-api.md
///   POST /auth/register {username,password} -> 201 {token,user}
///   POST /auth/login    {username,password} -> 200 {token,user}
///   GET  /sync/get      (Bearer) -> 200 {data,updatedAt}
///   POST /sync/put      (Bearer) {data,updatedAt} -> 200 {data,updatedAt,accepted}
///
/// The gateway base URL is injected at build time via `--dart-define`
/// (`DIANDUJI_SYNC_BASE_URL`), defaulting to the local gateway.
const String kDefaultSyncBaseUrl = 'http://127.0.0.1:8080';

enum SyncApiError {
  offline, // network unreachable / timeout
  invalidCredentials, // 401 on login/register conflict-free paths
  usernameTaken, // 409 register
  rejected, // 401 token invalid/expired
  badResponse, // unexpected status or malformed body
}

class SyncApiException implements Exception {
  const SyncApiException(this.error, [this.message = '']);

  final SyncApiError error;
  final String message;

  @override
  String toString() => 'SyncApiException($error, $message)';
}

class SyncUser {
  const SyncUser({required this.id, required this.username});

  final int id;
  final String username;
}

class SyncSnapshot {
  const SyncSnapshot({required this.data, required this.updatedAt});

  final Map<String, Object?> data;
  final int updatedAt; // epoch millis
}

class SyncPutResult {
  const SyncPutResult({
    required this.data,
    required this.updatedAt,
    required this.accepted,
  });

  final Map<String, Object?> data;
  final int updatedAt;
  final bool accepted;
}

/// HTTP implementation against the gateway's /auth and /sync endpoints.
class SyncApiClient {
  SyncApiClient({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 10),
    HttpClient Function()? clientFactory,
  }) : _clientFactory = clientFactory ?? HttpClient.new;

  final Uri baseUrl;
  final Duration timeout;
  final HttpClient Function() _clientFactory;

  Future<({String token, SyncUser user})> register(
    String username,
    String password,
  ) => _authenticate('/auth/register', username, password, accepted: 201);

  Future<({String token, SyncUser user})> login(
    String username,
    String password,
  ) => _authenticate('/auth/login', username, password, accepted: 200);

  Future<SyncSnapshot?> fetch(String token) async {
    final body = await _request('GET', '/sync/get', token: token);
    final decoded = _decode(body, expected: 200);
    final rawData = decoded['data'];
    final updatedAt = decoded['updatedAt'];
    if (rawData is! Map && rawData != null) {
      throw const SyncApiException(SyncApiError.badResponse, 'data shape');
    }
    if (updatedAt is! int) {
      throw const SyncApiException(SyncApiError.badResponse, 'updatedAt');
    }
    final data = rawData is Map
        ? rawData.cast<String, Object?>()
        : null;
    return data == null
        ? null
        : SyncSnapshot(data: data, updatedAt: updatedAt);
  }

  Future<SyncPutResult> push(String token, Map<String, Object?> data, int updatedAt) async {
    final body = await _request(
      'POST',
      '/sync/put',
      token: token,
      payload: {'data': data, 'updatedAt': updatedAt},
    );
    final decoded = _decode(body, expected: 200);
    final rawData = decoded['data'];
    final remoteUpdatedAt = decoded['updatedAt'];
    final accepted = decoded['accepted'];
    if (rawData is! Map || remoteUpdatedAt is! int || accepted is! bool) {
      throw const SyncApiException(SyncApiError.badResponse, 'put shape');
    }
    return SyncPutResult(
      data: rawData.cast<String, Object?>(),
      updatedAt: remoteUpdatedAt,
      accepted: accepted,
    );
  }

  Future<({String token, SyncUser user})> _authenticate(
    String path,
    String username,
    String password, {
    required int accepted,
  }) async {
    final body = await _request(
      'POST',
      path,
      payload: {'username': username, 'password': password},
      acceptedStatuses: const {201, 200},
    );
    final decoded = _decode(body, expected: accepted);
    final token = decoded['token'];
    final user = decoded['user'];
    if (token is! String || user is! Map<String, Object?>) {
      throw const SyncApiException(SyncApiError.badResponse, 'auth shape');
    }
    final id = user['id'];
    final name = user['username'];
    if (id is! int || name is! String) {
      throw const SyncApiException(SyncApiError.badResponse, 'user shape');
    }
    return (token: token, user: SyncUser(id: id, username: name));
  }

  Future<String> _request(
    String method,
    String path, {
    String? token,
    Map<String, Object?>? payload,
    Set<int> acceptedStatuses = const {200},
  }) async {
    final client = _clientFactory();
    try {
      final uri = baseUrl.replace(path: path);
      final request = await client
          .openUrl(method, uri)
          .timeout(timeout);
      if (token != null) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
      if (payload != null) {
        request.headers.contentType = ContentType(
          'application',
          'json',
          charset: 'utf-8',
        );
        final bodyBytes = utf8.encode(jsonEncode(payload));
        request.contentLength = bodyBytes.length;
        request.add(bodyBytes);
      } else {
        request.contentLength = 0;
      }
      final response = await request.close().timeout(timeout);
      final responseBody = await response
          .transform(utf8.decoder)
          .join()
          .timeout(timeout);

      if (response.statusCode == HttpStatus.unauthorized) {
        throw SyncApiException(
          path.startsWith('/auth/')
              ? SyncApiError.invalidCredentials
              : SyncApiError.rejected,
          'HTTP 401',
        );
      }
      if (response.statusCode == HttpStatus.conflict) {
        throw const SyncApiException(SyncApiError.usernameTaken, 'HTTP 409');
      }
      if (!acceptedStatuses.contains(response.statusCode)) {
        throw SyncApiException(
          SyncApiError.badResponse,
          'HTTP ${response.statusCode}',
        );
      }
      return responseBody;
    } on SyncApiException {
      rethrow;
    } on TimeoutException {
      throw const SyncApiException(SyncApiError.offline, 'timeout');
    } on SocketException catch (error) {
      throw SyncApiException(SyncApiError.offline, error.message);
    } on HttpException catch (error) {
      throw SyncApiException(SyncApiError.offline, error.message);
    } on Object catch (error) {
      throw SyncApiException(SyncApiError.offline, error.toString());
    } finally {
      client.close(force: true);
    }
  }

  Map<String, Object?> _decode(String body, {required int expected}) {
    Object? decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException {
      throw SyncApiException(
        SyncApiError.badResponse,
        'malformed JSON (expected HTTP $expected)',
      );
    }
    if (decoded is! Map<String, Object?>) {
      throw const SyncApiException(SyncApiError.badResponse, 'not an object');
    }
    return decoded;
  }
}
