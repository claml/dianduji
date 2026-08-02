import 'package:pdfrx/pdfrx.dart';

import 'pdf_page_geometry.dart';
import 'pdf_word_hit_target.dart';

final _pageNumber = RegExp(
  r'^(?:page\s*)?\d+(?:\s*(?:of|/)\s*\d+)?$',
  caseSensitive: false,
);
final _affiliation = RegExp(
  r'\b(department|university|institute|college|school|laboratory|lab|'
  r'correspondence|orcid)\b|@',
  caseSensitive: false,
);
final _softLineBreak = RegExp(r'-\s*[\r\n]\s*');
final _lineBreak = RegExp(r'[\r\n]+');
final _whitespace = RegExp(r'\s+');

PdfWordHitTarget? hitTestPdfText(
  PdfPageGeometry page,
  PdfPoint point, {
  double margin = 12,
}) {
  final textIndex = _findCharacterAt(page, point, margin);
  if (textIndex == null) return null;

  final range = _wordRangeAt(page, textIndex);
  if (range == null) return null;
  if (!_isInteractiveLine(_lineAt(page.fullText, textIndex))) return null;

  final bounds = _boundsForRange(page, range.start, range.end);
  if (bounds.isEmpty) return null;

  final surface = _normalizeSoftLineBreaks(
    page.fullText.substring(range.start, range.end),
  );
  if (!surface.codeUnits.any(_isAsciiLetter)) return null;

  return PdfWordHitTarget(
    pageNumber: page.pageNumber,
    surface: surface,
    normalized: surface.toLowerCase().replaceAll('\u2019', "'"),
    start: range.start,
    end: range.end,
    bounds: bounds,
    contextText: _sentenceAt(page.fullText, textIndex),
  );
}

int? _findCharacterAt(PdfPageGeometry page, PdfPoint point, double margin) {
  int? containingIndex;
  var containingCenterDistance = double.infinity;
  int? nearestIndex;
  var nearestDistance = double.infinity;
  final usableMargin = margin < 0 ? 0.0 : margin;
  final maxDistance = usableMargin * usableMargin;

  for (final run in page.runs) {
    for (var runIndex = 0; runIndex < run.rects.length; runIndex++) {
      final textIndex = run.textStart + runIndex;
      final rect = run.rects[runIndex];
      if (!_isUsableRect(rect)) continue;
      if (rect.containsPoint(point)) {
        final centerDistance = rect.center.distanceSquaredTo(point);
        if (centerDistance < containingCenterDistance) {
          containingIndex = textIndex;
          containingCenterDistance = centerDistance;
        }
        continue;
      }
      final distance = rect.distanceSquaredTo(point);
      if (distance <= maxDistance && distance < nearestDistance) {
        nearestIndex = textIndex;
        nearestDistance = distance;
      }
    }
  }
  return containingIndex ?? nearestIndex;
}

_TextRange? _wordRangeAt(PdfPageGeometry page, int textIndex) {
  final text = page.fullText;
  int? letterIndex;
  if (_isLetterAt(text, textIndex)) {
    letterIndex = textIndex;
  } else if (_isApostropheAt(text, textIndex) || _isHyphenAt(text, textIndex)) {
    if (_isLetterAt(text, textIndex - 1)) {
      letterIndex = textIndex - 1;
    } else if (_isLetterAt(text, textIndex + 1)) {
      letterIndex = textIndex + 1;
    }
  }
  if (letterIndex == null) return null;

  var start = letterIndex;
  while (_isLetterAt(text, start - 1)) {
    start--;
  }
  var end = letterIndex + 1;
  while (_isLetterAt(text, end)) {
    end++;
  }

  while (true) {
    if (_isApostropheAt(text, end) && _isLetterAt(text, end + 1)) {
      end += 2;
      while (_isLetterAt(text, end)) {
        end++;
      }
      continue;
    }
    if (_isHyphenAt(text, end)) {
      if (_isLetterAt(text, end + 1) &&
          _sameLineAcross(page, start, end, end + 1, text.length)) {
        end += 2;
        while (_isLetterAt(text, end)) {
          end++;
        }
        continue;
      }
      final softContinuation = _softContinuationAfter(text, end);
      if (softContinuation != null) {
        end = softContinuation + 1;
        while (_isLetterAt(text, end)) {
          end++;
        }
        continue;
      }
    }
    break;
  }

  while (true) {
    if (_isApostropheAt(text, start - 1) && _isLetterAt(text, start - 2)) {
      start -= 2;
      while (_isLetterAt(text, start - 1)) {
        start--;
      }
      continue;
    }
    if (_isHyphenAt(text, start - 1) &&
        _isLetterAt(text, start - 2) &&
        _sameLineAcross(page, 0, start - 1, start, end)) {
      start -= 2;
      while (_isLetterAt(text, start - 1)) {
        start--;
      }
      continue;
    }
    final softHyphen = _softHyphenBefore(text, start);
    if (softHyphen != null && _isLetterAt(text, softHyphen - 1)) {
      start = softHyphen - 1;
      while (_isLetterAt(text, start - 1)) {
        start--;
      }
      continue;
    }
    break;
  }

  return _TextRange(start, end);
}

