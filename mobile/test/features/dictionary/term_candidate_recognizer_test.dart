import 'package:dian_du_ji/features/dictionary/data/specialized_term_catalog.dart';
import 'package:dian_du_ji/features/dictionary/domain/specialized_terms.dart';
import 'package:dian_du_ji/features/dictionary/domain/term_candidate_recognizer.dart';
import 'package:dian_du_ji/features/documents/domain/models/parsed_block.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SpecializedTermCatalog catalog() => SpecializedTermCatalog.load('''
{
  "version": "1", "source": "t", "license": "MIT",
  "terms": [
    {"term": "random forest", "domain": "computerScience", "definition": "随机森林"},
    {"term": "convolutional neural network", "domain": "computerScience", "definition": "卷积神经网络"},
    {"term": "chronic obstructive pulmonary disease", "domain": "medicine", "definition": "慢性阻塞性肺疾病"},
    {"term": "cell membrane", "domain": "biology", "definition": "细胞膜"}
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

  test('recognizes a two-word term containing the tapped word', () {
    final recognizer = TermCandidateRecognizer(catalog: catalog());
    final tokens = tokensOf('A random forest classifies samples');

    final candidates = recognizer.recognize(tokens: tokens, tappedIndex: 1);

    expect(candidates, hasLength(1));
    expect(candidates.single.surface, 'random forest');
    expect(candidates.single.domain, SpecializedDomain.computerScience);
    expect(candidates.single.wordCount, 2);
  });

  test('ranks longer terms first and respects the tapped word', () {
    final recognizer = TermCandidateRecognizer(catalog: catalog());
    final tokens = tokensOf(
      'The convolutional neural network learns features',
    );

    final candidates = recognizer.recognize(tokens: tokens, tappedIndex: 2);

    expect(candidates, isNotEmpty);
    expect(candidates.first.surface, 'convolutional neural network');
    expect(candidates.first.wordCount, 3);
  });

  test('recognizes a four-word term spanning the tapped middle word', () {
    final recognizer = TermCandidateRecognizer(catalog: catalog());
    final tokens = tokensOf('chronic obstructive pulmonary disease is common');

    final candidates = recognizer.recognize(tokens: tokens, tappedIndex: 2);

    expect(candidates.single.surface, 'chronic obstructive pulmonary disease');
    expect(candidates.single.wordCount, 4);
  });

  test('prefers enabled domains over disabled ones', () {
    final recognizer = TermCandidateRecognizer(catalog: catalog());
    final tokens = tokensOf('the cell membrane surrounds the cell');

    // Only medicine enabled: the biology hit is excluded entirely.
    final filtered = recognizer.recognize(
      tokens: tokens,
      tappedIndex: 1,
      enabledDomains: const [SpecializedDomain.medicine],
    );
    expect(filtered, isEmpty);

    final all = recognizer.recognize(tokens: tokens, tappedIndex: 1);
    expect(all.single.surface, 'cell membrane');
  });

  test('returns nothing when the tapped word has no specialized term', () {
    final recognizer = TermCandidateRecognizer(catalog: catalog());
    final tokens = tokensOf('completely unrelated words here');

    expect(recognizer.recognize(tokens: tokens, tappedIndex: 1), isEmpty);
  });

  test('handles out-of-range tapped indices and empty tokens', () {
    final recognizer = TermCandidateRecognizer(catalog: catalog());
    final tokens = tokensOf('random forest');

    expect(recognizer.recognize(tokens: tokens, tappedIndex: -1), isEmpty);
    expect(recognizer.recognize(tokens: tokens, tappedIndex: 99), isEmpty);
    expect(recognizer.recognize(tokens: const [], tappedIndex: 0), isEmpty);
  });
}
