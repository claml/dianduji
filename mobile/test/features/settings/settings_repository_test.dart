import 'dart:convert';

import 'package:dian_du_ji/core/database/app_database.dart';
import 'package:dian_du_ji/features/settings/data/reading_settings.dart';
import 'package:dian_du_ji/features/settings/data/settings_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftSettingsRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftSettingsRepository(database.settingsDao);
  });

  tearDown(() => database.close());

  test(
    'falls back to defaults when persisted settings are malformed',
    () async {
      await database.settingsDao.setValue('reading-settings', '{invalid-json');

      expect(await repository.load(), ReadingSettings());
    },
  );

  test('round trips reading settings through the database', () async {
    final settings = ReadingSettings(
      theme: ReaderTheme.eyeCare,
      fontSize: 20,
      lineHeight: 1.8,
      autoSaveVocabulary: false,
    );

    await repository.save(settings);

    expect(await repository.load(), settings);
    expect(
      jsonDecode((await database.settingsDao.getValue('reading-settings'))!),
      settings.toJson(),
    );
  });
}
