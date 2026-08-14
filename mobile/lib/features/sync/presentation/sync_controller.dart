import 'package:flutter/foundation.dart';

import '../domain/sync_api_client.dart';
import '../domain/sync_engine.dart';

enum SyncUiStatus { loggedOut, working, loggedIn }

class SyncUiState {
  const SyncUiState({
    this.status = SyncUiStatus.loggedOut,
    this.username,
    this.errorMessage,
    this.lastSyncAt,
    this.syncing = false,
  });

  final SyncUiStatus status;
  final String? username;
  final String? errorMessage;
  final DateTime? lastSyncAt;
  final bool syncing;

  SyncUiState copyWith({
    SyncUiStatus? status,
    String? username,
    String? errorMessage,
    DateTime? lastSyncAt,
    bool? syncing,
    bool clearError = false,
  }) => SyncUiState(
    status: status ?? this.status,
    username: username ?? this.username,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    syncing: syncing ?? this.syncing,
  );
}

/// ChangeNotifier state machine for the login/sync section of the settings
/// page. Keeps the engine; all session persistence lives in the engine.
class SyncController extends ChangeNotifier {
  SyncController({
    required SyncEngine engine,
  })  :
        // ignore: prefer_initializing_formals — private field, public name.
        _engine = engine {
    _restore();
  }

  final SyncEngine _engine;

  SyncUiState _state = const SyncUiState();
  SyncUiState get state => _state;

  String? get _username => _engine.user?.username;

  Future<void> _restore() async {
    final restored = await _engine.restoreSession();
    if (restored) {
      _state = _state.copyWith(
        status: SyncUiStatus.loggedIn,
        username: _username,
      );
      notifyListeners();
    }
  }

  Future<void> register(String username, String password) =>
      _authenticate(() => _engine.register(username, password));

  Future<void> login(String username, String password) =>
      _authenticate(() => _engine.login(username, password));

  Future<void> _authenticate(Future<SyncUser> Function() action) async {
    _setWorking();
    try {
      await action();
      _state = _state.copyWith(
        status: SyncUiStatus.loggedIn,
        username: _username,
        clearError: true,
        syncing: false,
      );
    } on SyncApiException catch (error) {
      _state = _state.copyWith(
        status: SyncUiStatus.loggedOut,
        errorMessage: _describe(error),
        syncing: false,
      );
    } on Object catch (error) {
      _state = _state.copyWith(
        status: SyncUiStatus.loggedOut,
        errorMessage: error.toString(),
        syncing: false,
      );
    }
    notifyListeners();
  }

  Future<void> syncNow() async {
    _state = _state.copyWith(syncing: true, clearError: true);
    notifyListeners();
    try {
      final outcome = await _engine.syncNow();
      _state = _state.copyWith(
        syncing: false,
        lastSyncAt: DateTime.now(),
        errorMessage: outcome.pushedLocal ? null : null,
      );
      // Surface what happened through the message only on failure paths.
    } on SyncApiException catch (error) {
      _state = _state.copyWith(
        syncing: false,
        errorMessage: _describe(error),
      );
      if (error.error == SyncApiError.rejected) {
        _state = _state.copyWith(
          status: SyncUiStatus.loggedOut,
          username: null,
        );
      }
    } on Object catch (error) {
      _state = _state.copyWith(syncing: false, errorMessage: error.toString());
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _engine.logout();
    _state = const SyncUiState();
    notifyListeners();
  }

  void clearError() {
    _state = _state.copyWith(clearError: true);
    notifyListeners();
  }

  void _setWorking() {
    _state = _state.copyWith(
      status: SyncUiStatus.working,
      clearError: true,
      syncing: false,
    );
  }

  String _describe(SyncApiException error) => switch (error.error) {
    SyncApiError.offline => '网络不可用，请检查连接后重试',
    SyncApiError.invalidCredentials => '用户名或密码错误',
    SyncApiError.usernameTaken => '用户名已被注册',
    SyncApiError.rejected => '登录已过期，请重新登录',
    SyncApiError.badResponse => '服务器响应异常，请稍后重试',
  };
}
