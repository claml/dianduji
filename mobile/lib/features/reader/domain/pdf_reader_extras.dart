import 'package:flutter/foundation.dart';
import 'package:pdfrx/pdfrx.dart' show PdfOutlineNode;

/// One flattened entry of the PDF outline, indented by depth.
class PdfOutlineEntry {
  const PdfOutlineEntry({
    required this.title,
    required this.pageNumber,
    required this.depth,
  });

  final String title;
  final int pageNumber;
  final int depth;
}

/// Flattens the PDF outline tree into a depth-annotated list. Entries without
/// a destination (no page to jump to) are skipped.
List<PdfOutlineEntry> flattenPdfOutline(
  List<PdfOutlineNode> nodes, {
  int depth = 0,
}) {
  final entries = <PdfOutlineEntry>[];
  for (final node in nodes) {
    final dest = node.dest;
    if (dest != null && dest.pageNumber > 0) {
      entries.add(
        PdfOutlineEntry(
          title: node.title,
          pageNumber: dest.pageNumber,
          depth: depth,
        ),
      );
    }
    entries.addAll(flattenPdfOutline(node.children, depth: depth + 1));
  }
  return entries;
}

/// View state for the PDF reading extras (outline navigation and the page
/// indicator). Kept free of Flutter widgets so the logic is unit-testable.
class PdfReaderExtras extends ChangeNotifier {
  List<PdfOutlineEntry> _outline = const [];
  int _currentPage = 1;
  int _pageCount = 1;

  List<PdfOutlineEntry> get outline => _outline;
  bool get hasOutline => _outline.isNotEmpty;
  int get currentPage => _currentPage;
  int get pageCount => _pageCount;

  void setOutline(List<PdfOutlineEntry> entries) {
    _outline = entries;
    notifyListeners();
  }

  void updatePage(int page, int count) {
    if (page == _currentPage && count == _pageCount) return;
    _currentPage = page < 1 ? 1 : page;
    _pageCount = count < 1 ? 1 : count;
    notifyListeners();
  }
}
