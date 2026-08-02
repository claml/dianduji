import 'package:pdfrx/pdfrx.dart';

class PdfTextGeometryRun {
  PdfTextGeometryRun(this.textStart, List<PdfRect> rects)
    : rects = List.unmodifiable(rects);

  final int textStart;
  final List<PdfRect> rects;
}

class PdfPageGeometry {
  PdfPageGeometry({
    required this.pageNumber,
    required this.fullText,
    required List<PdfTextGeometryRun> runs,
  }) : runs = List.unmodifiable(
         runs.where(
           (run) =>
               run.textStart >= 0 &&
               run.rects.isNotEmpty &&
               run.textStart + run.rects.length <= fullText.length,
         ),
       );

  factory PdfPageGeometry.fromStructured(PdfPageText text) {
    if (text.fullText.length == text.charRects.length) {
      return PdfPageGeometry(
        pageNumber: text.pageNumber,
        fullText: text.fullText,
        runs: [PdfTextGeometryRun(0, text.charRects)],
      );
    }

    final runs = <PdfTextGeometryRun>[];
    for (final fragment in text.fragments) {
      if (fragment.index >= 0 &&
          fragment.end <= text.fullText.length &&
          fragment.length == fragment.charRects.length) {
        runs.add(PdfTextGeometryRun(fragment.index, fragment.charRects));
      }
    }
    return PdfPageGeometry(
      pageNumber: text.pageNumber,
      fullText: text.fullText,
      runs: runs,
    );
  }

  factory PdfPageGeometry.fromRaw(int pageNumber, PdfPageRawText text) {
    return PdfPageGeometry(
      pageNumber: pageNumber,
      fullText: text.fullText,
      runs: text.fullText.length == text.charRects.length
          ? [PdfTextGeometryRun(0, text.charRects)]
          : const [],
    );
  }

  final int pageNumber;
  final String fullText;
  final List<PdfTextGeometryRun> runs;

  PdfRect? rectAt(int textIndex) {
    if (textIndex < 0 || textIndex >= fullText.length) return null;
    for (final run in runs) {
      final runIndex = textIndex - run.textStart;
      if (runIndex < 0 || runIndex >= run.rects.length) continue;
      final rect = run.rects[runIndex];
      if (_isUsablePdfRect(rect)) return rect;
    }
    return null;
  }
}

bool _isUsablePdfRect(PdfRect rect) {
  return rect.left.isFinite &&
      rect.top.isFinite &&
      rect.right.isFinite &&
      rect.bottom.isFinite &&
      rect.left < rect.right &&
      rect.bottom < rect.top;
}
