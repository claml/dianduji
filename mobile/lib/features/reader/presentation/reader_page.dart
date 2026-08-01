import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../dictionary/presentation/translation_view_model.dart';
import '../../documents/domain/document_models.dart';
import '../../settings/data/reading_settings.dart';
import 'reader_controller.dart';
import 'reader_screen.dart';

class ReaderPage extends ConsumerStatefulWidget {
  const ReaderPage({
    required this.documentId,
    this.controller,
    this.restoreItem,
    super.key,
  });
  final String documentId;
  final ReaderController? controller;
  final Future<void> Function(BuildContext target)? restoreItem;
  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage>
    with WidgetsBindingObserver {
  late final ReaderController _controller;
  late final bool _ownsController;
  final _scrollController = ScrollController();
  final _sentenceKeys = <String, GlobalKey>{};
  final _tokenKeys = <String, GlobalKey>{};
  var _opened = false;
  var _positionScheduled = false;
  var _restoringPosition = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        ReaderController(
          documents: ref.read(documentRepositoryProvider),
          translation: TranslationViewModel(
            dictionary: ref.read(dictionaryLookupProvider),
            learning: ref.read(learningRepositoryProvider),
            phraseRecognizer: ref.read(phraseRecognizerProvider),
          ),
          settings: ReadingSettings(autoSaveVocabulary: false),
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
      _restoringPosition = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final sentence = _controller.state.sentences
            .where((candidate) => candidate.id == id)
            .firstOrNull;
        final token = sentence == null
            ? null
            : _tokenForOffset(sentence, _controller.state.restoredLocalOffset);
        final item = token == null
            ? _sentenceKeys[id]?.currentContext
            : _tokenKeys[token.id]?.currentContext;
        try {
          if (item != null) await _restoreItem(item);
        } on Object {
          // A failed programmatic calibration must not permanently suppress user saves.
        } finally {
          if (!mounted) {
            _restoringPosition = false;
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _restoringPosition = false;
            });
          }
        }
      });
    }
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  void _recordPosition() {
    if (_restoringPosition || _positionScheduled) return;
    _positionScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _positionScheduled = false;
      if (mounted && !_restoringPosition) _writePosition();
    });
  }

  void _writePosition() {
    final state = _controller.state;
    if (state.sentences.isEmpty || !_scrollController.hasClients) return;
    var sentence = state.sentences.first;
    var closestDistance = double.infinity;
    for (final candidate in state.sentences) {
      final box =
          _sentenceKeys[candidate.id]?.currentContext?.findRenderObject()
              as RenderBox?;
      if (box == null) continue;
      final distance = (box.localToGlobal(Offset.zero).dy - 96).abs();
      if (distance < closestDistance) {
        closestDistance = distance;
        sentence = candidate;
      }
    }
    final offset = _nearestTokenOffset(sentence);
    final token = offset == null ? null : _tokenForOffset(sentence, offset);
    final progress = _scrollController.position.maxScrollExtent == 0
        ? 0.0
        : _scrollController.position.pixels /
              _scrollController.position.maxScrollExtent;
    _controller.updateReadingPosition(
      sentenceId: sentence.id,
      localOffset: token?.startOffset ?? 0,
      progress: progress,
    );
  }

  StoredReaderToken? _tokenForOffset(
    StoredReaderSentence sentence,
    int offset,
  ) {
    if (sentence.tokens.isEmpty) return null;
    return sentence.tokens.lastWhere(
      (token) => token.startOffset <= offset,
      orElse: () => sentence.tokens.first,
    );
  }

  Future<void> _restoreItem(BuildContext item) {
    return widget.restoreItem?.call(item) ??
        Scrollable.ensureVisible(item, alignment: 0.15);
  }

  int? _nearestTokenOffset(StoredReaderSentence sentence) {
    if (sentence.tokens.isEmpty) return null;
    var nearest = sentence.tokens.first;
    var distance = double.infinity;
    for (final token in sentence.tokens) {
      final box =
          _tokenKeys[token.id]?.currentContext?.findRenderObject()
              as RenderBox?;
      if (box == null) continue;
      final candidateDistance = (box.localToGlobal(Offset.zero).dy - 96).abs();
      if (candidateDistance < distance) {
        distance = candidateDistance;
        nearest = token;
      }
    }
    return nearest.startOffset;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _controller.forceSave();
    }
  }

  @override
  Widget build(BuildContext context) {
    final persisted = ref.watch(readingSettingsProvider);
    if (persisted.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final settings = persisted.settings;
    if (settings == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('设置加载失败'),
              FilledButton(
                onPressed: ref.read(persistedSettingsControllerProvider).retry,
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }
    _controller.updateSettings(settings);
    final state = _controller.state;
    if (!_opened || state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (state.error != null) {
      return Scaffold(body: Center(child: Text('打开文档失败：${state.error}')));
    }
    return PopScope(
      onPopInvokedWithResult: (_, _) => _controller.forceSave(),
      child: ReaderScreen(
        title: state.document?.title ?? '阅读器',
        blocks: state.document?.blocks ?? const [],
        sentences: state.sentences
            .map(
              (sentence) => ReaderSentence(
                id: sentence.id,
                tokens: sentence.tokens
                    .map(
                      (token) =>
                          ReaderToken(id: token.id, surface: token.surface),
                    )
                    .toList(growable: false),
              ),
            )
            .toList(growable: false),
        selectedTokenId: state.selectedTokenId,
        translationState: _controller.translation.state,
        fontSize: settings.fontSize,
        lineHeight: settings.lineHeight,
        sentenceKeyFor: (id) => _sentenceKeys.putIfAbsent(id, GlobalKey.new),
        tokenKeyFor: (id) => _tokenKeys.putIfAbsent(id, GlobalKey.new),
        scrollController: _scrollController,
        onTokenTap: (sentence, token) =>
            _controller.selectToken(sentenceId: sentence.id, tokenId: token.id),
        onStoredTokenTap: (sentence, token) => _controller.selectToken(
          sentenceId: sentence.id,
          tokenId: token.id,
        ),
        onCloseTranslation: _controller.closeTranslation,
        onSavePhrase: _controller.savePhrase,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController
      ..removeListener(_recordPosition)
      ..dispose();
    _controller.removeListener(_changed);
    _controller.forceSave();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }
}
