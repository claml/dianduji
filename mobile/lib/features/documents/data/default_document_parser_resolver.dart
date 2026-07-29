import '../../../core/platform/pdf_text_extractor.dart';
import '../domain/file_format.dart';
import '../domain/import_document_use_case.dart';
import '../domain/parsers/document_parser.dart';
import 'parsers/docx_document_parser.dart';
import 'parsers/pdf_document_parser.dart';
import 'parsers/txt_document_parser.dart';

class DefaultDocumentParserResolver implements DocumentParserResolver {
  DefaultDocumentParserResolver({PdfTextExtractor? pdfExtractor})
    : _pdfExtractor = pdfExtractor ?? const _UnavailablePdfTextExtractor();

  final PdfTextExtractor _pdfExtractor;

  @override
  DocumentParser forFormat(FileFormat format) => switch (format) {
    FileFormat.txt => const TxtDocumentParser(),
    FileFormat.docx => const DocxDocumentParser(),
    FileFormat.pdf => PdfDocumentParser(extractor: _pdfExtractor),
  };
}

class _UnavailablePdfTextExtractor implements PdfTextExtractor {
  const _UnavailablePdfTextExtractor();

  @override
  Stream<PdfPageText> extract(
    String path, {
    required ParseCancellationToken cancellationToken,
  }) async* {
    throw const PdfExtractionException(
      PdfExtractionError.unavailable,
      'PDF \u89e3\u6790\u5668\u5c1a\u672a\u5728\u6b64\u5e73\u53f0\u53ef\u7528\u3002',
    );
  }
}
