import '../models/parsed_block.dart';

const _abbreviations = <String>{
  'dr',
  'e.g',
  'etc',
  'i.e',
  'jr',
  'mr',
  'mrs',
  'ms',
  'prof',
  'sr',
  'st',
  'vs',
};

List<SentenceSpan> splitSentences(String paragraph) {
  final result = <SentenceSpan>[];
  var segmentStart = 0;
  var index = 0;

  void addSegment(int rawEnd) {
    var start = segmentStart;
    var end = rawEnd;
    while (start < end && _isWhitespace(paragraph.codeUnitAt(start))) {
      start++;
    }
    while (end > start && _isWhitespace(paragraph.codeUnitAt(end - 1))) {
      end--;
    }
    if (start < end) {
      result.add(
        SentenceSpan(
          text: paragraph.substring(start, end),
          start: start,
          end: end,
        ),
      );
    }
  }

  while (index < paragraph.length) {
    final char = paragraph[index];
    if (char == '\r' || char == '\n') {
      addSegment(index);
      if (char == '\r' &&
          index + 1 < paragraph.length &&
          paragraph[index + 1] == '\n') {
        index++;
      }
      segmentStart = index + 1;
      index++;
      continue;
    }

    if ((char == '.' || char == '!' || char == '?') &&
        !_isNonTerminalPeriod(paragraph, index)) {
      var end = index + 1;
      while (end < paragraph.length && _isClosingMark(paragraph[end])) {
        end++;
      }
      if (end == paragraph.length || _isWhitespace(paragraph.codeUnitAt(end))) {
        addSegment(end);
        segmentStart = end;
        index = end;
        continue;
      }
    }
    index++;
  }

  addSegment(paragraph.length);
  return result;
}

bool _isNonTerminalPeriod(String text, int index) {
  if (text[index] != '.') return false;
  if (index > 0 &&
      index + 1 < text.length &&
      _isDigit(text.codeUnitAt(index - 1)) &&
      _isDigit(text.codeUnitAt(index + 1))) {
    return true;
  }
  if (index + 2 < text.length &&
      _isAsciiLetter(text.codeUnitAt(index + 1)) &&
      text[index + 2] == '.') {
    return true;
  }

  var start = index - 1;
  while (start >= 0) {
    final code = text.codeUnitAt(start);
    if (!_isAsciiLetter(code) && text[start] != '.') break;
    start--;
  }
  final candidate = text.substring(start + 1, index).toLowerCase();
  return _abbreviations.contains(candidate);
}

bool _isClosingMark(String char) =>
    char == '"' ||
    char == "'" ||
    char == '”' ||
    char == '’' ||
    char == ')' ||
    char == ']' ||
    char == '}';

bool _isWhitespace(int codeUnit) =>
    codeUnit == 0x20 ||
    codeUnit == 0x09 ||
    codeUnit == 0x0a ||
    codeUnit == 0x0d ||
    codeUnit == 0x0b ||
    codeUnit == 0x0c ||
    codeUnit == 0xa0;

bool _isDigit(int codeUnit) => codeUnit >= 0x30 && codeUnit <= 0x39;

bool _isAsciiLetter(int codeUnit) =>
    (codeUnit >= 0x41 && codeUnit <= 0x5a) ||
    (codeUnit >= 0x61 && codeUnit <= 0x7a);
