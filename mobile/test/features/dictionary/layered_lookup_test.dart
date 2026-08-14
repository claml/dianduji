import 'package:dian_du_ji/features/dictionary/data/dictionary_repository.dart';
import 'package:dian_du_ji/features/dictionary/data/specialized_term_catalog.dart';
import 'package:dian_du_ji/features/dictionary/domain/layered_lookup.dart';
import 'package:dian_du_ji/features/dictionary/domain/specialized_terms.dart';
import 'package:dian_du_ji/features/documents/domain/models/parsed_block.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final specialized = SpecializedTermCatalog.load('''
{
  "version": "1", "source": "t", "license": "MIT",
  "terms": [
    {"term": "random forest", "domain": "computerScience", "definition": "随机森林"},
    {"term": "cell", "domain": "biology", "definition": "细胞"},
    {"term": "mitochondria", "domain": "biology", "definition": "线粒体"}
  ]
}
''');

  List<TokenSpan> tokensOf(String sentence) => sentence
      .split(' ')
      .where((word) => word.isNotEmpty)
      .toList()
      .asMap()
      .entries
      .map((entry) => TokenSpan(
        surface: entry.value,
        normalized: entry.value.toLowerCase(),
        start: entry.key,
        end: entry.key + 1,
      ))
      .toList();

  const generalHit = DictionaryEntry(
    word: 'random',
    phonetic: '',
    partOfSpeech: 'adj',
    definitionEnglish: 'made without method',
    definitionChinese: '随机的',
  );

  test('general hit never shadows a specialized multi-word term', () async {
    final lookup = LayeredLookup(
      general: _General({'random': generalHit}),
      specialized: specialized,
    );
    final tokens = tokensOf('a random forest classifies samples');

    final result = await lookup.lookup(tokens: tokens, tappedOrdinal: 1);

    expect(result.generalEntry?.word, 'random');
    expect(result.specializedTerm?.term, 'random forest');
    expect(result.matchedCandidate?.surface, 'random forest');
    expect(result.hasHit, isTrue);
  });

  test('specialized-only hit has no general entry', () async {
    final lookup = LayeredLookup(
      general: _General(const {}),
      specialized: specialized,
    );
    final tokens = tokensOf('the mitochondria generate energy');

    final result = await lookup.lookup(tokens: tokens, tappedOrdinal: 1);

    expect(result.generalEntry, isNull);
    expect(result.specializedTerm?.term, 'mitochondria');
    expect(result.matchedCandidate, isNull);
  });

  test('single-word specialized hit applies to the tapped word', () async {
    final lookup = LayeredLookup(
      general: _General(const {}),
      specialized: specialized,
    );
    final tokens = tokensOf('each cell divides');

    final result = await lookup.lookup(tokens: tokens, tappedOrdinal: 1);

    expect(result.specializedTerm?.term, 'cell');
    expect(result.matchedCandidate, isNull);
  });

  test('both miss yields a hitless result', () async {
    final lookup = LayeredLookup(
      general: _General(const {}),
      specialized: specialized,
    );
    final tokens = tokensOf('unrelated plain words');

    final result = await lookup.lookup(tokens: tokens, tappedOrdinal: 0);

    expect(result.hasHit, isFalse);
  });

  test('disabled domains exclude specialized terms', () async {
    final lookup = LayeredLookup(
      general: _General(const {}),
      specialized: specialized,
    );
    final tokens = tokensOf('a random forest classifies');

    final result = await lookup.lookup(
      tokens: tokens,
      tappedOrdinal: 1,
      enabledDomains: const [SpecializedDomain.medicine],
    );

    expect(result.specializedTerm, isNull);
    expect(result.generalEntry, isNull);
  });

  test('null specialized index degrades to general-only', () async {
    final lookup = LayeredLookup(
      general: _General({'cell': generalHit}),
      specialized: null,
    );
    final tokens = tokensOf('the cell divides');

    final result = await lookup.lookup(tokens: tokens, tappedOrdinal: 1);

    expect(result.generalEntry?.word, 'random');
    expect(result.specializedTerm, isNull);
  });

  test('throws for an out-of-range tapped ordinal', () async {
    final lookup = LayeredLookup(
      general: _General(const {}),
      specialized: specialized,
    );

    expect(
      () => lookup.lookup(tokens: tokensOf('a b'), tappedOrdinal: 5),
      throwsRangeError,
    );
  });
}

class _General implements DictionaryLookup {
  const _General(this.entries);

  final Map<String, DictionaryEntry> entries;

  @override
  Future<DictionaryEntry?> lookup(String surface) async =>
      entries[surface.toLowerCase()];
}
