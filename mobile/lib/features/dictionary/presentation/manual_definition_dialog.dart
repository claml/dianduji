import 'package:flutter/material.dart';

import '../domain/user_dictionary_repository.dart';

/// Dialog for writing a custom definition for a word the local dictionaries
/// do not know (proper nouns, abbreviations, context-specific senses).
/// Returns the filled entry, or null when cancelled.
Future<ManualDictionaryEntry?> showManualDefinitionDialog(
  BuildContext context, {
  required String surface,
  String phonetic = '',
  String partOfSpeech = '',
}) {
  return showDialog<ManualDictionaryEntry>(
    context: context,
    builder: (dialogContext) => _ManualDefinitionDialog(
      surface: surface,
      phonetic: phonetic,
      partOfSpeech: partOfSpeech,
    ),
  );
}

class _ManualDefinitionDialog extends StatefulWidget {
  const _ManualDefinitionDialog({
    required this.surface,
    required this.phonetic,
    required this.partOfSpeech,
  });

  final String surface;
  final String phonetic;
  final String partOfSpeech;

  @override
  State<_ManualDefinitionDialog> createState() =>
      _ManualDefinitionDialogState();
}

class _ManualDefinitionDialogState extends State<_ManualDefinitionDialog> {
  late final TextEditingController _surface = TextEditingController(
    text: widget.surface,
  );
  late final TextEditingController _phonetic = TextEditingController(
    text: widget.phonetic,
  );
  late final TextEditingController _partOfSpeech = TextEditingController(
    text: widget.partOfSpeech,
  );
  final _definitionEnglish = TextEditingController();
  final _definitionChinese = TextEditingController();
  var _saving = false;

  @override
  void dispose() {
    _surface.dispose();
    _phonetic.dispose();
    _partOfSpeech.dispose();
    _definitionEnglish.dispose();
    _definitionChinese.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加自定义释义'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('manual-surface'),
              controller: _surface,
              decoration: const InputDecoration(labelText: '单词 / 缩写'),
            ),
            TextField(
              key: const Key('manual-phonetic'),
              controller: _phonetic,
              decoration: const InputDecoration(labelText: '音标（可选）'),
            ),
            TextField(
              key: const Key('manual-pos'),
              controller: _partOfSpeech,
              decoration: const InputDecoration(labelText: '词性（可选）'),
            ),
            TextField(
              key: const Key('manual-english'),
              controller: _definitionEnglish,
              decoration: const InputDecoration(
                labelText: '英文释义（可选）',
              ),
            ),
            TextField(
              key: const Key('manual-chinese'),
              controller: _definitionChinese,
              decoration: const InputDecoration(
                labelText: '中文释义',
                hintText: '按当前语境的释义，如：专科名词、缩写含义',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          key: const Key('manual-save'),
          onPressed: _saving ? null : _save,
          child: const Text('收录'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final chinese = _definitionChinese.text.trim();
    if (chinese.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('中文释义不能为空')),
      );
      return;
    }
    setState(() => _saving = true);
    Navigator.pop(
      context,
      ManualDictionaryEntry(
        surface: _surface.text.trim(),
        phonetic: _phonetic.text.trim(),
        partOfSpeech: _partOfSpeech.text.trim(),
        definitionEnglish: _definitionEnglish.text.trim(),
        definitionChinese: chinese,
      ),
    );
  }
}
