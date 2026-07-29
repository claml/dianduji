import 'package:flutter/material.dart';

import '../../dictionary/presentation/translation_detail.dart';
import '../../dictionary/presentation/translation_view_model.dart';
import '../../phrases/domain/phrase_recognizer.dart';
import 'widgets/token_text.dart';

export 'widgets/token_text.dart' show ReaderToken;

class ReaderSentence {
  const ReaderSentence({required this.id, required this.tokens});

  final String id;
  final List<ReaderToken> tokens;
}

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({
    required this.title,
    required this.sentences,
    this.selectedTokenId,
    this.translationState,
    this.onTokenTap,
    this.onCloseTranslation,
    this.fontSize = 16,
    this.lineHeight = 1.6,
    this.sentenceKeyFor,
    this.scrollController,
    this.tokenKeyFor,
    this.onSavePhrase,
    super.key,
  });

  final String title;
  final List<ReaderSentence> sentences;
  final String? selectedTokenId;
  final TranslationState? translationState;
  final void Function(ReaderSentence sentence, ReaderToken token)? onTokenTap;
  final VoidCallback? onCloseTranslation;
  final double fontSize;
  final double lineHeight;
  final Key? Function(String sentenceId)? sentenceKeyFor;
  final ScrollController? scrollController;
  final Key? Function(String tokenId)? tokenKeyFor;
  final Future<void> Function(PhraseMatch phrase)? onSavePhrase;

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  String? _selectedTokenId;

  String? get _activeTokenId => widget.selectedTokenId ?? _selectedTokenId;

  ReaderToken? get _selectedToken {
    for (final sentence in widget.sentences) {
      for (final token in sentence.tokens) {
        if (token.id == _activeTokenId) return token;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: '阅读设置',
            onPressed: () {},
            icon: const Icon(Icons.text_fields_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 600) {
            return _tabletLayout();
          }
          return _phoneLayout(constraints.maxHeight);
        },
      ),
    );
  }

  Widget _tabletLayout() {
    final selected = _selectedToken;
    return Row(
      children: [
        Expanded(child: _article()),
        if (selected != null) ...[
          const VerticalDivider(width: 1),
          SizedBox(
            key: const Key('translation-side-pane'),
            width: 360,
            child: TranslationDetail(state: widget.translationState, word: selected.surface, onClose: _close, onSavePhrase: widget.onSavePhrase),
          ),
        ],
      ],
    );
  }

  Widget _phoneLayout(double height) {
    final selected = _selectedToken;
    return Stack(
      children: [
        Positioned.fill(
          bottom: selected == null ? 24 : height * 0.4,
          child: _article(),
        ),
        if (selected == null)
          const Positioned(
            key: Key('reader-progress'),
            left: 20,
            right: 20,
            bottom: 12,
            child: LinearProgressIndicator(value: 0.2, minHeight: 4),
          )
        else
          Positioned(
            key: const Key('translation-bottom-sheet'),
            left: 0,
            right: 0,
            bottom: 0,
            height: height * 0.4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: TranslationDetail(state: widget.translationState, word: selected.surface, onClose: _close, onSavePhrase: widget.onSavePhrase),
            ),
          ),
      ],
    );
  }

  Widget _article() {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView.separated(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 56),
      itemCount: widget.sentences.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final sentence = widget.sentences[index];
        final selectedSentence = sentence.tokens.any(
          (token) => token.id == _activeTokenId,
        );
        return AnimatedContainer(
          key: widget.sentenceKeyFor?.call(sentence.id),
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: selectedSentence
                ? colorScheme.primary.withValues(alpha: 0.05)
                : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final token in sentence.tokens)
                TokenText(
                  token: token,
                  selected: token.id == _activeTokenId,
                  onTap: () {
                    widget.onTokenTap?.call(sentence, token);
                    if (widget.selectedTokenId == null) {
                      setState(() => _selectedTokenId = token.id);
                    }
                  },
                  style: TextStyle(fontSize: widget.fontSize, height: widget.lineHeight),
                  widgetKey: widget.tokenKeyFor?.call(token.id),
                ),
            ],
          ),
        );
      },
    );
  }

  void _close() {
    widget.onCloseTranslation?.call();
    if (widget.selectedTokenId == null) setState(() => _selectedTokenId = null);
  }
}
