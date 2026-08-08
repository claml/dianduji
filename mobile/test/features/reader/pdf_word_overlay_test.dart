import 'dart:async';
import 'dart:ui' as ui;

import 'package:dian_du_ji/features/reader/domain/pdf_word_hit_target.dart';
import 'package:dian_du_ji/features/reader/presentation/widgets/pdf_document_view.dart';
import 'package:dian_du_ji/features/reader/presentation/widgets/pdf_page_text_store.dart';
import 'package:dian_du_ji/features/reader/presentation/widgets/pdf_word_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdfrx/pdfrx.dart';

void main() {
  test('clamps invalid restored pages', () {
    expect(clampPdfInitialPage(7, 10), 7);
    expect(clampPdfInitialPage(0, 10), 1);
    expect(clampPdfInitialPage(99, 10), 1);
  });

  group('PdfPageTextStore', () {
    test('evicts the least recently accessed page', () async {
      final store = PdfPageTextStore(maxPages: 2);

      await store.load(_FakeTextSource(_pageText('one', pageNumber: 1)));
      await store.load(_FakeTextSource(_pageText('two', pageNumber: 2)));
      expect(store.get(1)?.fullText, 'one');
      await store.load(_FakeTextSource(_pageText('three', pageNumber: 3)));

      expect(store.get(1)?.fullText, 'one');
      expect(store.get(2), isNull);
      expect(store.get(3)?.fullText, 'three');
    });

    test('coalesces duplicate in-flight loads for one page', () async {
      final structured = Completer<PdfPageText>();
      final source = _FakeTextSource(
        null,
        pageNumber: 1,
        structuredLoader: structured.future,
      );
      final store = PdfPageTextStore();

      final first = store.load(source);
      final second = store.load(source);

      expect(identical(first, second), isTrue);
      expect(source.structuredLoadCount, 1);
      structured.complete(_pageText('shared'));
      expect(await first, same(await second));
    });

    test(
      'falls back to raw text only when structured geometry has no run',
      () async {
        final source = _FakeTextSource(
          const PdfPageText(
            pageNumber: 1,
            fullText: 'fallback',
            charRects: [],
            fragments: [],
          ),
          rawText: PdfPageRawText(
            'fallback',
            _horizontalRects('fallback', left: 10, top: 100),
          ),
        );

        final geometry = await PdfPageTextStore().load(source);

        expect(geometry?.fullText, 'fallback');
        expect(geometry?.runs, hasLength(1));
        expect(source.structuredLoadCount, 1);
        expect(source.rawLoadCount, 1);
      },
    );

    test(
      'does not load raw text when structured geometry has a valid run',
      () async {
        final source = _FakeTextSource(
          _pageText('structured'),
          rawText: PdfPageRawText(
            'raw',
            _horizontalRects('raw', left: 10, top: 100),
          ),
        );

        final geometry = await PdfPageTextStore().load(source);

        expect(geometry?.fullText, 'structured');
        expect(source.rawLoadCount, 0);
      },
    );

    test('isolates one page extraction error from other pages', () async {
      final store = PdfPageTextStore();
      final broken = _FakeTextSource(
        null,
        pageNumber: 1,
        structuredLoader: Future<PdfPageText>.error(StateError('broken')),
      );
      final healthy = _FakeTextSource(_pageText('healthy', pageNumber: 2));

      expect(await store.load(broken), isNull);
      expect((await store.load(healthy))?.fullText, 'healthy');
      expect(store.get(1), isNull);
      expect(store.get(2)?.fullText, 'healthy');
    });
  });

  testWidgets('page overlay has constant widget count after text loads', (
    tester,
  ) async {
    final source = _FakePageOverlayData(_pageText('many words on one page'));
    final store = PdfPageTextStore();
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 320,
          height: 480,
          child: PdfWordOverlay(
            page: source,
            selectedTarget: null,
            store: store,
          ),
        ),
      ),
    );
    await tester.pump();

    final overlay = find.byKey(const Key('pdf-page-overlay-1'));
    expect(overlay, findsOneWidget);
    expect(find.byKey(const Key('pdf-word-hit-1-0')), findsNothing);
    for (final type in [Positioned, GestureDetector, Semantics, ColoredBox]) {
      expect(
        find.descendant(of: overlay, matching: find.byType(type)),
        findsNothing,
      );
    }
    expect(source.structuredLoadCount, 1);
  });

  testWidgets('page overlay paints only the selected target rectangles', (
    tester,
  ) async {
    final source = _FakePageOverlayData(_pageText('many words on one page'));
    final selected = PdfWordHitTarget(
      pageNumber: 1,
      surface: 'selected',
      normalized: 'selected',
      start: 0,
      end: 8,
      bounds: const [PdfRect(12, 450, 40, 432), PdfRect(12, 420, 40, 402)],
      contextText: 'selected',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: RepaintBoundary(
          key: const Key('selection-paint-boundary'),
          child: SizedBox(
            width: 320,
            height: 480,
            child: PdfWordOverlay(
              page: source,
              selectedTarget: selected,
              store: PdfPageTextStore(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final overlay = find.byKey(const Key('pdf-page-overlay-1'));
    expect(
      overlay,
      paints
        ..rect(rect: const Rect.fromLTRB(12, 30, 40, 48))
        ..rect(rect: const Rect.fromLTRB(12, 60, 40, 78)),
    );
    for (final type in [Positioned, GestureDetector, Semantics, ColoredBox]) {
      expect(
        find.descendant(of: overlay, matching: find.byType(type)),
        findsNothing,
      );
    }
    expect(await _nonTransparentPixelCount(tester), 2 * 28 * 18);
  });

  testWidgets('a replacement page source reloads after a document clear', (
    tester,
  ) async {
    final store = PdfPageTextStore();
    final first = _FakePageOverlayData(_pageText('first'));
    final second = _FakePageOverlayData(_pageText('second'));

    await tester.pumpWidget(
      MaterialApp(
        home: PdfWordOverlay(page: first, selectedTarget: null, store: store),
      ),
    );
    await tester.pump();
    expect(first.structuredLoadCount, 1);

    store.clear();
    await tester.pumpWidget(
      MaterialApp(
        home: PdfWordOverlay(page: second, selectedTarget: null, store: store),
      ),
    );
    await tester.pump();

    expect(second.structuredLoadCount, 1);
    expect(store.get(1)?.fullText, 'second');
  });

  testWidgets('changing documents clears injected page text cache', (
    tester,
  ) async {
    final store = PdfPageTextStore();
    await store.load(_FakeTextSource(_pageText('cached')));

    await tester.pumpWidget(
      MaterialApp(
        home: PdfDocumentView(
          localPath: 'first.pdf',
          onWordTap: (_) {},
          textStore: store,
          renderer: (_, _) => const SizedBox(),
        ),
      ),
    );
    expect(store.get(1), isNotNull);

    await tester.pumpWidget(
      MaterialApp(
        home: PdfDocumentView(
          localPath: 'second.pdf',
          onWordTap: (_) {},
          textStore: store,
          renderer: (_, _) => const SizedBox(),
        ),
      ),
    );

    expect(store.get(1), isNull);
  });

  testWidgets(
    'changing document and store invalidates the new store cached page',
    (tester) async {
      final oldStore = PdfPageTextStore();
      final newStore = PdfPageTextStore();
      await newStore.load(_FakeTextSource(_pageText('stale cached page')));

      await tester.pumpWidget(
        MaterialApp(
          home: PdfDocumentView(
            localPath: 'first.pdf',
            onWordTap: (_) {},
            textStore: oldStore,
            renderer: (_, _) => const SizedBox(),
          ),
        ),
      );
      expect(newStore.get(1)?.fullText, 'stale cached page');

      await tester.pumpWidget(
        MaterialApp(
          home: PdfDocumentView(
            localPath: 'second.pdf',
            onWordTap: (_) {},
            textStore: newStore,
            renderer: (_, _) => const SizedBox(),
          ),
        ),
      );

      expect(newStore.get(1), isNull);
    },
  );

  testWidgets(
    'changing document and store invalidates the new store in-flight page',
    (tester) async {
      final oldStore = PdfPageTextStore();
      final newStore = PdfPageTextStore();
      final structured = Completer<PdfPageText>();
      final staleLoad = newStore.load(
        _FakeTextSource(
          null,
          pageNumber: 1,
          structuredLoader: structured.future,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: PdfDocumentView(
            localPath: 'first.pdf',
            onWordTap: (_) {},
            textStore: oldStore,
            renderer: (_, _) => const SizedBox(),
          ),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: PdfDocumentView(
            localPath: 'second.pdf',
            onWordTap: (_) {},
            textStore: newStore,
            renderer: (_, _) => const SizedBox(),
          ),
        ),
      );

      structured.complete(_pageText('stale in-flight page'));
      await staleLoad;

      expect(newStore.get(1), isNull);
    },
  );

  testWidgets('an unrelated parent update does not rebuild the PDF renderer', (
    tester,
  ) async {
    var parentState = 0;
    var renderCount = 0;
    late StateSetter updateParent;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            updateParent = setState;
            return Column(
              children: [
                Text('$parentState'),
                Expanded(
                  child: PdfDocumentView(
                    localPath: 'stable.pdf',
                    onWordTap: (_) {},
                    renderer: (_, _) {
                      renderCount++;
                      return const SizedBox();
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
    expect(renderCount, 1);

    updateParent(() => parentState++);
    await tester.pump();

    expect(renderCount, 1);
  });
}

class _FakeTextSource implements PdfPageTextSource {
  _FakeTextSource(
    this.structuredText, {
    int? pageNumber,
    this.rawText,
    this.structuredLoader,
  }) : pageNumber = pageNumber ?? structuredText?.pageNumber ?? 1;

  final PdfPageText? structuredText;
  final PdfPageRawText? rawText;
  final Future<PdfPageText>? structuredLoader;

  @override
  final int pageNumber;

  var structuredLoadCount = 0;
  var rawLoadCount = 0;

  @override
  Future<PdfPageText> loadStructuredText() {
    structuredLoadCount++;
    return structuredLoader ?? Future.value(structuredText!);
  }

  @override
  Future<PdfPageRawText?> loadRawText() async {
    rawLoadCount++;
    return rawText;
  }
}

class _FakePageOverlayData extends _FakeTextSource
    implements PdfPageOverlayData {
  _FakePageOverlayData(super.structuredText);

  @override
  Rect mapRect(PdfRect rect, Size scaledPageSize) {
    return Rect.fromLTRB(
      rect.left,
      480 - rect.top,
      rect.right,
      480 - rect.bottom,
    );
  }
}

PdfPageText _pageText(String text, {int pageNumber = 1}) {
  return PdfPageText(
    pageNumber: pageNumber,
    fullText: text,
    charRects: _horizontalRects(text, left: 12, top: 450),
    fragments: const [],
  );
}

List<PdfRect> _horizontalRects(
  String text, {
  required double left,
  required double top,
}) {
  return List.generate(text.length, (index) {
    final x = left + index * 7;
    return PdfRect(x, top, x + 7, top - 18);
  });
}

Future<int> _nonTransparentPixelCount(WidgetTester tester) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const Key('selection-paint-boundary')),
  );
  return (await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    var count = 0;
    for (var index = 3; index < bytes!.lengthInBytes; index += 4) {
      if (bytes.getUint8(index) != 0) count++;
    }
    return count;
  }))!;
}
