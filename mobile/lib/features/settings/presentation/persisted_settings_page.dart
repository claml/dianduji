import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/network/drift_online_translation_cache.dart';
import '../../sync/presentation/sync_section.dart';
import '../data/reading_settings.dart';
import 'persisted_settings_controller.dart';

class PersistedSettingsPage extends ConsumerWidget {
  const PersistedSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(readingSettingsProvider);
    final controller = ref.read(persistedSettingsControllerProvider);

    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('设置')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final settings = state.settings;
    if (settings == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('设置')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('设置加载失败'),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: controller.retry,
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (state.saveError != null) ...[
            Semantics(
              container: true,
              liveRegion: true,
              label: '设置保存失败，请重试',
              excludeSemantics: true,
              child: const Text('保存失败，请重试'),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: () => controller.retrySave().ignore(),
                child: const Text('重试保存'),
              ),
            ),
            const Divider(height: 32),
          ],
          Text('阅读外观', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          const Text(
            '字号和行距仅适用于 TXT/DOCX 重排阅读，PDF 保留原版式。',
            key: Key('reading-settings-scope-note'),
          ),
          const SizedBox(height: 12),
          SegmentedButton<ReaderTheme>(
            segments: const [
              ButtonSegment(value: ReaderTheme.day, label: Text('日间')),
              ButtonSegment(value: ReaderTheme.night, label: Text('夜间')),
              ButtonSegment(value: ReaderTheme.eyeCare, label: Text('护眼')),
            ],
            selected: {settings.theme},
            onSelectionChanged: (values) =>
                controller.updateTheme(values.single),
          ),
          const SizedBox(height: 16),
          Text('字号 ${settings.fontSize.round()}'),
          Slider(
            key: const Key('reading-font-size-slider'),
            value: settings.fontSize,
            min: 12,
            max: 24,
            divisions: 12,
            label: settings.fontSize.round().toString(),
            onChanged: controller.updateFontSize,
          ),
          Text('行距 ${settings.lineHeight.toStringAsFixed(1)}'),
          Slider(
            key: const Key('reading-line-height-slider'),
            value: settings.lineHeight,
            min: 1.4,
            max: 2,
            divisions: 6,
            label: settings.lineHeight.toStringAsFixed(1),
            onChanged: controller.updateLineHeight,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('自动收录生词'),
            value: settings.autoSaveVocabulary,
            onChanged: controller.updateAutoSaveVocabulary,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('在线翻译'),
            subtitle: const Text('本地未收录时联网查询，仅发送所点词与所在句子'),
            value: settings.onlineTranslationEnabled,
            onChanged: (value) => _toggleOnlineTranslation(
              context,
              ref,
              controller,
              value,
            ),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('隐私说明'),
            subtitle: const Text('文档与查询均在本机离线处理'),
            onTap: () => _showPrivacyDialog(context),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('开源许可证'),
            subtitle: const Text('ECDICT MIT 等第三方许可证'),
            onTap: () => _showLicensesDialog(context),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            minVerticalPadding: 12,
            title: const Text('清理可重建缓存'),
            subtitle: const Text('仅清理词典和解析缓存，不会删除文档或学习记录'),
            onTap: () => _confirmCacheCleanup(context, ref),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            minVerticalPadding: 12,
            title: const Text('清除在线翻译缓存'),
            subtitle: const Text('删除已缓存的在线翻译结果，不影响本地词典'),
            onTap: () => _confirmOnlineCacheCleanup(context, ref),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            minVerticalPadding: 12,
            title: const Text('词典更新中心'),
            subtitle: const Text('在线翻译过的新词经 AI 整理后存入用户词典，离线可用'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _openDictionaryUpdateCenter(context),
          ),
          const Divider(height: 32),
          const SyncSection(),
        ],
      ),
    );
  }

  Future<void> _openDictionaryUpdateCenter(BuildContext context) =>
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (sheetContext) => const _DictionaryUpdateCenterSheet(),
      );

  Future<void> _toggleOnlineTranslation(
    BuildContext context,
    WidgetRef ref,
    PersistedSettingsController controller,
    bool enable,
  ) async {
    final settings = ref.read(readingSettingsProvider).settings;
    if (settings == null) return;
    if (enable && !settings.onlineTranslationConsented) {
      final agreed = await _showOnlineConsentDialog(context);
      if (agreed != true) return;
      await controller.updateOnlineTranslationConsented(true);
    }
    await controller.updateOnlineTranslationEnabled(enable);
  }

  Future<bool?> _showOnlineConsentDialog(BuildContext context) =>
      showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('开启在线翻译'),
          content: const SingleChildScrollView(
            child: Text(
              '本地词典未收录时，将把所点击的单词或术语及其所在的单个句子'
              '发送至在线翻译服务。\n\n'
              '不会上传：文档全文、PDF 页面图像、文档标题、作者、文件路径、'
              '设备标识或阅读历史。\n\n'
              '可随时在设置中关闭，并可清除本地缓存。',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('同意并开启'),
            ),
          ],
        ),
      );

  Future<void> _confirmOnlineCacheCleanup(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('清除在线翻译缓存？'),
        content: const Text('不会删除文档、生词、短语或本地词典。'),
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

    try {
      final cache = DriftOnlineTranslationCache(ref.read(appDatabaseProvider));
      await cache.clear();
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('清除失败，请重试')));
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('在线翻译缓存已清除')));
  }

  Future<void> _showPrivacyDialog(BuildContext context) => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('隐私说明'),
      content: const SingleChildScrollView(
        child: Text(
          '本应用的所有功能均在本机离线完成：\n'
          '· 文档解析、词典查询、短语识别与学习记录不离开设备；\n'
          '· 不收集、不上传文档内容、查询记录或阅读历史；\n'
          '· 从其他应用分享的文档仅通过系统授权读取，并复制到应用私有目录后解析；\n'
          '· 应用不请求通讯录、定位、麦克风等无关权限。',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('知道了'),
        ),
      ],
    ),
  );

  Future<void> _showLicensesDialog(BuildContext context) => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('开源许可证'),
      content: const SingleChildScrollView(
        child: Text(
          '本应用基于以下开源组件构建：\n'
          '· ECDICT 英汉词典（MIT）\n'
          '· Flutter / Dart（BSD-3-Clause）\n'
          '· pdfrx PDF 引擎（BSD-3-Clause）\n'
          '· Riverpod、Drift、SQLite 等（MIT / 公有领域）\n'
          '完整清单见 docs/third-party-notices.md。',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('关闭'),
        ),
      ],
    ),
  );

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

    try {
      await ref.read(cacheCleanupServiceProvider).clearRebuildableCaches();
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('缓存清理失败，请重试')));
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('缓存已清理')));
  }
}

