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

Future<AppRuntime> initializeAppRuntime() async {
  final database = createAppDatabase();
  try {
    final supportDirectory = await getApplicationSupportDirectory();
    final dictionary = await DictionaryAssetStore(
      supportDirectory: supportDirectory,
      assetReader: rootBundle.load,
    ).open();
    final phraseRecognizer = await PhraseCatalogLoader(
      assetReader: rootBundle.load,
    ).load();
    return AppRuntime(
      database: database,
      dictionary: dictionary,
      phraseRecognizer: phraseRecognizer,
    );
  } on Object {
    await database.close();
    rethrow;
  }
}
