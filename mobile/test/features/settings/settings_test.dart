import 'package:dian_du_ji/features/settings/data/reading_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('valid settings round trip through persisted JSON', () {
    final settings = ReadingSettings(
      theme: ReaderTheme.eyeCare,
      fontSize: 20,
      lineHeight: 1.8,
      autoSaveVocabulary: false,
    );

    expect(ReadingSettings.fromJson(settings.toJson()), settings);
  });

  test('rejects font size and line height outside mobile-safe ranges', () {
    expect(() => ReadingSettings(fontSize: 11), throwsArgumentError);
    expect(() => ReadingSettings(lineHeight: 2.1), throwsArgumentError);
  });

  test('falls back to defaults when persisted settings are malformed', () {
    expect(
      ReadingSettings.tryFromJson({'theme': 'unknown', 'fontSize': 'large'}),
      ReadingSettings(),
    );
  });
}
