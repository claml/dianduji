import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../phrases/domain/phrase_type.dart';
import '../data/csv_export_service.dart';
import '../data/learning_repository.dart';
import 'learning_controllers.dart';

class VocabularyPage extends ConsumerStatefulWidget {
  const VocabularyPage({super.key});

  @override
  ConsumerState<VocabularyPage> createState() => _VocabularyPageState();
}

class _VocabularyPageState extends ConsumerState<VocabularyPage> {
  String? _selectedLemma;

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(vocabularyControllerProvider);
    final isWide = MediaQuery.sizeOf(context).width >= 600;
    final selected = controller.entries
        .where((entry) => entry.lemma == _selectedLemma)
        .firstOrNull;
    return Scaffold(
      appBar: AppBar(
        title: const Text('生词本'),
        actions: [
          IconButton(
            tooltip: '导出 CSV',
            onPressed: controller.entries.isEmpty
                ? null
                : () => _export(context, controller),
            icon: const Icon(Icons.ios_share_rounded),
          ),
          PopupMenuButton<VocabularySort>(
            tooltip: '排序',
            initialValue: controller.query.sort,
            onSelected: controller.sort,
            itemBuilder: (context) => VocabularySort.values
                .map(
                  (sort) =>
                      PopupMenuItem(value: sort, child: Text(_sortLabel(sort))),
                )
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SearchBar(
              hintText: '搜索单词或中文释义',
              leading: const Icon(Icons.search_rounded),
              onChanged: controller.search,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: VocabularyFilter.values
                  .map(
                    (filter) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 48),
                        child: ChoiceChip(
                          label: Text(_filterLabel(filter)),
                          selected: controller.query.filter == filter,
                          onSelected: (_) => controller.filter(filter),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.error != null) {
                  return _LearningLoadError(
                    message: '加载生词失败',
                    onRetry: controller.retry,
                  );
                }
                final list = _VocabularyList(
                  entries: controller.entries,
                  onSelected: (entry) {
                    if (isWide) {
                      setState(() => _selectedLemma = entry.lemma);
                    } else {
                      _showVocabularySheet(context, entry.lemma);
                    }
                  },
                );
                if (!isWide) return list;
                return Row(
                  children: [
                    Expanded(child: list),
                    const VerticalDivider(width: 1),
                    SizedBox(
                      width: 340,
                      child: selected == null
                          ? const Center(child: Text('选择一个生词查看详情'))
                          : VocabularyDetail(
                              key: const ValueKey('vocabulary-detail-pane'),
                              entry: selected,
                              controller: controller,
                              onDeleted: () =>
                                  setState(() => _selectedLemma = null),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '添加生词',
        onPressed: () => _addVocabulary(context, controller),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _export(
    BuildContext context,
    VocabularyController controller,
  ) async {
    final result = await controller.exportCsv();
    if (!context.mounted || result is CsvExportCancelled) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('CSV 已导出')));
  }

  Future<void> _addVocabulary(
    BuildContext context,
    VocabularyController controller,
  ) async {
    final word = TextEditingController();
    final definition = TextEditingController();
    var error = '';
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('手动添加生词'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: word,
                decoration: const InputDecoration(labelText: '单词'),
              ),
              TextField(
                controller: definition,
                decoration: const InputDecoration(labelText: '中文释义'),
              ),
              if (error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    error,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                if (word.text.trim().isEmpty ||
                    definition.text.trim().isEmpty) {
                  setDialogState(() => error = '单词和释义不能为空');
                  return;
                }
                try {
                  await controller.add(
                    ManualVocabularyDraft(
                      word: word.text,
                      definition: definition.text,
                    ),
                  );
                } on StateError {
                  setDialogState(() => error = '该单词已存在');
                  return;
                }
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
    word.dispose();
    definition.dispose();
  }

  Future<void> _showVocabularySheet(BuildContext context, String lemma) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) => SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.5,
            child: _VocabularyDetailSheet(
              lemma: lemma,
              onDeleted: () => Navigator.pop(sheetContext),
            ),
          ),
        ),
      );
}

class _VocabularyDetailSheet extends ConsumerWidget {
  const _VocabularyDetailSheet({required this.lemma, required this.onDeleted});

  final String lemma;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(vocabularyControllerProvider);
    final entry = controller.entries
        .where((candidate) => candidate.lemma == lemma)
        .firstOrNull;
    if (entry == null) return const Center(child: Text('该生词已不在当前列表'));
    return VocabularyDetail(
      entry: entry,
      controller: controller,
      onDeleted: onDeleted,
    );
  }
}

class _VocabularyList extends StatelessWidget {
  const _VocabularyList({required this.entries, required this.onSelected});

  final List<VocabularyListItem> entries;
  final ValueChanged<VocabularyListItem> onSelected;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const Center(child: Text('还没有生词'));
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      itemCount: entries.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return ListTile(
          minVerticalPadding: 12,
          title: Text(entry.displayWord),
          subtitle: Text(entry.definition),
          trailing: Text('查询 ${entry.lookupCount} 次'),
          onTap: () => onSelected(entry),
        );
      },
    );
  }
}

