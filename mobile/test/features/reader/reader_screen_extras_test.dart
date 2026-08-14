import 'package:dian_du_ji/features/reader/domain/pdf_reader_extras.dart';
import 'package:dian_du_ji/features/reader/presentation/reader_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget app({
    PdfReaderExtras? extras,
    ValueChanged<int>? onPdfPageJump,
  }) => MaterialApp(
    home: Scaffold(
      body: ReaderScreen(
        title: 'Paper',
        sentences: const [],
        document: const ColoredBox(color: Colors.white),
        onTokenTap: null,
        onNavigateBack: () async {},
        pdfExtras: extras,
        onPdfPageJump: onPdfPageJump,
      ),
    ),
  );

  testWidgets('outline button opens the table of contents and jumps', (
    tester,
  ) async {
    final extras = PdfReaderExtras()
      ..setOutline(const [
        PdfOutlineEntry(title: '1. Introduction', pageNumber: 1, depth: 0),
        PdfOutlineEntry(title: '2. Method', pageNumber: 5, depth: 0),
        PdfOutlineEntry(title: '2.1 Data', pageNumber: 5, depth: 1),
      ]);
    int? jumped;
    await tester.pumpWidget(app(extras: extras, onPdfPageJump: (p) => jumped = p));

    expect(find.byKey(const Key('reader-outline-button')), findsOneWidget);
    await tester.tap(find.byKey(const Key('reader-outline-button')));
    await tester.pumpAndSettle();

    expect(find.text('目录'), findsOneWidget);
    expect(find.text('1. Introduction'), findsOneWidget);
    expect(find.text('2.1 Data'), findsOneWidget);

    await tester.tap(find.text('2. Method'));
    await tester.pumpAndSettle();
    expect(jumped, 5);
  });

  testWidgets('no outline hides the outline button', (tester) async {
    await tester.pumpWidget(app(extras: PdfReaderExtras()));

    expect(find.byKey(const Key('reader-outline-button')), findsNothing);
  });

  testWidgets('page indicator shows progress and jumps via the dialog', (
    tester,
  ) async {
    final extras = PdfReaderExtras()..updatePage(3, 21);
    int? jumped;
    await tester.pumpWidget(app(extras: extras, onPdfPageJump: (p) => jumped = p));

    expect(find.text('3 / 21'), findsOneWidget);

    await tester.tap(find.byKey(const Key('reader-page-indicator')));
    await tester.pumpAndSettle();
    expect(find.text('跳转到页码'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('page-jump-input')),
      '17',
    );
    await tester.tap(find.text('跳转'));
    await tester.pumpAndSettle();
    expect(jumped, 17);
  });

  testWidgets('out-of-range jump input is ignored', (tester) async {
    final extras = PdfReaderExtras()..updatePage(1, 10);
    int? jumped;
    await tester.pumpWidget(app(extras: extras, onPdfPageJump: (p) => jumped = p));

    await tester.tap(find.byKey(const Key('reader-page-indicator')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('page-jump-input')), '99');
    await tester.tap(find.text('跳转'));
    await tester.pumpAndSettle();
    expect(jumped, isNull);
  });

  testWidgets('reflow documents show no page indicator', (tester) async {
    await tester.pumpWidget(app(extras: null));

    expect(find.byKey(const Key('reader-page-indicator')), findsNothing);
    expect(find.byKey(const Key('reader-outline-button')), findsNothing);
  });
}
