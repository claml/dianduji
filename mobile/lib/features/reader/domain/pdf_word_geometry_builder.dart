import 'package:pdfrx/pdfrx.dart';

import 'pdf_word_hit_target.dart';

final _englishWord = RegExp(r"[A-Za-z]+(?:['’\-][A-Za-z]+)*");
final _pageNumber = RegExp(
  r'^(?:page\s*)?\d+(?:\s*(?:of|/)\s*\d+)?$',
  caseSensitive: false,
);
final _affiliation = RegExp(
  r'\b(department|university|institute|college|school|laboratory|lab|'
  r'correspondence|orcid)\b|@',
  caseSensitive: false,
);

List<PdfWordHitTarget> buildPdfWordTargets(PdfPageText pageText) {
  if (pageText.fullText.isEmpty ||
      pageText.charRects.length != pageText.fullText.length) {
    return const [];
  }
  final targets = <PdfWordHitTarget>[];
  for (final match in _englishWord.allMatches(pageText.fullText)) {
    final context = _lineAt(pageText.fullText, match.start);
    if (!_isInteractiveLine(context)) continue;
    final bounds = _groupBounds(
      pageText.charRects.sublist(match.start, match.end),
    );
    if (bounds.isEmpty) continue;
    final surface = pageText.fullText.substring(match.start, match.end);
    targets.add(
      PdfWordHitTarget(
        pageNumber: pageText.pageNumber,
        surface: surface,
        normalized: surface.toLowerCase().replaceAll('’', "'"),
        start: match.start,
        end: match.end,
        bounds: List.unmodifiable(bounds),
        contextText: context,
      ),
    );
  }
  return List.unmodifiable(targets);
}

String _lineAt(String text, int offset) {
  final start = offset == 0 ? 0 : text.lastIndexOf('\n', offset - 1) + 1;
  final nextNewline = text.indexOf('\n', offset);
  final end = nextNewline == -1 ? text.length : nextNewline;
  return text.substring(start, end).trim();
}

bool _isInteractiveLine(String line) {
  final compact = line.trim();
  if (compact.isEmpty || _pageNumber.hasMatch(compact)) return false;
  if (_affiliation.hasMatch(compact)) return false;
  if (_looksLikeAuthorList(compact)) return false;
  final digits = RegExp(r'\d').allMatches(compact).length;
  if (digits > compact.length * 0.35) return false;
  return true;
}

bool _looksLikeAuthorList(String line) {
  final names = line.split(',').map((name) => name.trim()).toList();
  if (names.length < 2) return false;
  return names.every((name) {
    final words = name.split(RegExp(r'\s+'));
    if (words.length < 2 || words.length > 4) return false;
    return words.every(
      (word) => RegExp(r'^[A-Z][A-Za-z.\-]*$').hasMatch(word),
    );
  });
}

List<PdfRect> _groupBounds(List<PdfRect> characterRects) {
  final groups = <PdfRect>[];
  for (final rect in characterRects.where((candidate) => candidate.isNotEmpty)) {
    if (groups.isEmpty || !_sameLine(groups.last, rect)) {
      groups.add(rect);
    } else {
      groups[groups.length - 1] = groups.last.merge(rect);
    }
  }
  return groups;
}

bool _sameLine(PdfRect left, PdfRect right) {
  final overlap = (left.top < right.top ? left.top : right.top) -
      (left.bottom > right.bottom ? left.bottom : right.bottom);
  final shorterHeight = left.height < right.height ? left.height : right.height;
  return overlap > shorterHeight * 0.35 && right.left >= left.left;
}
