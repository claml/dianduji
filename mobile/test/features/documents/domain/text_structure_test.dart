import 'package:dian_du_ji/features/documents/domain/text/sentence_splitter.dart';
import 'package:dian_du_ji/features/documents/domain/text/tokenizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('sentence splitting', () {
    test('preserves offsets through whitespace and unicode punctuation', () {
      const text = '  Don’t stop.  It\'s working! ';

      final sentences = splitSentences(text);

      expect(sentences.map((span) => text.substring(span.start, span.end)), [
        'Don’t stop.',
        "It's working!",
      ]);
      expect(sentences.map((span) => span.text), [
        'Don’t stop.',
        "It's working!",
      ]);
    });

    test('does not split common abbreviations', () {
      const text = 'Mr. Smith writes, e.g. short notes. Next line?';

      expect(splitSentences(text).map((span) => span.text), [
        'Mr. Smith writes, e.g. short notes.',
        'Next line?',
      ]);
    });

    test('treats paragraph line breaks as boundaries and ignores empties', () {
      const text = '\nFirst line\n\n  Second line.\n';

      expect(splitSentences(text).map((span) => span.text), [
        'First line',
        'Second line.',
      ]);
      expect(splitSentences('   \n\t'), isEmpty);
    });
  });

  group('tokenization', () {
    test(
      'offsets slice exact contractions possessives and hyphenated words',
      () {
        const sentence = "It's James’s well-known book.";

        final tokens = tokenize(sentence);

        expect(
          tokens.map((token) => sentence.substring(token.start, token.end)),
          ["It's", 'James’s', 'well-known', 'book'],
        );
        expect(tokens.map((token) => token.normalized), [
          "it's",
          "james's",
          'well-known',
          'book',
        ]);
      },
    );

    test('keeps independent offsets for repeated words', () {
      const sentence = 'very very clear';

      final tokens = tokenize(sentence);

      expect(tokens.map((token) => token.start), [0, 5, 10]);
      expect(tokens.map((token) => token.end), [4, 9, 15]);
    });
  });
}
