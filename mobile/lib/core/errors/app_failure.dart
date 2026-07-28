enum AppFailureCode {
  unsupportedFormat,
  unknownEncoding,
  corruptArchive,
  archiveLimitExceeded,
  encryptedPdf,
  ocrRequired,
  cancelled,
  timeout,
  fileUnavailable,
  storage,
  unknown,
}

class AppFailure implements Exception {
  const AppFailure(this.code, this.message, {this.cause});

  final AppFailureCode code;
  final String message;
  final Object? cause;

  @override
  String toString() => 'AppFailure(${code.name}): $message';
}
