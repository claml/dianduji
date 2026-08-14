import 'package:flutter/material.dart';

import '../domain/import_document_use_case.dart';

enum DocumentLibrarySort { lastOpened, title, importTime }

enum LibraryDocumentStatus { queued, parsing, completed, failed, cancelled }

class LibraryDocument {
  const LibraryDocument({
    required this.id,
    required this.title,
    required this.sourceName,
    required this.formatLabel,
    required this.progress,
    required this.status,
    this.failureMessage,
  });

  final String id;
  final String title;
  final String sourceName;
  final String formatLabel;
  final double progress;
  final LibraryDocumentStatus status;
  final String? failureMessage;
}

class DocumentLibraryState {
  const DocumentLibraryState({
    this.documents = const [],
    this.selectedDocumentId,
    this.errorMessage,
    this.searchQuery = '',
    this.sort = DocumentLibrarySort.lastOpened,
    this.imports = const {},
  });

  final List<LibraryDocument> documents;
  final String? selectedDocumentId;
  final String? errorMessage;
  final String searchQuery;
  final DocumentLibrarySort sort;
  final Map<String, ImportState> imports;
}

class DocumentLibraryScreen extends StatelessWidget {
  const DocumentLibraryScreen({
    required this.state,
    this.onImport,
    this.onOpen,
    this.onSelect,
    this.onRetry,
    this.onCancel,
    this.onDelete,
    this.onSearchChanged,
    this.onSortChanged,
    this.showNavigation = true,
    super.key,
  });

  final DocumentLibraryState state;
  final VoidCallback? onImport;
  final ValueChanged<String>? onOpen;
  final ValueChanged<String>? onSelect;
  final ValueChanged<String>? onRetry;
  final ValueChanged<String>? onCancel;
  final ValueChanged<String>? onDelete;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<DocumentLibrarySort>? onSortChanged;
  final bool showNavigation;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tablet = constraints.maxWidth >= 600;
        return Scaffold(
          appBar: AppBar(
            title: const Text('文档'),
            actions: [
              IconButton(
                tooltip: '导入文档',
                onPressed: onImport,
                icon: const Icon(Icons.add_rounded),
              ),
              PopupMenuButton<DocumentLibrarySort>(
                tooltip: '\u6392\u5e8f\u6587\u6863',
                onSelected: onSortChanged,
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: DocumentLibrarySort.lastOpened,
                    child: Text('\u6309\u6700\u8fd1\u6253\u5f00\u6392\u5e8f'),
                  ),
                  PopupMenuItem(
                    value: DocumentLibrarySort.title,
                    child: Text('\u6309\u6807\u9898\u6392\u5e8f'),
                  ),
                  PopupMenuItem(
                    value: DocumentLibrarySort.importTime,
                    child: Text('\u6309\u5bfc\u5165\u65f6\u95f4\u6392\u5e8f'),
                  ),
                ],
                icon: const Icon(Icons.sort_rounded),
              ),
              const SizedBox(width: 8),
            ],
            bottom: onSearchChanged == null
                ? null
                : PreferredSize(
                    preferredSize: const Size.fromHeight(60),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: TextField(
                        key: const Key('document-search'),
                        onChanged: onSearchChanged,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search_rounded),
                          hintText:
                              '\u641c\u7d22\u6807\u9898\u6216\u6587\u4ef6\u540d',
                        ),
                      ),
                    ),
                  ),
          ),
          body: tablet ? _tabletBody(context) : _documentList(context),
          bottomNavigationBar: tablet || !showNavigation
              ? null
              : const _BottomNavigation(),
        );
      },
    );
  }

  Widget _tabletBody(BuildContext context) {
    final selected = state.documents
        .where((document) => document.id == state.selectedDocumentId)
        .firstOrNull;
    return Row(
      children: [
        if (showNavigation) ...[
          const _LibraryRail(),
          const VerticalDivider(width: 1),
        ],
        SizedBox(
          key: const Key('document-list-pane'),
          width: 380,
          child: _documentList(context),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          key: const Key('document-detail-pane'),
          child: selected == null
              ? const _NoSelection()
              : _DocumentDetail(
                  document: selected,
                  onOpen: onOpen == null ? null : () => onOpen!(selected.id),
                  onDelete: onDelete == null
                      ? null
                      : () => onDelete!(selected.id),
                ),
        ),
      ],
    );
  }

  Widget _documentList(BuildContext context) {
    if (state.documents.isEmpty) {
      return _EmptyLibrary(onImport: onImport);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: state.documents.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final document = state.documents[index];
        return _DocumentTile(
          document: document,
          selected: document.id == state.selectedDocumentId,
          onTap: () {
            // On tablets a tap only selects the document and shows its
            // details in the right pane; the explicit "open" action enters
            // the reader. On phones a tap opens the reader directly.
            final isWide = MediaQuery.sizeOf(context).width >= 600;
            onSelect?.call(document.id);
            if (!isWide && document.status == LibraryDocumentStatus.completed) {
              onOpen?.call(document.id);
            }
          },
          onOpen: onOpen == null ? null : () => onOpen!(document.id),
          onRetry: onRetry == null ? null : () => onRetry!(document.id),
          onCancel: onCancel == null ? null : () => onCancel!(document.id),
          onDelete: onDelete == null ? null : () => onDelete!(document.id),
        );
      },
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({this.onImport});

  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 34,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 22),
            Text('还没有文档', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '导入 TXT、PDF 或 DOCX，开始离线点读。',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.add_rounded),
              label: const Text('导入文档'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.document,
    required this.selected,
    required this.onTap,
    this.onOpen,
    this.onRetry,
    this.onCancel,
    this.onDelete,
  });

  final LibraryDocument document;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onOpen;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? colorScheme.primaryContainer.withValues(alpha: 0.45)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? colorScheme.primary : colorScheme.outlineVariant,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _FormatBadge(label: document.formatLabel),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          document.sourceName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  _DocumentActions(
                    document: document,
                    onOpen: onOpen,
                    onRetry: onRetry,
                    onCancel: onCancel,
                    onDelete: onDelete,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _DocumentStatusLine(document: document),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormatBadge extends StatelessWidget {
  const _FormatBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _DocumentActions extends StatelessWidget {
  const _DocumentActions({
    required this.document,
    this.onOpen,
    this.onRetry,
    this.onCancel,
    this.onDelete,
  });

  final LibraryDocument document;
  final VoidCallback? onOpen;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return switch (document.status) {
      LibraryDocumentStatus.failed => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: '重试导入',
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: '删除文档',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      LibraryDocumentStatus.parsing ||
      LibraryDocumentStatus.queued => IconButton(
        tooltip: '取消导入',
        onPressed: onCancel,
        icon: const Icon(Icons.close_rounded),
      ),
      _ => PopupMenuButton<String>(
        tooltip: '更多操作',
        enabled: onOpen != null || onDelete != null,
        onSelected: (value) {
          switch (value) {
            case 'open':
              onOpen?.call();
            case 'delete':
              onDelete?.call();
          }
        },
        itemBuilder: (context) => [
          if (onOpen != null)
            PopupMenuItem(
              value: 'open',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.chrome_reader_mode_rounded),
                title: const Text('打开文档'),
              ),
            ),
          if (onDelete != null)
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.delete_outline_rounded),
                title: const Text('删除文档'),
              ),
            ),
        ],
        icon: const Icon(Icons.more_horiz_rounded),
      ),
    };
  }
}

