import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../documents/domain/document_models.dart';

class ClickableTextBlock extends StatelessWidget {
  const ClickableTextBlock({
    required this.block,
    required this.style,
    required this.onTokenTap,
    this.selectedTokenId,
    this.sentenceKeyFor,
    this.tokenKeyFor,
    super.key,
  });

  final StoredReaderBlock block;
  final TextStyle style;
  final String? selectedTokenId;
  final void Function(StoredReaderSentence sentence, StoredReaderToken token)
  onTokenTap;
  final Key? Function(String sentenceId)? sentenceKeyFor;
  final Key? Function(String tokenId)? tokenKeyFor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final placements = _placements(block);
        final span = _buildSpan(
          text: block.text,
          placements: placements,
          baseStyle: style,
          selectedTokenId: selectedTokenId,
          selectedColor: colorScheme.primary,
        );
        final painter = TextPainter(
          text: span,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final hitRects = <_TokenHitRect>[];
        for (final placement in placements) {
          final boxes = painter.getBoxesForSelection(
            TextSelection(
              baseOffset: placement.start,
              extentOffset: placement.end,
            ),
          );
          for (var index = 0; index < boxes.length; index++) {
            final visualRect = boxes[index].toRect();
            hitRects.add(
              _TokenHitRect(
                placement: placement,
                rect: _minimumTapRect(visualRect, painter.size),
                visualRect: visualRect,
                isPrimary: index == 0,
              ),
            );
          }
        }

        return SizedBox(
          width: constraints.maxWidth,
          height: painter.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (final hit in hitRects)
                if (hit.placement.token.id == selectedTokenId)
                  Positioned.fromRect(
                    rect: hit.visualRect.inflate(2),
                    child: IgnorePointer(
                      child: ColoredBox(
                        key: hit.isPrimary
                            ? Key('selected-token-${hit.placement.token.id}')
                            : null,
                        color: colorScheme.primary.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
              Positioned.fill(
                child: IgnorePointer(
                  child: RichText(
                    text: span,
                    textScaler: MediaQuery.textScalerOf(context),
                  ),
                ),
              ),
              for (final sentence in block.sentences)
                Positioned(
                  left: 0,
                  top: _sentenceTop(painter, sentence),
                  child: SizedBox(
                    key: sentenceKeyFor?.call(sentence.id),
                    width: 1,
                    height: 1,
                  ),
                ),
              for (final hit in hitRects)
                Positioned.fromRect(
                  rect: hit.rect,
                  child: Semantics(
                    button: true,
                    selected: hit.placement.token.id == selectedTokenId,
                    label: '${hit.placement.token.surface}，点按查看释义',
                    child: GestureDetector(
                      key: hit.isPrimary
                          ? Key('token-hit-${hit.placement.token.id}')
                          : null,
                      behavior: HitTestBehavior.translucent,
                      onTap: () => onTokenTap(
                        hit.placement.sentence,
                        hit.placement.token,
                      ),
                      child: SizedBox(
                        key: hit.isPrimary
                            ? tokenKeyFor?.call(hit.placement.token.id)
                            : null,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

TextSpan _buildSpan({
  required String text,
  required List<_TokenPlacement> placements,
  required TextStyle baseStyle,
  required String? selectedTokenId,
  required Color selectedColor,
}) {
  final children = <InlineSpan>[];
  var cursor = 0;
  for (final placement in placements) {
    if (placement.start > cursor) {
      children.add(TextSpan(text: text.substring(cursor, placement.start)));
    }
    children.add(
      TextSpan(
        text: text.substring(placement.start, placement.end),
        style: placement.token.id == selectedTokenId
            ? TextStyle(
                color: selectedColor,
                decoration: TextDecoration.underline,
                decorationColor: selectedColor,
                decorationThickness: 2,
              )
            : null,
      ),
    );
    cursor = placement.end;
  }
  if (cursor < text.length) {
    children.add(TextSpan(text: text.substring(cursor)));
  }
  return TextSpan(style: baseStyle, children: children);
}

List<_TokenPlacement> _placements(StoredReaderBlock block) {
  final placements = <_TokenPlacement>[];
  for (final sentence in block.sentences) {
    for (final token in sentence.tokens) {
      final start = sentence.startOffset + token.startOffset;
      final end = sentence.startOffset + token.endOffset;
      if (start < 0 || end <= start || end > block.text.length) continue;
      placements.add(
        _TokenPlacement(
          sentence: sentence,
          token: token,
          start: start,
          end: end,
        ),
      );
    }
  }
  placements.sort((left, right) => left.start.compareTo(right.start));
  return placements;
}

Rect _minimumTapRect(Rect visual, Size canvas) {
  const target = 48.0;
  final width = math.max(target, visual.width);
  final height = math.max(target, visual.height);
  final left = (visual.center.dx - width / 2)
      .clamp(0.0, math.max(0.0, canvas.width - width))
      .toDouble();
  final top = (visual.center.dy - height / 2)
      .clamp(0.0, math.max(0.0, canvas.height - height))
      .toDouble();
  return Rect.fromLTWH(
    left,
    top,
    math.min(width, canvas.width),
    math.min(height, canvas.height),
  );
}

double _sentenceTop(TextPainter painter, StoredReaderSentence sentence) {
  final length = painter.text?.toPlainText().length ?? 0;
  final offset = sentence.startOffset.clamp(0, length);
  return painter.getOffsetForCaret(TextPosition(offset: offset), Rect.zero).dy;
}

class _TokenPlacement {
  const _TokenPlacement({
    required this.sentence,
    required this.token,
    required this.start,
    required this.end,
  });

  final StoredReaderSentence sentence;
  final StoredReaderToken token;
  final int start;
  final int end;
}

class _TokenHitRect {
  const _TokenHitRect({
    required this.placement,
    required this.rect,
    required this.visualRect,
    required this.isPrimary,
  });

  final _TokenPlacement placement;
  final Rect rect;
  final Rect visualRect;
  final bool isPrimary;
}
