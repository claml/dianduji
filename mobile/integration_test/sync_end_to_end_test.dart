import 'package:dian_du_ji/features/sync/domain/sync_api_client.dart';
import 'package:dian_du_ji/features/sync/domain/sync_engine.dart';
import 'package:dian_du_ji/features/sync/domain/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// On-device end-to-end check against the self-hosted gateway.
///
/// Requires the gateway on the host and the adb reverse tunnel:
///   adb reverse tcp:8080 tcp:8080
/// so the device's 127.0.0.1:8080 reaches the host gateway.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  test('register, sync, and restore the session against the gateway', () async {
    final api = SyncApiClient(baseUrl: Uri.parse('http://127.0.0.1:8080'));
    final storage = MemoryTokenStorage();
    final username = 'e2e_${DateTime.now().millisecondsSinceEpoch}';

    final engine = SyncEngine(
      api: api,
      storage: storage,
      local: const _NoopLocalData(),
    );
    await engine.register(username, 'secret1');
    expect(engine.isLoggedIn, isTrue);
    expect(engine.user?.username, username);

    final outcome = await engine.syncNow();
    expect(outcome.pushedLocal || outcome.appliedRemote, isTrue);

    // A fresh engine over the same storage restores token and username,
    // mirroring an app restart.
    final restored = SyncEngine(
      api: api,
      storage: storage,
      local: const _NoopLocalData(),
    );
    expect(await restored.restoreSession(), isTrue);
    expect(restored.user?.username, username);

    await restored.logout();
    expect(restored.isLoggedIn, isFalse);
  });
}

class _NoopLocalData implements LocalDataProvider {
  const _NoopLocalData();

  @override
  Future<({Map<String, Object?> data, int updatedAt})> collect() async => (
    data: const <String, Object?>{},
    updatedAt: DateTime.now().millisecondsSinceEpoch,
  );

  @override
  Future<void> apply(Map<String, Object?> data, int updatedAt) async {}
}
