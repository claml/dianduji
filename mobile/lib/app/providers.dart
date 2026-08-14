import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/database/app_database.dart';
import '../core/network/dictionary_enrichment_gateway.dart';
import '../core/network/drift_online_translation_cache.dart';
import '../core/network/http_online_translation_gateway.dart';
import '../core/network/online_translation_cache.dart';
import '../core/network/online_translation_gateway.dart';
import '../core/platform/android_shared_file_receiver.dart';
import '../core/platform/shared_file_receiver.dart';
import '../features/dictionary/data/dictionary_repository.dart';
import '../features/dictionary/data/drift_user_dictionary.dart';
import '../features/dictionary/domain/specialized_terms.dart';
import '../features/dictionary/domain/user_dictionary_repository.dart';
import '../features/dictionary/presentation/dictionary_update_center.dart';
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
import '../features/learning/data/csv_export_service.dart';
import '../features/learning/data/learning_repository.dart';
import '../features/learning/presentation/learning_controllers.dart';
import '../features/phrases/domain/phrase_recognizer.dart';
import '../features/reader/data/reader_card_preferences.dart';
import '../features/settings/data/cache_cleanup_service.dart';
import '../features/settings/data/settings_repository.dart';
import '../features/settings/presentation/persisted_settings_controller.dart';
import '../features/sync/domain/app_local_data_provider.dart';
import '../features/sync/domain/sync_api_client.dart';
import '../features/sync/domain/sync_engine.dart';
import '../features/sync/domain/token_storage.dart';
import '../features/sync/presentation/sync_controller.dart';
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

final specializedTermCatalogProvider = Provider<SpecializedTermIndex?>((ref) {
  return ref.watch(appRuntimeProvider).specializedIndex;
});

final userDictionaryProvider = Provider<UserDictionaryStore>((ref) {
  return DriftUserDictionary(ref.watch(appDatabaseProvider));
});

final dictionaryEnrichmentGatewayProvider =
    Provider<DictionaryEnrichmentGateway?>((ref) {
      const baseUrl = String.fromEnvironment('DIANDUJI_TRANSLATE_BASE_URL');
      if (baseUrl.isEmpty) return null;
      return HttpDictionaryEnrichmentGateway(baseUrl: Uri.parse(baseUrl));
    });

final dictionaryUpdateCenterProvider =
    ChangeNotifierProvider.autoDispose<DictionaryUpdateCenter>((ref) {
      return DictionaryUpdateCenter(
        store: ref.watch(userDictionaryProvider),
        gateway: ref.watch(dictionaryEnrichmentGatewayProvider),
      );
    });

final onlineTranslationGatewayProvider = Provider<OnlineTranslationGateway?>((
  ref,
) {
  const baseUrl = String.fromEnvironment('DIANDUJI_TRANSLATE_BASE_URL');
  // Logging the configured base URL (not any key) so a missing dart-define
  // is immediately visible in logcat.
  debugPrint('ONLINE_GATEWAY_CONFIG baseUrl="$baseUrl"');
  if (baseUrl.isEmpty) return null;
  const apiKey = String.fromEnvironment('DIANDUJI_TRANSLATE_API_KEY');
  final inner = HttpOnlineTranslationGateway(
    baseUrl: Uri.parse(baseUrl),
    apiKey: apiKey.isEmpty ? null : apiKey,
  );
  final cache = DriftOnlineTranslationCache(ref.watch(appDatabaseProvider));
  return CachedOnlineTranslationGateway(inner: inner, cache: cache);
});

final learningRepositoryProvider = Provider<LearningRepository>((ref) {
  return DriftLearningRepository(ref.watch(appDatabaseProvider).learningDao);
});

final csvExportServiceProvider = Provider<CsvExportService>((ref) {
  return const CsvExportService(destination: FilePickerCsvDestinationPicker());
});

final vocabularyControllerProvider =
    ChangeNotifierProvider.autoDispose<VocabularyController>((ref) {
      return VocabularyController(
        ref.watch(learningRepositoryProvider),
        ref.watch(csvExportServiceProvider),
      );
    });

final phraseBookControllerProvider =
    ChangeNotifierProvider.autoDispose<PhraseBookController>((ref) {
      return PhraseBookController(ref.watch(learningRepositoryProvider));
    });

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final repository = DriftSettingsRepository(
    ref.watch(appDatabaseProvider).settingsDao,
  );
  ref.onDispose(repository.dispose);
  return repository;
});

final persistedSettingsControllerProvider =
    ChangeNotifierProvider<PersistedSettingsController>((ref) {
      return PersistedSettingsController(ref.watch(settingsRepositoryProvider));
    });

final readingSettingsProvider = Provider<PersistedSettingsState>((ref) {
  return ref.watch(persistedSettingsControllerProvider).state;
});

final readerCardPreferencesRepositoryProvider =
    Provider<ReaderCardPreferencesStore>((ref) {
      return ReaderCardPreferencesRepository(
        ref.watch(appDatabaseProvider).settingsDao,
      );
    });

final cacheCleanupServiceProvider = Provider<CacheCleanupService>((ref) {
  return DirectoryCacheCleanupService(
    appSupportDirectory: ref.watch(appSupportDirectoryProvider),
  );
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

final sharedFileReceiverProvider = Provider<SharedFileReceiver>((ref) {
  if (!kIsWeb && Platform.isAndroid) return AndroidSharedFileReceiver();
  return const NoopSharedFileReceiver();
});

final documentImportControllerProvider =
    ChangeNotifierProvider.autoDispose<DocumentImportController>((ref) {
      return DocumentImportController(
        picker: ref.watch(documentPickerProvider),
        importer: ref.watch(importDocumentUseCaseProvider),
        repository: ref.watch(documentRepositoryProvider),
        sharedFileReceiver: ref.watch(sharedFileReceiverProvider),
      );
    });

final syncApiClientProvider = Provider<SyncApiClient>((ref) {
  const configured = String.fromEnvironment('DIANDUJI_SYNC_BASE_URL');
  final url = configured.isEmpty ? kDefaultSyncBaseUrl : configured;
  debugPrint('SYNC_GATEWAY_CONFIG baseUrl="$url"');
  return SyncApiClient(baseUrl: Uri.parse(url));
});

final syncEngineProvider = Provider<SyncEngine>((ref) {
  return SyncEngine(
    api: ref.watch(syncApiClientProvider),
    storage: SecureTokenStorage(),
    local: AppLocalDataProvider(
      learning: ref.watch(learningRepositoryProvider),
      settings: ref.watch(settingsRepositoryProvider),
    ),
  );
});

final syncControllerProvider = ChangeNotifierProvider<SyncController>((ref) {
  return SyncController(engine: ref.watch(syncEngineProvider));
});
