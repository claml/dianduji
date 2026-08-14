import '../../documents/domain/models/parsed_block.dart';
import '../data/dictionary_repository.dart';
import 'specialized_terms.dart';
import 'term_candidate_recognizer.dart';

/// Merged result of the layered lookup (general dictionary + specialized
/// dictionary). At least one of [generalEntry] and [specializedTerm] is
/// non-null on a hit; both may be null (offline fallthrough to the online
/// gateway is layered above this unit).
class LayeredLookupResult {
  const LayeredLookupResult({
    required this.tappedSurface,
    this.generalEntry,
    this.specializedTerm,
    this.matchedCandidate,
  });

  final String tappedSurface;
  final DictionaryEntry? generalEntry;
  final SpecializedTerm? specializedTerm;

  /// The multi-word term that produced [specializedTerm], or null when the
  /// specialized hit is the tapped word itself (or no specialized hit).
  final TermCandidate? matchedCandidate;

  bool get hasHit => generalEntry != null || specializedTerm != null;
}

/// Runs the general and specialized dictionaries in parallel and merges the
/// results so a general word gloss never shadows a specialized multi-word
/// term.
class LayeredLookup {
  LayeredLookup({required this.general, this.specialized});

  final DictionaryLookup general;
  final SpecializedTermIndex? specialized;

  Future<LayeredLookupResult> lookup({
    required List<TokenSpan> tokens,
    required int tappedOrdinal,
    List<SpecializedDomain> enabledDomains = SpecializedDomain.values,
  }) async {
    if (tappedOrdinal < 0 || tappedOrdinal >= tokens.length) {
      throw RangeError.index(tappedOrdinal, tokens, 'tappedOrdinal');
    }
    final tapped = tokens[tappedOrdinal];

    final generalFuture = general.lookup(tapped.surface);

    // Specialized lookup is in-memory and synchronous; it is collected while
    // the general dictionary await runs.
    SpecializedTerm? specializedTerm;
    TermCandidate? matchedCandidate;
    final specializedIndex = specialized;
    if (specializedIndex != null) {
      final recognizer = TermCandidateRecognizer(catalog: specializedIndex);
      final candidates = recognizer.recognize(
        tokens: tokens,
        tappedIndex: tappedOrdinal,
        enabledDomains: enabledDomains,
      );
      if (candidates.isNotEmpty) {
        matchedCandidate = candidates.first;
        specializedTerm = specializedIndex.lookup(matchedCandidate.surface);
      } else {
        specializedTerm = specializedIndex.lookup(tapped.surface);
      }
    }

    final generalEntry = await generalFuture;
    return LayeredLookupResult(
      tappedSurface: tapped.surface,
      generalEntry: generalEntry,
      specializedTerm: specializedTerm,
      matchedCandidate: matchedCandidate,
    );
  }
}
