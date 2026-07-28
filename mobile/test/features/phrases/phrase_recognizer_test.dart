import 'dart:convert';

import 'package:dian_du_ji/features/documents/domain/text/tokenizer.dart';
import 'package:dian_du_ji/features/phrases/domain/phrase_recognizer.dart';
import 'package:dian_du_ji/features/phrases/domain/phrase_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final recognizer = PhraseRecognizer([
    const PhraseDefinition(
      key: 'look-up',
      words: ['look', 'up'],
      type: PhraseType.phrasalVerb,
      meaning: '查阅；抬头看',
    ),
    const PhraseDefinition(
      key: 'give-up',
      words: ['give', 'up'],
      type: PhraseType.phrasalVerb,
      meaning: '放弃',
    ),
    const PhraseDefinition(
      key: 'in-addition',
      words: ['in', 'addition'],
      type: PhraseType.collocation,
      meaning: '此外',
    ),
    const PhraseDefinition(
      key: 'in-addition-to',
      words: ['in', 'addition', 'to'],
      type: PhraseType.prepositionalPhrase,
      meaning: '除……之外（还）',
    ),
    const PhraseDefinition(
      key: 'take-advantage-of',
      words: ['take', 'advantage', 'of'],
      type: PhraseType.collocation,
      meaning: '利用',
    ),
    const PhraseDefinition(
      key: 'piece-of-cake',
      words: ['piece', 'of', 'cake'],
      type: PhraseType.idiom,
      meaning: '轻而易举的事',
    ),
  ]);

  test('recognizes typed phrases across punctuation-separated tokens', () {
    const sentence = 'Look up “take advantage of” and give up.';

    final matches = recognizer.recognize(tokenize(sentence));

    expect(matches.map((match) => match.key), [
      'look-up',
      'take-advantage-of',
      'give-up',
    ]);
    expect(matches.map((match) => match.type), [
      PhraseType.phrasalVerb,
      PhraseType.collocation,
      PhraseType.phrasalVerb,
    ]);
  });

  test('uses longest match first instead of returning overlaps', () {
    final matches = recognizer.recognize(tokenize('In addition to tea.'));

    expect(matches.map((match) => match.key), ['in-addition-to']);
    expect(matches.single.startTokenOrdinal, 0);
    expect(matches.single.endTokenOrdinal, 2);
  });

  test('returns only phrases covering the selected occurrence', () {
    final matches = recognizer.recognize(tokenize('Look up, then give up.'));

    expect(recognizer.coveringToken(matches, 1).map((match) => match.key), [
      'look-up',
    ]);
    expect(recognizer.coveringToken(matches, 3).map((match) => match.key), [
      'give-up',
    ]);
  });

  test('does not invent phrases from merely adjacent words', () {
    expect(recognizer.recognize(tokenize('Look beside the table.')), isEmpty);
    expect(recognizer.recognize(tokenize('A piece of bread.')), isEmpty);
  });

  test('stable phrase type strings round trip to persistence values', () {
    for (final type in PhraseType.values) {
      expect(PhraseTypeCodec.fromStorage(type.storageValue), type);
    }
    expect(PhraseType.phrasalVerb.storageValue, 'phrasalVerb');
    expect(PhraseType.prepositionalPhrase.storageValue, 'prepositionalPhrase');
  });

  test('loads the shipped JSON shape without accepting unknown types', () {
    final definitions = PhraseDefinition.listFromJson(
      jsonDecode('''
[
  {"key":"look-up","words":["look","up"],"type":"phrasalVerb","meaning":"查阅","confidence":0.95}
]
'''),
    );

    expect(definitions.single.key, 'look-up');
    expect(definitions.single.type, PhraseType.phrasalVerb);
    expect(definitions.single.confidence, 0.95);
    expect(
      () => PhraseDefinition.listFromJson([
        {
          'key': 'bad',
          'words': ['bad', 'type'],
          'type': 'unknown',
          'meaning': 'bad',
        },
      ]),
      throwsFormatException,
    );
  });
}
