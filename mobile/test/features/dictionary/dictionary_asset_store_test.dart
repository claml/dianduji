import 'dart:io';
import 'dart:typed_data';

import 'package:dian_du_ji/features/dictionary/data/dictionary_asset_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Directory tempDirectory;
  late _FakeAssetReader assetReader;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('dictionary-store-');
    final source = File(
      '${tempDirectory.path}${Platform.pathSeparator}source.sqlite',
    );
    final database = sqlite3.open(source.path);
    database.execute('''
CREATE TABLE entries (
  word TEXT PRIMARY KEY,
  phonetic TEXT NOT NULL,
  part_of_speech TEXT NOT NULL,
  definition_english TEXT NOT NULL,
  definition_chinese TEXT NOT NULL
);
CREATE TABLE lemmas (form TEXT PRIMARY KEY, lemma TEXT NOT NULL);
INSERT INTO entries VALUES ('language', '', 'n.', 'communication', '语言');
''');
    database.close();
    assetReader = _FakeAssetReader(await source.readAsBytes());
    await source.delete();
  });

  tearDown(() => tempDirectory.delete(recursive: true));

  test('copies the bundled dictionary once and opens it read-only', () async {
    final store = DictionaryAssetStore(
      supportDirectory: tempDirectory,
      assetReader: assetReader.read,
    );

    final first = await store.open();
    final second = await store.open();

    expect(assetReader.readCount, 1);
    expect(await first.lookup('language'), isNotNull);
    expect(
      () => second.database.execute('DELETE FROM entries'),
      throwsA(anything),
    );

    first.database.close();
    second.database.close();
  });

  test(
    'reuses a hash-validated dictionary without rereading the asset',
    () async {
      final firstStore = DictionaryAssetStore(
        supportDirectory: tempDirectory,
        assetReader: assetReader.read,
      );
      final first = await firstStore.open();
      first.database.close();

      final secondStore = DictionaryAssetStore(
        supportDirectory: tempDirectory,
        assetReader: assetReader.read,
      );
      final second = await secondStore.open();

      expect(assetReader.readCount, 1);
      expect(await second.lookup('language'), isNotNull);
      second.database.close();
    },
  );
}

class _FakeAssetReader {
  _FakeAssetReader(this._bytes);

  final Uint8List _bytes;
  var readCount = 0;

  Future<ByteData> read(String key) async {
    expect(key, 'assets/dictionary/ecdict.sqlite');
    readCount++;
    return ByteData.sublistView(_bytes);
  }
}
