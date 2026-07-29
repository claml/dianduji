import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:sqlite3/sqlite3.dart';

import 'dictionary_repository.dart';

typedef DictionaryAssetReader = Future<ByteData> Function(String key);

class DictionaryAssetStore {
  DictionaryAssetStore({
    required this.supportDirectory,
    required this.assetReader,
  });

  static const assetKey = 'assets/dictionary/ecdict.sqlite';
  static const _databaseName = 'ecdict.sqlite';

  final Directory supportDirectory;
  final DictionaryAssetReader assetReader;

  Future<DictionaryRepository> open() async {
    final databaseFile = File(_path(_databaseName));
    final metadataFile = File(_path('$_databaseName.sha256'));
    await supportDirectory.create(recursive: true);

    if (!await _isValid(databaseFile, metadataFile)) {
      await _copyAsset(databaseFile, metadataFile);
    }

    return DictionaryRepository(
      sqlite3.open(databaseFile.path, mode: OpenMode.readOnly),
    );
  }

  String _path(String name) =>
      '${supportDirectory.path}${Platform.pathSeparator}$name';

  Future<bool> _isValid(File databaseFile, File metadataFile) async {
    if (!await databaseFile.exists() || !await metadataFile.exists()) {
      return false;
    }
    final expected = (await metadataFile.readAsString()).trim();
    return expected.isNotEmpty && expected == await _hashFile(databaseFile);
  }

  Future<void> _copyAsset(File databaseFile, File metadataFile) async {
    final data = await assetReader(assetKey);
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    final hash = sha256.convert(bytes).toString();
    final part = File('${databaseFile.path}.part');
    final metadataPart = File('${metadataFile.path}.part');
    if (await part.exists()) await part.delete();
    if (await metadataPart.exists()) await metadataPart.delete();

    try {
      await part.writeAsBytes(bytes, flush: true);
      await metadataPart.writeAsString(hash, flush: true);
      if (await databaseFile.exists()) await databaseFile.delete();
      if (await metadataFile.exists()) await metadataFile.delete();
      await part.rename(databaseFile.path);
      await metadataPart.rename(metadataFile.path);
    } on Object {
      if (await part.exists()) await part.delete();
      if (await metadataPart.exists()) await metadataPart.delete();
      rethrow;
    }
  }

  Future<String> _hashFile(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }
}
