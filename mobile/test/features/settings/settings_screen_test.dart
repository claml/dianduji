import 'package:dian_du_ji/features/settings/data/reading_settings.dart';
import 'package:dian_du_ji/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('updates theme and automatic vocabulary preferences', (
    tester,
  ) async {
    final changes = <ReadingSettings>[];
    await tester.pumpWidget(
      MaterialApp(home: SettingsScreen(onChanged: changes.add)),
    );

    await tester.tap(find.text('护眼'));
    await tester.pump();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();

    expect(changes.last.theme, ReaderTheme.eyeCare);
    expect(changes.last.autoSaveVocabulary, isFalse);
    expect(find.text('字号 16'), findsOneWidget);
    expect(find.text('行距 1.6'), findsOneWidget);
  });
}
