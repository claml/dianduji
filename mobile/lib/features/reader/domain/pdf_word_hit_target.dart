import 'package:pdfrx/pdfrx.dart';

class PdfWordHitTarget {
  const PdfWordHitTarget({
    required this.pageNumber,
    required this.surface,
    required this.normalized,
    required this.start,
    required this.end,
    required this.bounds,
    required this.contextText,
  });

  final int pageNumber;
  final String surface;
  final String normalized;
  final int start;
  final int end;
  final List<PdfRect> bounds;
  final String contextText;
}
