import 'package:dian_du_ji/features/dictionary/data/dictionary_repository.dart';
import 'package:dian_du_ji/features/documents/domain/document_structure_builder.dart';
import 'package:dian_du_ji/features/documents/domain/models/parsed_block.dart';
import 'package:dian_du_ji/features/phrases/domain/phrase_recognizer.dart';
import 'package:dian_du_ji/features/phrases/domain/phrase_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds offset-safe rows and resolves each unique lemma once', () async {
    final dictionary = _CountingDictionary({
      'she': 'she',
      'looked': 'look',
      'up': 'up',
      'again': 'again',
      'look': 'look',
      'it': 'it',
    });
    final result =
        await DocumentStructureBuilder(
          dictionary: dictionary,
          phraseRecognizer: PhraseRecognizer(const [
            PhraseDefinition(
              key: 'look-it-up',
              words: ['look', 'it', 'up'],
              type: PhraseType.phrasalVerb,
              meaning: 'search for information',
            ),
          ]),
        ).build(
          documentId: 'doc-1',
          blocks: const [
            ParsedBlock(text: 'She looked up. She looked again.'),
            ParsedBlock(text: 'Look it up.'),
          ],
        );

    expect(result.paragraphs.map((row) => row.id), [
      'doc-1-paragraph-0',
      'doc-1-paragraph-1',
    ]);
    expect(result.sentences.map((row) => row.id), [
      'doc-1-sentence-0',
      'doc-1-sentence-1',
      'doc-1-sentence-2',
    ]);
    expect(result.sentences.map((row) => (row.startOffset, row.endOffset)), [
      (0, 14),
      (15, 32),
      (0, 11),
    ]);
    expect(
      result.tokens
          .where((row) => row.surface == 'looked')
          .map((row) => (row.startOffset, row.endOffset, row.lemma)),
      [(4, 10, 'look'), (4, 10, 'look')],
    );
    expect(
      result.tokens.map((row) => row.id).toSet(),
      hasLength(result.tokens.length),
    );
    expect(dictionary.callsFor('looked'), 1);
    expect(dictionary.callsFor('look'), 1);
    expect(result.phraseOccurrences, hasLength(1));
    expect(result.phraseOccurrences.single, isA<PhraseOccurrenceRow>());
    expect(
      result.phraseOccurrences.single.startTokenOrdinal,
      result.tokens
          .where((row) => row.sentenceId == 'doc-1-sentence-2')
          .first
          .ordinal,
    );
    expect(result.phraseOccurrences.single.endTokenOrdinal, 2);
  });
}

class _CountingDictionary implements DictionaryLookup {
  _CountingDictionary(this.lemmas);

  final Map<String, String> lemmas;
  final Map<String, int> _calls = {};

  int callsFor(String normalized) => _calls[normalized] ?? 0;

  @override
  Future<DictionaryEntry?> lookup(String normalized) async {
    _calls[normalized] = callsFor(normalized) + 1;
    final lemma = lemmas[normalized];
    if (lemma == null) return null;
    return DictionaryEntry(
      word: lemma,
      phonetic: '',
      partOfSpeech: '',
      definitionEnglish: '',
      definitionChinese: '',
    );
  }
}
