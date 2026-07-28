class ParseCancellationToken {
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  void cancel() => _isCancelled = true;
}

class PdfPageText {
  const PdfPageText({
    required this.pageNumber,
    required this.pageCount,
    required this.text,
  });

  final int pageNumber;
  final int pageCount;
  final String text;
}

enum PdfExtractionError { encrypted, corrupt, unavailable, cancelled, unknown }

class PdfExtractionException implements Exception {
  const PdfExtractionException(this.error, [this.message = '']);

  final PdfExtractionError error;
  final String message;
}

abstract interface class PdfTextExtractor {
  Stream<PdfPageText> extract(
    String path, {
    required ParseCancellationToken cancellationToken,
  });
}
