import 'package:dian_du_ji/app/providers.dart';
import 'package:dian_du_ji/features/dictionary/data/dictionary_repository.dart';
import 'package:dian_du_ji/features/dictionary/presentation/translation_view_model.dart';
import 'package:dian_du_ji/features/documents/data/drift_document_repository.dart';
import 'package:dian_du_ji/features/documents/domain/document_models.dart';
import 'package:dian_du_ji/features/phrases/domain/phrase_recognizer.dart';
import 'package:dian_du_ji/features/reader/domain/reading_locator.dart';
import 'package:dian_du_ji/features/reader/presentation/reader_controller.dart';
import 'package:dian_du_ji/features/reader/presentation/reader_page.dart';
import 'package:dian_du_ji/features/settings/data/reading_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reader page exposes a route-ready document id', () {
    const page = ReaderPage(documentId: 'doc-1');

    expect(page.documentId, 'doc-1');
  });

  testWidgets('uses a phone bottom card and force-saves position on pause', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final documents = _Documents();
    final controller = _controller(documents);
    await tester.pumpWidget(_page(controller));
    await tester.pump();

    await tester.tap(find.byKey(const Key('t1')));
    await tester.pump();
    expect(find.byKey(const Key('translation-bottom-sheet')), findsOneWidget);

    controller.updateReadingPosition(sentenceId: 's1', localOffset: 1, progress: 0.5);
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      SystemChannels.lifecycle.name,
      const StringCodec().encodeMessage('AppLifecycleState.paused'),
      (_) {},
    );
    await tester.pump();
    expect(documents.saved, [(_locator, 0.5)]);
  });

  testWidgets('uses a tablet side pane after a token tap', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = _controller(_Documents());
    await tester.pumpWidget(_page(controller));
    await tester.pump();

    await tester.tap(find.byKey(const Key('t1')));
    await tester.pump();
    expect(find.byKey(const Key('translation-side-pane')), findsOneWidget);
  });

  testWidgets('force-saves pending progress when navigating back', (tester) async {
    final documents = _Documents();
    final controller = _controller(documents);
    await tester.pumpWidget(_page(controller, withBackRoute: true));
    await tester.pumpAndSettle();

    controller.updateReadingPosition(sentenceId: 's1', localOffset: 1, progress: 0.5);
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(documents.saved, [(_locator, 0.5)]);
  });

  testWidgets('records a stable token offset and restores that token after rebuild', (tester) async {
    await tester.binding.setSurfaceSize(const Size(180, 200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final documents = _ScrollableDocuments();
    final first = _scrollController(documents);
    await tester.pumpWidget(_page(first));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -240));
    await tester.pumpAndSettle();
    await first.forceSave();
    final saved = documents.saved.single.$1;
    expect(saved.localOffset, greaterThan(0));

    documents.lastLocator = saved;
    final restored = _scrollController(documents);
    await tester.pumpWidget(_page(restored));
    await tester.pumpAndSettle();
    final token = documents.tokens.lastWhere((item) => item.startOffset <= saved.localOffset);
    expect(tester.getRect(find.byKey(Key(token.id))).top, lessThan(180));
  });
}

Widget _page(ReaderController controller, {bool withBackRoute = false}) => ProviderScope(
  overrides: [readingSettingsProvider.overrideWith((ref) => Stream.value(ReadingSettings()))],
  child: MaterialApp(home: withBackRoute ? _PushReader(controller) : ReaderPage(documentId: 'doc-1', controller: controller)),
);

class _PushReader extends StatefulWidget {
  const _PushReader(this.controller);
  final ReaderController controller;
  @override State<_PushReader> createState() => _PushReaderState();
}

class _PushReaderState extends State<_PushReader> {
  @override void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReaderPage(documentId: 'doc-1', controller: widget.controller)))); }
  @override Widget build(BuildContext context) => const Scaffold(body: SizedBox());
}

ReaderController _controller(_Documents documents) => ReaderController(
  documents: documents,
  translation: TranslationViewModel(dictionary: const _Dictionary(), learning: const _Learning(), phraseRecognizer: PhraseRecognizer(const [])),
  settings: ReadingSettings(),
  progressDelay: const Duration(days: 1),
);

ReaderController _scrollController(_ScrollableDocuments documents) => ReaderController(
  documents: documents,
  translation: TranslationViewModel(dictionary: const _Dictionary(), learning: const _Learning(), phraseRecognizer: PhraseRecognizer(const [])),
  settings: ReadingSettings(),
  progressDelay: const Duration(days: 1),
);

const _locator = ReadingLocator(documentId: 'doc-1', paragraphId: 'p1', sentenceId: 's1', localOffset: 1);

class _Documents implements DocumentRepository {
  final saved = <(ReadingLocator, double)>[];
  @override Future<void> deleteDocument(String id) async {}
  @override Future<StoredReaderDocument> loadReaderDocument(String id) async => const StoredReaderDocument(id: 'doc-1', title: 'Lesson', readProgress: 0, sentences: [StoredReaderSentence(id: 's1', paragraphId: 'p1', ordinal: 0, text: 'Word.', startOffset: 0, endOffset: 5, tokens: [StoredReaderToken(id: 't1', ordinal: 0, surface: 'Word', normalized: 'word', lemma: 'word', startOffset: 0, endOffset: 4)])]);
  @override Future<void> recoverInterruptedImports() async {}
  @override Future<void> saveProgress(ReadingLocator locator, double progress) async => saved.add((locator, progress));
  @override Stream<List<DocumentSummary>> watchDocuments() => const Stream.empty();
}

class _Dictionary implements DictionaryLookup { const _Dictionary(); @override Future<DictionaryEntry?> lookup(String surface) async => null; }
class _Learning implements LearningRepository { const _Learning(); @override Future<void> recordLookup({required String surface, required DictionaryEntry entry, required LearningContext context}) async {} @override Future<void> savePhrase(SavedPhraseDraft phrase) async {} }

class _ScrollableDocuments implements DocumentRepository {
  _ScrollableDocuments()
      : tokens = List.generate(24, (index) => StoredReaderToken(id: 'scroll-$index', ordinal: index, surface: 'w$index', normalized: 'w$index', lemma: 'w$index', startOffset: index * 3, endOffset: index * 3 + 2));
  final List<StoredReaderToken> tokens;
  ReadingLocator? lastLocator;
  final saved = <(ReadingLocator, double)>[];
  @override Future<void> deleteDocument(String id) async {}
  @override Future<StoredReaderDocument> loadReaderDocument(String id) async => StoredReaderDocument(id: 'doc-1', title: 'Scrollable', readProgress: 0, lastLocator: lastLocator, sentences: [StoredReaderSentence(id: 'scroll-sentence', paragraphId: 'p1', ordinal: 0, text: tokens.map((token) => token.surface).join(' '), startOffset: 0, endOffset: 72, tokens: tokens)]);
  @override Future<void> recoverInterruptedImports() async {}
  @override Future<void> saveProgress(ReadingLocator locator, double progress) async => saved.add((locator, progress));
  @override Stream<List<DocumentSummary>> watchDocuments() => const Stream.empty();
}
