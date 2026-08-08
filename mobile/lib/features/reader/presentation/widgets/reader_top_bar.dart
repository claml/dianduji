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
    super.key,
  });

  final String title;
  final bool visible;
  final VoidCallback? onBack;
  final VoidCallback onReveal;
  final VoidCallback? onSettings;

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
            child: SafeArea(
              bottom: false,
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                elevation: 2,
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
