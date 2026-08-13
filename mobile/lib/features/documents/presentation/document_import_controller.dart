import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/platform/pdf_text_extractor.dart';
import '../../../core/platform/shared_file_receiver.dart';
import '../data/drift_document_repository.dart';
import '../data/file_picker_document_picker.dart';
import '../data/services/file_intake_service.dart';
import '../domain/document_models.dart';
import '../domain/import_document_use_case.dart';
import 'document_library_screen.dart';

class DocumentImportController extends ChangeNotifier {
  DocumentImportController({
    required this.picker,
    required this.importer,
    required this.repository,
    SharedFileReceiver? sharedFileReceiver,
  }) {
    _subscription = repository.watchDocuments().listen(_receiveDocuments);
    final receiver = sharedFileReceiver;
    if (receiver != null) {
      unawaited(receiver.initialize());
      _sharedSubscription = receiver.events.listen(_receiveSharedFile);
    }
  }

  final DocumentPicker picker;
  final DocumentImporter importer;
  final DocumentRepository repository;
  StreamSubscription<SharedFileEvent>? _sharedSubscription;
  final _imports = <String, ImportState>{};
  final _cancellations = <String, ParseCancellationToken>{};
  final _activeCancellations = <ParseCancellationToken>{};
  final _records = <String, DocumentSummary>{};
  late final StreamSubscription<List<DocumentSummary>> _subscription;

  DocumentLibraryState _state = const DocumentLibraryState();
  DocumentLibraryState get state => _state;

  Future<ImportState?> pickAndImport() async {
    try {
      final selected = await picker.pickDocument();
      if (selected == null) return null;
      return importSelectedFile(selected);
    } on AppFailure catch (failure) {
      _setState(errorMessage: _messageFor(failure));
    } on Object {
      _setState(
        errorMessage:
            '\u9009\u62e9\u6587\u4ef6\u5931\u8d25\uff0c\u8bf7\u91cd\u65b0\u9009\u62e9\u3002',
      );
    }
    return null;
  }

  Future<ImportState?> importSelectedFile(SelectedFile selectedFile) {
    final token = ParseCancellationToken();
    return _consume(
      importer.start(selectedFile, cancellationToken: token),
      cancellationToken: token,
    );
  }

  void _receiveSharedFile(SharedFileEvent event) {
    if (event.isFailure) {
      _setState(
        errorMessage:
            '\u65e0\u6cd5\u8bfb\u53d6\u5206\u4eab\u7684\u6587\u4ef6\uff0c\u6743\u9650\u53ef\u80fd\u5df2\u5931\u6548\uff0c\u8bf7\u91cd\u65b0\u5206\u4eab\u3002',
      );
      return;
    }
    if (!event.isSupportedDocument) {
      _setState(
        errorMessage:
            '\u4e0d\u652f\u6301\u8be5\u6587\u4ef6\u683c\u5f0f\uff0c\u8bf7\u5206\u4eab TXT\u3001PDF \u6216 DOCX \u6587\u4ef6\u3002',
      );
      return;
    }
    unawaited(
      importSelectedFile(
        SelectedFile(path: event.path, originalName: event.name),
      ),
    );
  }

  Future<void> retry(String documentId) async {
    final record = _records[documentId];
    if (record == null || record.localPath.isEmpty) {
      _setState(
        errorMessage:
            '\u627e\u4e0d\u5230\u672c\u5730\u6587\u4ef6\uff0c\u8bf7\u91cd\u65b0\u5bfc\u5165\u3002',
      );
      return;
    }
    final token = ParseCancellationToken();
    await _consume(
      importer.retry(
        documentId,
        SelectedFile(path: record.localPath, originalName: record.sourceName),
        cancellationToken: token,
      ),
      cancellationToken: token,
    );
  }

  Future<void> cancel(String documentId) async {
    final token = _cancellations[documentId];
    token?.cancel();
  }

  Future<void> delete(String documentId) =>
      repository.deleteDocument(documentId);

  void select(String documentId) => _setState(selectedDocumentId: documentId);

  void setSearchQuery(String value) => _setState(searchQuery: value);

  void setSort(DocumentLibrarySort value) => _setState(sort: value);

