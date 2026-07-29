import 'package:dian_du_ji/features/dictionary/data/dictionary_repository.dart';
import 'package:dian_du_ji/features/dictionary/presentation/translation_detail.dart';
import 'package:dian_du_ji/features/dictionary/presentation/translation_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders an offline found translation with semantic pronunciation action', (tester) async {
    await tester.pumpWidget(MaterialApp(home: TranslationDetail(
      state: const TranslationState(status: TranslationStatus.found, surface: 'look', entry: DictionaryEntry(word: 'look', phonetic: 'lʊk', partOfSpeech: 'v.', definitionEnglish: 'see', definitionChinese: '看'),),
      onClose: () {},
    )));

    expect(find.text('look'), findsOneWidget);
    expect(find.text('lʊk'), findsOneWidget);
    expect(find.text('v.'), findsOneWidget);
    expect(find.text('看'), findsOneWidget);
    expect(find.byTooltip('发音'), findsOneWidget);
  });

  testWidgets('renders an explicit not-found state', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TranslationDetail(
      state: TranslationState(status: TranslationStatus.notFound, surface: 'mystery'),
      onClose: _noop,
    )));

    expect(find.text('本地词典未收录'), findsOneWidget);
  });
}

void _noop() {}
