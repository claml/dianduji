import '../../features/dictionary/domain/specialized_terms.dart';

/// Error categories for the online translation gateway.
enum OnlineTranslationError {
  offline,
  timeout,
  badResponse,
  unauthorized,
  cancelled,
  unknown,
}

class OnlineTranslationException implements Exception {
  const OnlineTranslationException(this.error, [this.message]);

  final OnlineTranslationError error;
  final String? message;

  @override
  String toString() =>
      'OnlineTranslationException(${error.name}${message == null ? '' : ': $message'})';
}

/// A minimal-disclosure online translation request. Only the tapped term and
/// its single sentence (never the PDF, page image, document title, author,
/// file path, device id, or reading history) may leave the device.
class OnlineTranslationRequest {
  const OnlineTranslationRequest({
    required this.term,
    required this.sentence,
    this.targetLanguage = 'zh',
    this.domain,
  });

  final String term;
  final String sentence;
  final String targetLanguage;
  final SpecializedDomain? domain;

  static const int maxSentenceLength = 1000;

  /// The sentence trimmed to [maxSentenceLength] Unicode characters, centered
  /// on the term when it is too long.
  String get disclosedSentence => _discloseSentence(sentence, term);

  static String _discloseSentence(String sentence, String term) {
    if (sentence.runes.length <= maxSentenceLength) return sentence;
    final termIndex = sentence.toLowerCase().indexOf(term.toLowerCase());
    if (termIndex < 0) {
      return String.fromCharCodes(
        sentence.runes.take(maxSentenceLength),
      );
    }
    final half = maxSentenceLength ~/ 2;
    final start = termIndex - half < 0 ? 0 : termIndex - half;
    final end = start + maxSentenceLength;
    final runes = sentence.runes.toList(growable: false);
    final clippedEnd = end > runes.length ? runes.length : end;
    final clippedStart = clippedEnd - maxSentenceLength < 0
        ? 0
        : clippedEnd - maxSentenceLength;
    return String.fromCharCodes(runes.sublist(clippedStart, clippedEnd));
  }
}

/// A structured, cacheable online translation result.
class OnlineTranslationResult {
  const OnlineTranslationResult({
    required this.termTranslation,
    required this.sentenceTranslation,
    this.domainGloss = '',
    this.examples = const [],
    required this.sourceId,
    required this.cacheVersion,
  });

  final String termTranslation;
  final String domainGloss;
  final String sentenceTranslation;
  final List<OnlineExample> examples;
  final String sourceId;
  final String cacheVersion;

  Map<String, Object?> toJson() => {
    'termTranslation': termTranslation,
    'sentenceTranslation': sentenceTranslation,
    'domainGloss': domainGloss,
    'examples': [
      for (final example in examples)
        {'source': example.source, 'translation': example.translation},
    ],
    'sourceId': sourceId,
    'cacheVersion': cacheVersion,
  };

  static OnlineTranslationResult? fromJson(Object? value) {
    if (value is! Map<String, Object?>) return null;
    final termTranslation = value['termTranslation'];
    final sentenceTranslation = value['sentenceTranslation'];
    if (termTranslation is! String || sentenceTranslation is! String) {
      return null;
    }
    final rawExamples = value['examples'];
    final examples = <OnlineExample>[];
    if (rawExamples is List<Object?>) {
      for (final raw in rawExamples) {
        if (raw is! Map<String, Object?>) continue;
        final source = raw['source'];
        final translation = raw['translation'];
        if (source is String && translation is String) {
          examples.add(OnlineExample(source: source, translation: translation));
        }
      }
    }
    return OnlineTranslationResult(
      termTranslation: termTranslation,
      sentenceTranslation: sentenceTranslation,
      domainGloss: value['domainGloss'] as String? ?? '',
      examples: examples,
      sourceId: value['sourceId'] as String? ?? 'gateway',
      cacheVersion: value['cacheVersion'] as String? ?? '1',
    );
  }
}

class OnlineExample {
  const OnlineExample({required this.source, required this.translation});

  final String source;
  final String translation;
}

/// Controlled translation gateway. Mobile calls only this abstraction; no
/// third-party key is embedded in the package.
abstract interface class OnlineTranslationGateway {
  Future<OnlineTranslationResult> translate(OnlineTranslationRequest request);
}
