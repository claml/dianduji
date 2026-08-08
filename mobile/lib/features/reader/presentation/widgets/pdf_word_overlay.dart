import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../domain/pdf_word_hit_target.dart';
import 'pdf_page_text_store.dart';

abstract interface class PdfPageOverlayData implements PdfPageTextSource {
  Rect mapRect(PdfRect rect, Size scaledPageSize);
}

class PdfrxPageOverlayData implements PdfPageOverlayData {
  const PdfrxPageOverlayData(this.page);

  final PdfPage page;

  @override
  int get pageNumber => page.pageNumber;

  @override
  Future<PdfPageText> loadStructuredText() => page.loadStructuredText();

  @override
  Future<PdfPageRawText?> loadRawText() => page.loadText();

  @override
  Rect mapRect(PdfRect rect, Size scaledPageSize) {
    return rect.toRect(page: page, scaledPageSize: scaledPageSize);
  }
}

class PdfWordOverlay extends StatefulWidget {
  const PdfWordOverlay({
    required this.page,
    required this.selectedTarget,
    required this.store,
    super.key,
  });

  final PdfPageOverlayData page;
  final PdfWordHitTarget? selectedTarget;
  final PdfPageTextStore store;

  @override
  State<PdfWordOverlay> createState() => _PdfWordOverlayState();
}

class _PdfWordOverlayState extends State<PdfWordOverlay> {
  @override
  void initState() {
    super.initState();
    unawaited(widget.store.load(widget.page));
  }

  @override
  void didUpdateWidget(PdfWordOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.store, widget.store) ||
        !identical(oldWidget.page, widget.page)) {
      unawaited(widget.store.load(widget.page));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return IgnorePointer(
          child: CustomPaint(
            key: Key('pdf-page-overlay-${widget.page.pageNumber}'),
            painter: _PdfSelectionPainter(
              page: widget.page,
              pageSize: constraints.biggest,
              selectedTarget: widget.selectedTarget,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.16),
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

class _PdfSelectionPainter extends CustomPainter {
  const _PdfSelectionPainter({
    required this.page,
    required this.pageSize,
    required this.selectedTarget,
    required this.color,
  });

  final PdfPageOverlayData page;
  final Size pageSize;
  final PdfWordHitTarget? selectedTarget;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final target = selectedTarget;
    if (target == null || target.pageNumber != page.pageNumber) return;
    final paint = Paint()..color = color;
    for (final bound in target.bounds) {
      canvas.drawRect(page.mapRect(bound, pageSize), paint);
    }
  }

  @override
  bool shouldRepaint(_PdfSelectionPainter oldDelegate) {
    return !identical(oldDelegate.page, page) ||
        oldDelegate.pageSize != pageSize ||
        !identical(oldDelegate.selectedTarget, selectedTarget) ||
        oldDelegate.color != color;
  }
}
