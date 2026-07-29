import '../../dictionary/data/dictionary_repository.dart';
import '../../phrases/domain/phrase_recognizer.dart';
import 'document_models.dart';
import 'models/parsed_block.dart';
import 'text/sentence_splitter.dart';
import 'text/tokenizer.dart';

export 'document_models.dart';

class DocumentStructureBuilder {
  const DocumentStructureBuilder({
    required this.dictionary,
    required this.phraseRecognizer,
  });

  final DictionaryLookup dictionary;
  final PhraseRecognizer phraseRecognizer;

  Future<DocumentStructure> build({
    required String documentId,
    required List<ParsedBlock> blocks,
  }) async {
    final paragraphs = <ParagraphRow>[];
    final sentences = <SentenceRow>[];
    final tokens = <TokenRow>[];
    final phraseOccurrences = <PhraseOccurrenceRow>[];
    final lemmaCache = <String, String>{};
    var sentenceOrdinal = 0;

    for (
      var paragraphOrdinal = 0;
      paragraphOrdinal < blocks.length;
      paragraphOrdinal++
    ) {
      final block = blocks[paragraphOrdinal];
      final paragraphId = '$documentId-paragraph-$paragraphOrdinal';
      paragraphs.add(
        ParagraphRow(
          id: paragraphId,
          documentId: documentId,
          ordinal: paragraphOrdinal,
          text: block.text,
          style: block.style.name,
        ),
      );

      for (final sentenceSpan in splitSentences(block.text)) {
        final sentenceId = '$documentId-sentence-$sentenceOrdinal';
        final sentenceTokens = tokenize(sentenceSpan.text);
        sentences.add(
          SentenceRow(
            id: sentenceId,
            documentId: documentId,
            paragraphId: paragraphId,
            ordinal: sentenceOrdinal,
            text: sentenceSpan.text,
            startOffset: sentenceSpan.start,
            endOffset: sentenceSpan.end,
          ),
        );

        for (
          var tokenOrdinal = 0;
          tokenOrdinal < sentenceTokens.length;
          tokenOrdinal++
        ) {
          final token = sentenceTokens[tokenOrdinal];
          final lemma = await _lemmaFor(token.normalized, lemmaCache);
          tokens.add(
            TokenRow(
              id: '$sentenceId-token-$tokenOrdinal',
              documentId: documentId,
              sentenceId: sentenceId,
              ordinal: tokenOrdinal,
              surface: token.surface,
              normalized: token.normalized,
              lemma: lemma,
              startOffset: token.start,
              endOffset: token.end,
            ),
          );
        }

        final matches = phraseRecognizer.recognize(sentenceTokens);
        for (
          var matchOrdinal = 0;
          matchOrdinal < matches.length;
          matchOrdinal++
        ) {
          final match = matches[matchOrdinal];
          phraseOccurrences.add(
            PhraseOccurrenceRow(
              id: '$sentenceId-phrase-$matchOrdinal',
              documentId: documentId,
              sentenceId: sentenceId,
              phraseKey: match.key,
              surface: match.surface,
              type: match.type.storageValue,
              meaning: match.meaning,
              confidence: match.confidence,
              startTokenOrdinal: match.startTokenOrdinal,
              endTokenOrdinal: match.endTokenOrdinal,
            ),
          );
        }
        sentenceOrdinal++;
      }
    }

    return DocumentStructure(
      paragraphs: List.unmodifiable(paragraphs),
      sentences: List.unmodifiable(sentences),
      tokens: List.unmodifiable(tokens),
      phraseOccurrences: List.unmodifiable(phraseOccurrences),
    );
  }

  Future<String> _lemmaFor(String normalized, Map<String, String> cache) async {
    final cached = cache[normalized];
    if (cached != null) return cached;
    final entry = await dictionary.lookup(normalized);
    final lemma = entry?.word ?? normalized;
    cache[normalized] = lemma;
    return lemma;
  }
}
