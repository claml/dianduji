import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A persisted session: the bearer token plus the username for display.
typedef StoredSession = ({String token, String username});

/// Persistent storage for the sync session.
abstract interface class TokenStorage {
  Future<StoredSession?> read();
  Future<void> write(String token, String username);
  Future<void> clear();
}

/// Secure store (Android Keystore-backed) for the session.
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'dianduji.sync.session';

  final FlutterSecureStorage _storage;

  @override
  Future<StoredSession?> read() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, Object?>) return null;
      final token = decoded['token'];
      final username = decoded['username'];
      if (token is! String || token.isEmpty || username is! String) {
        return null;
      }
      return (token: token, username: username);
    } on Object {
      // PlatformException (keystore issue) or MissingPluginException in
      // tests: the sync section degrades to logged-out instead of crashing.
      return null;
    }
  }

  @override
  Future<void> write(String token, String username) async {
    await _storage.write(
      key: _key,
      value: jsonEncode({'token': token, 'username': username}),
    );
  }

  @override
  Future<void> clear() => _storage.delete(key: _key);
}

/// In-memory session storage for tests and widget previews.
class MemoryTokenStorage implements TokenStorage {
  StoredSession? _session;

  @override
  Future<StoredSession?> read() async => _session;

  @override
  Future<void> write(String token, String username) async {
    _session = (token: token, username: username);
  }

  @override
  Future<void> clear() async => _session = null;
}

/// Serializes/deserializes the sync payload. The engine treats it as an
/// opaque JSON object; the app wires its own collector/apply functions.
Map<String, Object?> encodeSyncData(Map<String, Object?> data) => data;

Map<String, Object?> decodeSyncData(String raw) {
  final decoded = jsonDecode(raw);
  if (decoded is! Map<String, Object?>) {
    throw const FormatException('sync data must be an object');
  }
  return decoded.cast<String, Object?>();
}
