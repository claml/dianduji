/// Domain tag for the bundled specialized dictionary.
enum SpecializedDomain {
  computerScience('计算机'),
  medicine('医学'),
  biology('生物'),
  chemistry('化学');

  const SpecializedDomain(this.label);

  final String label;

  static SpecializedDomain? tryParse(String? name) {
    for (final domain in values) {
      if (domain.name == name) return domain;
    }
    return null;
  }
}

/// A single specialized dictionary entry.
class SpecializedTerm {
  const SpecializedTerm({
    required this.term,
    required this.domain,
    required this.definition,
    this.synonyms = const [],
  });

  final String term;
  final SpecializedDomain domain;
  final String definition;
  final List<String> synonyms;
}

/// Read-only lookup surface over the specialized dictionary, so domain logic
/// (e.g. term recognition) never depends on the concrete data layer.
abstract interface class SpecializedTermIndex {
  SpecializedTerm? lookup(String term);

  SpecializedTerm? lookupLongestPrefix(String term);
}
