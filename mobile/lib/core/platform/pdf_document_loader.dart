import 'dart:typed_data';

import 'package:pdfrx/pdfrx.dart';

class PdfDocumentLoader {
  const PdfDocumentLoader();

  Future<PdfDocument> openData(Uint8List data) {
    return PdfDocument.openData(data, sourceName: 'memory:test.pdf');
  }

  Future<PdfPageText> loadPageText(PdfPage page) {
    return page.loadStructuredText();
  }
}
