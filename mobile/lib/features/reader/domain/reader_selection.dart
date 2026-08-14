class ReaderSelection {
  const ReaderSelection({
    required this.surface,
    required this.normalized,
    required this.contextText,
    required this.startOffset,
    required this.endOffset,
    this.sentenceId,
    this.tokenId,
    this.pageNumber,
  });

  final String surface;
  final String normalized;
  final String contextText;
  final int startOffset;
  final int endOffset;
  final String? sentenceId;
  final String? tokenId;
  final int? pageNumber;
}

/// Candidate joined words for a line-break split without a hyphen. Some PDF
/// engines drop the break hyphen from extracted text, leaving `de mands`
/// where the page shows `de-` / `mands`. This returns up to two concatenated
/// candidates — `previous + surface` and `surface + next` — when [surface]
/// sits at a word boundary adjacent to a lower-case word. The caller must
/// verify each candidate against the dictionary: normal sentence words also
/// produce candidates (`wordinside`), which a dictionary miss discards.
///
/// Returns an empty list when [surface] is absent or not at a word boundary,
/// or when the neighboring word starts with an upper-case letter (a new
/// sentence, not a split).
List<String> lineBreakJoinedCandidates(String contextText, String surface) {
  final lower = contextText.toLowerCase();
  final needle = surface.toLowerCase();
  if (needle.isEmpty) return const [];
  final pos = _wordBoundaryIndexOf(lower, needle);
  if (pos < 0) return const [];

  bool isAsciiLetter(int codeUnit) =>
      (codeUnit >= 65 && codeUnit <= 90) ||
      (codeUnit >= 97 && codeUnit <= 122);

  final candidates = <String>[];

  // Candidate 1: surface ends a visual line; the next line starts with the
  // remainder (de -> mands).
  var index = pos + needle.length;
  if (index < lower.length && lower.codeUnitAt(index) == 32) {
    index++;
    if (index < lower.length && isAsciiLetter(lower.codeUnitAt(index))) {
      final nextStart = index;
      while (index < lower.length && isAsciiLetter(lower.codeUnitAt(index))) {
        index++;
      }
      final next = contextText.substring(nextStart, index);
      if (next.toLowerCase() == next) {
        candidates.add('$surface$next');
      }
    }
  }

  // Candidate 2: surface starts a visual line; the previous line ends with
  // the first part (mands <- de).
  if (pos > 1 && lower.codeUnitAt(pos - 1) == 32) {
    var start = pos - 2;
    if (isAsciiLetter(lower.codeUnitAt(start))) {
      while (start > 0 && isAsciiLetter(lower.codeUnitAt(start - 1))) {
        start--;
      }
      final previous = contextText.substring(start, pos - 1);
      if (previous.toLowerCase() == previous) {
        candidates.add('$previous$surface');
      }
    }
  }
  return candidates;
}

int _wordBoundaryIndexOf(String lowerText, String needle) {
  var from = 0;
  while (true) {
    final pos = lowerText.indexOf(needle, from);
    if (pos < 0) return -1;
    final before = pos == 0 ? null : lowerText.codeUnitAt(pos - 1);
    final after = pos + needle.length >= lowerText.length
        ? null
        : lowerText.codeUnitAt(pos + needle.length);
    final beforeOk =
        before == null || before == 32 || before == 10 || before == 13;
    final afterOk = after == null || after == 32 || after == 10 || after == 13;
    if (beforeOk && afterOk) return pos;
    from = pos + 1;
  }
}