class VocabularyDetail extends StatelessWidget {
  const VocabularyDetail({
    required this.entry,
    required this.controller,
    required this.onDeleted,
    super.key,
  });

  final VocabularyListItem entry;
  final VocabularyController controller;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry.displayWord,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        if (entry.phonetic.isNotEmpty) Text(entry.phonetic),
        if (entry.partOfSpeech.isNotEmpty) Text(entry.partOfSpeech),
        const SizedBox(height: 12),
        Text(entry.definition),
        if (entry.context.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(entry.context),
        ],
        const SizedBox(height: 12),
        Text(
          entry.sourceAvailability == SourceAvailability.deleted
              ? '原文档已删除'
              : entry.sourceTitle,
        ),
        const SizedBox(height: 16),
        DropdownButton<VocabularyProficiency>(
          value: entry.proficiency,
          isExpanded: true,
          items: VocabularyProficiency.values
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text(_proficiencyLabel(value)),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              controller.setProficiency(entry.lemma, value);
            }
          },
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _deleteVocabulary(context),
            icon: const Icon(Icons.delete_outline),
            label: const Text('删除生词'),
          ),
        ),
      ],
    ),
  );

  Future<void> _deleteVocabulary(BuildContext context) async {
    final confirmed = await _confirmDelete(context, title: '删除这个生词？');
    if (!confirmed) return;
    await controller.delete(entry.lemma);
    if (!context.mounted) return;
    onDeleted();
  }
}

class PhraseBookPage extends ConsumerStatefulWidget {
  const PhraseBookPage({super.key});

  @override
  ConsumerState<PhraseBookPage> createState() => _PhraseBookPageState();
}

class _PhraseBookPageState extends ConsumerState<PhraseBookPage> {
  String? _selectedPhraseKey;

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(phraseBookControllerProvider);
    final isWide = MediaQuery.sizeOf(context).width >= 600;
    final selected = controller.entries
        .where((entry) => entry.phraseKey == _selectedPhraseKey)
        .firstOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('短语本')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SearchBar(
              hintText: '搜索短语或中文释义',
              leading: const Icon(Icons.search_rounded),
              onChanged: controller.search,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: <PhraseType?>[null, ...PhraseType.values]
                  .map(
                    (type) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 48),
                        child: ChoiceChip(
                          label: Text(_phraseTypeLabel(type)),
                          selected: controller.query.type == type,
                          onSelected: (_) => controller.filter(type),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.error != null) {
                  return _LearningLoadError(
                    message: '加载短语失败',
                    onRetry: controller.retry,
                  );
                }
                final list = _PhraseList(
                  entries: controller.entries,
                  onSelected: (entry) {
                    if (isWide) {
                      setState(() => _selectedPhraseKey = entry.phraseKey);
                    } else {
                      _showPhraseSheet(context, entry.phraseKey);
                    }
                  },
                );
                if (!isWide) return list;
                return Row(
                  children: [
                    Expanded(child: list),
                    const VerticalDivider(width: 1),
                    SizedBox(
                      width: 340,
                      child: selected == null
                          ? const Center(child: Text('选择一个短语查看详情'))
                          : PhraseDetail(
                              key: const ValueKey('phrase-detail-pane'),
                              entry: selected,
                              controller: controller,
                              onDeleted: () =>
                                  setState(() => _selectedPhraseKey = null),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPhraseSheet(BuildContext context, String phraseKey) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) => SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.5,
            child: _PhraseDetailSheet(
              phraseKey: phraseKey,
              onDeleted: () => Navigator.pop(sheetContext),
            ),
          ),
        ),
      );
}

class _PhraseDetailSheet extends ConsumerWidget {
  const _PhraseDetailSheet({required this.phraseKey, required this.onDeleted});

