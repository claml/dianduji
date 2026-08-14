import 'package:flutter/material.dart';

import '../../dictionary/presentation/translation_detail.dart';
import '../../dictionary/presentation/translation_view_model.dart';
import '../../dictionary/domain/user_dictionary_repository.dart';
import '../../documents/domain/document_models.dart';
import '../../phrases/domain/phrase_recognizer.dart';
import '../data/reader_card_preferences.dart';
import '../domain/pdf_reader_extras.dart';
import '../domain/reader_selection.dart';
import 'reader_chrome_controller.dart';
import 'widgets/adaptive_translation_surface.dart';
import 'widgets/reader_top_bar.dart';
import 'widgets/reflow_document_view.dart';
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
    this.blocks = const [],
    this.document,
    this.selection,
    this.selectedTokenId,
    this.translationState,
    this.onTokenTap,
    this.onStoredTokenTap,
    this.onCloseTranslation,
    this.fontSize = 16,
    this.lineHeight = 1.6,
    this.sentenceKeyFor,
    this.scrollController,
    this.tokenKeyFor,
    this.onSavePhrase,
    this.onAddManualDefinition,
    this.onTranslateSentence,
    this.onNavigateBack,
    this.onSettings,
    this.chromeController,
    this.cardPreferences = ReaderCardPreferences.defaults,
    this.onCardPreferencesChanged,
    this.pdfExtras,
    this.onPdfPageJump,
    super.key,
  });

  final String title;
  final List<ReaderSentence> sentences;
  final List<StoredReaderBlock> blocks;
  final Widget? document;
  final ReaderSelection? selection;
  final String? selectedTokenId;
  final TranslationState? translationState;
  final void Function(ReaderSentence sentence, ReaderToken token)? onTokenTap;
  final void Function(StoredReaderSentence sentence, StoredReaderToken token)?
  onStoredTokenTap;
  final VoidCallback? onCloseTranslation;
  final double fontSize;
  final double lineHeight;
  final Key? Function(String sentenceId)? sentenceKeyFor;
  final ScrollController? scrollController;
  final Key? Function(String tokenId)? tokenKeyFor;
  final Future<void> Function(PhraseMatch phrase)? onSavePhrase;
  final Future<void> Function(ManualDictionaryEntry entry)?
  onAddManualDefinition;

  /// Translates the whole current sentence explicitly; hidden when null.
  final VoidCallback? onTranslateSentence;
  final Future<void> Function()? onNavigateBack;
  final VoidCallback? onSettings;
  final ReaderChromeController? chromeController;
  final ReaderCardPreferences cardPreferences;
  final ValueChanged<ReaderCardPreferences>? onCardPreferencesChanged;

  /// PDF reading extras (outline + page indicator); null for reflow docs.
  final PdfReaderExtras? pdfExtras;

  /// Jumps the PDF viewer to a page number.
  final ValueChanged<int>? onPdfPageJump;

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  String? _selectedTokenId;
  late final ReaderChromeController _chromeController;
  late final bool _ownsChromeController;

  @override
  void initState() {
    super.initState();
    _ownsChromeController = widget.chromeController == null;
    _chromeController = widget.chromeController ?? ReaderChromeController();
  }

  @override
  void dispose() {
    if (_ownsChromeController) _chromeController.dispose();
    super.dispose();
  }

  String? get _activeTokenId => widget.selectedTokenId ?? _selectedTokenId;

  ReaderToken? get _selectedToken {
    for (final sentence in widget.sentences) {
      for (final token in sentence.tokens) {
        if (token.id == _activeTokenId) return token;
      }
    }
    return null;
  }

  String? get _selectedSurface =>
      widget.selection?.surface ?? _selectedToken?.surface;

  @override
  Widget build(BuildContext context) {
    final pdfExtras = widget.pdfExtras;
    final documentSurface = AdaptiveTranslationSurface(
      visible: _selectedSurface != null,
      document: widget.document ?? _article(),
      translation: _selectedSurface == null
          ? const SizedBox.shrink()
          : TranslationDetail(
              state: widget.translationState,
              word: _selectedSurface,
              onClose: _close,
              onSavePhrase: widget.onSavePhrase,
              onAddManualDefinition: widget.onAddManualDefinition,
              onTranslateSentence: widget.onTranslateSentence,
            ),
      preferences: widget.cardPreferences,
      onPreferencesChanged:
          widget.onCardPreferencesChanged ?? _ignorePreferences,
      topExclusion: readerToolbarExclusionHeight(context),
      idleOverlay: const Positioned(
        key: Key('reader-progress'),
        left: 20,
        right: 20,
        bottom: 12,
        child: LinearProgressIndicator(value: 0.2, minHeight: 4),
      ),
    );
    return Scaffold(
      body: AnimatedBuilder(
        animation: _chromeController,
        child: documentSurface,
        builder: (context, child) => Stack(
          children: [
            Positioned.fill(child: child!),
            ReaderTopBar(
              title: widget.title,
              visible: _chromeController.visible,
              onBack: widget.onNavigateBack,
              onReveal: _chromeController.reveal,
              onSettings: widget.onSettings,
              onOutline: pdfExtras != null && pdfExtras.hasOutline
                  ? () => _openOutline(context, pdfExtras)
                  : null,
            ),
            if (pdfExtras != null && widget.onPdfPageJump != null)
              _PageIndicator(
                extras: pdfExtras,
                onTap: () => _openPageJump(context, pdfExtras),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openOutline(
    BuildContext context,
    PdfReaderExtras extras,
  ) async {
    final target = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                '目录',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
            for (final entry in extras.outline)
              ListTile(
                key: Key('outline-entry-${entry.pageNumber}'),
                dense: true,
                contentPadding: EdgeInsets.only(
                  left: 16.0 + entry.depth * 16,
                  right: 16,
                ),
                title: Text(entry.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Text(
                  '${entry.pageNumber}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () => Navigator.pop(sheetContext, entry.pageNumber),
              ),
          ],
        ),
      ),
    );
    if (target != null && context.mounted) {
      widget.onPdfPageJump?.call(target);
    }
  }

  Future<void> _openPageJump(
    BuildContext context,
    PdfReaderExtras extras,
  ) async {
    final controller = TextEditingController(
      text: extras.currentPage.toString(),
    );
    final target = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('跳转到页码'),
        content: TextField(
          key: const Key('page-jump-input'),
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '1 - ${extras.pageCount}',
            suffixText: '/ ${extras.pageCount}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final page = int.tryParse(controller.text.trim());
              Navigator.pop(dialogContext, page);
            },
            child: const Text('跳转'),
          ),
        ],
      ),
    );
    if (target != null &&
        target >= 1 &&
        target <= extras.pageCount &&
        context.mounted) {
      widget.onPdfPageJump?.call(target);
    }
  }

  Widget _article() {
    if (widget.blocks.isNotEmpty && widget.onStoredTokenTap != null) {
      return _watchReflowScroll(
        Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.paddingOf(context).top + kToolbarHeight,
          ),
          child: ReflowDocumentView(
            blocks: widget.blocks,
            selectedTokenId: _activeTokenId,
            fontSize: widget.fontSize,
            lineHeight: widget.lineHeight,
            scrollController: widget.scrollController,
            sentenceKeyFor: widget.sentenceKeyFor,
            tokenKeyFor: widget.tokenKeyFor,
            onTokenTap: widget.onStoredTokenTap!,
          ),
        ),
      );
    }
    final colorScheme = Theme.of(context).colorScheme;
    return _watchReflowScroll(
      ListView.separated(
        controller: widget.scrollController,
        padding: EdgeInsets.fromLTRB(
          24,
          MediaQuery.paddingOf(context).top + kToolbarHeight + 24,
          24,
          56,
        ),
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
                    style: TextStyle(
                      fontSize: widget.fontSize,
                      height: widget.lineHeight,
                    ),
                    widgetKey: widget.tokenKeyFor?.call(token.id),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _watchReflowScroll(Widget child) {
    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (notification) {
        _chromeController.handleContentScroll(
          notification.scrollDelta ?? 0,
          atTop:
              notification.metrics.pixels <=
              notification.metrics.minScrollExtent,
        );
        return false;
      },
      child: child,
    );
  }

  void _close() {
    widget.onCloseTranslation?.call();
    if (widget.selectedTokenId == null) setState(() => _selectedTokenId = null);
  }
}

void _ignorePreferences(ReaderCardPreferences _) {}

/// Bottom-center page indicator for the PDF reader; tapping it opens the
/// page-jump dialog.
class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.extras, required this.onTap});

  final PdfReaderExtras extras;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 20,
      child: Center(
        child: AnimatedBuilder(
          animation: extras,
          builder: (context, child) => Material(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
            elevation: 3,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              key: const Key('reader-page-indicator'),
              borderRadius: BorderRadius.circular(20),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  '${extras.currentPage} / ${extras.pageCount}',
                  key: const Key('reader-page-label'),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
