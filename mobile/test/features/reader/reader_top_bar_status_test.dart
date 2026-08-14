import 'package:dian_du_ji/features/reader/presentation/widgets/reader_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The reader top bar must cover the edge-to-edge status-bar region with its
/// own background (so the system clock/battery and the document underneath do
/// not show through) while its contents still clear the status bar.
void main() {
  testWidgets('bar background starts at the very top of the screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(2200, 1440);
    tester.view.devicePixelRatio = 1.0;
    tester.view.padding = const FakeViewPadding(top: 48);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              const Positioned.fill(child: ColoredBox(color: Colors.green)),
              ReaderTopBar(
                title: 'Paper',
                visible: true,
                onBack: null,
                onReveal: () {},
                onSettings: null,
              ),
            ],
          ),
        ),
      ),
    );

    // The bar's material background covers the status-bar region: its top
    // edge sits at y=0, above the status bar.
    final barMaterial = find.descendant(
      of: find.byKey(const Key('reader-top-bar')),
      matching: find.byType(Material),
    );
    final rect = tester.getRect(barMaterial.first);
    expect(rect.top, 0);
    expect(rect.height, greaterThanOrEqualTo(48 + kToolbarHeight));

    // Contents still clear the status bar: the back button is below it.
    final backTop = tester
        .getRect(find.byKey(const Key('reader-back-button')))
        .top;
    expect(backTop, greaterThanOrEqualTo(48));
  });
}
