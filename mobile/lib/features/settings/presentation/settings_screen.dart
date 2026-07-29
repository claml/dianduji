import 'package:flutter/material.dart';

import '../data/reading_settings.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({ReadingSettings? initial, this.onChanged, super.key})
    : initial = initial ?? ReadingSettings();

  final ReadingSettings initial;
  final ValueChanged<ReadingSettings>? onChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ReadingSettings _settings = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text('阅读外观', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SegmentedButton<ReaderTheme>(
            segments: const [
              ButtonSegment(value: ReaderTheme.day, label: Text('日间')),
              ButtonSegment(value: ReaderTheme.night, label: Text('夜间')),
              ButtonSegment(value: ReaderTheme.eyeCare, label: Text('护眼')),
            ],
            selected: {_settings.theme},
            onSelectionChanged: (selection) {
              _replace(theme: selection.single);
            },
          ),
          const SizedBox(height: 28),
          Text('字号 ${_settings.fontSize.round()}'),
          Slider(
            value: _settings.fontSize,
            min: 12,
            max: 24,
            divisions: 12,
            semanticFormatterCallback: (value) => '字号 ${value.round()}',
            onChanged: (value) => _replace(fontSize: value),
          ),
          const SizedBox(height: 12),
          Text('行距 ${_settings.lineHeight.toStringAsFixed(1)}'),
          Slider(
            value: _settings.lineHeight,
            min: 1.4,
            max: 2,
            divisions: 6,
            semanticFormatterCallback: (value) =>
                '行距 ${value.toStringAsFixed(1)}',
            onChanged: (value) => _replace(lineHeight: value),
          ),
          const Divider(height: 40),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('自动收录生词'),
            subtitle: const Text('点词查到释义后自动加入生词本'),
            value: _settings.autoSaveVocabulary,
            onChanged: (value) => _replace(autoSaveVocabulary: value),
          ),
          const Divider(height: 40),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.shield_outlined),
            title: Text('隐私说明'),
            subtitle: Text('文档与查询均在本机离线处理'),
          ),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.description_outlined),
            title: Text('开源许可证'),
            subtitle: Text('ECDICT MIT 等第三方许可'),
          ),
        ],
      ),
    );
  }

  void _replace({
    ReaderTheme? theme,
    double? fontSize,
    double? lineHeight,
    bool? autoSaveVocabulary,
  }) {
    setState(() {
      _settings = ReadingSettings(
        theme: theme ?? _settings.theme,
        fontSize: fontSize ?? _settings.fontSize,
        lineHeight: lineHeight ?? _settings.lineHeight,
        autoSaveVocabulary: autoSaveVocabulary ?? _settings.autoSaveVocabulary,
      );
    });
    widget.onChanged?.call(_settings);
  }
}
