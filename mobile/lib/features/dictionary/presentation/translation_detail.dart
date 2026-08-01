import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/platform/android_pronunciation_service.dart';
import '../../../core/platform/pronunciation_service.dart';
import '../../phrases/domain/phrase_recognizer.dart';
import 'translation_view_model.dart';

class TranslationDetail extends StatefulWidget {
  const TranslationDetail({
    this.state,
    this.word,
    required this.onClose,
    this.onSavePhrase,
    this.pronunciation,
    super.key,
  });

  final TranslationState? state;
  final String? word;
  final VoidCallback onClose;
  final Future<void> Function(PhraseMatch phrase)? onSavePhrase;
  final PronunciationService? pronunciation;

  @override
  State<TranslationDetail> createState() => _TranslationDetailState();
}

class _TranslationDetailState extends State<TranslationDetail> {
  String? _feedback;
  late final PronunciationService _pronunciation =
      widget.pronunciation ?? AndroidPronunciationService();
  var _stopped = false;

  TranslationState get _state =>
      widget.state ??
      TranslationState(
        status: TranslationStatus.loading,
        surface: widget.word ?? '',
      );

  @override
  Widget build(BuildContext context) {
    final state = _state;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    state.surface,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Semantics(
                  label: '播放英语发音',
                  button: true,
                  child: IconButton(
                    tooltip: '发音',
                    onPressed: state.surface.isEmpty ? null : _speak,
                    icon: const Icon(Icons.volume_up_outlined),
                  ),
                ),
                IconButton(
                  tooltip: '关闭释义',
                  onPressed: _close,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(child: _body(state)),
            if (_feedback != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_feedback!, key: const Key('translation-feedback')),
              ),
          ],
        ),
      ),
    );
  }

  Widget _body(TranslationState state) => switch (state.status) {
    TranslationStatus.idle => const SizedBox.shrink(),
    TranslationStatus.loading => const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('本地词典查询中…'),
        SizedBox(height: 20),
        LinearProgressIndicator(),
      ],
    ),
    TranslationStatus.notFound => const Text('本地词典未收录'),
    TranslationStatus.failed => Text('查询失败：${state.errorMessage ?? '请稍后重试'}'),
    TranslationStatus.found => _found(state),
  };

  Widget _found(TranslationState state) {
    final entry = state.entry!;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        if (entry.phonetic.isNotEmpty) Text(entry.phonetic),
        if (entry.partOfSpeech.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(entry.partOfSpeech),
          ),
        if (entry.definitionChinese.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(entry.definitionChinese),
          ),
        if (state.phrases.isNotEmpty) ...[
          const Padding(padding: EdgeInsets.only(top: 18), child: Text('相关短语')),
          for (final phrase in state.phrases)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(phrase.surface),
              subtitle: Text(phrase.meaning),
              trailing: widget.onSavePhrase == null
                  ? null
                  : IconButton(
                      tooltip: '保存短语',
                      onPressed: () => _savePhrase(phrase),
                      icon: const Icon(Icons.bookmark_add_outlined),
                    ),
            ),
        ],
      ],
    );
  }

  Future<void> _speak() async {
    final result = await _pronunciation.speak(_state.surface);
    if (!mounted || result == PronunciationResult.spoken) return;
    setState(() => _feedback = '本机未安装英语语音');
  }

  Future<void> _savePhrase(PhraseMatch phrase) async {
    await widget.onSavePhrase!(phrase);
    if (mounted) setState(() => _feedback = '短语已保存');
  }

  void _close() {
    widget.onClose();
    unawaited(_stop());
  }

  Future<void> _stop() {
    if (_stopped) return Future.value();
    _stopped = true;
    return _pronunciation.stop();
  }

  @override
  void dispose() {
    unawaited(_stop());
    super.dispose();
  }
}
