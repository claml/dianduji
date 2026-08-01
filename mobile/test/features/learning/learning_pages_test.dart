import 'dart:async';
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
      final destination = _Destination('words.csv');
      final controller = VocabularyController(
        repository,
        CsvExportService(destination: destination),
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
      expect(destination.bytes, isNotEmpty);
    },
  );

  testWidgets(
    'vocabulary controls select filters, sort and validate manual add',
    (tester) async {
      final repository = _LearningRepository();
      final destination = _Destination('words.csv');
      await tester.pumpWidget(
        _learningApp(
          repository,
          const VocabularyPage(),
          destination: destination,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('导出 CSV'));
      await tester.pumpAndSettle();
      expect(destination.calls, 1);

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

  testWidgets('vocabulary load error is visible and retryable', (tester) async {
    final repository = _LearningRepository()..failVocabulary = true;
    await tester.pumpWidget(_learningApp(repository, const VocabularyPage()));
    await tester.pumpAndSettle();

    expect(find.text('加载生词失败'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
    expect(find.text('还没有生词'), findsNothing);

    repository.failVocabulary = false;
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(find.text('language'), findsOneWidget);
  });

  testWidgets('vocabulary shows loading before its first database result', (
    tester,
  ) async {
    final repository = _LearningRepository()..holdVocabulary = true;
    await tester.pumpWidget(_learningApp(repository, const VocabularyPage()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('还没有生词'), findsNothing);

    repository.releaseVocabulary();
    await tester.pumpAndSettle();
    expect(find.text('language'), findsOneWidget);
  });

  testWidgets('phrase load error is visible and retryable', (tester) async {
    final repository = _LearningRepository()..failPhrases = true;
    await tester.pumpWidget(_learningApp(repository, const PhraseBookPage()));
    await tester.pumpAndSettle();

    expect(find.text('加载短语失败'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
    expect(find.text('还没有收藏短语'), findsNothing);

    repository.failPhrases = false;
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(find.text('look up'), findsOneWidget);
  });

  testWidgets(
    'phone vocabulary detail updates proficiency and confirms delete',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repository = _LearningRepository();
      await tester.pumpWidget(_learningApp(repository, const VocabularyPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ListTile, 'language'));
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

  testWidgets(
    'tablet detail follows repository updates and selection removal',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repository = _LearningRepository();
      addTearDown(repository.dispose);
      await tester.pumpWidget(_learningApp(repository, const VocabularyPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('language'));
      await tester.pumpAndSettle();
      repository.replaceVocabulary([
        _vocabularyItem(
          proficiency: VocabularyProficiency.known,
          context: 'Updated context from repository.',
        ),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('Updated context from repository.'), findsOneWidget);
      expect(
        tester
            .widget<DropdownButton<VocabularyProficiency>>(
              find.byType(DropdownButton<VocabularyProficiency>),
            )
            .value,
        VocabularyProficiency.known,
      );

      repository.replaceVocabulary(const []);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('vocabulary-detail-pane')),
        findsNothing,
      );
      expect(find.text('选择一个生词查看详情'), findsOneWidget);
    },
  );

  testWidgets(
    'vocabulary delete completing after disposal has no exception or stale callback',
    (tester) async {
      final repository = _LearningRepository()
        ..vocabularyDelete = Completer<void>();
      final controller = VocabularyController(
        repository,
        CsvExportService(destination: _Destination('words.csv')),
      );
      addTearDown(controller.dispose);
      var deletedCallbacks = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VocabularyDetail(
              entry: _vocabularyItem(),
              controller: controller,
              onDeleted: () => deletedCallbacks++,
            ),
          ),
        ),
      );

      await tester.tap(find.text('删除生词'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('确认删除'));
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
      repository.vocabularyDelete!.complete();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(deletedCallbacks, 0);
    },
  );

  testWidgets(
    'phrase delete completing after disposal has no exception or stale callback',
    (tester) async {
      final repository = _LearningRepository()..phraseDelete = Completer<void>();
      final controller = PhraseBookController(repository);
      addTearDown(controller.dispose);
      var deletedCallbacks = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhraseDetail(
              entry: repository.phrases.single,
              controller: controller,
              onDeleted: () => deletedCallbacks++,
            ),
          ),
        ),
      );

      await tester.tap(find.text('删除短语'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('确认删除'));
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
      repository.phraseDelete!.complete();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(deletedCallbacks, 0);
    },
  );

  testWidgets(
    '640dp window keeps multi-pane when navigation reduces body width',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(640, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repository = _LearningRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            learningRepositoryProvider.overrideWithValue(repository),
            csvExportServiceProvider.overrideWithValue(
              CsvExportService(destination: _Destination('words.csv')),
            ),
          ],
          child: const MaterialApp(
            home: Row(
              children: [
                SizedBox(width: 80),
                Expanded(child: VocabularyPage()),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('选择一个生词查看详情'), findsOneWidget);
    },
  );
}

Widget _learningApp(
  _LearningRepository repository,
  Widget page, {
  _Destination? destination,
}) {
  final exportDestination = destination ?? _Destination('words.csv');
  return ProviderScope(
    overrides: [
      learningRepositoryProvider.overrideWithValue(repository),
      csvExportServiceProvider.overrideWithValue(
        CsvExportService(destination: exportDestination),
      ),
    ],
    child: MaterialApp(home: page),
  );
}

class _LearningRepository implements LearningRepository {
  final _vocabularyChanges =
      StreamController<List<VocabularyListItem>>.broadcast();
  final added = <ManualVocabularyDraft>[];
  final proficiency = <(String, VocabularyProficiency)>[];
  final deletedVocabulary = <String>[];
  final deletedPhrases = <String>[];
  VocabularyQuery lastVocabularyQuery = const VocabularyQuery();
  SavedPhraseQuery lastPhraseQuery = const SavedPhraseQuery();
  bool failVocabulary = false;
  bool holdVocabulary = false;
  bool failPhrases = false;
  Completer<void>? _vocabularyRelease;
  Completer<void>? vocabularyDelete;
  Completer<void>? phraseDelete;

  final vocabulary = [_vocabularyItem()];
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
    if (failVocabulary) throw StateError('database unavailable');
    if (holdVocabulary) {
      _vocabularyRelease = Completer<void>();
      await _vocabularyRelease!.future;
    }
    List<VocabularyListItem> filter(List<VocabularyListItem> source) => source
        .where(
          (entry) =>
              (query.filter == VocabularyFilter.all ||
                  entry.proficiency.name == query.filter.name) &&
              (query.search.isEmpty ||
                  entry.lemma.contains(query.search) ||
                  entry.definition.contains(query.search)),
        )
        .toList();
    yield filter(vocabulary);
    yield* _vocabularyChanges.stream.map(filter);
  }

  void replaceVocabulary(List<VocabularyListItem> value) {
    vocabulary
      ..clear()
      ..addAll(value);
    _vocabularyChanges.add(List.unmodifiable(vocabulary));
  }

  void releaseVocabulary() {
    holdVocabulary = false;
    _vocabularyRelease?.complete();
  }

  void dispose() => _vocabularyChanges.close();

  @override
  Stream<List<SavedPhraseListItem>> watchSavedPhrases(
    SavedPhraseQuery query,
  ) async* {
    lastPhraseQuery = query;
    if (failPhrases) throw StateError('database unavailable');
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
  Future<void> deleteSavedPhrase(String phraseKey) async {
    await phraseDelete?.future;
    deletedPhrases.add(phraseKey);
  }

  @override
  Future<void> deleteVocabulary(String lemma) async {
    await vocabularyDelete?.future;
    deletedVocabulary.add(lemma);
  }

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

VocabularyListItem _vocabularyItem({
  VocabularyProficiency proficiency = VocabularyProficiency.unknown,
  String context = 'Languages connect people.',
}) => VocabularyListItem(
  lemma: 'language',
  displayWord: 'language',
  phonetic: 'ˈlæŋɡwɪdʒ',
  partOfSpeech: 'n.',
  definition: '语言',
  proficiency: proficiency,
  lookupCount: 2,
  context: context,
  sourceAvailability: SourceAvailability.available,
  sourceTitle: 'A Lesson',
  lastLookupAt: DateTime(2026),
);

class _Destination implements CsvDestinationPicker {
  _Destination(this.path);

  final String? path;
  var calls = 0;
  Uint8List bytes = Uint8List(0);

  @override
  Future<String?> saveCsv({
    required String suggestedName,
    required Uint8List bytes,
  }) async {
    calls++;
    this.bytes = bytes;
    return path;
  }
}