  Future<ImportState?> _consume(
    Stream<ImportState> stream, {
    required ParseCancellationToken cancellationToken,
  }) async {
    ImportState? latest;
    _activeCancellations.add(cancellationToken);
    _setState(errorMessage: null);
    try {
      await for (final importState in stream) {
        latest = importState;
        _imports[importState.documentId] = importState;
        _cancellations[importState.documentId] = cancellationToken;
        if (importState.status == ImportStatus.duplicate) {
          _setState(
            selectedDocumentId: importState.documentId,
            errorMessage:
                '\u8be5\u6587\u4ef6\u5df2\u5bfc\u5165\uff0c\u5df2\u9009\u4e2d\u73b0\u6709\u6587\u6863\u3002',
          );
        } else {
          _setState(
            errorMessage: importState.failure == null
                ? null
                : _messageFor(importState.failure!),
          );
        }
      }
    } on AppFailure catch (failure) {
      _setState(errorMessage: _messageFor(failure));
    } on Object {
      _setState(
        errorMessage: '\u5bfc\u5165\u5931\u8d25\uff0c\u8bf7\u91cd\u8bd5\u3002',
      );
    } finally {
      _activeCancellations.remove(cancellationToken);
    }
    return latest;
  }

  void _receiveDocuments(List<DocumentSummary> documents) {
    _records
      ..clear()
      ..addEntries(
        documents.map((document) => MapEntry(document.id, document)),
      );
    _setState();
  }

  void _setState({
    String? selectedDocumentId,
    String? errorMessage,
    String? searchQuery,
    DocumentLibrarySort? sort,
  }) {
    final nextSearchQuery = searchQuery ?? _state.searchQuery;
    final nextSort = sort ?? _state.sort;
    final next = DocumentLibraryState(
      documents: _libraryDocuments(
        searchQuery: nextSearchQuery,
        sort: nextSort,
      ),
      selectedDocumentId: selectedDocumentId ?? _state.selectedDocumentId,
      errorMessage: errorMessage,
      searchQuery: nextSearchQuery,
      sort: nextSort,
      imports: Map.unmodifiable(_imports),
    );
    _state = next;
    notifyListeners();
  }

  List<LibraryDocument> _libraryDocuments({
    required String searchQuery,
    required DocumentLibrarySort sort,
  }) {
    final query = searchQuery.trim().toLowerCase();
    final records = _records.values.where((document) {
      return query.isEmpty ||
          document.title.toLowerCase().contains(query) ||
          document.sourceName.toLowerCase().contains(query);
    }).toList();
    records.sort(
      (left, right) => switch (sort) {
        DocumentLibrarySort.title => left.title.compareTo(right.title),
        DocumentLibrarySort.importTime => _compareDates(
          left.importedAt,
          right.importedAt,
        ),
        DocumentLibrarySort.lastOpened => _compareDates(
          left.lastOpenedAt,
          right.lastOpenedAt,
        ),
      },
    );
    return records.map(_libraryDocument).toList(growable: false);
  }

  int _compareDates(DateTime? left, DateTime? right) {
    return (right ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
      left ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  LibraryDocument _libraryDocument(DocumentSummary document) {
    final completed = document.status == 'completed';
    return LibraryDocument(
      id: document.id,
      title: document.title,
      sourceName: document.sourceName,
      formatLabel: document.format.toUpperCase(),
      progress: completed ? document.readProgress : document.progress,
      status: switch (document.status) {
        'queued' => LibraryDocumentStatus.queued,
        'parsing' => LibraryDocumentStatus.parsing,
        'completed' => LibraryDocumentStatus.completed,
        'cancelled' => LibraryDocumentStatus.cancelled,
        _ => LibraryDocumentStatus.failed,
      },
      failureMessage: document.failureMessage,
    );
  }

  String _messageFor(AppFailure failure) => switch (failure.code) {
    AppFailureCode.unsupportedFormat =>
      '\u4e0d\u652f\u6301\u8be5\u6587\u4ef6\u683c\u5f0f\uff0c\u8bf7\u9009\u62e9 TXT\u3001PDF \u6216 DOCX\u3002',
    AppFailureCode.fileUnavailable =>
      '\u65e0\u6cd5\u8bfb\u53d6\u8be5\u6587\u4ef6\uff0c\u8bf7\u91cd\u65b0\u9009\u62e9\u3002',
    _ => failure.message,
  };

  @override
  void dispose() {
    _subscription.cancel();
    _sharedSubscription?.cancel();
    super.dispose();
  }
}
