import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../domain/pdf_word_geometry_builder.dart';
import '../../domain/pdf_word_hit_target.dart';
import '../../domain/reader_selection.dart';

typedef PdfTargetsLoaded =
    void Function(int pageNumber, List<PdfWordHitTarget> targets);

abstract interface class PdfPageOverlayData {
  int get pageNumber;
  Future<PdfPageText> loadText();
  Rect mapRect(PdfRect rect, Size scaledPageSize);
}

class PdfrxPageOverlayData implements PdfPageOverlayData {
  const PdfrxPageOverlayData(this.page);

  final PdfPage page;

  @override
  int get pageNumber => page.pageNumber;

  @override
  Future<PdfPageText> loadText() => page.loadStructuredText();

  @override
  Rect mapRect(PdfRect rect, Size scaledPageSize) {
    return rect.toRect(page: page, scaledPageSize: scaledPageSize);
  }
}

class PdfWordOverlay extends StatefulWidget {
  const PdfWordOverlay({
    required this.page,
    required this.onWordTap,
    this.selection,
    this.onTargetsLoaded,
    super.key,
  });

  final PdfPageOverlayData page;
  final ReaderSelection? selection;
  final ValueChanged<ReaderSelection> onWordTap;
  final PdfTargetsLoaded? onTargetsLoaded;

  @override
  State<PdfWordOverlay> createState() => _PdfWordOverlayState();
}

class _PdfWordOverlayState extends State<PdfWordOverlay> {
  late Future<PdfPageText> _pageText = widget.page.loadText();

  @override
  void didUpdateWidget(PdfWordOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page.pageNumber != widget.page.pageNumber) {
      _pageText = widget.page.loadText();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PdfPageText>(
      future: _pageText,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.expand();
        final targets = buildPdfWordTargets(snapshot.data!);
        widget.onTargetsLoaded?.call(widget.page.pageNumber, targets);
        return LayoutBuilder(
          builder: (context, constraints) {
            final visualTargets = targets
                .map(
                  (target) => _VisualTarget(
                    target,
                    target.bounds
                        .map(
                          (rect) =>
                              widget.page.mapRect(rect, constraints.biggest),
                        )
                        .toList(growable: false),
                  ),
                )
                .toList(growable: false);
            return IgnorePointer(
              child: Stack(
                key: Key('pdf-page-overlay-${widget.page.pageNumber}'),
                children: [
                  for (final target in visualTargets)
                    for (var index = 0; index < target.rects.length; index++)
                      Positioned.fromRect(
                        key: index == 0
                            ? Key(
                                'pdf-word-hit-${target.target.pageNumber}-'
                                '${target.target.start}',
                              )
                            : null,
                        rect: target.rects[index],
                        child: Semantics(
                          key: index == 0
                              ? Key(
                                  'pdf-word-semantics-'
                                  '${target.target.pageNumber}-'
                                  '${target.target.start}',
                                )
                              : null,
                          button: true,
                          selected: _isSelected(target.target),
                          label:
                              '${target.target.surface}\uff0c'
                              '\u70b9\u6309\u67e5\u770b\u91ca\u4e49',
                          onTap: () => widget.onWordTap(
                            readerSelectionForPdfTarget(target.target),
                          ),
                          child: ColoredBox(
                            color: _isSelected(target.target)
                                ? Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.16)
                                : Colors.transparent,
                          ),
                        ),
                      ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  bool _isSelected(PdfWordHitTarget target) {
    final selection = widget.selection;
    return selection?.pageNumber == target.pageNumber &&
        selection?.startOffset == target.start &&
        selection?.endOffset == target.end;
  }
}

ReaderSelection readerSelectionForPdfTarget(PdfWordHitTarget target) {
  return ReaderSelection(
    surface: target.surface,
    normalized: target.normalized,
    contextText: target.contextText,
    startOffset: target.start,
    endOffset: target.end,
    pageNumber: target.pageNumber,
  );
}

class _VisualTarget {
  const _VisualTarget(this.target, this.rects);

  final PdfWordHitTarget target;
  final List<Rect> rects;
}
