import '../../documents/domain/models/parsed_block.dart';
import 'specialized_terms.dart';

/// A multi-word term extracted from a tapped sentence.
class TermCandidate {
  const TermCandidate({
    required this.surface,
    required this.startToken,
    required this.endToken,
    required this.domain,
  });

  final String surface;
  final int startToken;

  /// Inclusive token index of the last word in the term.
  final int endToken;

  final SpecializedDomain domain;

  int get wordCount => endToken - startToken + 1;
}

/// Generates and ranks multi-word term candidates from a sentence's tokens.
///
/// Candidates are exact hits in the specialized dictionary that span the
/// tapped word; longer terms rank first, then terms whose domain is enabled.
/// The single tapped word itself is intentionally not returned here — the
/// layered lookup keeps it as the final fallback so a failed term recognition
/// can never leave the tap without a query.
class TermCandidateRecognizer {
  const TermCandidateRecognizer({required this.catalog});

  final SpecializedTermIndex catalog;

  List<TermCandidate> recognize({
    required List<TokenSpan> tokens,
    required int tappedIndex,
    List<SpecializedDomain> enabledDomains = SpecializedDomain.values,
  }) {
    if (tokens.isEmpty || tappedIndex < 0 || tappedIndex >= tokens.length) {
      return const [];
    }

    final candidates = <TermCandidate>[];
    // Longest terms first; a window of up to 5 words that contains the
    // tapped word (start <= tappedIndex <= start + length - 1).
    for (var length = 5; length >= 2; length--) {
      final minStart = tappedIndex - length + 1;
      final firstStart = minStart < 0 ? 0 : minStart;
      final lastStart = tappedIndex < tokens.length - length
          ? tappedIndex
          : tokens.length - length;
      for (var start = firstStart; start <= lastStart; start++) {
        final end = start + length - 1;
        final surface = tokens
            .sublist(start, end + 1)
            .map((token) => token.surface)
            .join(' ');
        final term = catalog.lookup(surface);
        if (term == null || !enabledDomains.contains(term.domain)) continue;
        candidates.add(
          TermCandidate(
            surface: term.term,
            startToken: start,
            endToken: end,
            domain: term.domain,
          ),
        );
      }
    }

    candidates.sort((a, b) {
      if (a.wordCount != b.wordCount) return b.wordCount.compareTo(a.wordCount);
      return a.surface.compareTo(b.surface);
    });
    return candidates;
  }
}
