import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../dictionary/presentation/translation_view_model.dart';
import '../../settings/data/reading_settings.dart';
import 'reader_controller.dart';
import 'reader_screen.dart';

class ReaderPage extends ConsumerStatefulWidget {
  const ReaderPage({required this.documentId, this.controller, super.key});
  final String documentId;
  final ReaderController? controller;
  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> with WidgetsBindingObserver {
  late final ReaderController _controller;
  late final bool _ownsController;
  final _scrollController = ScrollController();
  final _sentenceKeys = <String, GlobalKey>{};
  var _opened = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? ReaderController(
      documents: ref.read(documentRepositoryProvider),
      translation: TranslationViewModel(
        dictionary: ref.read(dictionaryLookupProvider),
        learning: ref.read(learningRepositoryProvider),
        phraseRecognizer: ref.read(phraseRecognizerProvider),
      ),
      settings: ReadingSettings(),
    );
    _controller.addListener(_changed);
    _scrollController.addListener(_recordPosition);
    _open();
  }

  Future<void> _open() async {
    await _controller.open(widget.documentId);
    if (!mounted) return;
    setState(() => _opened = true);
    final id = _controller.state.restoredSentenceId;
    if (id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final item = _sentenceKeys[id]?.currentContext;
        if (item != null) Scrollable.ensureVisible(item, alignment: 0.15);
      });
    }
  }

  void _changed() { if (mounted) setState(() {}); }

  void _recordPosition() {
    final state = _controller.state;
    if (state.sentences.isEmpty || !_scrollController.hasClients) return;
    var sentence = state.sentences.first;
    var closestDistance = double.infinity;
    for (final candidate in state.sentences) {
      final box = _sentenceKeys[candidate.id]?.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final distance = (box.localToGlobal(Offset.zero).dy - 96).abs();
      if (distance < closestDistance) {
        closestDistance = distance;
        sentence = candidate;
      }
    }
    final progress = _scrollController.position.maxScrollExtent == 0
        ? 0.0 : _scrollController.position.pixels / _scrollController.position.maxScrollExtent;
    _controller.updateReadingPosition(sentenceId: sentence.id, localOffset: 0, progress: progress);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) _controller.forceSave();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(readingSettingsProvider).valueOrNull ?? ReadingSettings();
    _controller.updateSettings(settings);
    final state = _controller.state;
    if (!_opened || state.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (state.error != null) return Scaffold(body: Center(child: Text('打开文档失败：${state.error}')));
    return PopScope(
      onPopInvokedWithResult: (_, _) => _controller.forceSave(),
      child: ReaderScreen(
        title: state.document?.title ?? '阅读器',
        sentences: state.sentences.map((sentence) => ReaderSentence(
          id: sentence.id,
          tokens: sentence.tokens.map((token) => ReaderToken(id: token.id, surface: token.surface)).toList(growable: false),
        )).toList(growable: false),
        selectedTokenId: state.selectedTokenId,
        translationState: _controller.translation.state,
        fontSize: settings.fontSize,
        lineHeight: settings.lineHeight,
        sentenceKeyFor: (id) => _sentenceKeys.putIfAbsent(id, GlobalKey.new),
        scrollController: _scrollController,
        onTokenTap: (sentence, token) => _controller.selectToken(sentenceId: sentence.id, tokenId: token.id),
        onCloseTranslation: _controller.closeTranslation,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController..removeListener(_recordPosition)..dispose();
    _controller.removeListener(_changed);
    _controller.forceSave();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }
}
