import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../core/database/app_database.dart';
import '../core/database/database_factory.dart';
import '../features/dictionary/data/dictionary_asset_store.dart';
import '../features/dictionary/data/dictionary_repository.dart';
import '../features/phrases/data/phrase_catalog_loader.dart';
import '../features/phrases/domain/phrase_recognizer.dart';

class AppRuntime {
  const AppRuntime({
    required this.database,
    required this.dictionary,
    required this.phraseRecognizer,
  });

  final AppDatabase database;
  final DictionaryRepository dictionary;
  final PhraseRecognizer phraseRecognizer;

  Future<void> close() async {
    // ignore: deprecated_member_use
    dictionary.database.dispose();
    await database.close();
  }
}

typedef RuntimeDictionaryOpener =
    Future<DictionaryRepository> Function(Directory supportDirectory);
typedef RuntimePhraseLoader = Future<PhraseRecognizer> Function();

Future<AppRuntime> initializeAppRuntime({
  AppDatabase Function()? databaseFactory,
  Future<Directory> Function()? supportDirectoryProvider,
  RuntimeDictionaryOpener? dictionaryOpener,
  RuntimePhraseLoader? phraseRecognizerLoader,
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
    return AppRuntime(
      database: database,
      dictionary: dictionary,
      phraseRecognizer: phraseRecognizer,
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
