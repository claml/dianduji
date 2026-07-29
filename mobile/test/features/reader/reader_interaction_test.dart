import 'package:dian_du_ji/features/reader/presentation/reader_screen.dart';
import 'package:dian_du_ji/features/reader/presentation/widgets/token_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sentence = ReaderSentence(
    id: 'sentence-1',
    tokens: [
      ReaderToken(id: 'token-0', surface: 'Very'),
      ReaderToken(id: 'token-1', surface: 'very'),
      ReaderToken(id: 'token-2', surface: 'clear'),
    ],
  );

  testWidgets('selects only the tapped repeated-token occurrence', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: ReaderScreen(title: 'Lesson', sentences: [sentence]),
      ),
    );

    await tester.tap(find.byKey(const Key('token-1')));
    await tester.pump();

    expect(
      tester
          .widget<Semantics>(find.byKey(const Key('token-semantics-token-1')))
          .properties
          .selected,
      isTrue,
    );
    expect(
      tester
          .widget<Semantics>(find.byKey(const Key('token-semantics-token-0')))
          .properties
          .selected,
      isFalse,
    );
    expect(find.byKey(const Key('translation-bottom-sheet')), findsOneWidget);
    expect(find.byKey(const Key('reader-progress')), findsNothing);
  });

  testWidgets('dragging over a word scrolls without selecting it', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: ReaderScreen(title: 'Lesson', sentences: [sentence]),
      ),
    );

    await tester.drag(find.byKey(const Key('token-1')), const Offset(0, -120));
    await tester.pump();

    expect(find.byKey(const Key('translation-bottom-sheet')), findsNothing);
    expect(find.byKey(const Key('reader-progress')), findsOneWidget);
  });

  testWidgets('closing phone translation detail restores reading progress', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: ReaderScreen(title: 'Lesson', sentences: [sentence]),
      ),
    );
    await tester.tap(find.byKey(const Key('token-2')));
    await tester.pump();

    await tester.tap(find.byTooltip('关闭释义'));
    await tester.pump();

    expect(find.byKey(const Key('translation-bottom-sheet')), findsNothing);
    expect(find.byKey(const Key('reader-progress')), findsOneWidget);
  });

  testWidgets('tablet keeps translation in a right-side pane', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1024, 768));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: ReaderScreen(title: 'Lesson', sentences: [sentence]),
      ),
    );

    await tester.tap(find.byKey(const Key('token-1')));
    await tester.pump();

    expect(find.byKey(const Key('translation-side-pane')), findsOneWidget);
    expect(find.byKey(const Key('translation-bottom-sheet')), findsNothing);
  });

  testWidgets('short tokens retain a 48 by 48 dp tap target', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: TokenText(token: ReaderToken(id: 'short-token', surface: 'I'), selected: false, onTap: _noop))));

    final size = tester.getSize(find.byKey(const Key('short-token')));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });
}

void _noop() {}
