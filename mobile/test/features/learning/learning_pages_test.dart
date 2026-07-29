import 'dart:typed_data';

import 'package:dian_du_ji/app/providers.dart';
import 'package:dian_du_ji/features/dictionary/data/dictionary_repository.dart';
import 'package:dian_du_ji/features/learning/data/csv_export_service.dart';
import 'package:dian_du_ji/features/learning/data/learning_repository.dart';
import 'package:dian_du_ji/features/learning/presentation/learning_controllers.dart';
import 'package:dian_du_ji/features/learning/presentation/learning_pages.dart';
import 'package:dian_du_ji/features/phrases/domain/phrase_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'vocabulary controller exposes query, mutations and CSV export',
    () async {
      final repository = _LearningRepository();
      final writer = _Writer();
      final controller = VocabularyController(
        repository,
        CsvExportService(
          destinationPicker: const _Picker('words.csv'),
          writer: writer,
        ),
      );
      addTearDown(controller.dispose);
      await Future<void>.delayed(Duration.zero);

      controller.filter(VocabularyFilter.known);
      controller.sort(VocabularySort.lookupCount);
      controller.search('语言');
      await controller.add(
        const ManualVocabularyDraft(word: 'manual', definition: '手动'),
      );
      await controller.setProficiency('language', VocabularyProficiency.vague);
      await controller.delete('language');
      await controller.exportCsv();

      expect(controller.query.filter, VocabularyFilter.known);
      expect(controller.query.sort, VocabularySort.lookupCount);
      expect(controller.query.search, '语言');
      expect(repository.added.single.word, 'manual');
      expect(repository.proficiency.single, (
        'language',
        VocabularyProficiency.vague,
      ));
      expect(repository.deletedVocabulary, ['language']);
      expect(writer.writes.single.$1, 'words.csv');
    },
  );

  testWidgets(
    'vocabulary controls select filters, sort and validate manual add',
    (tester) async {
      final repository = _LearningRepository();
      final writer = _Writer();
      await tester.pumpWidget(
        _learningApp(repository, const VocabularyPage(), writer: writer),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('导出 CSV'));
      await tester.pumpAndSettle();
      expect(writer.writes, hasLength(1));

      await tester.tap(find.text('认识'));
      await tester.pumpAndSettle();
      final knownChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, '认识'),
      );
      expect(knownChip.selected, isTrue);

      await tester.tap(find.byTooltip('排序'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('查询次数').last);
      await tester.pumpAndSettle();
      expect(repository.lastVocabularyQuery.sort, VocabularySort.lookupCount);

      await tester.tap(find.byTooltip('添加生词'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('保存'));
      await tester.pump();
      expect(find.text('单词和释义不能为空'), findsOneWidget);
    },
  );

  testWidgets(
    'phone vocabulary detail updates proficiency and confirms delete',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repository = _LearningRepository();
      await tester.pumpWidget(_learningApp(repository, const VocabularyPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('language'));
      await tester.pumpAndSettle();
      expect(find.text('Languages connect people.'), findsOneWidget);
      expect(find.text('A Lesson'), findsOneWidget);

      await tester.tap(find.byType(DropdownButton<VocabularyProficiency>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('模糊').last);
      await tester.pumpAndSettle();
      expect(repository.proficiency.single.$2, VocabularyProficiency.vague);

      await tester.tap(find.text('删除生词'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
      expect(repository.deletedVocabulary, isEmpty);

      await tester.tap(find.text('删除生词'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('确认删除'));
      await tester.pumpAndSettle();
      expect(repository.deletedVocabulary, ['language']);
    },
  );

  testWidgets(
    'tablet phrase page filters, searches and shows retained detail',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repository = _LearningRepository();
      await tester.pumpWidget(_learningApp(repository, const PhraseBookPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('短语动词'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '短语动词'))
            .selected,
        isTrue,
      );
      await tester.enterText(find.byType(SearchBar), '查阅');
      await tester.pumpAndSettle();
      expect(repository.lastPhraseQuery.search, '查阅');

      await tester.tap(find.text('look up'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('phrase-detail-pane')), findsOneWidget);
      expect(find.text('Look it up.'), findsOneWidget);
      expect(find.text('原文档已删除'), findsOneWidget);

      await tester.tap(find.text('删除短语'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
      expect(repository.deletedPhrases, isEmpty);
      await tester.tap(find.text('删除短语'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('确认删除'));
      await tester.pumpAndSettle();
      expect(repository.deletedPhrases, ['look-up']);
    },
  );
}

Widget _learningApp(
  _LearningRepository repository,
  Widget page, {
  _Writer? writer,
}) {
  final exportWriter = writer ?? _Writer();
  return ProviderScope(
    overrides: [
      learningRepositoryProvider.overrideWithValue(repository),
      csvExportServiceProvider.overrideWithValue(
        CsvExportService(
          destinationPicker: const _Picker('words.csv'),
          writer: exportWriter,
        ),
      ),
    ],
    child: MaterialApp(home: page),
  );
}

class _LearningRepository implements LearningRepository {
  final added = <ManualVocabularyDraft>[];
  final proficiency = <(String, VocabularyProficiency)>[];
  final deletedVocabulary = <String>[];
  final deletedPhrases = <String>[];
  VocabularyQuery lastVocabularyQuery = const VocabularyQuery();
  SavedPhraseQuery lastPhraseQuery = const SavedPhraseQuery();

  final vocabulary = [
    VocabularyListItem(
      lemma: 'language',
      displayWord: 'language',
      phonetic: 'ˈlæŋɡwɪdʒ',
      partOfSpeech: 'n.',
      definition: '语言',
      proficiency: VocabularyProficiency.unknown,
      lookupCount: 2,
      context: 'Languages connect people.',
      sourceAvailability: SourceAvailability.available,
      sourceTitle: 'A Lesson',
      lastLookupAt: DateTime(2026),
    ),
  ];
  final phrases = [
    SavedPhraseListItem(
      phraseKey: 'look-up',
      surface: 'look up',
      meaning: '查阅',
      type: PhraseType.phrasalVerb,
      context: 'Look it up.',
      createdAt: DateTime(2026),
      sourceAvailability: SourceAvailability.deleted,
      sourceTitle: 'Deleted Lesson',
    ),
  ];

  @override
  Stream<List<VocabularyListItem>> watchVocabulary(
    VocabularyQuery query,
  ) async* {
    lastVocabularyQuery = query;
    yield vocabulary
        .where(
          (entry) =>
              (query.filter == VocabularyFilter.all ||
                  entry.proficiency.name == query.filter.name) &&
              (query.search.isEmpty ||
                  entry.lemma.contains(query.search) ||
                  entry.definition.contains(query.search)),
        )
        .toList();
  }

  @override
  Stream<List<SavedPhraseListItem>> watchSavedPhrases(
    SavedPhraseQuery query,
  ) async* {
    lastPhraseQuery = query;
    yield phrases
        .where(
          (entry) =>
              (query.type == null || entry.type == query.type) &&
              (query.search.isEmpty ||
                  entry.surface.contains(query.search) ||
                  entry.meaning.contains(query.search)),
        )
        .toList();
  }

  @override
  Future<void> addManualVocabulary(ManualVocabularyDraft draft) async =>
      added.add(draft);

  @override
  Future<void> deleteSavedPhrase(String phraseKey) async =>
      deletedPhrases.add(phraseKey);

  @override
  Future<void> deleteVocabulary(String lemma) async =>
      deletedVocabulary.add(lemma);

  @override
  Future<void> updateProficiency(
    String lemma,
    VocabularyProficiency value,
  ) async => proficiency.add((lemma, value));

  @override
  Future<void> recordLookup({
    required String surface,
    required DictionaryEntry entry,
    required LearningContext context,
  }) async {}

  @override
  Future<void> savePhrase(SavedPhraseDraft phrase) async {}
}

class _Picker implements CsvDestinationPicker {
  const _Picker(this.path);

  final String? path;

  @override
  Future<String?> saveCsv({required String suggestedName}) async => path;
}

class _Writer implements CsvFileWriter {
  final writes = <(String, Uint8List)>[];

  @override
  Future<void> write(String path, Uint8List bytes) async =>
      writes.add((path, bytes));
}
