import 'package:dian_du_ji/features/reader/presentation/widgets/pdf_document_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Night-mode gate for the PDF reader: the original-layout PDF surface must
/// be inverted (dark paper, light text) and get a dark viewer background,
/// while day mode keeps the plain viewer.
void main() {
  testWidgets('night mode inverts the PDF viewer surface', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF16191E),
        ),
        home: PdfDocumentView(
          localPath: '/documents/paper.pdf',
          onWordTap: (_) {},
          renderer: (context, view) => const ColoredBox(
            key: Key('pdf-renderer'),
            color: Colors.white,
          ),
        ),
      ),
    );

    final filter = tester.widget<ColorFiltered>(
      find.byKey(const Key('pdf-night-color-filter')),
    );
    expect(filter.colorFilter, isA<ColorFilter>());
    expect(filter.child, isNotNull);
    expect(find.byKey(const Key('pdf-renderer')), findsOneWidget);
  });

  testWidgets('day mode keeps the plain PDF viewer', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          useMaterial3: true,
        ),
        home: PdfDocumentView(
          localPath: '/documents/paper.pdf',
          onWordTap: (_) {},
          renderer: (context, view) => const ColoredBox(
            key: Key('pdf-renderer'),
            color: Colors.white,
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('pdf-night-color-filter')), findsNothing);
    expect(find.byKey(const Key('pdf-renderer')), findsOneWidget);
  });
}
