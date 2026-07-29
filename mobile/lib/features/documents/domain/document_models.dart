import '../../reader/domain/reading_locator.dart';

class DocumentSummary {
  const DocumentSummary({
    required this.id,
    required this.title,
    required this.sourceName,
    required this.format,
    required this.status,
    required this.progress,
    required this.wordCount,
    required this.readProgress,
    this.failureCode,
    this.failureMessage,
  });

  final String id;
  final String title;
  final String sourceName;
  final String format;
  final String status;
  final double progress;
  final int wordCount;
  final double readProgress;
  final String? failureCode;
  final String? failureMessage;
}

class StoredReaderDocument {
  const StoredReaderDocument({
    required this.id,
    required this.title,
    required this.sentences,
    required this.readProgress,
    this.lastLocator,
  });

  final String id;
  final String title;
  final List<StoredReaderSentence> sentences;
  final double readProgress;
  final ReadingLocator? lastLocator;
}

class StoredReaderSentence {
  const StoredReaderSentence({
    required this.id,
    required this.paragraphId,
    required this.ordinal,
    required this.text,
    required this.startOffset,
    required this.endOffset,
    required this.tokens,
  });

  final String id;
  final String paragraphId;
  final int ordinal;
  final String text;
  final int startOffset;
  final int endOffset;
  final List<StoredReaderToken> tokens;
}

class StoredReaderToken {
  const StoredReaderToken({
    required this.id,
    required this.ordinal,
    required this.surface,
    required this.normalized,
    required this.lemma,
    required this.startOffset,
    required this.endOffset,
  });

  final String id;
  final int ordinal;
  final String surface;
  final String normalized;
  final String lemma;
  final int startOffset;
  final int endOffset;
}

class ParagraphRow {
  const ParagraphRow({
    required this.id,
    required this.documentId,
    required this.ordinal,
    required this.text,
    required this.style,
  });

  final String id;
  final String documentId;
  final int ordinal;
  final String text;
  final String style;
}

class SentenceRow {
  const SentenceRow({
    required this.id,
    required this.documentId,
    required this.paragraphId,
    required this.ordinal,
    required this.text,
    required this.startOffset,
    required this.endOffset,
  });

  final String id;
  final String documentId;
  final String paragraphId;
  final int ordinal;
  final String text;
  final int startOffset;
  final int endOffset;
}

class TokenRow {
  const TokenRow({
    required this.id,
    required this.documentId,
    required this.sentenceId,
    required this.ordinal,
    required this.surface,
    required this.normalized,
    required this.lemma,
    required this.startOffset,
    required this.endOffset,
    this.partOfSpeech = '',
  });

  final String id;
  final String documentId;
  final String sentenceId;
  final int ordinal;
  final String surface;
  final String normalized;
  final String lemma;
  final String partOfSpeech;
  final int startOffset;
  final int endOffset;
}

class PhraseOccurrenceRow {
  const PhraseOccurrenceRow({
    required this.id,
    required this.documentId,
    required this.sentenceId,
    required this.phraseKey,
    required this.surface,
    required this.type,
    required this.meaning,
    required this.confidence,
    required this.startTokenOrdinal,
    required this.endTokenOrdinal,
  });

  final String id;
  final String documentId;
  final String sentenceId;
  final String phraseKey;
  final String surface;
  final String type;
  final String meaning;
  final double confidence;
  final int startTokenOrdinal;
  final int endTokenOrdinal;
}

class DocumentStructure {
  const DocumentStructure({
    required this.paragraphs,
    required this.sentences,
    required this.tokens,
    required this.phraseOccurrences,
  });

  final List<ParagraphRow> paragraphs;
  final List<SentenceRow> sentences;
  final List<TokenRow> tokens;
  final List<PhraseOccurrenceRow> phraseOccurrences;
}
