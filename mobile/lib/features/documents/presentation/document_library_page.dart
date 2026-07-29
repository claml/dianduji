import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../domain/import_document_use_case.dart';
import 'document_import_controller.dart';
import 'document_library_screen.dart';

class DocumentLibraryPage extends ConsumerStatefulWidget {
  const DocumentLibraryPage({
    this.controller,
    this.controllerLoader,
    this.onOpen,
    super.key,
  });

  final DocumentImportController? controller;
  final DocumentImportController Function()? controllerLoader;
  final ValueChanged<String>? onOpen;

  @override
  ConsumerState<DocumentLibraryPage> createState() =>
      _DocumentLibraryPageState();
}

class _DocumentLibraryPageState extends ConsumerState<DocumentLibraryPage> {
  late DocumentImportController? _controller = widget.controller;

  @override
  Widget build(BuildContext context) {
    final DocumentImportController controller =
        _controller ??
        widget.controllerLoader?.call() ??
        ref.watch(documentImportControllerProvider);
    _controller ??= controller;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final state = controller.state;
        return Stack(
          children: [
            DocumentLibraryScreen(
              state: state,
              showNavigation: false,
              onImport: () => unawaited(_pickAndImport(controller)),
              onOpen: widget.onOpen,
              onSelect: controller.select,
              onRetry: (id) => unawaited(controller.retry(id)),
              onCancel: (id) => unawaited(controller.cancel(id)),
              onDelete: _confirmDelete,
              onSearchChanged: controller.setSearchQuery,
              onSortChanged: controller.setSort,
            ),
            if (state.errorMessage != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: Semantics(
                  liveRegion: true,
                  label: state.errorMessage,
                  child: ExcludeSemantics(
                    child: Center(
                      child: Material(
                        color: Theme.of(context).colorScheme.inverseSurface,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            state.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onInverseSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _pickAndImport(DocumentImportController controller) async {
    final result = await controller.pickAndImport();
    if (result?.status == ImportStatus.duplicate) {
      widget.onOpen?.call(result!.documentId);
    }
  }

  Future<void> _confirmDelete(String documentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('\u5220\u9664\u8fd9\u7bc7\u6587\u6863\uff1f'),
        content: const Text(
          '\u5220\u9664\u540e\u65e0\u6cd5\u6062\u590d\uff0c\u5305\u62ec\u672c\u5730\u89e3\u6790\u7ed3\u679c\u3002',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('\u53d6\u6d88'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('\u5220\u9664'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await _controller!.delete(documentId);
  }
}
