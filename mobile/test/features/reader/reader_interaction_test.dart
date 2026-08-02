import 'package:dian_du_ji/features/reader/presentation/reader_screen.dart';
import 'package:dian_du_ji/features/reader/presentation/reader_chrome_controller.dart';
import 'package:dian_du_ji/features/reader/data/reader_card_preferences.dart';
import 'package:dian_du_ji/features/reader/domain/reader_selection.dart';
import 'package:dian_du_ji/features/reader/presentation/widgets/reader_top_bar.dart';
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

  testWidgets('tablet reader honors a persisted floating card mode', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1024, 768));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: ReaderScreen(
          title: 'Lesson',
          sentences: const [sentence],
          cardPreferences: ReaderCardPreferences(
            mode: ReaderCardMode.floating,
            relativeX: 0.7,
            relativeY: 0.2,
          ),
          onCardPreferencesChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('token-1')));
    await tester.pump();

    expect(find.byKey(const Key('translation-floating-card')), findsOneWidget);
    expect(find.byKey(const Key('translation-side-pane')), findsNothing);
  });

  testWidgets('short tokens retain a 48 by 48 dp tap target', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TokenText(
            token: ReaderToken(id: 'short-token', surface: 'I'),
            selected: false,
            onTap: _noop,
          ),
        ),
      ),
    );

    final size = tester.getSize(find.byKey(const Key('short-token')));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  testWidgets('shows translation for a word selected from a PDF overlay', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: ReaderScreen(
          title: 'Paper',
          sentences: [],
          document: ColoredBox(key: Key('pdf-document'), color: Colors.white),
          selection: ReaderSelection(
            surface: 'Foundation',
            normalized: 'foundation',
            contextText: 'Foundation Models',
            startOffset: 0,
            endOffset: 10,
            pageNumber: 1,
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('pdf-document')), findsOneWidget);
    expect(find.byKey(const Key('translation-bottom-sheet')), findsOneWidget);
    expect(find.text('Foundation'), findsOneWidget);
  });

  testWidgets(
    'auto-hides the overlay toolbar without changing the document viewport',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final chrome = ReaderChromeController();
      await tester.pumpWidget(
        MaterialApp(
          home: ReaderScreen(
            title: 'Lesson',
            sentences: _scrollableSentences(),
            chromeController: chrome,
          ),
        ),
      );

      final document = find.byKey(const Key('reader-document-viewport'));
      final before = tester.getRect(document);
      await tester.dragFrom(const Offset(195, 200), const Offset(0, -30));
      await tester.pump(const Duration(milliseconds: 180));

      expect(chrome.visible, isFalse);
      expect(
        tester
            .widget<AnimatedSlide>(find.byKey(const Key('reader-top-bar')))
            .offset,
        const Offset(0, -1),
      );
      expect(tester.getRect(document), before);

      await tester.dragFrom(const Offset(195, 200), const Offset(0, 30));
      await tester.pump(const Duration(milliseconds: 180));
      expect(chrome.visible, isTrue);

      chrome.handleContentScroll(30);
      await tester.pump(const Duration(milliseconds: 180));
      await tester.tap(find.byKey(const Key('reader-top-reveal-zone')));
      await tester.pump(const Duration(milliseconds: 180));

      expect(chrome.visible, isTrue);
    },
  );

  testWidgets('disables the top-bar slide animation when reduce motion is on', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: const Scaffold(
            body: ReaderTopBar(
              title: 'Lesson',
              visible: true,
              onBack: _noop,
              onReveal: _noop,
              onSettings: _noop,
            ),
          ),
        ),
      ),
    );

    expect(
      tester
          .widget<AnimatedSlide>(find.byKey(const Key('reader-top-bar')))
          .duration,
      Duration.zero,
    );
  });
}

void _noop() {}

List<ReaderSentence> _scrollableSentences() => List.generate(
  32,
  (index) => ReaderSentence(
    id: 'scroll-sentence-$index',
    tokens: [ReaderToken(id: 'scroll-token-$index', surface: 'Sentence')],
  ),
);
