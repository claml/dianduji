import '../data/dictionary_repository.dart';

/// One LLM-enriched candidate awaiting confirmation into the user dictionary.
class EnrichedDictionaryEntry {
  const EnrichedDictionaryEntry({
    required this.surface,
    required this.phonetic,
    required this.partOfSpeech,
    required this.definitionEnglish,
    required this.definitionChinese,
    required this.isValid,
  });

  final String surface;
  final String phonetic;
  final String partOfSpeech;
  final String definitionEnglish;
  final String definitionChinese;

  /// False when the LLM judged the word a misspelling/proper noun; such
  /// entries are dropped instead of entering the dictionary.
  final bool isValid;
}

/// A definition the user wrote themselves (proper nouns, abbreviations, or
/// context-specific senses). Stored as a confirmed user-dictionary entry.
class ManualDictionaryEntry {
  const ManualDictionaryEntry({
    required this.surface,
    required this.phonetic,
    required this.partOfSpeech,
    required this.definitionEnglish,
    required this.definitionChinese,
    this.author = '',
  });

  final String surface;
  final String phonetic;
  final String partOfSpeech;
  final String definitionEnglish;
  final String definitionChinese;

  /// Reserved for future community sharing; locally it stays the device
  /// owner.
  final String author;
}

class UserDictionaryCandidate {
  const UserDictionaryCandidate({
    required this.lemma,
    required this.surface,
    required this.source,
    required this.createdAt,
  });

  final String lemma;
  final String surface;
  final String source;
  final DateTime createdAt;
}

/// Read/write surface for the user-grown dictionary: candidates are collected
/// from successful online translations, enriched by the LLM, and confirmed
/// entries then take priority in the lookup chain.
abstract interface class UserDictionaryStore {
  /// Lookup a confirmed entry (used as the highest-priority lookup layer).
  Future<DictionaryEntry?> lookupConfirmed(String surface);

  /// Records an online-translated word as a candidate; de-duplicates on the
  /// normalized lemma and never downgrades a confirmed entry.
  Future<void> collectCandidate(String surface, {String source = ''});

  Future<int> pendingCandidateCount();

  Future<List<UserDictionaryCandidate>> pendingCandidates();

  /// Applies LLM enrichment: valid entries become confirmed, invalid ones are
  /// removed.
  Future<void> applyEnrichment(List<EnrichedDictionaryEntry> entries);

  /// Saves a user-written definition as a confirmed entry, replacing any
  /// candidate of the same lemma.
  Future<void> saveManualEntry(ManualDictionaryEntry entry);

  Future<void> clearCandidates();
}

String normalizeUserLemma(String surface) => surface
    .trim()
    .toLowerCase()
    .replaceAll('’', "'")
    .replaceAll('\u2010', '-')
    .replaceAll('\u2011', '-')
    .replaceAll('\u2212', '-');
