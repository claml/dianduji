import 'package:dian_du_ji/app/providers.dart';
import 'package:dian_du_ji/features/dictionary/data/dictionary_repository.dart';
import 'package:dian_du_ji/features/learning/data/learning_repository.dart';
import 'package:dian_du_ji/features/dictionary/presentation/translation_view_model.dart';
import 'package:dian_du_ji/features/documents/data/drift_document_repository.dart';
import 'package:dian_du_ji/features/documents/domain/document_models.dart';
import 'package:dian_du_ji/features/phrases/domain/phrase_recognizer.dart';
import 'package:dian_du_ji/features/reader/domain/reading_locator.dart';
import 'package:dian_du_ji/features/reader/domain/reader_selection.dart';
import 'package:dian_du_ji/features/reader/data/reader_card_preferences.dart';
import 'package:dian_du_ji/features/reader/presentation/reader_controller.dart';
import 'package:dian_du_ji/features/reader/presentation/reader_page.dart';
import 'package:dian_du_ji/features/reader/presentation/widgets/pdf_document_view.dart';
import 'package:dian_du_ji/features/settings/data/reading_settings.dart';
import 'package:dian_du_ji/features/settings/data/settings_repository.dart';
import 'package:dian_du_ji/features/settings/presentation/persisted_settings_controller.dart';
import 'package:dian_du_ji/features/sync/domain/sync_api_client.dart';
import 'package:dian_du_ji/features/sync/domain/sync_engine.dart';
import 'package:dian_du_ji/features/sync/domain/token_storage.dart';
import 'package:dian_du_ji/features/sync/presentation/sync_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfrx/pdfrx.dart';