int? _softContinuationAfter(String text, int hyphenIndex) {
  var index = hyphenIndex + 1;
  var sawLineBreak = false;
  while (index < text.length && _isWhitespaceAt(text, index)) {
    final codeUnit = text.codeUnitAt(index);
    sawLineBreak = sawLineBreak || codeUnit == 10 || codeUnit == 13;
    index++;
  }
  return sawLineBreak && _isLetterAt(text, index) ? index : null;
}

int? _softHyphenBefore(String text, int textIndex) {
  var index = textIndex - 1;
  var sawLineBreak = false;
  while (index >= 0 && _isWhitespaceAt(text, index)) {
    final codeUnit = text.codeUnitAt(index);
    sawLineBreak = sawLineBreak || codeUnit == 10 || codeUnit == 13;
    index--;
  }
  return sawLineBreak && _isHyphenAt(text, index) ? index : null;
}

bool _sameLineAcross(
  PdfPageGeometry page,
  int leftLimit,
  int hyphenIndex,
  int rightStart,
  int rightLimit,
) {
  PdfRect? left;
  for (var index = hyphenIndex - 1; index >= leftLimit; index--) {
    if (!_isLetterAt(page.fullText, index)) continue;
    left = page.rectAt(index);
    if (left != null) break;
  }
  PdfRect? right;
  for (var index = rightStart; index < rightLimit; index++) {
    if (!_isLetterAt(page.fullText, index)) continue;
    right = page.rectAt(index);
    if (right != null) break;
  }
  return left != null && right != null && _sameVisualLine(left, right);
}

List<PdfRect> _boundsForRange(PdfPageGeometry page, int start, int end) {
  final bounds = <PdfRect>[];
  for (var index = start; index < end; index++) {
    final rect = page.rectAt(index);
    if (rect == null) continue;
    if (bounds.isEmpty || !_sameVisualLine(bounds.last, rect)) {
      bounds.add(rect);
    } else {
      bounds[bounds.length - 1] = bounds.last.merge(rect);
    }
  }
  return bounds;
}

bool _sameVisualLine(PdfRect left, PdfRect right) {
  final overlap =
      (left.top < right.top ? left.top : right.top) -
      (left.bottom > right.bottom ? left.bottom : right.bottom);
  final shorterHeight = left.height < right.height ? left.height : right.height;
  return overlap > shorterHeight * 0.35;
}

String _lineAt(String text, int offset) {
  final start = offset == 0 ? 0 : text.lastIndexOf('\n', offset - 1) + 1;
  final nextLineBreak = text.indexOf('\n', offset);
  final end = nextLineBreak == -1 ? text.length : nextLineBreak;
  return text.substring(start, end).replaceAll('\r', '').trim();
}

bool _isInteractiveLine(String line) {
  final compact = line.trim();
  if (compact.isEmpty || _pageNumber.hasMatch(compact)) return false;
  if (_affiliation.hasMatch(compact)) return false;
  return !_looksLikeAuthorList(compact);
}

bool _looksLikeAuthorList(String line) {
  final names = line.split(',').map((name) => name.trim()).toList();
  if (names.length < 2) return false;
  return names.every((name) {
    final words = name.split(RegExp(r'\s+'));
    if (words.length < 2 || words.length > 4) return false;
    return words.every((word) => RegExp(r'^[A-Z][A-Za-z.\-]*$').hasMatch(word));
  });
}

String _sentenceAt(String text, int offset) {
  var start = offset;
  while (start > 0 && !_isSentenceBoundaryAt(text, start - 1)) {
    start--;
  }
  var end = offset;
  while (end < text.length && !_isSentenceBoundaryAt(text, end)) {
    end++;
  }
  if (end < text.length) end++;
  return _normalizeSoftLineBreaks(text.substring(start, end));
}

String _normalizeSoftLineBreaks(String text) {
  return text
      .replaceAll(_softLineBreak, '')
      .replaceAll(_lineBreak, ' ')
      .replaceAll(_whitespace, ' ')
      .trim();
}

bool _isUsableRect(PdfRect rect) {
  return rect.left.isFinite &&
      rect.top.isFinite &&
      rect.right.isFinite &&
      rect.bottom.isFinite &&
      rect.left < rect.right &&
      rect.bottom < rect.top;
}

bool _isLetterAt(String text, int index) {
  return index >= 0 &&
      index < text.length &&
      _isAsciiLetter(text.codeUnitAt(index));
}

bool _isAsciiLetter(int codeUnit) {
  return (codeUnit >= 65 && codeUnit <= 90) ||
      (codeUnit >= 97 && codeUnit <= 122);
}

bool _isApostropheAt(String text, int index) {
  if (index < 0 || index >= text.length) return false;
  final codeUnit = text.codeUnitAt(index);
  return codeUnit == 39 || codeUnit == 0x2019;
}

bool _isHyphenAt(String text, int index) {
  return index >= 0 && index < text.length && text.codeUnitAt(index) == 45;
}

bool _isWhitespaceAt(String text, int index) {
  return index >= 0 &&
      index < text.length &&
      RegExp(r'\s').hasMatch(text[index]);
}

bool _isSentenceBoundaryAt(String text, int index) {
  if (index < 0 || index >= text.length) return false;
  final codeUnit = text.codeUnitAt(index);
  return codeUnit == 46 || codeUnit == 33 || codeUnit == 63;
}

class _TextRange {
  const _TextRange(this.start, this.end);

  final int start;
  final int end;
}
