import 'dart:io';

import 'package:pdfrx/pdfrx.dart' as pdfrx;

import 'pdf_text_extractor.dart';

class PdfrxPdfTextExtractor implements PdfTextExtractor {
  const PdfrxPdfTextExtractor();

  @override
  Stream<PdfPageText> extract(
    String path, {
    required ParseCancellationToken cancellationToken,
  }) async* {
    if (cancellationToken.isCancelled) {
      throw const PdfExtractionException(PdfExtractionError.cancelled);
    }
    if (!await File(path).exists()) {
      throw const PdfExtractionException(
        PdfExtractionError.unavailable,
        'PDF file is unavailable.',
      );
    }

    pdfrx.PdfDocument? document;
    try {
      document = await pdfrx.PdfDocument.openFile(
        path,
        useProgressiveLoading: false,
      );
      final pageCount = document.pages.length;
      for (final page in document.pages) {
        if (cancellationToken.isCancelled) {
          throw const PdfExtractionException(PdfExtractionError.cancelled);
        }
        final text = await page.loadStructuredText();
        if (cancellationToken.isCancelled) {
          throw const PdfExtractionException(PdfExtractionError.cancelled);
        }
        yield PdfPageText(
          pageNumber: page.pageNumber,
          pageCount: pageCount,
          text: text.fullText,
        );
      }
    } on PdfExtractionException {
      rethrow;
    } on pdfrx.PdfPasswordException catch (error) {
      throw PdfExtractionException(PdfExtractionError.encrypted, error.message);
    } on pdfrx.PdfException catch (error) {
      final extractionError = switch (error.errorCode) {
        2 => PdfExtractionError.unavailable,
        3 => PdfExtractionError.corrupt,
        4 => PdfExtractionError.encrypted,
        _ => PdfExtractionError.unknown,
      };
      throw PdfExtractionException(extractionError, error.message);
    } on FileSystemException catch (error) {
      throw PdfExtractionException(
        PdfExtractionError.unavailable,
        error.message,
      );
    } on Object catch (error) {
      throw PdfExtractionException(
        PdfExtractionError.unknown,
        error.toString(),
      );
    } finally {
      if (document != null) await document.dispose();
    }
  }
}
