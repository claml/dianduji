import 'package:dian_du_ji/features/documents/domain/document_models.dart';
import 'package:dian_du_ji/features/documents/domain/models/parsed_block.dart';
import 'package:dian_du_ji/features/reader/presentation/widgets/reflow_document_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders document blocks and taps heading and body words', (
    tester,
  ) async {
    final tapped = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReflowDocumentView(
            blocks: const [
              StoredReaderBlock(
                id: 'heading',
                ordinal: 0,
                text: 'Foundation Models',
                style: ParsedBlockStyle.heading,
                sentences: [
                  StoredReaderSentence(
                    id: 'heading-sentence',
                    paragraphId: 'heading',
                    ordinal: 0,
                    text: 'Foundation Models',
                    startOffset: 0,
                    endOffset: 17,
                    tokens: [
                      StoredReaderToken(
                        id: 'heading-foundation',
                        ordinal: 0,
                        surface: 'Foundation',
                        normalized: 'foundation',
                        lemma: 'foundation',
                        startOffset: 0,
                        endOffset: 10,
                      ),
                      StoredReaderToken(
                        id: 'heading-models',
                        ordinal: 1,
                        surface: 'Models',
                        normalized: 'models',
                        lemma: 'model',
                        startOffset: 11,
                        endOffset: 17,
                      ),
                    ],
                  ),
                ],
              ),
              StoredReaderBlock(
                id: 'list',
                ordinal: 1,
                text: 'Models learn patterns.',
                style: ParsedBlockStyle.listItem,
                sentences: [
                  StoredReaderSentence(
                    id: 'body-sentence',
                    paragraphId: 'list',
                    ordinal: 1,
                    text: 'Models learn patterns.',
                    startOffset: 0,
                    endOffset: 21,
                    tokens: [
                      StoredReaderToken(
                        id: 'body-models',
                        ordinal: 0,
                        surface: 'Models',
                        normalized: 'models',
                        lemma: 'model',
                        startOffset: 0,
                        endOffset: 6,
                      ),
                    ],
                  ),
                ],
              ),
            ],
            onTokenTap: (sentence, token) => tapped.add(token.id),
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('文档标题'), findsOneWidget);
    expect(find.text('•'), findsOneWidget);
    expect(find.text('Foundation Models', findRichText: true), findsOneWidget);
    expect(
      find.text('Models learn patterns.', findRichText: true),
      findsOneWidget,
    );
    expect(find.byKey(const Key('sentence-card')), findsNothing);

    await tester.tap(find.byKey(const Key('token-hit-heading-models')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('token-hit-body-models')));
    await tester.pump();

    expect(tapped, ['heading-models', 'body-models']);
  });

  testWidgets('highlights a selected token without changing block text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ReflowDocumentView(
          blocks: const [
            StoredReaderBlock(
              id: 'body',
              ordinal: 0,
              text: 'Clear layout.',
              style: ParsedBlockStyle.body,
              sentences: [
                StoredReaderSentence(
                  id: 'sentence',
                  paragraphId: 'body',
                  ordinal: 0,
                  text: 'Clear layout.',
                  startOffset: 0,
                  endOffset: 13,
                  tokens: [
                    StoredReaderToken(
                      id: 'clear',
                      ordinal: 0,
                      surface: 'Clear',
                      normalized: 'clear',
                      lemma: 'clear',
                      startOffset: 0,
                      endOffset: 5,
                    ),
                  ],
                ),
              ],
            ),
          ],
          selectedTokenId: 'clear',
          onTokenTap: (_, _) {},
        ),
      ),
    );

    expect(find.text('Clear layout.', findRichText: true), findsOneWidget);
    expect(find.byKey(const Key('selected-token-clear')), findsOneWidget);
  });
}