void main() {
  test('reader page exposes a route-ready document id', () {
    const page = ReaderPage(documentId: 'doc-1');

    expect(page.documentId, 'doc-1');
  });

  testWidgets('uses a phone bottom card and force-saves position on pause', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final documents = _Documents();
    final controller = _controller(documents);
    await tester.pumpWidget(_page(controller));
    await tester.pump();

    await tester.tap(find.byKey(const Key('t1')));
    await tester.pump();
    expect(find.byKey(const Key('translation-bottom-sheet')), findsOneWidget);

    controller.updateReadingPosition(
      sentenceId: 's1',
      localOffset: 1,
      progress: 0.5,
    );
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

  testWidgets(
    'keeps the PDF renderer mounted across tablet card and chrome changes',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final controller = _readerController(_PdfDocuments());
      final preferences = _PreferencesStore(
        ReaderCardPreferences(
          mode: ReaderCardMode.sidePane,
          relativeX: 0.7,
          relativeY: 0,
        ),
      );
      PdfDocumentView? configuredView;
      var renderCount = 0;
      await tester.pumpWidget(
        _page(
          controller,
          cardPreferences: preferences,
          pdfRenderer: (context, view) {
            configuredView = view;
            renderCount++;
            return const ColoredBox(
              key: Key('stable-pdf-renderer'),
              color: Colors.white,
            );
          },
        ),
      );
      await tester.pump();

      expect(renderCount, 1);
      configuredView!.onWordTap(
        const ReaderSelection(
          surface: 'Foundation',
          normalized: 'foundation',
          contextText: 'Foundation Models',
          startOffset: 0,
          endOffset: 10,
          pageNumber: 1,
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('translation-side-pane')), findsOneWidget);
      expect(renderCount, 1);
      final documentViewport = find.byKey(
        const Key('reader-document-viewport'),
      );
      final viewportRect = tester.getRect(documentViewport);
      final toolbarBottom = tester
          .getRect(find.byKey(const Key('reader-top-bar')))
          .bottom;

      await tester.tap(find.byKey(const Key('reader-float-card')));
      await tester.pump();
      expect(
        find.byKey(const Key('translation-floating-card')),
        findsOneWidget,
      );
      expect(preferences.saved.last.mode, ReaderCardMode.floating);
      expect(
        tester.getRect(find.byKey(const Key('translation-floating-card'))).top,
        greaterThanOrEqualTo(toolbarBottom),
      );
      expect(renderCount, 1);
      final floatingViewportRect = tester.getRect(documentViewport);

      await tester.drag(
        find.byKey(const Key('translation-floating-drag-handle')),
        const Offset(80, 0),
      );
      await tester.pump();
      expect(preferences.saved.last.mode, ReaderCardMode.floating);
      expect(preferences.saved.last.relativeY, 0);
      expect(renderCount, 1);
      expect(tester.getRect(documentViewport), floatingViewportRect);

      await tester.tap(find.byTooltip('关闭释义'));
      await tester.pump();
      expect(find.byKey(const Key('translation-floating-card')), findsNothing);
      configuredView!.onWordTap(
        const ReaderSelection(
          surface: 'Foundation',
          normalized: 'foundation',
          contextText: 'Foundation Models',
          startOffset: 0,
          endOffset: 10,
          pageNumber: 1,
        ),
      );
      await tester.pump();
      expect(
        find.byKey(const Key('translation-floating-card')),
        findsOneWidget,
      );
      expect(renderCount, 1);

      await tester.tap(find.byKey(const Key('reader-dock-card')));
      await tester.pump();
      expect(find.byKey(const Key('translation-side-pane')), findsOneWidget);
      expect(renderCount, 1);
      expect(tester.getRect(documentViewport), viewportRect);

      configuredView!.onContentScroll!(30);
      await tester.pump(const Duration(milliseconds: 180));
      expect(find.byKey(const Key('reader-top-reveal-zone')), findsOneWidget);
      expect(renderCount, 1);
      expect(tester.getRect(documentViewport), viewportRect);

      await tester.tap(find.byKey(const Key('reader-float-card')));
      await tester.pump();
      expect(
        find.byKey(const Key('translation-floating-card')),
        findsOneWidget,
      );
      expect(
        tester.getRect(find.byKey(const Key('translation-floating-card'))).top,
        greaterThanOrEqualTo(toolbarBottom),
      );
      expect(renderCount, 1);
      expect(tester.getRect(documentViewport), floatingViewportRect);

      await tester.tap(find.byKey(const Key('reader-dock-card')));
      await tester.pump();
      expect(find.byKey(const Key('translation-side-pane')), findsOneWidget);
      expect(renderCount, 1);
      expect(tester.getRect(documentViewport), viewportRect);

      configuredView!.onContentScroll!(-1);
      await tester.pump(const Duration(milliseconds: 180));
      expect(find.byKey(const Key('reader-top-reveal-zone')), findsNothing);
      expect(renderCount, 1);
    },
  );

  testWidgets(
    'opens persisted reading settings without rebuilding the PDF renderer',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final settings = _SettingsRepository();
      var renderCount = 0;
      await tester.pumpWidget(
        _page(
          _readerController(_PdfDocuments()),
          settingsRepository: settings,
          pdfRenderer: (context, view) {
            renderCount++;
            return const ColoredBox(color: Colors.white);
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(renderCount, 1);
      await tester.tap(find.byKey(const Key('reader-settings-button')));
      await tester.pumpAndSettle();
      expect(find.text('字号和行距仅适用于 TXT/DOCX 重排阅读，PDF 保留原版式。'), findsOneWidget);

      await tester.tap(find.text('夜间'));
      await tester.pump();
      final fontSlider = tester.getRect(
        find.byKey(const Key('reading-font-size-slider')),
      );
      await tester.tapAt(
        Offset(fontSlider.left + fontSlider.width * 0.75, fontSlider.center.dy),
      );
      await tester.pump();
      final lineHeightSlider = tester.getRect(
        find.byKey(const Key('reading-line-height-slider')),
      );
      await tester.tapAt(
        Offset(
          lineHeightSlider.left + lineHeightSlider.width * 0.75,
          lineHeightSlider.center.dy,
        ),
      );
      await tester.pumpAndSettle();

      expect(settings.value.theme, ReaderTheme.night);
      expect(settings.value.fontSize, greaterThan(16));
      expect(settings.value.lineHeight, greaterThan(1.6));
      expect(settings.saved, isNotEmpty);
      expect(renderCount, 1);
    },
  );

  testWidgets('uses the original PDF view and forwards overlay word taps', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final documents = _PdfDocuments(
      lastLocator: const ReadingLocator(
        documentId: 'doc-1',
        paragraphId: '',
        sentenceId: '',
        localOffset: 0,
        pageNumber: 4,
      ),
    );
    final controller = _readerController(documents);
    PdfDocumentView? configuredView;
    await tester.pumpWidget(
      _page(
        controller,
        pdfRenderer: (context, view) {
          configuredView = view;
          return const ColoredBox(
            key: Key('stub-pdf-page'),
            color: Colors.white,
          );
        },
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('stub-pdf-page')), findsOneWidget);
    expect(configuredView?.localPath, 'documents/paper.pdf');
    expect(configuredView?.initialPageNumber, 4);
    configuredView!.onContentScroll!(30);
    await tester.pump();
    expect(find.byKey(const Key('reader-top-reveal-zone')), findsOneWidget);
    configuredView!.onContentScroll!(-1);
    await tester.pump();
    expect(find.byKey(const Key('reader-top-reveal-zone')), findsNothing);
    configuredView!.onWordTap(
      const ReaderSelection(
        surface: 'Foundation',
        normalized: 'foundation',
        contextText: 'Foundation Models',
        startOffset: 12,
        endOffset: 22,
        pageNumber: 1,
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('translation-bottom-sheet')), findsOneWidget);
    expect(find.text('Foundation'), findsOneWidget);
    await controller.forceSave();
    expect(documents.saved.single.$1.pageNumber, 1);
    expect(documents.saved.single.$1.localOffset, 12);
    documents.saved.clear();
    configuredView!.onPageChanged!(6, 10);
    await controller.forceSave();
    expect(documents.saved.single.$1.pageNumber, 6);
    expect(documents.saved.single.$2, 0.6);
  });

  testWidgets('reports only normalized one-finger PDF pan deltas', (
    tester,
  ) async {
    final deltas = <double>[];
    await tester.pumpWidget(
      MaterialApp(
        home: PdfDocumentView(
          localPath: 'missing.pdf',
          onWordTap: (_) {},
          onContentScroll: deltas.add,
        ),
      ),
    );

    final params = tester.widget<PdfViewer>(find.byType(PdfViewer)).params;
    params.onInteractionUpdate!(
      ScaleUpdateDetails(
        pointerCount: 1,
        scale: 1,
        focalPointDelta: Offset(0, -12),
      ),
    );
    params.onInteractionUpdate!(
      ScaleUpdateDetails(
        pointerCount: 1,
        scale: 1.009,
        focalPointDelta: Offset(0, 7),
      ),
    );
    params.onInteractionUpdate!(
      ScaleUpdateDetails(
        pointerCount: 2,
        scale: 1,
        focalPointDelta: Offset(0, -20),
      ),
    );
    params.onInteractionUpdate!(
      ScaleUpdateDetails(
        pointerCount: 1,
        scale: 1.02,
        focalPointDelta: Offset(0, -20),
      ),
    );

    expect(deltas, [12, -7]);
    params.onInteractionUpdate!(
      ScaleUpdateDetails(
        pointerCount: 1,
        scale: 1,
        focalPointDelta: Offset.zero,
      ),
    );
    expect(deltas, [12, -7]);
    params.onInteractionUpdate!(
      ScaleUpdateDetails(
        pointerCount: 1,
        scale: 1,
        focalPointDelta: Offset(0, double.nan),
      ),
    );
    expect(deltas, [12, -7]);
    params.onInteractionUpdate!(
      ScaleUpdateDetails(
        pointerCount: 1,
        scale: 1,
        focalPointDelta: Offset(0, double.infinity),
      ),
    );
    expect(deltas, [12, -7]);
    params.onInteractionUpdate!(
      ScaleUpdateDetails(
        pointerCount: 1,
        scale: 1,
        focalPointDelta: Offset(0, double.negativeInfinity),
      ),
    );
    expect(deltas, [12, -7]);
  });

  testWidgets('loads and saves the tablet card layout preference', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final preferences = _PreferencesStore(
      ReaderCardPreferences(
        mode: ReaderCardMode.floating,
        relativeX: 0.6,
        relativeY: 0.2,
      ),
    );
    final controller = _controller(_Documents());
    await tester.pumpWidget(_page(controller, cardPreferences: preferences));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('t1')));
    await tester.pump();
    expect(find.byKey(const Key('translation-floating-card')), findsOneWidget);

    await tester.tap(find.byKey(const Key('reader-dock-card')));
    await tester.pump();
    expect(preferences.saved.last.mode, ReaderCardMode.sidePane);
  });

  testWidgets('force-saves pending progress when navigating back', (
    tester,
  ) async {
    final documents = _Documents();
    final controller = _controller(documents);
    await tester.pumpWidget(_page(controller, withBackRoute: true));
    await tester.pumpAndSettle();

    controller.updateReadingPosition(
      sentenceId: 's1',
      localOffset: 1,
      progress: 0.5,
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(documents.saved, [(_locator, 0.5)]);
  });

  testWidgets(
    'explicit back button saves progress and returns to the prior route',
    (tester) async {
      final documents = _Documents();
      final controller = _controller(documents);
      final router = _readerRouter(controller, initialLocation: '/');
      addTearDown(router.dispose);
      await tester.pumpWidget(_routerPage(router));
      await tester.pumpAndSettle();
      router.push('/reader/doc-1');
      await tester.pumpAndSettle();

      controller.updateReadingPosition(
        sentenceId: 's1',
        localOffset: 1,
        progress: 0.5,
      );
      expect(find.byKey(const Key('reader-back-button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('reader-back-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home-route-marker')), findsOneWidget);
      expect(documents.saved, [(_locator, 0.5)]);
    },
  );

  testWidgets(
    'explicit back button saves progress and returns direct entries to home',
    (tester) async {
      final documents = _Documents();
      final controller = _controller(documents);
      final router = _readerRouter(
        controller,
        initialLocation: '/reader/doc-1',
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(_routerPage(router));
      await tester.pumpAndSettle();

      controller.updateReadingPosition(
        sentenceId: 's1',
        localOffset: 1,
        progress: 0.5,
      );
      await tester.tap(find.byKey(const Key('reader-back-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home-route-marker')), findsOneWidget);
      expect(documents.saved, [(_locator, 0.5)]);
    },
  );

  testWidgets(
    'records a stable token offset and restores that token after rebuild',
    (tester) async {
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
      final token = documents.tokens.lastWhere(
        (item) => item.startOffset <= saved.localOffset,
      );
      expect(tester.getRect(find.byKey(Key(token.id))).top, lessThan(180));
    },
  );

  testWidgets(
    'restores leading, trailing, and empty-token locators without throwing',
    (tester) async {
      final token = StoredReaderToken(
        id: 'leading-token',
        ordinal: 0,
        surface: 'word',
        normalized: 'word',
        lemma: 'word',
        startOffset: 2,
        endOffset: 6,
      );
      await tester.pumpWidget(
        _page(
          _readerController(_LocatorDocuments(tokens: [token], localOffset: 0)),
          appKey: const ValueKey('leading'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('leading-token')), findsOneWidget);

      await tester.pumpWidget(
        _page(
          _readerController(
            _LocatorDocuments(tokens: [token], localOffset: 999),
          ),
          appKey: const ValueKey('trailing'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('leading-token')), findsOneWidget);

      await tester.pumpWidget(
        _page(
          _readerController(
            _LocatorDocuments(tokens: const [], localOffset: 999),
          ),
          appKey: const ValueKey('empty'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ReaderPage), findsOneWidget);
    },
  );

  testWidgets(
    'initial locator calibration never overwrites persisted progress',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(180, 200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final documents = _ScrollableDocuments()
        ..lastLocator = const ReadingLocator(
          documentId: 'doc-1',
          paragraphId: 'p1',
          sentenceId: 'scroll-sentence',
          localOffset: 36,
        );
      final controller = _readerController(documents, delay: Duration.zero);
      await tester.pumpWidget(_page(controller));
      await tester.pumpAndSettle();
      await controller.forceSave();

      expect(documents.saved, isEmpty);
      await tester.drag(find.byType(ListView), const Offset(0, -80));
      await tester.pumpAndSettle();
      await controller.forceSave();
      expect(documents.saved, hasLength(1));
    },
  );

  testWidgets(
    'releases restore suppression when calibration throws so a later drag saves',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(180, 200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final documents = _ScrollableDocuments()
        ..lastLocator = const ReadingLocator(
          documentId: 'doc-1',
          paragraphId: 'p1',
          sentenceId: 'scroll-sentence',
          localOffset: 36,
        );
      final controller = _readerController(documents, delay: Duration.zero);
      await tester.pumpWidget(
        _page(
          controller,
          restoreItem: (_) async => throw StateError('calibration failed'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -80));
      await tester.pumpAndSettle();
      await controller.forceSave();
      expect(documents.saved, hasLength(1));
    },
  );

  testWidgets(
    'scrolling to an empty-token sentence saves its sentence locator at offset zero',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(180, 200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final documents = _EmptyTokenDocuments();
      final controller = _readerController(documents, delay: Duration.zero);
      await tester.pumpWidget(_page(controller));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -1000));
      await tester.pumpAndSettle();
      await controller.forceSave();
      expect(documents.saved.last.$1.sentenceId, 'empty-sentence');
      expect(documents.saved.last.$1.localOffset, 0);
    },
  );
}

Widget _page(
  ReaderController controller, {
  bool withBackRoute = false,
  Key? appKey,
  Future<void> Function(BuildContext)? restoreItem,
  ReaderCardPreferencesStore? cardPreferences,
  PdfDocumentRenderer? pdfRenderer,
  SettingsRepository? settingsRepository,
}) => ProviderScope(
  overrides: [
    if (settingsRepository == null)
      readingSettingsProvider.overrideWithValue(
        PersistedSettingsState(settings: ReadingSettings(), isLoading: false),
      )
    else
      settingsRepositoryProvider.overrideWithValue(settingsRepository),
    readerCardPreferencesRepositoryProvider.overrideWithValue(
      cardPreferences ?? _PreferencesStore(ReaderCardPreferences.defaults),
    ),
    syncControllerProvider.overrideWith(
      (_) => SyncController(
        engine: SyncEngine(
          api: SyncApiClient(baseUrl: Uri.parse('http://127.0.0.1:0')),
          storage: MemoryTokenStorage(),
          local: _NoopLocalData(),
        ),
      ),
    ),
  ],
  child: MaterialApp(
    key: appKey,
    home: withBackRoute
        ? _PushReader(controller)
        : ReaderPage(
            documentId: 'doc-1',
            controller: controller,
            restoreItem: restoreItem,
            pdfRenderer: pdfRenderer,
          ),
  ),
);

Widget _routerPage(GoRouter router) => ProviderScope(
  overrides: [
    readingSettingsProvider.overrideWithValue(
      PersistedSettingsState(settings: ReadingSettings(), isLoading: false),
    ),
    readerCardPreferencesRepositoryProvider.overrideWithValue(
      _PreferencesStore(ReaderCardPreferences.defaults),
    ),
    syncControllerProvider.overrideWith(
      (_) => SyncController(
        engine: SyncEngine(
          api: SyncApiClient(baseUrl: Uri.parse('http://127.0.0.1:0')),
          storage: MemoryTokenStorage(),
          local: _NoopLocalData(),
        ),
      ),
    ),
  ],
  child: MaterialApp.router(routerConfig: router),
);

GoRouter _readerRouter(
  ReaderController controller, {
  required String initialLocation,
}) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) =>
          const Scaffold(body: SizedBox(key: Key('home-route-marker'))),
    ),
    GoRoute(
      path: '/reader/:documentId',
      builder: (context, state) => ReaderPage(
        documentId: state.pathParameters['documentId']!,
        controller: controller,
      ),
    ),
  ],
);

class _PushReader extends StatefulWidget {
  const _PushReader(this.controller);
  final ReaderController controller;
  @override
  State<_PushReader> createState() => _PushReaderState();
}

class _PushReaderState extends State<_PushReader> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              ReaderPage(documentId: 'doc-1', controller: widget.controller),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox());
}

