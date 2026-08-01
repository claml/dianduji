import 'package:dian_du_ji/features/reader/domain/pdf_word_geometry_builder.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds English word targets with punctuation and wrapped bounds', () {
    final page = _pageText(
      "Foundation-based models don't\nreflow documents.",
    );

    final targets = buildPdfWordTargets(page);

    expect(
      targets.map((target) => target.surface),
      ['Foundation-based', 'models', "don't", 'reflow', 'documents'],
    );
    expect(targets.first.normalized, 'foundation-based');
    expect(targets.first.contextText, "Foundation-based models don't");
    expect(targets.first.bounds, hasLength(1));
    expect(targets[3].contextText, 'reflow documents.');
    expect(targets.every((target) => target.pageNumber == 1), isTrue);
  });

  test('keeps title words but filters metadata and page-number lines', () {
    final page = _pageText(
      'Research on Foundation Models\n'
      'Zhen Wenjie, Li Ming\n'
      'Department of Computer Science, Zhengzhou University\n'
      '42',
    );

    final targets = buildPdfWordTargets(page);

    expect(
      targets.map((target) => target.surface),
      ['Research', 'on', 'Foundation', 'Models'],
    );
  });

  test('returns no targets when character geometry is incomplete', () {
    const page = PdfPageText(
      pageNumber: 1,
      fullText: 'Model',
      charRects: [],
      fragments: [],
    );

    expect(buildPdfWordTargets(page), isEmpty);
  });
}

PdfPageText _pageText(String text) {
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
  return PdfPageText(
    pageNumber: 1,
    fullText: text,
    charRects: rects,
    fragments: const [],
  );
}
