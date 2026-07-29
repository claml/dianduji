import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../data/reading_settings.dart';

class PersistedSettingsPage extends ConsumerWidget {
  const PersistedSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(readingSettingsProvider);
    final settings = state.valueOrNull ?? ReadingSettings();

    Future<void> save(ReadingSettings value) =>
        ref.read(settingsRepositoryProvider).save(value);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('阅读外观', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SegmentedButton<ReaderTheme>(
            segments: const [
              ButtonSegment(value: ReaderTheme.day, label: Text('日间')),
              ButtonSegment(value: ReaderTheme.night, label: Text('夜间')),
              ButtonSegment(value: ReaderTheme.eyeCare, label: Text('护眼')),
            ],
            selected: {settings.theme},
            onSelectionChanged: (values) =>
                save(_copySettings(settings, theme: values.single)),
          ),
          const SizedBox(height: 16),
          Text('字号 ${settings.fontSize.round()}'),
          Slider(
            value: settings.fontSize,
            min: 12,
            max: 24,
            divisions: 12,
            label: settings.fontSize.round().toString(),
            onChanged: (value) =>
                save(_copySettings(settings, fontSize: value)),
          ),
          Text('行距 ${settings.lineHeight.toStringAsFixed(1)}'),
          Slider(
            value: settings.lineHeight,
            min: 1.4,
            max: 2,
            divisions: 6,
            label: settings.lineHeight.toStringAsFixed(1),
            onChanged: (value) =>
                save(_copySettings(settings, lineHeight: value)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('自动收录生词'),
            value: settings.autoSaveVocabulary,
            onChanged: (value) =>
                save(_copySettings(settings, autoSaveVocabulary: value)),
          ),
          const Divider(),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('隐私说明'),
            subtitle: Text('文档与查询均在本机离线处理'),
          ),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('开源许可证'),
            subtitle: Text('ECDICT MIT 等第三方许可证'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            minVerticalPadding: 12,
            title: const Text('清理可重建缓存'),
            subtitle: const Text('仅清理词典和解析缓存，不会删除文档或学习记录'),
            onTap: () => _confirmCacheCleanup(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCacheCleanup(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('清理缓存？'),
        content: const Text('不会删除文档、生词或短语。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('确认'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(cacheCleanupServiceProvider).clearRebuildableCaches();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('缓存已清理')));
  }
}

ReadingSettings _copySettings(
  ReadingSettings settings, {
  ReaderTheme? theme,
  double? fontSize,
  double? lineHeight,
  bool? autoSaveVocabulary,
}) => ReadingSettings(
  theme: theme ?? settings.theme,
  fontSize: fontSize ?? settings.fontSize,
  lineHeight: lineHeight ?? settings.lineHeight,
  autoSaveVocabulary: autoSaveVocabulary ?? settings.autoSaveVocabulary,
);
