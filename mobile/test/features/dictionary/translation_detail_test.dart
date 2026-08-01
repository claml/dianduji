import 'package:dian_du_ji/features/dictionary/data/dictionary_repository.dart';
import 'package:dian_du_ji/features/dictionary/presentation/translation_detail.dart';
import 'package:dian_du_ji/features/dictionary/presentation/translation_view_model.dart';
import 'package:dian_du_ji/features/phrases/domain/phrase_recognizer.dart';
import 'package:dian_du_ji/features/phrases/domain/phrase_type.dart';
import 'package:dian_du_ji/core/platform/pronunciation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'renders an offline found translation with semantic pronunciation action',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TranslationDetail(
            state: const TranslationState(
              status: TranslationStatus.found,
              surface: 'look',
              entry: DictionaryEntry(
                word: 'look',
                phonetic: 'lʊk',
                partOfSpeech: 'v.',
                definitionEnglish: 'see',
                definitionChinese: '看',
              ),
            ),
            onClose: () {},
          ),
        ),
      );

      expect(find.text('look'), findsOneWidget);
      expect(find.text('lʊk'), findsOneWidget);
      expect(find.text('v.'), findsOneWidget);
      expect(find.text('看'), findsOneWidget);
      expect(find.byTooltip('发音'), findsOneWidget);
    },
  );

  testWidgets('renders an explicit not-found state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TranslationDetail(
          state: TranslationState(
            status: TranslationStatus.notFound,
            surface: 'mystery',
          ),
          onClose: _noop,
        ),
      ),
    );

    expect(find.text('本地词典未收录'), findsOneWidget);
  });

  testWidgets('exposes a phrase save action and forwards its phrase once', (
    tester,
  ) async {
    PhraseMatch? saved;
    const phrase = PhraseMatch(
      key: 'look-up',
      surface: 'look up',
      type: PhraseType.phrasalVerb,
      meaning: '查找',
      confidence: 1,
      startTokenOrdinal: 0,
      endTokenOrdinal: 1,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: TranslationDetail(
          state: const TranslationState(
            status: TranslationStatus.found,
            surface: 'look',
            entry: DictionaryEntry(
              word: 'look',
              phonetic: '',
              partOfSpeech: '',
              definitionEnglish: '',
              definitionChinese: '看',
            ),
            phrases: [phrase],
          ),
          onSavePhrase: (value) async => saved = value,
          onClose: _noop,
        ),
      ),
    );

    expect(find.byTooltip('保存短语'), findsOneWidget);
    await tester.tap(find.byTooltip('保存短语'));
    await tester.pump();
    expect(saved, phrase);
  });

  testWidgets('stops pronunciation once when detail closes or disposes', (
    tester,
  ) async {
    final closing = _Pronunciation();
    await tester.pumpWidget(
      MaterialApp(
        home: TranslationDetail(
          word: 'look',
          pronunciation: closing,
          onClose: _noop,
        ),
      ),
    );
    await tester.tap(find.byTooltip('关闭释义'));
    await tester.pump();
    expect(closing.stops, 1);

    final disposing = _Pronunciation();
    await tester.pumpWidget(
      MaterialApp(
        key: const ValueKey('disposing-app'),
        home: TranslationDetail(
          word: 'look',
          pronunciation: disposing,
          onClose: _noop,
        ),
      ),
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(disposing.stops, 1);
  });
}

void _noop() {}

class _Pronunciation implements PronunciationService {
  var stops = 0;
  @override
  Future<PronunciationResult> speak(String text) async =>
      PronunciationResult.spoken;
  @override
  Future<void> stop() async => stops++;
}
