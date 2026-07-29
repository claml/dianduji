import 'package:dian_du_ji/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the document library shell', (tester) async {
    await tester.pumpWidget(const DianDuJiApp());

    expect(find.text('文档'), findsWidgets);
    expect(find.text('导入文档'), findsWidgets);
  });

  testWidgets('bottom navigation opens learning and settings screens', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const DianDuJiApp());

    await tester.tap(find.text('生词').last);
    await tester.pumpAndSettle();
    expect(find.text('生词本'), findsOneWidget);

    await tester.tap(find.text('设置').last);
    await tester.pumpAndSettle();
    expect(find.text('阅读外观'), findsOneWidget);
  });

  testWidgets('settings change the application theme immediately', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const DianDuJiApp());
    await tester.tap(find.text('设置').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('夜间'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });
}
