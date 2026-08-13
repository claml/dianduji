/// Contract for documents handed to the app through a platform share/open
/// action (Android ACTION_SEND / ACTION_VIEW with a content URI).
///
/// The receiver never parses file bytes; it only prepares a private copy in
/// the application cache and forwards the resulting local path. All import
/// behavior stays in [DocumentImportController].
library;

/// A document handed to the app by another app through a share or open action.
class SharedFileEvent {
  const SharedFileEvent({
    required this.path,
    required this.name,
    this.mime,
    this.error,
  });

  /// Absolute path of the private copy in the application cache. Empty when
  /// [error] is set.
  final String path;

  /// Display name of the shared document, falling back to a local label when
  /// the platform cannot provide one.
  final String name;

  /// MIME type reported by the sharing app, when available.
  final String? mime;

  /// Platform failure code, e.g. `permission_revoked`. Null for a usable
  /// document.
  final String? error;

  bool get isFailure => error != null;

  /// Whether the MIME type matches one of the supported document formats
  /// (TXT, text PDF, DOCX). A null MIME is treated as unsupported so the UI
  /// can ask the user to share a supported format.
  bool get isSupportedDocument => switch (mime) {
    'text/plain' ||
    'application/pdf' ||
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document' =>
      true,
    _ => false,
  };
}

abstract interface class SharedFileReceiver {
  /// Broadcast of shared-file events. Events buffered before the first
  /// listener attaches are replayed at most once.
  Stream<SharedFileEvent> get events;

  /// Attaches the platform channel and drains any cold-start buffered events.
  Future<void> initialize();
}

/// Platform-neutral receiver used on iOS and desktop targets where no share
/// intent channel exists. Emits nothing.
class NoopSharedFileReceiver implements SharedFileReceiver {
  const NoopSharedFileReceiver();

  @override
  Stream<SharedFileEvent> get events => const Stream.empty();

  @override
  Future<void> initialize() async {}
}
