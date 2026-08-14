import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dian_du_ji/app/app_runtime.dart';
import 'package:dian_du_ji/app/providers.dart';
import 'package:dian_du_ji/core/database/app_database.dart';
import 'package:dian_du_ji/features/dictionary/data/dictionary_repository.dart';
import 'package:dian_du_ji/features/phrases/domain/phrase_recognizer.dart';
import 'package:dian_du_ji/features/phrases/data/phrase_catalog_loader.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('loads a valid phrase JSON catalog once', () async {
    final reader = _PhraseAssetReader(
      '[{"key":"look-up","words":["look","up"],'
      '"type":"phrasalVerb","meaning":"查阅"}]',
    );
    final loader = PhraseCatalogLoader(assetReader: reader.read);

    expect(await loader.load(), same(await loader.load()));
    expect(reader.readCount, 1);
  });

  test('provider disposal closes application-owned databases', () async {
    final dictionaryDatabase = sqlite3.openInMemory();
    final userDatabase = _RecordingDatabase();
    final runtime = AppRuntime(
      database: userDatabase,
      dictionary: DictionaryRepository(dictionaryDatabase),
      phraseRecognizer: PhraseRecognizer(const []),
      specializedIndex: null,
    );
    final container = ProviderContainer(
      overrides: [
        appRuntimeProvider.overrideWith((ref) {
          ref.onDispose(() => unawaited(runtime.close()));
          return runtime;
        }),
      ],
    );
    container.read(appDatabaseProvider);
    container.read(dictionaryLookupProvider);

    container.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(() => dictionaryDatabase.select('SELECT 1'), throwsA(anything));
    expect(userDatabase.closed, isTrue);
  });
}

class _RecordingDatabase extends AppDatabase {
  _RecordingDatabase() : super(NativeDatabase.memory());

  var closed = false;

  @override
  Future<void> close() async {
    closed = true;
    await super.close();
  }
}

class _PhraseAssetReader {
  _PhraseAssetReader(this._json);

  final String _json;
  var readCount = 0;

  Future<ByteData> read(String key) async {
    expect(key, 'assets/phrases/phrases.json');
    readCount++;
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(_json)));
  }
}
