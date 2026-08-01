import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/reader_card_preferences.dart';

class DraggableTranslationCard extends StatefulWidget {
  const DraggableTranslationCard({
    required this.translation,
    required this.preferences,
    required this.onPreferencesChanged,
    super.key,
  });

  final Widget translation;
  final ReaderCardPreferences preferences;
  final ValueChanged<ReaderCardPreferences> onPreferencesChanged;

  @override
  State<DraggableTranslationCard> createState() =>
      _DraggableTranslationCardState();
}

class _DraggableTranslationCardState
    extends State<DraggableTranslationCard> {
  late double _relativeX = widget.preferences.relativeX;
  late double _relativeY = widget.preferences.relativeY;

  @override
  void didUpdateWidget(DraggableTranslationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.preferences.relativeX != widget.preferences.relativeX ||
        oldWidget.preferences.relativeY != widget.preferences.relativeY) {
      _relativeX = widget.preferences.relativeX;
      _relativeY = widget.preferences.relativeY;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = math.min(
          400.0,
          math.max(320.0, constraints.maxWidth * 0.36),
        );
        final cardHeight = math.min(
          480.0,
          math.max(280.0, constraints.maxHeight * 0.62),
        );
        final availableX = math.max(0.0, constraints.maxWidth - cardWidth);
        final availableY = math.max(0.0, constraints.maxHeight - cardHeight);
        final left = _relativeX * availableX;
        final top = _relativeY * availableY;

        return Stack(
          children: [
            Positioned(
              key: const Key('translation-floating-card'),
              left: left,
              top: top,
              width: cardWidth,
              height: cardHeight,
              child: Material(
                elevation: 12,
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  children: [
                    GestureDetector(
                      key: const Key('translation-floating-drag-handle'),
                      behavior: HitTestBehavior.opaque,
                      onPanUpdate: (details) {
                        setState(() {
                          if (availableX > 0) {
                            _relativeX = ((_relativeX * availableX +
                                        details.delta.dx) /
                                    availableX)
                                .clamp(0, 1)
                                .toDouble();
                          }
                          if (availableY > 0) {
                            _relativeY = ((_relativeY * availableY +
                                        details.delta.dy) /
                                    availableY)
                                .clamp(0, 1)
                                .toDouble();
                          }
                        });
                      },
                      onPanEnd: (_) => _save(ReaderCardMode.floating),
                      child: SizedBox(
                        height: 52,
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            Icon(
                              Icons.drag_indicator_rounded,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const Spacer(),
                            IconButton(
                              key: const Key('reader-dock-card'),
                              tooltip: '停靠到右侧',
                              onPressed: () => _save(ReaderCardMode.sidePane),
                              icon: const Icon(Icons.view_sidebar_outlined),
                            ),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ),
                    ),
                    Expanded(child: widget.translation),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _save(ReaderCardMode mode) {
    widget.onPreferencesChanged(
      ReaderCardPreferences(
        mode: mode,
        relativeX: _relativeX,
        relativeY: _relativeY,
      ),
    );
  }
}