  final String phraseKey;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(phraseBookControllerProvider);
    final entry = controller.entries
        .where((candidate) => candidate.phraseKey == phraseKey)
        .firstOrNull;
    if (entry == null) return const Center(child: Text('该短语已不在当前列表'));
    return PhraseDetail(
      entry: entry,
      controller: controller,
      onDeleted: onDeleted,
    );
  }
}

class _PhraseList extends StatelessWidget {
  const _PhraseList({required this.entries, required this.onSelected});

  final List<SavedPhraseListItem> entries;
  final ValueChanged<SavedPhraseListItem> onSelected;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const Center(child: Text('还没有收藏短语'));
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      itemCount: entries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Card.outlined(
          child: ListTile(
            minVerticalPadding: 12,
            title: Text(entry.surface),
            subtitle: Text(entry.meaning),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => onSelected(entry),
          ),
        );
      },
    );
  }
}

class _LearningLoadError extends StatelessWidget {
  const _LearningLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: FilledButton(onPressed: onRetry, child: const Text('重试')),
        ),
      ],
    ),
  );
}

class PhraseDetail extends StatelessWidget {
  const PhraseDetail({
    required this.entry,
    required this.controller,
    required this.onDeleted,
    super.key,
  });

  final SavedPhraseListItem entry;
  final PhraseBookController controller;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(entry.surface, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(entry.meaning),
        const SizedBox(height: 12),
        Text(_phraseTypeLabel(entry.type)),
        if (entry.context.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(entry.context),
        ],
        const SizedBox(height: 12),
        Text(
          entry.sourceAvailability == SourceAvailability.deleted
              ? '原文档已删除'
              : entry.sourceTitle,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _deletePhrase(context),
            icon: const Icon(Icons.delete_outline),
            label: const Text('删除短语'),
          ),
        ),
      ],
    ),
  );

  Future<void> _deletePhrase(BuildContext context) async {
    final confirmed = await _confirmDelete(context, title: '删除这个短语？');
    if (!confirmed) return;
    await controller.delete(entry.phraseKey);
    if (!context.mounted) return;
    onDeleted();
  }
}

Future<bool> _confirmDelete(
  BuildContext context, {
  required String title,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: const Text('删除后无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('确认删除'),
          ),
        ],
      ),
    ) ??
    false;

String _filterLabel(VocabularyFilter filter) => switch (filter) {
  VocabularyFilter.all => '全部',
  VocabularyFilter.known => '认识',
  VocabularyFilter.vague => '模糊',
  VocabularyFilter.unknown => '陌生',
};

String _sortLabel(VocabularySort sort) => switch (sort) {
  VocabularySort.recent => '最近查询',
  VocabularySort.alphabetical => '字母顺序',
  VocabularySort.lookupCount => '查询次数',
};

String _proficiencyLabel(VocabularyProficiency value) => switch (value) {
  VocabularyProficiency.known => '认识',
  VocabularyProficiency.vague => '模糊',
  VocabularyProficiency.unknown => '陌生',
};

String _phraseTypeLabel(PhraseType? type) => switch (type) {
  null => '全部',
  PhraseType.phrasalVerb => '短语动词',
  PhraseType.prepositionalPhrase => '介词短语',
  PhraseType.collocation => '搭配',
  PhraseType.idiom => '习语',
};
