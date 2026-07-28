import 'package:dian_du_ji/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the document library shell', (tester) async {
    await tester.pumpWidget(const DianDuJiApp());

    expect(find.text('文档'), findsOneWidget);
    expect(find.text('导入文档'), findsOneWidget);
  });
}
