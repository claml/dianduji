import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/specialized_terms.dart';

/// Metadata describing the bundled specialized dictionary dataset.
class SpecializedCatalogMetadata {
  const SpecializedCatalogMetadata({
    required this.version,
    required this.source,
    required this.license,
  });

  final String version;
  final String source;
  final String license;
}

/// Read-only in-memory index over the bundled four-domain term table.
///
/// Exact lookup is O(1); prefix lookup returns the longest matching term,
/// which powers multi-word term recognition (e.g. tapping "random" surfaces
/// "random forest").
class SpecializedTermCatalog implements SpecializedTermIndex {
  SpecializedTermCatalog._(
    this.metadata,
    Map<String, SpecializedTerm> exactIndex,
    List<SpecializedTerm> all,
  ) : _exactIndex = exactIndex,
      _all = all;

  factory SpecializedTermCatalog.load(String jsonSource) {
    final decoded = jsonDecode(jsonSource);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Specialized dictionary must be an object.');
    }
    final metadata = SpecializedCatalogMetadata(
      version: decoded['version'] as String? ?? '',
      source: decoded['source'] as String? ?? '',
      license: decoded['license'] as String? ?? '',
    );
    final rawTerms = decoded['terms'];
    if (rawTerms is! List<Object?>) {
      throw const FormatException('Specialized dictionary has no terms list.');
    }

    final exactIndex = <String, SpecializedTerm>{};
    final all = <SpecializedTerm>[];
    for (final raw in rawTerms) {
      if (raw is! Map<String, Object?>) continue;
      final term = raw['term'];
      final domainName = raw['domain'];
      final definition = raw['definition'];
      if (term is! String || definition is! String) continue;
      final domain = SpecializedDomain.tryParse(domainName as String?);
      if (domain == null) continue;
      final synonyms = raw['synonyms'];
      final entry = SpecializedTerm(
        term: term,
        domain: domain,
        definition: definition,
        synonyms: synonyms is List<Object?>
            ? synonyms.whereType<String>().toList(growable: false)
            : const [],
      );
      exactIndex[_normalize(term)] ??= entry;
      for (final synonym in entry.synonyms) {
        exactIndex[_normalize(synonym)] ??= entry;
      }
      all.add(entry);
    }
    return SpecializedTermCatalog._(metadata, exactIndex, all);
  }

  /// Loads the bundled asset through the Flutter asset bundle.
  static Future<SpecializedTermCatalog> loadFromAssets({
    AssetBundle? bundle,
    String assetName = 'assets/specialized/terms.json',
  }) async {
    final source = await (bundle ?? rootBundle).loadString(assetName);
    return SpecializedTermCatalog.load(source);
  }

  final SpecializedCatalogMetadata metadata;
  final Map<String, SpecializedTerm> _exactIndex;
  final List<SpecializedTerm> _all;

  SpecializedDomain get primaryDomain => SpecializedDomain.computerScience;

  List<SpecializedDomain> get domains =>
      SpecializedDomain.values.where((domain) => hasDomain(domain)).toList();

  bool hasDomain(SpecializedDomain domain) =>
      _all.any((term) => term.domain == domain);

  /// Exact (case-insensitive, normalized) term or synonym hit.
  @override
  SpecializedTerm? lookup(String term) => _exactIndex[_normalize(term)];

  /// The longest term whose normalized form starts with [term]. Returns null
  /// when no specialized term extends [term] (a shorter exact hit is not a
  /// prefix hit by itself).
  @override
  SpecializedTerm? lookupLongestPrefix(String term) {
    final normalized = _normalize(term);
    if (normalized.isEmpty) return null;
    SpecializedTerm? best;
    for (final entry in _all) {
      final candidate = _normalize(entry.term);
      if (candidate.length > normalized.length &&
          candidate.startsWith(normalized)) {
        if (best == null || candidate.length > _normalize(best.term).length) {
          best = entry;
        }
      }
    }
    return best;
  }

  int get length => _all.length;

  static String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll('’', "'");
}
