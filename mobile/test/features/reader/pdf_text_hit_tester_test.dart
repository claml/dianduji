import 'package:dian_du_ji/features/reader/domain/pdf_page_geometry.dart';
import 'package:dian_du_ji/features/reader/domain/pdf_text_hit_tester.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdfrx/pdfrx.dart';

void main() {
  group('PdfPageGeometry', () {
    test('maps aligned structured and raw character geometry', () {
      final structuredFixture = _laidOutText('Model');

      final structured = PdfPageGeometry.fromStructured(
        structuredFixture.pageText,
      );
      final raw = PdfPageGeometry.fromRaw(
        3,
        PdfPageRawText('Model', structuredFixture.rects),
      );

      expect(structured.rectAt(2), structuredFixture.rects[2]);
      expect(raw.pageNumber, 3);
      expect(raw.fullText, 'Model');
      expect(raw.rectAt(2), structuredFixture.rects[2]);
    });

    test('rejects a raw page whose rectangle count is incomplete', () {
      final geometry = PdfPageGeometry.fromRaw(
        4,
        PdfPageRawText('Model', const [PdfRect(10, 100, 18, 88)]),
      );

      expect(geometry.fullText, 'Model');
      expect(geometry.runs, isEmpty);
      expect(geometry.rectAt(0), isNull);
    });

    test('skips empty and non-finite rectangles without shifting indices', () {
      final geometry = PdfPageGeometry(
        pageNumber: 1,
        fullText: 'bad wayfinding',
        runs: [
          PdfTextGeometryRun(0, [
            PdfRect.empty,
            PdfRect(0, double.infinity, 8, 88),
            PdfRect(20, 100, 28, 88),
          ]),
          PdfTextGeometryRun(4, const [PdfRect(100, 100, 108, 88)]),
        ],
      );

      expect(geometry.rectAt(0), isNull);
      expect(geometry.rectAt(1), isNull);
      expect(geometry.rectAt(2), const PdfRect(20, 100, 28, 88));
      expect(geometry.rectAt(3), isNull);
      expect(geometry.rectAt(4), const PdfRect(100, 100, 108, 88));
    });

    test('a malformed fragment does not hide a later valid fragment', () {
      const text = 'broken wayfinding';
      const validRects = [
        PdfRect(100, 100, 108, 88),
        PdfRect(108, 100, 116, 88),
        PdfRect(116, 100, 124, 88),
        PdfRect(124, 100, 132, 88),
        PdfRect(132, 100, 140, 88),
        PdfRect(140, 100, 148, 88),
        PdfRect(148, 100, 156, 88),
        PdfRect(156, 100, 164, 88),
        PdfRect(164, 100, 172, 88),
        PdfRect(172, 100, 180, 88),
      ];
      const fragmentOwner = PdfPageText(
        pageNumber: 1,
        fullText: text,
        charRects: [],
        fragments: [],
      );
      const badFragment = PdfPageTextFragment(
        pageText: fragmentOwner,
        index: 0,
        length: 6,
        bounds: PdfRect(10, 100, 58, 88),
        charRects: [PdfRect(10, 100, 18, 88)],
        direction: PdfTextDirection.ltr,
      );
      const validFragment = PdfPageTextFragment(
        pageText: fragmentOwner,
        index: 7,
        length: 10,
        bounds: PdfRect(100, 100, 180, 88),
        charRects: validRects,
        direction: PdfTextDirection.ltr,
      );
      const pageText = PdfPageText(
        pageNumber: 1,
        fullText: text,
        charRects: [],
        fragments: [badFragment, validFragment],
      );
      final geometry = PdfPageGeometry.fromStructured(pageText);

      expect(geometry.rectAt(0), isNull);
      expect(geometry.rectAt(7), validRects.first);
      expect(
        hitTestPdfText(geometry, const PdfPoint(104, 94))?.surface,
        'wayfinding',
      );
    });
  });

  group('hitTestPdfText', () {
    test('expands apostrophes and true same-line compound hyphens', () {
      final fixture = _laidOutText("context-sensitive model's");
      final page = PdfPageGeometry.fromStructured(fixture.pageText);

      final compound = hitTestPdfText(page, fixture.pointIn('sensitive'));
      final possessive = hitTestPdfText(page, fixture.pointIn("model's"));

      expect(compound?.surface, 'context-sensitive');
      expect(compound?.normalized, 'context-sensitive');
      expect(compound?.bounds, hasLength(1));
      expect(possessive?.surface, "model's");
      expect(possessive?.normalized, "model's");
    });

    test('dehyphenates a soft line wrap and keeps both highlight lines', () {
      const text = 'It explains mecha-\nnisms at scale.';
      final fixture = _laidOutText(text);
      final page = PdfPageGeometry.fromStructured(fixture.pageText);

      final result = hitTestPdfText(page, fixture.pointIn('nisms'));

      expect(result?.surface, 'mechanisms');
      expect(result?.normalized, 'mechanisms');
      expect(result?.start, text.indexOf('mecha'));
      expect(result?.end, text.indexOf('nisms') + 'nisms'.length);
      expect(result?.bounds, hasLength(2));
      expect(result?.contextText, 'It explains mechanisms at scale.');
    });

    test('uses PDF coordinates to select text in a two-column row', () {
      const text = 'navigation\nwayfinding';
      final rects = List<PdfRect>.filled(text.length, PdfRect.empty);
      _placeWord(rects, text.indexOf('navigation'), 200, 100, 'navigation');
      _placeWord(rects, text.indexOf('wayfinding'), 10, 100, 'wayfinding');
      final page = PdfPageGeometry.fromStructured(
        PdfPageText(
          pageNumber: 1,
          fullText: text,
          charRects: rects,
          fragments: const [],
        ),
      );

      expect(
        hitTestPdfText(page, const PdfPoint(14, 94))?.surface,
        'wayfinding',
      );
      expect(
        hitTestPdfText(page, const PdfPoint(204, 94))?.surface,
        'navigation',
      );
    });

    test('filters metadata only on the clicked visual line', () {
      final fixture = _laidOutText(
        'Research on Foundation Models\n'
        'Zhen Wenjie, Li Ming\n'
        'Department of Computer Science, Zhengzhou University\n'
        'Page 42\n'
        '2. Methods',
      );
      final page = PdfPageGeometry.fromStructured(fixture.pageText);

      expect(
        hitTestPdfText(page, fixture.pointIn('Research'))?.surface,
        'Research',
      );
      expect(hitTestPdfText(page, fixture.pointIn('Wenjie')), isNull);
      expect(hitTestPdfText(page, fixture.pointIn('Department')), isNull);
      expect(hitTestPdfText(page, fixture.pointIn('Page 42')), isNull);
      expect(
        hitTestPdfText(page, fixture.pointIn('Methods'))?.surface,
        'Methods',
      );
    });

    test('prefers a containing character then honors nearest margin', () {
      final page = PdfPageGeometry(
        pageNumber: 1,
        fullText: 'left right',
        runs: [
          PdfTextGeometryRun(0, const [
            PdfRect(0, 100, 8, 88),
            PdfRect(8, 100, 16, 88),
            PdfRect(16, 100, 24, 88),
            PdfRect(24, 100, 31, 88),
          ]),
          PdfTextGeometryRun(5, const [
            PdfRect(31, 100, 39, 88),
            PdfRect(39, 100, 47, 88),
            PdfRect(47, 100, 55, 88),
            PdfRect(55, 100, 63, 88),
            PdfRect(63, 100, 71, 88),
          ]),
        ],
      );

      expect(
        hitTestPdfText(page, const PdfPoint(31.5, 94), margin: 12)?.surface,
        'right',
      );
      expect(
        hitTestPdfText(page, const PdfPoint(75, 94), margin: 5)?.surface,
        'right',
      );
      expect(hitTestPdfText(page, const PdfPoint(75, 94), margin: 3), isNull);
    });

    test('returns null when no alphabetic word or highlight exists', () {
      final punctuation = _laidOutText('--- 42');
      final punctuationPage = PdfPageGeometry.fromStructured(
        punctuation.pageText,
      );
      final missingGeometry = PdfPageGeometry(
        pageNumber: 1,
        fullText: 'word',
        runs: const [],
      );

      expect(
        hitTestPdfText(punctuationPage, punctuation.pointIn('---')),
        isNull,
      );
      expect(hitTestPdfText(missingGeometry, const PdfPoint(10, 94)), isNull);
    });
  });
}

class _LaidOutText {
  const _LaidOutText(this.pageText, this.rects);

  final PdfPageText pageText;
  final List<PdfRect> rects;

  PdfPoint pointIn(String surface) {
    final index = pageText.fullText.indexOf(surface);
    if (index < 0) throw ArgumentError.value(surface, 'surface');
    return rects[index].center;
  }
}

_LaidOutText _laidOutText(String text) {
  var x = 10.0;
  var top = 100.0;
  final rects = <PdfRect>[];
  for (final codeUnit in text.codeUnits) {
    if (codeUnit == 10) {
      rects.add(PdfRect.empty);
      x = 10;
      top -= 20;
      continue;
    }
    rects.add(PdfRect(x, top, x + 8, top - 12));
    x += 8;
  }
  return _LaidOutText(
    PdfPageText(
      pageNumber: 1,
      fullText: text,
      charRects: rects,
      fragments: const [],
    ),
    rects,
  );
}

void _placeWord(
  List<PdfRect> rects,
  int textStart,
  double left,
  double top,
  String word,
) {
  for (var index = 0; index < word.length; index++) {
    final x = left + index * 8;
    rects[textStart + index] = PdfRect(x, top, x + 8, top - 12);
  }
}