/// Bottom-sheet UI for the user-dictionary enrichment loop.
class _DictionaryUpdateCenterSheet extends ConsumerStatefulWidget {
  const _DictionaryUpdateCenterSheet();

  @override
  ConsumerState<_DictionaryUpdateCenterSheet> createState() =>
      _DictionaryUpdateCenterSheetState();
}

class _DictionaryUpdateCenterSheetState
    extends ConsumerState<_DictionaryUpdateCenterSheet> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(dictionaryUpdateCenterProvider).refresh(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final center = ref.watch(dictionaryUpdateCenterProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('词典更新中心', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '在线翻译过的新词会收集为候选词；AI 整理后写入用户词典，'
              '之后点读同词即可离线查询。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              '待整理候选词：${center.candidateCount} 个',
              key: const Key('dictionary-candidate-count'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (center.lastEnriched > 0) ...[
              const SizedBox(height: 8),
              Text(
                '上次整理：入库 ${center.lastConfirmed} 词，'
                '丢弃 ${center.lastDropped} 词',
                key: const Key('dictionary-enrich-summary'),
              ),
            ],
            if (center.error != null) ...[
              const SizedBox(height: 8),
              Text(
                center.error!,
                key: const Key('dictionary-enrich-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('dictionary-enrich-button'),
                onPressed: center.busy || !center.gatewayConfigured
                    ? null
                    : () => center.runEnrichment(),
                icon: center.busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(center.busy ? '正在整理…' : '一键整理并入库'),
              ),
            ),
            if (!center.gatewayConfigured) ...[
              const SizedBox(height: 8),
              Text(
                '未配置在线翻译网关地址，整理功能不可用。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
