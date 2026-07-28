import '../../documents/domain/models/parsed_block.dart';
import 'phrase_type.dart';

class PhraseDefinition {
  const PhraseDefinition({
    required this.key,
    required this.words,
    required this.type,
    required this.meaning,
    this.confidence = 1,
  });

  final String key;
  final List<String> words;
  final PhraseType type;
  final String meaning;
  final double confidence;

  static List<PhraseDefinition> listFromJson(Object? value) {
    if (value is! List<Object?>) {
      throw const FormatException('Phrase catalog must be a JSON array.');
    }
    return value
        .map((item) {
          if (item is! Map<String, Object?>) {
            throw const FormatException('Phrase entry must be a JSON object.');
          }
          final key = item['key'];
          final words = item['words'];
          final type = item['type'];
          final meaning = item['meaning'];
          final confidence = item['confidence'] ?? 1;
          if (key is! String ||
              words is! List<Object?> ||
              words.any((word) => word is! String) ||
              type is! String ||
              meaning is! String ||
              confidence is! num) {
            throw const FormatException('Phrase entry has invalid fields.');
          }
          return PhraseDefinition(
            key: key,
            words: words.cast<String>(),
            type: PhraseTypeCodec.fromStorage(type),
            meaning: meaning,
            confidence: confidence.toDouble(),
          );
        })
        .toList(growable: false);
  }
}

class PhraseMatch {
  const PhraseMatch({
    required this.key,
    required this.surface,
    required this.type,
    required this.meaning,
    required this.confidence,
    required this.startTokenOrdinal,
    required this.endTokenOrdinal,
  });

  final String key;
  final String surface;
  final PhraseType type;
  final String meaning;
  final double confidence;
  final int startTokenOrdinal;
  final int endTokenOrdinal;
}

class PhraseRecognizer {
  PhraseRecognizer(Iterable<PhraseDefinition> definitions)
    : _byFirstWord = _index(definitions);

  final Map<String, List<PhraseDefinition>> _byFirstWord;

  List<PhraseMatch> recognize(
    List<TokenSpan> sentenceTokens, {
    double minimumConfidence = 0.7,
  }) {
    final matches = <PhraseMatch>[];
    var tokenIndex = 0;
    while (tokenIndex < sentenceTokens.length) {
      final candidates = _byFirstWord[sentenceTokens[tokenIndex].normalized];
      PhraseDefinition? matched;
      if (candidates != null) {
        for (final candidate in candidates) {
          if (candidate.confidence < minimumConfidence ||
              tokenIndex + candidate.words.length > sentenceTokens.length) {
            continue;
          }
          var isMatch = true;
          for (var offset = 0; offset < candidate.words.length; offset++) {
            if (sentenceTokens[tokenIndex + offset].normalized !=
                candidate.words[offset]) {
              isMatch = false;
              break;
            }
          }
          if (isMatch) {
            matched = candidate;
            break;
          }
        }
      }

      if (matched == null) {
        tokenIndex++;
        continue;
      }
      final end = tokenIndex + matched.words.length - 1;
      matches.add(
        PhraseMatch(
          key: matched.key,
          surface: sentenceTokens
              .sublist(tokenIndex, end + 1)
              .map((token) => token.surface)
              .join(' '),
          type: matched.type,
          meaning: matched.meaning,
          confidence: matched.confidence,
          startTokenOrdinal: tokenIndex,
          endTokenOrdinal: end,
        ),
      );
      tokenIndex = end + 1;
    }
    return matches;
  }

  List<PhraseMatch> coveringToken(
    Iterable<PhraseMatch> matches,
    int tokenOrdinal,
  ) {
    return matches
        .where(
          (match) =>
              match.startTokenOrdinal <= tokenOrdinal &&
              match.endTokenOrdinal >= tokenOrdinal,
        )
        .toList(growable: false);
  }
}

Map<String, List<PhraseDefinition>> _index(
  Iterable<PhraseDefinition> definitions,
) {
  final index = <String, List<PhraseDefinition>>{};
  for (final definition in definitions) {
    if (definition.words.isEmpty) continue;
    final normalizedWords = definition.words
        .map((word) => word.replaceAll('’', "'").toLowerCase())
        .toList(growable: false);
    final normalized = PhraseDefinition(
      key: definition.key,
      words: normalizedWords,
      type: definition.type,
      meaning: definition.meaning,
      confidence: definition.confidence,
    );
    index.putIfAbsent(normalizedWords.first, () => []).add(normalized);
  }
  for (final definitions in index.values) {
    definitions.sort(
      (left, right) => right.words.length.compareTo(left.words.length),
    );
  }
  return index;
}
