import 'dart:math' as math;

import 'package:flutter/material.dart';

double readerToolbarExclusionHeight(BuildContext context) =>
    MediaQuery.paddingOf(context).top + kToolbarHeight;

class ReaderTopBar extends StatelessWidget {
  const ReaderTopBar({
    required this.title,
    required this.visible,
    required this.onBack,
    required this.onReveal,
    required this.onSettings,
    this.onOutline,
    super.key,
  });

  final String title;
  final bool visible;
  final VoidCallback? onBack;
  final VoidCallback onReveal;
  final VoidCallback? onSettings;

  /// Opens the PDF table of contents; only shown for PDFs with an outline.
  final VoidCallback? onOutline;

  @override
  Widget build(BuildContext context) {
    final revealHeight = math.max(MediaQuery.paddingOf(context).top, 24.0);
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedSlide(
            key: const Key('reader-top-bar'),
            offset: visible ? Offset.zero : const Offset(0, -1),
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 180),
            // The material background starts at the very top of the screen so
            // the transparent system status-bar region is covered by the bar
            // (edge-to-edge Android) instead of showing the document beneath;
            // only the bar's contents clear the status bar.
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              elevation: 2,
              child: SafeArea(
                bottom: false,
                child: SizedBox(
                  height: kToolbarHeight,
                  child: Row(
                    children: [
                      IconButton(
                        key: const Key('reader-back-button'),
                        tooltip: '返回',
                        onPressed: onBack,
                        icon: const Icon(Icons.arrow_back),
                      ),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      if (onOutline != null)
                        IconButton(
                          key: const Key('reader-outline-button'),
                          tooltip: '目录',
                          onPressed: onOutline,
                          icon: const Icon(Icons.toc_rounded),
                        ),
                      IconButton(
                        key: const Key('reader-settings-button'),
                        tooltip: '阅读设置',
                        onPressed: onSettings,
                        icon: const Icon(Icons.text_fields_rounded),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (!visible)
          Positioned(
            key: const Key('reader-top-reveal-zone'),
            top: 0,
            left: 0,
            right: 0,
            height: revealHeight,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: onReveal,
              child: const SizedBox.expand(),
            ),
          ),
      ],
    );
  }
}
