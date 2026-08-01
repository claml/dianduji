import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../domain/pdf_word_geometry_builder.dart';
import '../../domain/pdf_word_hit_target.dart';
import '../../domain/reader_selection.dart';
import 'pdf_word_overlay.dart';

typedef PdfDocumentRenderer =
    Widget Function(BuildContext context, PdfDocumentView view);
typedef PdfPageProgressChanged = void Function(int pageNumber, int pageCount);

int clampPdfInitialPage(int requestedPage, int pageCount) {
  if (requestedPage < 1 || requestedPage > pageCount) return 1;
  return requestedPage;
}

class PdfWordTargetCache {
  PdfWordTargetCache({this.maxPages = 8}) : assert(maxPages > 0);

  final int maxPages;
  final Map<int, List<PdfWordHitTarget>> _pages = {};

  int get length => _pages.length;

  List<PdfWordHitTarget>? operator [](int pageNumber) => _pages[pageNumber];

  void put(int pageNumber, List<PdfWordHitTarget> targets) {
    _pages.remove(pageNumber);
    _pages[pageNumber] = targets;
    while (_pages.length > maxPages) {
      _pages.remove(_pages.keys.first);
    }
  }

  void clear() => _pages.clear();
}

class PdfDocumentView extends StatefulWidget {
  const PdfDocumentView({
    required this.localPath,
    required this.onWordTap,
    this.selection,
    this.initialPageNumber = 1,
    this.controller,
    this.onPageChanged,
    this.renderer,
    super.key,
  });

  final String localPath;
  final ReaderSelection? selection;
  final int initialPageNumber;
  final PdfViewerController? controller;
  final ValueChanged<ReaderSelection> onWordTap;
  final PdfPageProgressChanged? onPageChanged;
  final PdfDocumentRenderer? renderer;

  @override
  State<PdfDocumentView> createState() => _PdfDocumentViewState();
}

class _PdfDocumentViewState extends State<PdfDocumentView> {
  final _targetsByPage = PdfWordTargetCache();
  var _pageCount = 1;

  @override
  void didUpdateWidget(PdfDocumentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.localPath != widget.localPath) {
      _targetsByPage.clear();
      _pageCount = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.renderer != null) return widget.renderer!(context, widget);
    return PdfViewer.file(
      widget.localPath,
      key: const Key('pdf-original-page-viewer'),
      controller: widget.controller,
      initialPageNumber: widget.initialPageNumber,
      params: PdfViewerParams(
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
          final targets = _targetsByPage[hit.page.pageNumber];
          if (targets == null) return false;
          final zoom = controller.currentZoom.clamp(0.1, 100.0);
          final target = findPdfWordTargetAt(
            targets,
            hit.offset,
            margin: 24 / zoom,
          );
          if (target == null) return false;
          widget.onWordTap(readerSelectionForPdfTarget(target));
          return true;
        },
        textSelectionParams: const PdfTextSelectionParams(enabled: false),
        pageOverlaysBuilder: (context, pageRect, page) => [
          PdfWordOverlay(
            key: ValueKey('pdf-word-overlay-${page.pageNumber}'),
            page: PdfrxPageOverlayData(page),
            selection: widget.selection,
            onWordTap: widget.onWordTap,
            onTargetsLoaded: (pageNumber, targets) {
              _targetsByPage.put(pageNumber, targets);
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