ReaderController _controller(_Documents documents) => ReaderController(
  documents: documents,
  translation: TranslationViewModel(
    dictionary: const _Dictionary(),
    learning: const _Learning(),
    phraseRecognizer: PhraseRecognizer(const []),
  ),
  settings: ReadingSettings(),
  progressDelay: const Duration(days: 1),
);

ReaderController _scrollController(_ScrollableDocuments documents) =>
    ReaderController(
      documents: documents,
      translation: TranslationViewModel(
        dictionary: const _Dictionary(),
        learning: const _Learning(),
        phraseRecognizer: PhraseRecognizer(const []),
      ),
      settings: ReadingSettings(),
      progressDelay: const Duration(days: 1),
    );

ReaderController _readerController(
  DocumentRepository documents, {
  Duration delay = const Duration(days: 1),
}) => ReaderController(
  documents: documents,
  translation: TranslationViewModel(
    dictionary: const _Dictionary(),
    learning: const _Learning(),
    phraseRecognizer: PhraseRecognizer(const []),
  ),
  settings: ReadingSettings(),
  progressDelay: delay,
);

const _locator = ReadingLocator(
  documentId: 'doc-1',
  paragraphId: 'p1',
  sentenceId: 's1',
  localOffset: 1,
);

class _Documents implements DocumentRepository {
  final saved = <(ReadingLocator, double)>[];
  @override
  Future<void> deleteDocument(String id) async {}
  @override
  Future<StoredReaderDocument> loadReaderDocument(String id) async =>
      StoredReaderDocument(
        id: 'doc-1',
        title: 'Lesson',
        readProgress: 0,
        sentences: [
          StoredReaderSentence(
            id: 's1',
            paragraphId: 'p1',
            ordinal: 0,
            text: 'Word.',
            startOffset: 0,
            endOffset: 5,
            tokens: [
              StoredReaderToken(
                id: 't1',
                ordinal: 0,
                surface: 'Word',
                normalized: 'word',
                lemma: 'word',
                startOffset: 0,
                endOffset: 4,
              ),
            ],
          ),
        ],
      );
  @override
  Future<void> recoverInterruptedImports() async {}
  @override
  Future<void> saveProgress(ReadingLocator locator, double progress) async =>
      saved.add((locator, progress));
  @override
  Stream<List<DocumentSummary>> watchDocuments() => const Stream.empty();
}

