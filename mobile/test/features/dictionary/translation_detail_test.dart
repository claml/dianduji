import 'package:dian_du_ji/features/dictionary/data/dictionary_repository.dart';
import 'package:dian_du_ji/features/dictionary/domain/specialized_terms.dart';
import 'package:dian_du_ji/features/dictionary/domain/term_candidate_recognizer.dart';
import 'package:dian_du_ji/features/dictionary/domain/user_dictionary_repository.dart';
import 'package:dian_du_ji/features/dictionary/presentation/translation_detail.dart';
import 'package:dian_du_ji/features/dictionary/presentation/translation_view_model.dart';
import 'package:dian_du_ji/features/phrases/domain/phrase_recognizer.dart';
import 'package:dian_du_ji/features/phrases/domain/phrase_type.dart';
import 'package:dian_du_ji/core/network/online_translation_gateway.dart';
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

  testWidgets('not-found card offers a manual definition action', (
    tester,
  ) async {
    ManualDictionaryEntry? saved;
    await tester.pumpWidget(
      MaterialApp(
        home: TranslationDetail(
          state: const TranslationState(
            status: TranslationStatus.notFound,
            surface: 'MEC',
          ),
          onClose: _noop,
          onAddManualDefinition: (entry) async => saved = entry,
        ),
      ),
    );

    expect(find.text('添加自定义释义'), findsOneWidget);
    await tester.tap(find.byKey(const Key('add-manual-definition')));
    await tester.pumpAndSettle();

    expect(find.text('添加自定义释义'), findsWidgets); // dialog title
    await tester.enterText(
      find.byKey(const Key('manual-chinese')),
      '城市设计与导航实验（缩写）',
    );
    await tester.tap(find.byKey(const Key('manual-save')));
    await tester.pumpAndSettle();

    expect(saved, isNotNull);
    expect(saved!.surface, 'MEC');
    expect(saved!.definitionChinese, '城市设计与导航实验（缩写）');
    expect(find.text('已收录，再次点击即可查询'), findsOneWidget);
  });

  testWidgets('manual definition action is hidden without a callback', (
    tester,
  ) async {
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

    expect(find.byKey(const Key('add-manual-definition')), findsNothing);
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

  testWidgets('renders term, specialized gloss, sentence and online source', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TranslationDetail(
          state: const TranslationState(
            status: TranslationStatus.found,
            surface: 'random',
            matchedCandidate: TermCandidate(
              surface: 'random forest',
              startToken: 0,
              endToken: 1,
              domain: SpecializedDomain.computerScience,
            ),
            specializedTerm: SpecializedTerm(
              term: 'random forest',
              domain: SpecializedDomain.computerScience,
              definition: '随机森林',
            ),
            sentence: 'A random forest classifies samples.',
            onlineResult: OnlineTranslationResult(
              termTranslation: '随机森林',
              sentenceTranslation: '随机森林对样本进行分类。',
              examples: [
                OnlineExample(
                  source: 'Random forests reduce variance.',
                  translation: '随机森林降低方差。',
                ),
              ],
              sourceId: 'gateway',
              cacheVersion: '1',
            ),
            onlineStatus: OnlineTranslationStatus.available,
          ),
          onClose: _noop,
        ),
      ),
    );

    expect(find.text('random forest'), findsOneWidget); // term first
    expect(find.text('专业释义'), findsOneWidget);
    expect(find.text('计算机'), findsOneWidget); // domain label
    expect(find.text('随机森林'), findsOneWidget);
    expect(find.text('A random forest classifies samples.'), findsOneWidget);
    expect(find.text('随机森林对样本进行分类。'), findsOneWidget);
    expect(find.text('Random forests reduce variance.'), findsOneWidget);
    expect(find.text('专业词典·计算机 / 在线翻译·gateway'), findsOneWidget);
  });

  testWidgets('specialized-only hit renders without a general entry', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TranslationDetail(
          state: TranslationState(
            status: TranslationStatus.found,
            surface: 'mitochondria',
            specializedTerm: SpecializedTerm(
              term: 'mitochondria',
              domain: SpecializedDomain.biology,
              definition: '线粒体',
            ),
            sentence: 'Mitochondria produce ATP.',
          ),
          onClose: _noop,
        ),
      ),
    );

    expect(find.text('mitochondria'), findsOneWidget);
    expect(find.text('专业释义'), findsOneWidget);
    expect(find.text('生物'), findsOneWidget);
    expect(find.text('线粒体'), findsOneWidget);
    expect(find.text('Mitochondria produce ATP.'), findsOneWidget);
    expect(find.text('专业词典·生物'), findsOneWidget);
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
