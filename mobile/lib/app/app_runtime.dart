import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../core/database/app_database.dart';
import '../core/database/database_factory.dart';
import '../features/dictionary/data/dictionary_asset_store.dart';
import '../features/dictionary/data/dictionary_repository.dart';
import '../features/dictionary/data/specialized_term_catalog.dart';
import '../features/dictionary/domain/specialized_terms.dart';
import '../features/phrases/data/phrase_catalog_loader.dart';
import '../features/phrases/domain/phrase_recognizer.dart';

class AppRuntime {
  const AppRuntime({
    required this.database,
    required this.dictionary,
    required this.phraseRecognizer,
    required this.specializedIndex,
  });

  final AppDatabase database;
  final DictionaryRepository dictionary;
  final PhraseRecognizer phraseRecognizer;
  final SpecializedTermIndex? specializedIndex;

  Future<void> close() async {
    // ignore: deprecated_member_use
    dictionary.database.dispose();
    await database.close();
  }
}

typedef RuntimeDictionaryOpener =
    Future<DictionaryRepository> Function(Directory supportDirectory);
typedef RuntimePhraseLoader = Future<PhraseRecognizer> Function();
typedef RuntimeSpecializedLoader = Future<SpecializedTermIndex> Function();

Future<AppRuntime> initializeAppRuntime({
  AppDatabase Function()? databaseFactory,
  Future<Directory> Function()? supportDirectoryProvider,
  RuntimeDictionaryOpener? dictionaryOpener,
  RuntimePhraseLoader? phraseRecognizerLoader,
  RuntimeSpecializedLoader? specializedLoader,
}) async {
  final database = (databaseFactory ?? createAppDatabase)();
  DictionaryRepository? dictionary;
  try {
    final supportDirectory =
        await (supportDirectoryProvider ?? getApplicationSupportDirectory)();
    dictionary = await (dictionaryOpener ?? _openBundledDictionary)(
      supportDirectory,
    );
    final phraseRecognizer =
        await (phraseRecognizerLoader ?? _loadBundledPhrases)();
    final specializedIndex = await (specializedLoader ?? _loadSpecialized)();
    return AppRuntime(
      database: database,
      dictionary: dictionary,
      phraseRecognizer: phraseRecognizer,
      specializedIndex: specializedIndex,
    );
  } on Object {
    // ignore: deprecated_member_use
    dictionary?.database.dispose();
    await database.close();
    rethrow;
  }
}

Future<DictionaryRepository> _openBundledDictionary(
  Directory supportDirectory,
) {
  return DictionaryAssetStore(
    supportDirectory: supportDirectory,
    assetReader: rootBundle.load,
  ).open();
}

Future<PhraseRecognizer> _loadBundledPhrases() {
  return PhraseCatalogLoader(assetReader: rootBundle.load).load();
}

Future<SpecializedTermIndex> _loadSpecialized() {
  return SpecializedTermCatalog.loadFromAssets();
}
