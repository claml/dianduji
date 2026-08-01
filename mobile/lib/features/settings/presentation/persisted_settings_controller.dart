import 'package:flutter/foundation.dart';

import '../data/reading_settings.dart';
import '../data/settings_repository.dart';

@immutable
class PersistedSettingsState {
  const PersistedSettingsState({
    this.settings,
    this.isLoading = true,
    this.loadError,
    this.saveError,
  });

  final ReadingSettings? settings;
  final bool isLoading;
  final Object? loadError;
  final Object? saveError;
}

class PersistedSettingsController extends ChangeNotifier {
  PersistedSettingsController(this._repository) {
    _ready = _load();
  }

  final SettingsRepository _repository;
  var _state = const PersistedSettingsState();
  Future<void> _ready = Future.value();
  Future<void> _saveTail = Future.value();
  var _saveGeneration = 0;
  int? _saveErrorGeneration;
  var _isDisposed = false;

  PersistedSettingsState get state => _state;
  Future<void> get ready => _ready;

  Future<void> retry() {
    _ready = _load();
    return _ready;
  }

  Future<void> _load() async {
    _state = const PersistedSettingsState();
    notifyListeners();
    try {
      final settings = await _repository.load();
      _state = PersistedSettingsState(settings: settings, isLoading: false);
    } on Object catch (error) {
      _state = PersistedSettingsState(isLoading: false, loadError: error);
    }
    notifyListeners();
  }

  Future<void> updateTheme(ReaderTheme value) =>
      _update((current) => _copy(current, theme: value));

  Future<void> updateFontSize(double value) =>
      _update((current) => _copy(current, fontSize: value));

  Future<void> updateLineHeight(double value) =>
      _update((current) => _copy(current, lineHeight: value));

  Future<void> updateAutoSaveVocabulary(bool value) =>
      _update((current) => _copy(current, autoSaveVocabulary: value));

  Future<void> retrySave() {
    final current = _state.settings;
    if (current == null) {
      throw StateError('Settings are not available.');
    }
    return _enqueueSave(current);
  }

  Future<void> _update(ReadingSettings Function(ReadingSettings) transform) {
    final current = _state.settings;
    if (current == null) {
      throw StateError('Settings are not available.');
    }
    final next = transform(current);
    _state = PersistedSettingsState(
      settings: next,
      isLoading: false,
      saveError: _state.saveError,
    );
    notifyListeners();

    return _enqueueSave(next);
  }

  Future<void> _enqueueSave(ReadingSettings settings) {
    final generation = ++_saveGeneration;
    final operation = _saveTail.then((_) => _repository.save(settings));
    _saveTail = operation.then<void>(
      (_) {
        if (_isDisposed) return;
        final errorGeneration = _saveErrorGeneration;
        if (errorGeneration == null || generation < errorGeneration) return;
        _saveErrorGeneration = null;
        _state = PersistedSettingsState(
          settings: _state.settings,
          isLoading: false,
        );
        notifyListeners();
      },
      onError: (Object error, StackTrace _) {
        if (_isDisposed) return;
        _saveErrorGeneration = generation;
        _state = PersistedSettingsState(
          settings: _state.settings,
          isLoading: false,
          saveError: error,
        );
        notifyListeners();
      },
    );
    return operation;
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

ReadingSettings _copy(
  ReadingSettings current, {
  ReaderTheme? theme,
  double? fontSize,
  double? lineHeight,
  bool? autoSaveVocabulary,
}) => ReadingSettings(
  theme: theme ?? current.theme,
  fontSize: fontSize ?? current.fontSize,
  lineHeight: lineHeight ?? current.lineHeight,
  autoSaveVocabulary: autoSaveVocabulary ?? current.autoSaveVocabulary,
);
