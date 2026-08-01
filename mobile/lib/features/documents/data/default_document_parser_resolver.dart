import '../../../core/platform/pdf_text_extractor.dart';
import '../../../core/platform/pdfrx_pdf_text_extractor.dart';
import '../domain/file_format.dart';
import '../domain/import_document_use_case.dart';
import '../domain/parsers/document_parser.dart';
import 'parsers/docx_document_parser.dart';
import 'parsers/pdf_document_parser.dart';
import 'parsers/txt_document_parser.dart';

class DefaultDocumentParserResolver implements DocumentParserResolver {
  DefaultDocumentParserResolver({PdfTextExtractor? pdfExtractor})
    : _pdfExtractor = pdfExtractor ?? const PdfrxPdfTextExtractor();

  final PdfTextExtractor _pdfExtractor;

  @override
  DocumentParser forFormat(FileFormat format) => switch (format) {
    FileFormat.txt => const TxtDocumentParser(),
    FileFormat.docx => const DocxDocumentParser(),
    FileFormat.pdf => PdfDocumentParser(extractor: _pdfExtractor),
  };
}