class _PdfDocuments implements DocumentRepository {
  _PdfDocuments({this.lastLocator});

  final ReadingLocator? lastLocator;
  final saved = <(ReadingLocator, double)>[];

  @override
  Future<void> deleteDocument(String id) async {}

  @override
  Future<StoredReaderDocument> loadReaderDocument(String id) async =>
      StoredReaderDocument(
        id: 'doc-1',
        title: 'Paper',
        format: 'pdf',
        localPath: 'documents/paper.pdf',
        readProgress: 0,
        sentences: [],
        lastLocator: lastLocator,
      );

  @override
  Future<void> recoverInterruptedImports() async {}

  @override
  Future<void> saveProgress(ReadingLocator locator, double progress) async =>
      saved.add((locator, progress));

  @override
  Stream<List<DocumentSummary>> watchDocuments() => const Stream.empty();
}

class _Dictionary implements DictionaryLookup {
  const _Dictionary();
  @override
  Future<DictionaryEntry?> lookup(String surface) async => null;
}

class _Learning implements LearningRepository {
  const _Learning();
  @override
  Future<void> recordLookup({
    required String surface,
    required DictionaryEntry entry,
    required LearningContext context,
  }) async {}
  @override
  Future<void> savePhrase(SavedPhraseDraft phrase) async {}
  @override
  Stream<List<VocabularyListItem>> watchVocabulary(VocabularyQuery query) =>
      const Stream.empty();
  @override
  Stream<List<SavedPhraseListItem>> watchSavedPhrases(SavedPhraseQuery query) =>
      const Stream.empty();
  @override
  Future<void> addManualVocabulary(ManualVocabularyDraft draft) async {}
  @override
  Future<void> updateProficiency(
    String lemma,
    VocabularyProficiency value,
  ) async {}
  @override
  Future<void> deleteVocabulary(String lemma) async {}
  @override
  Future<void> deleteSavedPhrase(String phraseKey) async {}
}

