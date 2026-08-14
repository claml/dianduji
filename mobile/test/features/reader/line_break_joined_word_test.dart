import 'package:dian_du_ji/features/reader/domain/reader_selection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('offers the joined candidate for a first-half tap', () {
    final candidates = lineBreakJoinedCandidates(
      'visual de mands of the task',
      'de',
    );

    expect(candidates, contains('demands'));
  });

  test('offers the joined candidate for a second-half tap', () {
    final candidates = lineBreakJoinedCandidates(
      'visual de mands of the task',
      'mands',
    );

    expect(candidates, contains('demands'));
  });

  test('does not join across a sentence boundary (upper-case word)', () {
    final candidates = lineBreakJoinedCandidates(
      'the model The next sentence',
      'model',
    );

    // Only the previous-word join surfaces; the dictionary rejects it.
    expect(candidates, ['themodel']);
  });

  test('only matches whole words, not mid-word substrings', () {
    final candidates = lineBreakJoinedCandidates(
      'visual demands of the task',
      'de',
    );

    expect(candidates, isEmpty);
  });

  test('normal sentence words still produce candidates for the dictionary '
      'to reject', () {
    final candidates = lineBreakJoinedCandidates(
      'the whole word inside a sentence',
      'word',
    );

    expect(candidates, contains('wordinside'));
  });

  test('returns nothing for a surface absent from the context', () {
    expect(lineBreakJoinedCandidates('unrelated text', 'absent'), isEmpty);
  });
}
