import 'package:flutter/material.dart';

import '../../../documents/domain/document_models.dart';
import '../../../documents/domain/models/parsed_block.dart';
import 'clickable_text_block.dart';

class ReflowDocumentView extends StatelessWidget {
  const ReflowDocumentView({
    required this.blocks,
    required this.onTokenTap,
    this.selectedTokenId,
    this.fontSize = 16,
    this.lineHeight = 1.6,
    this.scrollController,
    this.sentenceKeyFor,
    this.tokenKeyFor,
    super.key,
  });

  final List<StoredReaderBlock> blocks;
  final String? selectedTokenId;
  final double fontSize;
  final double lineHeight;
  final ScrollController? scrollController;
  final void Function(StoredReaderSentence sentence, StoredReaderToken token)
  onTokenTap;
  final Key? Function(String sentenceId)? sentenceKeyFor;
  final Key? Function(String tokenId)? tokenKeyFor;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 64),
      itemCount: blocks.length,
      itemBuilder: (context, index) {
        final block = blocks[index];
        final style = _styleFor(context, block.style);
        final text = ClickableTextBlock(
          block: block,
          style: style,
          selectedTokenId: selectedTokenId,
          sentenceKeyFor: sentenceKeyFor,
          tokenKeyFor: tokenKeyFor,
          onTokenTap: onTokenTap,
        );
        final content = block.style == ParsedBlockStyle.listItem
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: fontSize * 0.18, right: 12),
                    child: Text('•', style: style),
                  ),
                  Expanded(child: text),
                ],
              )
            : text;
        final semanticContent = block.style == ParsedBlockStyle.heading
            ? Semantics(
                header: true,
                label: '文档标题',
                child: ExcludeSemantics(child: content),
              )
            : content;
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: block.style == ParsedBlockStyle.heading ? 24 : 16,
              ),
              child: semanticContent,
            ),
          ),
        );
      },
    );
  }

  TextStyle _styleFor(BuildContext context, ParsedBlockStyle blockStyle) {
    final base = Theme.of(context).textTheme.bodyLarge ?? const TextStyle();
    return switch (blockStyle) {
      ParsedBlockStyle.heading => base.copyWith(
        fontSize: fontSize + 10,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      ParsedBlockStyle.listItem || ParsedBlockStyle.body => base.copyWith(
        fontSize: fontSize,
        height: lineHeight,
      ),
    };
  }
}
