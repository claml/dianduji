import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../domain/pdf_text_hit_tester.dart';
import '../../domain/pdf_word_hit_target.dart';
import '../../domain/reader_selection.dart';
import 'pdf_page_text_store.dart';
import 'pdf_word_overlay.dart';

typedef PdfDocumentRenderer =
    Widget Function(BuildContext context, PdfDocumentView view);
typedef PdfPageProgressChanged = void Function(int pageNumber, int pageCount);

/// Inverts the PDF page bitmap so paper becomes dark and text becomes light.
/// Applied only in night mode; PDF images render as negatives, which is the
/// standard trade-off of PDF night modes.
const List<double> _nightInvertMatrix = [
  -1, 0, 0, 0, 255, //
  0, -1, 0, 0, 255, //
  0, 0, -1, 0, 255, //
  0, 0, 0, 1, 0, //
];

int clampPdfInitialPage(int requestedPage, int pageCount) {
  if (requestedPage < 1 || requestedPage > pageCount) return 1;
  return requestedPage;
}

class PdfDocumentView extends StatefulWidget {
  const PdfDocumentView({
    required this.localPath,
    required this.onWordTap,
    this.selection,
    this.initialPageNumber = 1,
    this.controller,
    this.onPageChanged,
    this.onContentScroll,
    this.renderer,
    this.textStore,
    super.key,
  });

  final String localPath;
  final ReaderSelection? selection;
  final int initialPageNumber;
  final PdfViewerController? controller;
  final ValueChanged<ReaderSelection> onWordTap;
  final PdfPageProgressChanged? onPageChanged;
  final ValueChanged<double>? onContentScroll;
  final PdfDocumentRenderer? renderer;
  final PdfPageTextStore? textStore;

  @override
  State<PdfDocumentView> createState() => _PdfDocumentViewState();
}

class _PdfDocumentViewState extends State<PdfDocumentView> {
  late PdfPageTextStore _textStore;
  late final ValueNotifier<PdfWordHitTarget?> _selectedTarget;
  Widget? _renderedDocument;
  var _pageCount = 1;

  @override
  void initState() {
    super.initState();
    _textStore = widget.textStore ?? PdfPageTextStore();
    _selectedTarget = ValueNotifier(null);
  }

  @override
  void didUpdateWidget(PdfDocumentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final documentChanged = oldWidget.localPath != widget.localPath;
    final storeChanged = !identical(oldWidget.textStore, widget.textStore);
    final previousTextStore = _textStore;

    if (storeChanged) {
      _textStore = widget.textStore ?? PdfPageTextStore();
      _selectedTarget.value = null;
    }

    if (documentChanged) {
      previousTextStore.clear();
      if (!identical(previousTextStore, _textStore)) {
        _textStore.clear();
      }
      _selectedTarget.value = null;
      _pageCount = 1;
    }
    if (documentChanged ||
        storeChanged ||
        !identical(oldWidget.controller, widget.controller)) {
      _renderedDocument = null;
    }
    if (oldWidget.selection != null && widget.selection == null) {
      _selectedTarget.value = null;
    }
  }

  @override
  void dispose() {
    _selectedTarget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewer =
        _renderedDocument ??=
        widget.renderer?.call(context, widget) ??
        _buildPdfViewer(context, isDark: isDark);
    if (!isDark) return viewer;
    // Night mode: invert the rendered pages (paper -> dark, text -> light)
    // and let the viewer background follow the dark surface.
    return ColorFiltered(
      key: const Key('pdf-night-color-filter'),
      colorFilter: const ColorFilter.matrix(_nightInvertMatrix),
      child: viewer,
    );
  }

  Widget _buildPdfViewer(BuildContext context, {required bool isDark}) {
    return PdfViewer.file(
      widget.localPath,
      key: const Key('pdf-original-page-viewer'),
      controller: widget.controller,
      initialPageNumber: widget.initialPageNumber,
      params: PdfViewerParams(
        backgroundColor: isDark
            ? const Color(0xFF16191E)
            : Colors.grey,
        onInteractionUpdate: (details) {
          if (details.pointerCount != 1 || (details.scale - 1).abs() > 0.01) {
            return;
          }
          final delta = -details.focalPointDelta.dy;
          if (delta.isFinite && delta != 0) {
            widget.onContentScroll?.call(delta);
          }
        },
        onViewerReady: (document, controller) {
          _pageCount = document.pages.length;
        },
        calculateInitialPageNumber: (document, controller) =>
            clampPdfInitialPage(
              widget.initialPageNumber,
              document.pages.length,
            ),
        onPageChanged: (pageNumber) {
          if (pageNumber != null) {
            widget.onPageChanged?.call(pageNumber, _pageCount);
          }
        },
        onGeneralTap: (context, controller, details) {
          if (details.type != PdfViewerGeneralTapType.tap) return false;
          final hit = controller.getPdfPageHitTestResult(
            details.documentPosition,
            useDocumentLayoutCoordinates: true,
          );
          if (hit == null) return false;
          final geometry = _textStore.get(hit.page.pageNumber);
          if (geometry == null) return false;
          final margin = 24 / controller.currentZoom.clamp(0.1, 100.0);
          final target = hitTestPdfText(geometry, hit.offset, margin: margin);
          if (target == null) return false;
          _selectedTarget.value = target;
          widget.onWordTap(_readerSelectionForTarget(target));
          return true;
        },
        textSelectionParams: const PdfTextSelectionParams(enabled: false),
        pageOverlaysBuilder: (context, pageRect, page) => [
          ValueListenableBuilder<PdfWordHitTarget?>(
            valueListenable: _selectedTarget,
            builder: (context, selectedTarget, child) {
              return PdfWordOverlay(
                key: ValueKey('pdf-word-overlay-${page.pageNumber}'),
                page: PdfrxPageOverlayData(page),
                selectedTarget: selectedTarget,
                store: _textStore,
              );
            },
          ),
        ],
        errorBannerBuilder: (context, error, stackTrace, documentRef) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('PDF \u6253\u5f00\u5931\u8d25\uff1a$error'),
            ),
          );
        },
      ),
    );
  }
}

ReaderSelection _readerSelectionForTarget(PdfWordHitTarget target) {
  return ReaderSelection(
    surface: target.surface,
    normalized: target.normalized,
    contextText: target.contextText,
    startOffset: target.start,
    endOffset: target.end,
    pageNumber: target.pageNumber,
  );
}
