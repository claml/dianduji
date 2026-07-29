import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/database/app_database.dart';
import '../core/platform/pdf_text_extractor.dart';
import '../features/dictionary/data/dictionary_repository.dart';
import '../features/documents/data/drift_document_import_store.dart';
import '../features/documents/data/drift_document_repository.dart';
import '../features/documents/data/parsers/docx_document_parser.dart';
import '../features/documents/data/parsers/pdf_document_parser.dart';
import '../features/documents/data/parsers/txt_document_parser.dart';
import '../features/documents/data/services/file_intake_service.dart';
import '../features/documents/domain/detect_file_format.dart';
import '../features/documents/domain/document_structure_builder.dart';
import '../features/documents/domain/file_format.dart';
import '../features/documents/domain/import_document_use_case.dart';
import '../features/documents/domain/parsers/document_parser.dart';
import '../features/learning/data/drift_learning_repository.dart';
import '../features/learning/data/learning_repository.dart';
import '../features/phrases/domain/phrase_recognizer.dart';
import '../features/settings/data/reading_settings.dart';
import '../features/settings/data/settings_repository.dart';
import 'app_runtime.dart';

final appRuntimeProvider = Provider<AppRuntime>((ref) {
  throw StateError('main.dart must override appRuntimeProvider');
});

final appSupportDirectoryProvider = Provider<Directory>((ref) {
  throw StateError('main.dart must override appSupportDirectoryProvider');
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return ref.watch(appRuntimeProvider).database;
});

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DriftDocumentRepository(ref.watch(appDatabaseProvider));
});

final dictionaryLookupProvider = Provider<DictionaryLookup>((ref) {
  return ref.watch(appRuntimeProvider).dictionary;
});

final phraseRecognizerProvider = Provider<PhraseRecognizer>((ref) {
  return ref.watch(appRuntimeProvider).phraseRecognizer;
});

final learningRepositoryProvider = Provider<LearningRepository>((ref) {
  return DriftLearningRepository(ref.watch(appDatabaseProvider).learningDao);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final repository = DriftSettingsRepository(
    ref.watch(appDatabaseProvider).settingsDao,
  );
  ref.onDispose(repository.dispose);
  return repository;
});

final readingSettingsProvider = StreamProvider<ReadingSettings>((ref) {
  return ref.watch(settingsRepositoryProvider).watch();
});

final importDocumentUseCaseProvider = Provider<ImportDocumentUseCase>((ref) {
  final database = ref.watch(appDatabaseProvider);
  final builder = DocumentStructureBuilder(
    dictionary: ref.watch(dictionaryLookupProvider),
    phraseRecognizer: ref.watch(phraseRecognizerProvider),
  );
  return ImportDocumentUseCase(
    intake: _AppImportIntake(
      FileIntakeService(
        sandboxDirectory: Directory(
          '${ref.watch(appSupportDirectoryProvider).path}${Platform.pathSeparator}documents',
        ),
      ),
    ),
    parsers: _AppDocumentParserResolver(),
    store: DriftDocumentImportStore(database: database, builder: builder),
    createId: const Uuid().v4,
  );
});

class _AppImportIntake implements ImportIntake {
  const _AppImportIntake(this._files);

  final FileIntakeService _files;

  @override
  Future<PreparedImportFile> prepare(SelectedFile selectedFile) async {
    final intake = await _files.copyIntoSandbox(selectedFile);
    final bytes = await File(intake.localPath).readAsBytes();
    return PreparedImportFile(
      intake: intake,
      format: detectFileFormat(bytes, selectedFile.originalName),
      bytes: bytes,
    );
  }
}

class _AppDocumentParserResolver implements DocumentParserResolver {
  final PdfTextExtractor _pdfExtractor = const _UnavailablePdfTextExtractor();

  @override
  DocumentParser forFormat(FileFormat format) => switch (format) {
    FileFormat.txt => const TxtDocumentParser(),
    FileFormat.docx => const DocxDocumentParser(),
    FileFormat.pdf => PdfDocumentParser(extractor: _pdfExtractor),
  };
}

class _UnavailablePdfTextExtractor implements PdfTextExtractor {
  const _UnavailablePdfTextExtractor();

  @override
  Stream<PdfPageText> extract(
    String path, {
    required ParseCancellationToken cancellationToken,
  }) async* {
    throw const PdfExtractionException(PdfExtractionError.unavailable);
  }
}
