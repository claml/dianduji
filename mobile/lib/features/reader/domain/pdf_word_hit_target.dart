import 'package:pdfrx/pdfrx.dart';

class PdfWordHitTarget {
  PdfWordHitTarget({
    required this.pageNumber,
    required this.surface,
    required this.normalized,
    required this.start,
    required this.end,
    required List<PdfRect> bounds,
    required this.contextText,
  }) : bounds = List.unmodifiable(bounds);

  final int pageNumber;
  final String surface;
  final String normalized;
  final int start;
  final int end;
  final List<PdfRect> bounds;
  final String contextText;
}
