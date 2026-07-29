import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/database/app_database.dart';
import '../features/dictionary/data/dictionary_repository.dart';
import '../features/documents/data/drift_document_import_store.dart';
import '../features/documents/data/drift_document_repository.dart';
import '../features/documents/data/default_document_parser_resolver.dart';
import '../features/documents/data/default_import_intake.dart';
import '../features/documents/data/services/file_intake_service.dart';
import '../features/documents/data/file_picker_document_picker.dart';
import '../features/documents/domain/document_structure_builder.dart';
import '../features/documents/domain/import_document_use_case.dart';
import '../features/documents/presentation/document_import_controller.dart';
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
    intake: DefaultImportIntake(
      FileIntakeService(
        sandboxDirectory: Directory(
          '${ref.watch(appSupportDirectoryProvider).path}${Platform.pathSeparator}documents',
        ),
      ),
    ),
    parsers: DefaultDocumentParserResolver(),
    store: DriftDocumentImportStore(database: database, builder: builder),
    createId: const Uuid().v4,
  );
});

final documentPickerProvider = Provider<DocumentPicker>((ref) {
  return const FilePickerDocumentPicker();
});

final documentImportControllerProvider =
    ChangeNotifierProvider.autoDispose<DocumentImportController>((ref) {
      return DocumentImportController(
        picker: ref.watch(documentPickerProvider),
        importer: ref.watch(importDocumentUseCaseProvider),
        repository: ref.watch(documentRepositoryProvider),
      );
    });