class _PreferencesStore implements ReaderCardPreferencesStore {
  _PreferencesStore(this.value);
  ReaderCardPreferences value;
  final saved = <ReaderCardPreferences>[];
  @override
  Future<ReaderCardPreferences> load() async => value;
  @override
  Future<void> save(ReaderCardPreferences preferences) async {
    value = preferences;
    saved.add(preferences);
  }
}

class _SettingsRepository implements SettingsRepository {
  var value = ReadingSettings();
  final saved = <ReadingSettings>[];

  @override
  Future<ReadingSettings> load() async => value;

  @override
  Future<void> save(ReadingSettings settings) async {
    value = settings;
    saved.add(settings);
  }

  @override
  Stream<ReadingSettings> watch() => Stream.value(value);
}

class _ScrollableDocuments implements DocumentRepository {
  _ScrollableDocuments()
    : tokens = List.generate(
        24,
        (index) => StoredReaderToken(
          id: 'scroll-$index',
          ordinal: index,
          surface: 'w$index',
          normalized: 'w$index',
          lemma: 'w$index',
          startOffset: index * 3,
          endOffset: index * 3 + 2,
        ),
      );
  final List<StoredReaderToken> tokens;
  ReadingLocator? lastLocator;
  final saved = <(ReadingLocator, double)>[];
  @override
  Future<void> deleteDocument(String id) async {}
  @override
  Future<StoredReaderDocument> loadReaderDocument(String id) async =>
      StoredReaderDocument(
        id: 'doc-1',
        title: 'Scrollable',
        readProgress: 0,
        lastLocator: lastLocator,
        sentences: [
          StoredReaderSentence(
            id: 'scroll-sentence',
            paragraphId: 'p1',
            ordinal: 0,
            text: tokens.map((token) => token.surface).join(' '),
            startOffset: 0,
            endOffset: 72,
            tokens: tokens,
          ),
        ],
      );
  @override
  Future<void> recoverInterruptedImports() async {}
  @override
  Future<void> saveProgress(ReadingLocator locator, double progress) async =>
      saved.add((locator, progress));
  @override
  Stream<List<DocumentSummary>> watchDocuments() => const Stream.empty();
}

