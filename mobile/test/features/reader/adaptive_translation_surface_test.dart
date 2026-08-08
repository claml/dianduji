import 'package:dian_du_ji/features/reader/data/reader_card_preferences.dart';
import 'package:dian_du_ji/features/reader/presentation/widgets/adaptive_translation_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('uses a bottom translation card on phones', (tester) async {
    await tester.binding.setSurfaceSize(const Size(412, 915));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: _Harness()));

    expect(find.byKey(const Key('translation-bottom-sheet')), findsOneWidget);
    expect(find.byKey(const Key('translation-side-pane')), findsNothing);
    expect(find.byKey(const Key('translation-floating-card')), findsNothing);
  });

  testWidgets('floats, clamps, resizes, and docks on tablets', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: _Harness()));

    expect(find.byKey(const Key('translation-side-pane')), findsOneWidget);
    await tester.tap(find.byKey(const Key('reader-float-card')));
    await tester.pump();

    expect(find.byKey(const Key('translation-floating-card')), findsOneWidget);
    await tester.drag(
      find.byKey(const Key('translation-floating-drag-handle')),
      const Offset(2000, 2000),
    );
    await tester.pump();
    _expectContained(tester);

    await tester.binding.setSurfaceSize(const Size(800, 1280));
    await tester.pump();
    _expectContained(tester);

    await tester.tap(find.byKey(const Key('reader-dock-card')));
    await tester.pump();
    expect(find.byKey(const Key('translation-side-pane')), findsOneWidget);
    expect(find.byKey(const Key('translation-floating-card')), findsNothing);
  });

  testWidgets(
    'contains a draggable floating card when tablet height is below 280',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 240));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const MaterialApp(home: _Harness()));

      await tester.tap(find.byKey(const Key('reader-float-card')));
      await tester.pump();
      _expectContained(tester);
      expect(
        tester
            .getSize(find.byKey(const Key('translation-floating-card')))
            .height,
        240,
      );

      await tester.drag(
        find.byKey(const Key('translation-floating-drag-handle')),
        const Offset(2000, 2000),
      );
      await tester.pump();
      _expectContained(tester);

      await tester.binding.setSurfaceSize(const Size(700, 220));
      await tester.pump();
      _expectContained(tester);
      expect(
        tester
            .getSize(find.byKey(const Key('translation-floating-card')))
            .height,
        220,
      );
    },
  );
}

void _expectContained(WidgetTester tester) {
  final viewport = tester.getRect(
    find.byKey(const Key('reader-document-viewport')),
  );
  final card = tester.getRect(
    find.byKey(const Key('translation-floating-card')),
  );
  expect(card.left, greaterThanOrEqualTo(viewport.left));
  expect(card.top, greaterThanOrEqualTo(viewport.top));
  expect(card.right, lessThanOrEqualTo(viewport.right));
  expect(card.bottom, lessThanOrEqualTo(viewport.bottom));
}

class _Harness extends StatefulWidget {
  const _Harness();

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  ReaderCardPreferences preferences = ReaderCardPreferences.defaults;

  @override
  Widget build(BuildContext context) {
    return AdaptiveTranslationSurface(
      visible: true,
      preferences: preferences,
      onPreferencesChanged: (value) => setState(() => preferences = value),
      document: const ColoredBox(
        key: Key('test-document'),
        color: Colors.white,
      ),
      translation: const ColoredBox(
        color: Colors.white,
        child: Center(child: Text('translation')),
      ),
    );
  }
}
