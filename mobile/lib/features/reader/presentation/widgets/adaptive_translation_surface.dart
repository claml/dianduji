import 'package:flutter/material.dart';

import '../../data/reader_card_preferences.dart';
import 'draggable_translation_card.dart';

class AdaptiveTranslationSurface extends StatelessWidget {
  const AdaptiveTranslationSurface({
    required this.visible,
    required this.document,
    required this.translation,
    required this.preferences,
    required this.onPreferencesChanged,
    this.topExclusion = 0,
    this.idleOverlay,
    super.key,
  });

  final bool visible;
  final Widget document;
  final Widget translation;
  final ReaderCardPreferences preferences;
  final ValueChanged<ReaderCardPreferences> onPreferencesChanged;
  final double topExclusion;
  final Widget? idleOverlay;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return _phone(constraints.maxHeight);
        }
        return _tablet(constraints.maxHeight);
      },
    );
  }

  Widget _phone(double height) {
    return Stack(
      children: [
        Positioned.fill(
          bottom: visible ? height * 0.4 : 0,
          child: _documentViewport(),
        ),
        if (!visible) ?idleOverlay,
        if (visible)
          Positioned(
            key: const Key('translation-bottom-sheet'),
            left: 0,
            right: 0,
            bottom: 0,
            height: height * 0.4,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0x22000000))),
              ),
              child: translation,
            ),
          ),
      ],
    );
  }

  Widget _tablet(double height) {
    final showSidePane = visible && preferences.mode == ReaderCardMode.sidePane;
    final showFloating = visible && preferences.mode == ReaderCardMode.floating;
    final usableTopExclusion = height.isFinite
        ? topExclusion.clamp(0, height).toDouble()
        : topExclusion;
    return Stack(
      children: [
        Positioned.fill(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _documentViewport()),
              if (showSidePane) ...[
                const VerticalDivider(width: 1),
                SizedBox(
                  key: const Key('translation-side-pane'),
                  width: 360,
                  child: Padding(
                    padding: EdgeInsets.only(top: usableTopExclusion),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            key: const Key('reader-float-card'),
                            tooltip: '悬浮词卡',
                            onPressed: () => onPreferencesChanged(
                              preferences.copyWith(
                                mode: ReaderCardMode.floating,
                              ),
                            ),
                            icon: const Icon(Icons.open_in_new_rounded),
                          ),
                        ),
                        Expanded(child: translation),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (!visible) ?idleOverlay,
        if (showFloating)
          Positioned(
            top: usableTopExclusion,
            left: 0,
            right: 0,
            bottom: 0,
            child: DraggableTranslationCard(
              preferences: preferences,
              onPreferencesChanged: onPreferencesChanged,
              translation: translation,
            ),
          ),
      ],
    );
  }

  Widget _documentViewport() {
    return KeyedSubtree(
      key: const Key('reader-document-viewport'),
      child: document,
    );
  }
}
