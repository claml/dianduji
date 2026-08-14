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
                    state.displaySurface,
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
                    onPressed: state.displaySurface.isEmpty ? null : _speak,
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
    final entry = state.entry;
    final specialized = state.specializedTerm;
    final online = state.onlineResult;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        if (entry != null && entry.phonetic.isNotEmpty) Text(entry.phonetic),
        if (entry != null && entry.partOfSpeech.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(entry.partOfSpeech),
          ),
        if (entry != null && entry.definitionChinese.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(entry.definitionChinese),
          ),
        if (specialized != null) ...[
          _sectionTitle('专业释义'),
          Chip(
            label: Text(specialized.domain.label),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(specialized.definition),
          ),
        ],
        if (state.sentence.isNotEmpty) ...[
          _sectionTitle('原文'),
          Text(state.sentence),
        ],
        if (online != null && online.sentenceTranslation.isNotEmpty) ...[
          _sectionTitle('译文'),
          Text(online.sentenceTranslation),
        ],
        if (online != null && online.examples.isNotEmpty) ...[
          _sectionTitle('例句'),
          for (final example in online.examples)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(example.source),
                  if (example.translation.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        example.translation,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
        if (state.phrases.isNotEmpty) ...[
          _sectionTitle('相关短语'),
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
        _sectionTitle('来源'),
        Text(
          _sourceLabel(state),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 6),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  String _sourceLabel(TranslationState state) {
    final sources = <String>[];
    if (state.entry != null) {
      sources.add(state.fromUserDictionary ? '用户词典' : '通用词典');
    }
    if (state.specializedTerm != null) {
      sources.add('专业词典·${state.specializedTerm!.domain.label}');
    }
    if (state.onlineStatus == OnlineTranslationStatus.available &&
        state.onlineResult != null) {
      sources.add('在线翻译·${state.onlineResult!.sourceId}');
    }
    if (sources.isEmpty) sources.add('本地词典');
    return sources.join(' / ');
  }

  Future<void> _speak() async {
    final result = await _pronunciation.speak(_state.displaySurface);
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