class _LocatorDocuments implements DocumentRepository {
  _LocatorDocuments({required this.tokens, required this.localOffset});
  final List<StoredReaderToken> tokens;
  final int localOffset;
  @override
  Future<void> deleteDocument(String id) async {}
  @override
  Future<StoredReaderDocument> loadReaderDocument(String id) async =>
      StoredReaderDocument(
        id: 'doc-1',
        title: 'Locator',
        readProgress: 0,
        lastLocator: ReadingLocator(
          documentId: 'doc-1',
          paragraphId: 'p1',
          sentenceId: 'locator-sentence',
          localOffset: localOffset,
        ),
        sentences: [
          StoredReaderSentence(
            id: 'locator-sentence',
            paragraphId: 'p1',
            ordinal: 0,
            text: '  word',
            startOffset: 0,
            endOffset: 6,
            tokens: tokens,
          ),
        ],
      );
  @override
  Future<void> recoverInterruptedImports() async {}
  @override
  Future<void> saveProgress(ReadingLocator locator, double progress) async {}
  @override
  Stream<List<DocumentSummary>> watchDocuments() => const Stream.empty();
}

class _EmptyTokenDocuments implements DocumentRepository {
  _EmptyTokenDocuments()
    : tokens = List.generate(
        24,
        (index) => StoredReaderToken(
          id: 'word-$index',
          ordinal: index,
          surface: 'w$index',
          normalized: 'w$index',
          lemma: 'w$index',
          startOffset: index * 3,
          endOffset: index * 3 + 2,
        ),
      );
  final List<StoredReaderToken> tokens;
  final saved = <(ReadingLocator, double)>[];
  @override
  Future<void> deleteDocument(String id) async {}
  @override
  Future<StoredReaderDocument> loadReaderDocument(String id) async =>
      StoredReaderDocument(
        id: 'doc-1',
        title: 'Empty tokens',
        readProgress: 0,
        sentences: [
          StoredReaderSentence(
            id: 'word-sentence',
            paragraphId: 'p1',
            ordinal: 0,
            text: tokens.map((token) => token.surface).join(' '),
            startOffset: 0,
            endOffset: 72,
            tokens: tokens,
          ),
          const StoredReaderSentence(
            id: 'empty-sentence',
            paragraphId: 'p1',
            ordinal: 1,
            text: '123，。',
            startOffset: 73,
            endOffset: 78,
            tokens: [],
          ),
        ],
      );
  @override
  Future<void> recoverInterruptedImports() async {}
  @override
  Future<void> saveProgress(ReadingLocator locator, double progress) async =>
      saved.add((locator, progress));
  @override
  Stream<List<DocumentSummary>> watchDocuments() => const Stream.empty();
}

class _NoopLocalData implements LocalDataProvider {
  @override
  Future<({Map<String, Object?> data, int updatedAt})> collect() async =>
      (data: const <String, Object?>{}, updatedAt: 0);

  @override
  Future<void> apply(Map<String, Object?> data, int updatedAt) async {}
}
