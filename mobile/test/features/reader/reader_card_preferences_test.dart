import 'package:dian_du_ji/core/database/app_database.dart';
import 'package:dian_du_ji/features/reader/data/reader_card_preferences.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults to a tablet side pane', () {
    const preferences = ReaderCardPreferences.defaults;

    expect(preferences.mode, ReaderCardMode.sidePane);
    expect(preferences.relativeX, inInclusiveRange(0, 1));
    expect(preferences.relativeY, inInclusiveRange(0, 1));
  });

  test('round-trips and clamps floating position', () {
    final preferences = ReaderCardPreferences(
      mode: ReaderCardMode.floating,
      relativeX: 1.8,
      relativeY: -0.4,
    );

    expect(preferences.relativeX, 1);
    expect(preferences.relativeY, 0);
    expect(
      ReaderCardPreferences.tryFromJson(preferences.toJson()),
      preferences,
    );
  });

  test('invalid preference fields fall back safely', () {
    expect(
      ReaderCardPreferences.tryFromJson(const {
        'mode': 'detached',
        'relativeX': 'right',
        'relativeY': null,
      }),
      ReaderCardPreferences.defaults,
    );
  });

  test('persists card preferences separately from reading settings', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = ReaderCardPreferencesRepository(database.settingsDao);
    final expected = ReaderCardPreferences(
      mode: ReaderCardMode.floating,
      relativeX: 0.72,
      relativeY: 0.25,
    );

    await repository.save(expected);

    expect(await repository.load(), expected);
    expect(await database.settingsDao.countSettings(), 1);
  });
}
