import 'package:dian_du_ji/features/reader/domain/pdf_reader_extras.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdfrx/pdfrx.dart';

void main() {
  PdfOutlineNode node(String title, int page, [List<PdfOutlineNode> children = const []]) =>
      PdfOutlineNode(
        title: title,
        dest: PdfDest(page, PdfDestCommand.fit, const []),
        children: children,
      );

  test('flattens nested outline entries with depth', () {
    final outline = flattenPdfOutline([
      node('1. Introduction', 1, [
        node('1.1 Background', 1),
        node('1.2 Related Work', 3),
      ]),
      node('2. Method', 5),
      node('3. Results', 9),
    ]);

    expect(outline, hasLength(5));
    expect(outline[0].title, '1. Introduction');
    expect(outline[0].pageNumber, 1);
    expect(outline[0].depth, 0);
    expect(outline[1].title, '1.1 Background');
    expect(outline[1].depth, 1);
    expect(outline.last.pageNumber, 9);
  });

  test('skips entries without a destination', () {
    final outline = flattenPdfOutline([
      const PdfOutlineNode(title: 'No dest', dest: null, children: []),
      node('2. Method', 5),
    ]);

    expect(outline, hasLength(1));
    expect(outline.single.title, '2. Method');
  });

  test('updatePage clamps out-of-range values', () {
    final extras = PdfReaderExtras();
    extras.updatePage(3, 21);
    expect(extras.currentPage, 3);
    expect(extras.pageCount, 21);

    extras.updatePage(0, 0);
    expect(extras.currentPage, 1);
    expect(extras.pageCount, 1);
  });

  test('setOutline notifies and flags hasOutline', () {
    final extras = PdfReaderExtras();
    var notified = 0;
    extras.addListener(() => notified++);
    expect(extras.hasOutline, isFalse);

    extras.setOutline([const PdfOutlineEntry(title: 't', pageNumber: 1, depth: 0)]);
    expect(extras.hasOutline, isTrue);
    expect(notified, 1);
  });
}