class _DocumentStatusLine extends StatelessWidget {
  const _DocumentStatusLine({required this.document});

  final LibraryDocument document;

  @override
  Widget build(BuildContext context) {
    if (document.status == LibraryDocumentStatus.failed) {
      return Text(
        document.failureMessage ?? '导入失败',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      );
    }
    final label = switch (document.status) {
      LibraryDocumentStatus.queued => '等待解析',
      LibraryDocumentStatus.parsing =>
        '正在解析 ${(document.progress * 100).round()}%',
      LibraryDocumentStatus.completed =>
        '已阅读 ${(document.progress * 100).round()}%',
      LibraryDocumentStatus.cancelled => '已取消',
      LibraryDocumentStatus.failed => '',
    };
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: document.status == LibraryDocumentStatus.queued
                ? null
                : document.progress,
            minHeight: 4,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

class _DocumentDetail extends StatelessWidget {
  const _DocumentDetail({required this.document, this.onOpen, this.onDelete});

  final LibraryDocument document;
  final VoidCallback? onOpen;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    // Scrollable so a tall title or a shrunken viewport (e.g. the on-screen
    // keyboard on tablets) can never overflow the pane.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FormatBadge(label: document.formatLabel),
          const SizedBox(height: 24),
          Text(
            document.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            document.sourceName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Text('阅读进度 ${(document.progress * 100).round()}%'),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: document.progress, minHeight: 6),
          const SizedBox(height: 32),
          Row(
            children: [
              FilledButton.icon(
                onPressed: document.status == LibraryDocumentStatus.completed
                    ? onOpen
                    : null,
                icon: const Icon(Icons.chrome_reader_mode_rounded),
                label: const Text('继续阅读'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('删除'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoSelection extends StatelessWidget {
  const _NoSelection();

  @override
  Widget build(BuildContext context) => const Center(child: Text('选择一篇文档查看详情'));
}

class _LibraryRail extends StatelessWidget {
  const _LibraryRail();

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: 0,
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.folder_outlined),
          selectedIcon: Icon(Icons.folder_rounded),
          label: Text('文档'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.school_outlined),
          label: Text('生词'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.bookmark_border_rounded),
          label: Text('短语'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          label: Text('设置'),
        ),
      ],
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation();

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 0,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.folder_rounded), label: '文档'),
        NavigationDestination(icon: Icon(Icons.school_outlined), label: '生词'),
        NavigationDestination(
          icon: Icon(Icons.bookmark_border_rounded),
          label: '短语',
        ),
        NavigationDestination(icon: Icon(Icons.settings_outlined), label: '设置'),
      ],
    );
  }
}
