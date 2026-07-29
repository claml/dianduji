import 'dart:convert';
import 'dart:typed_data';

import '../domain/phrase_recognizer.dart';

typedef PhraseAssetReader = Future<ByteData> Function(String key);

class PhraseCatalogLoader {
  PhraseCatalogLoader({required this.assetReader});

  static const assetKey = 'assets/phrases/phrases.json';

  final PhraseAssetReader assetReader;
  PhraseRecognizer? _recognizer;

  Future<PhraseRecognizer> load() async {
    final cached = _recognizer;
    if (cached != null) return cached;
    final data = await assetReader(assetKey);
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    final decoded = jsonDecode(utf8.decode(bytes));
    final recognizer = PhraseRecognizer(PhraseDefinition.listFromJson(decoded));
    _recognizer = recognizer;
    return recognizer;
  }
}
