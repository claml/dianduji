import 'package:dian_du_ji/core/platform/pdf_text_extractor.dart';
import 'package:dian_du_ji/core/platform/pdfrx_pdf_text_extractor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('parse the shared paper PDF', () async {
    const path = r'C:\Users\24439\AppData\Local\Temp\paper.pdf';
    final extractor = const PdfrxPdfTextExtractor();
    final stopwatch = Stopwatch()..start();
    var pages = 0;
    var chars = 0;
    try {
      await for (final page in extractor.extract(
        path,
        cancellationToken: ParseCancellationToken(),
      )) {
        pages++;
        chars += page.text.length;
        if (pages % 10 == 0) {
          // ignore: avoid_print
          print('page $pages at ${stopwatch.elapsedMilliseconds}ms');
        }
      }
      // ignore: avoid_print
      print('OK pages=$pages chars=$chars ms=${stopwatch.elapsedMilliseconds}');
    } on Object catch (error) {
      // ignore: avoid_print
      print('FAILED ${error.runtimeType}: $error after '
          '${stopwatch.elapsedMilliseconds}ms');
      rethrow;
    }
  }, timeout: const Timeout(Duration(minutes: 3)));
}
