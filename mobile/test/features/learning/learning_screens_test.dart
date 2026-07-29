import 'package:dian_du_ji/features/learning/presentation/phrase_book_screen.dart';
import 'package:dian_du_ji/features/learning/presentation/vocabulary_screen.dart';
import 'package:dian_du_ji/features/phrases/domain/phrase_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('vocabulary search matches word and Chinese definition', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: VocabularyScreen(
          entries: [
            VocabularyListItem(
              lemma: 'language',
              phonetic: 'ˈlæŋɡwɪdʒ',
              definition: '语言',
              proficiency: VocabularyProficiency.vague,
              lookupCount: 3,
            ),
            VocabularyListItem(
              lemma: 'walk',
              phonetic: 'wɔːk',
              definition: '步行',
              proficiency: VocabularyProficiency.known,
              lookupCount: 1,
            ),
          ],
        ),
      ),
    );

    await tester.enterText(find.byType(SearchBar), '语言');
    await tester.pump();

    expect(find.text('language'), findsOneWidget);
    expect(find.text('walk'), findsNothing);
  });

  testWidgets('phrase book filters with the shared phrase enum', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PhraseBookScreen(
          phrases: [
            SavedPhraseListItem(
              surface: 'look up',
              meaning: '查阅',
              type: PhraseType.phrasalVerb,
              context: 'Look it up.',
            ),
            SavedPhraseListItem(
              surface: 'piece of cake',
              meaning: '轻而易举',
              type: PhraseType.idiom,
              context: 'It is a piece of cake.',
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('习语'));
    await tester.pump();

    expect(find.text('piece of cake'), findsOneWidget);
    expect(find.text('look up'), findsNothing);
  });
}
