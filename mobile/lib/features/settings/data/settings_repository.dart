import 'dart:async';
import 'dart:convert';

import '../../../core/database/app_database.dart';
import 'reading_settings.dart';

abstract interface class SettingsRepository {
  Stream<ReadingSettings> watch();
  Future<ReadingSettings> load();
  Future<void> save(ReadingSettings settings);
}

class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._dao);

  static const _key = 'reading-settings';

  final SettingsDao _dao;
  final StreamController<ReadingSettings> _changes =
      StreamController<ReadingSettings>.broadcast();

  @override
  Stream<ReadingSettings> watch() async* {
    yield await load();
    yield* _changes.stream;
  }

  @override
  Future<ReadingSettings> load() async {
    final value = await _dao.getValue(_key);
    if (value == null) return ReadingSettings();
    try {
      final decoded = jsonDecode(value);
      if (decoded is! Map<String, Object?>) return ReadingSettings();
      return ReadingSettings.tryFromJson(decoded);
    } on Object {
      return ReadingSettings();
    }
  }

  @override
  Future<void> save(ReadingSettings settings) async {
    await _dao.setValue(_key, jsonEncode(settings.toJson()));
    _changes.add(settings);
  }

  void dispose() => _changes.close();
}
