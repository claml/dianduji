import 'sync_api_client.dart';
import 'token_storage.dart';

/// Supplies and consumes the local learning data snapshot.
///
/// The engine stays repository-agnostic: the app wires this provider to
/// its vocabulary/phrases/progress/settings repositories and marks
/// `updatedAt` with the newest local change time.
abstract interface class LocalDataProvider {
  Future<({Map<String, Object?> data, int updatedAt})> collect();
  Future<void> apply(Map<String, Object?> data, int updatedAt);
}

class SyncOutcome {
  const SyncOutcome({
    required this.appliedRemote,
    required this.pushedLocal,
    required this.remoteUpdatedAt,
  });

  /// Remote snapshot was newer and has been applied locally.
  final bool appliedRemote;

  /// Local snapshot was newer and has been pushed.
  final bool pushedLocal;

  final int remoteUpdatedAt;
}

/// Orchestrates authentication and one-shot last-write-wins sync against
/// the gateway (contract: mobile/docs/gateway-reference/sync-api.md).
class SyncEngine {
  SyncEngine({
    required SyncApiClient api,
    required TokenStorage storage,
    required LocalDataProvider local,
  })  :
        // ignore: prefer_initializing_formals — private field, public name.
        _api = api,
        // ignore: prefer_initializing_formals — private field, public name.
        _storage = storage,
        // ignore: prefer_initializing_formals — private field, public name.
        _local = local;

  final SyncApiClient _api;
  final TokenStorage _storage;
  final LocalDataProvider _local;

  String? _token;
  SyncUser? _user;

  SyncUser? get user => _user;
  bool get isLoggedIn => _token != null;

  /// Restores a previously stored session without network traffic.
  Future<bool> restoreSession() async {
    final token = await _storage.read();
    if (token == null || token.isEmpty) return false;
    _token = token;
    return true;
  }

  Future<SyncUser> register(String username, String password) async {
    final result = await _api.register(username, password);
    await _storeSession(result.token, result.user);
    return result.user;
  }

  Future<SyncUser> login(String username, String password) async {
    final result = await _api.login(username, password);
    await _storeSession(result.token, result.user);
    return result.user;
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    await _storage.clear();
  }

  /// Pulls the remote snapshot, applies last-write-wins, and pushes when
  /// the local snapshot is newer. Throws [SyncApiException] on failure;
  /// a rejected token clears the session.
  Future<SyncOutcome> syncNow() async {
    final token = _requireToken();
    try {
      final remote = await _api.fetch(token);
      final local = await _local.collect();

      if (remote == null || local.updatedAt > remote.updatedAt) {
        final result = await _api.push(token, local.data, local.updatedAt);
        if (!result.accepted) {
          // The server had a newer snapshot after all; adopt it.
          await _local.apply(result.data, result.updatedAt);
          return SyncOutcome(
            appliedRemote: true,
            pushedLocal: false,
            remoteUpdatedAt: result.updatedAt,
          );
        }
        return SyncOutcome(
          appliedRemote: false,
          pushedLocal: true,
          remoteUpdatedAt: result.updatedAt,
        );
      }

      await _local.apply(remote.data, remote.updatedAt);
      return SyncOutcome(
        appliedRemote: true,
        pushedLocal: false,
        remoteUpdatedAt: remote.updatedAt,
      );
    } on SyncApiException catch (error) {
      if (error.error == SyncApiError.rejected) {
        await logout();
      }
      rethrow;
    }
  }

  String _requireToken() {
    final token = _token;
    if (token == null) {
      throw const SyncApiException(SyncApiError.rejected, 'not logged in');
    }
    return token;
  }

  Future<void> _storeSession(String token, SyncUser user) async {
    _token = token;
    _user = user;
    await _storage.write(token);
  }
}
