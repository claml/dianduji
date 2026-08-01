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
