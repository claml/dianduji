import 'package:dian_du_ji/features/reader/domain/reader_selection.dart';
import 'package:dian_du_ji/features/reader/domain/pdf_word_geometry_builder.dart';
import 'package:dian_du_ji/features/reader/presentation/widgets/pdf_word_overlay.dart';
import 'package:dian_du_ji/features/reader/presentation/widgets/pdf_document_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdfrx/pdfrx.dart';

void main() {
  test('clamps invalid restored pages and bounds cached page geometry', () {
    expect(clampPdfInitialPage(7, 10), 7);
    expect(clampPdfInitialPage(0, 10), 1);
    expect(clampPdfInitialPage(99, 10), 1);

    final cache = PdfWordTargetCache(maxPages: 2);
    final targets = buildPdfWordTargets(_pageText('Foundation Models'));
    cache
      ..put(1, targets)
      ..put(2, targets)
      ..put(3, targets);

    expect(cache[1], isNull);
    expect(cache[2], same(targets));
    expect(cache[3], same(targets));
    expect(cache.length, 2);
  });

  testWidgets('title and body words are transparent semantic tap targets', (
    tester,
  ) async {
    ReaderSelection? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 320,
          height: 480,
          child: PdfWordOverlay(
            page: _FakePageOverlayData(
              _pageText('Research on Foundation Models\nReadable body text'),
            ),
            onWordTap: (value) => selected = value,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('pdf-word-hit-1-0')), findsOneWidget);
    final foundation = tester.widget<Semantics>(
      find.byKey(const Key('pdf-word-semantics-1-12')),
    );
    foundation.properties.onTap!();
    await tester.pump();

    expect(selected?.surface, 'Foundation');
    expect(selected?.normalized, 'foundation');
    expect(selected?.contextText, 'Research on Foundation Models');
    expect(selected?.pageNumber, 1);
  });
}

class _FakePageOverlayData implements PdfPageOverlayData {
  const _FakePageOverlayData(this.text);

  final PdfPageText text;

  @override
  int get pageNumber => text.pageNumber;

  @override
  Future<PdfPageText> loadText() async => text;

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

PdfPageText _pageText(String text) {
  var x = 12.0;
  var top = 450.0;
  final rects = <PdfRect>[];
  for (final codeUnit in text.codeUnits) {
    if (codeUnit == 10) {
      rects.add(PdfRect.empty);
      x = 12;
      top -= 28;
      continue;
    }
    rects.add(PdfRect(x, top, x + 7, top - 18));
    x += 7;
  }
  return PdfPageText(
    pageNumber: 1,
    fullText: text,
    charRects: rects,
    fragments: const [],
  );
}
