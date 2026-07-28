enum ParsedBlockStyle { body, heading, listItem }

class ParsedBlock {
  const ParsedBlock({
    required this.text,
    this.style = ParsedBlockStyle.body,
    this.sourceIndex,
  });

  final String text;
  final ParsedBlockStyle style;
  final int? sourceIndex;
}

class SentenceSpan {
  const SentenceSpan({
    required this.text,
    required this.start,
    required this.end,
  });

  final String text;
  final int start;
  final int end;
}

class TokenSpan {
  const TokenSpan({
    required this.surface,
    required this.normalized,
    required this.start,
    required this.end,
  });

  final String surface;
  final String normalized;
  final int start;
  final int end;
}
