import 'dart:async';
import 'dart:typed_data';

import 'package:dian_du_ji/core/errors/app_failure.dart';
import 'package:dian_du_ji/core/platform/pdf_text_extractor.dart';
import 'package:dian_du_ji/features/documents/data/parsers/pdf_document_parser.dart';
import 'package:dian_du_ji/features/documents/domain/parsers/document_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('emits PDF pages in page order with progress', () async {
    final parser = PdfDocumentParser(
      extractor: _FakePdfExtractor(
        pages: const [
          PdfPageText(pageNumber: 1, pageCount: 2, text: 'Page one.'),
          PdfPageText(pageNumber: 2, pageCount: 2, text: 'Page two.'),
        ],
      ),
    );

    final events = await parser.parse(_request()).toList();

    expect(
      events.whereType<ParsedBlockEvent>().map((event) => event.block.text),
      ['Page one.', 'Page two.'],
    );
    expect(events.whereType<ParseProgress>().map((event) => event.progress), [
      0,
      0.5,
      1,
    ]);
    expect(events.last, isA<ParseSucceeded>());
  });

  test('maps encrypted files to a stable failure', () async {
    final parser = PdfDocumentParser(
      extractor: _FakePdfExtractor(
        error: const PdfExtractionException(PdfExtractionError.encrypted),
      ),
    );

    final events = await parser.parse(_request()).toList();

    expect(
      (events.last as ParseFailed).failure.code,
      AppFailureCode.encryptedPdf,
    );
  });

  test('maps pages without useful text to OCR required', () async {
    final parser = PdfDocumentParser(
      extractor: _FakePdfExtractor(
        pages: const [
          PdfPageText(pageNumber: 1, pageCount: 2, text: '   '),
          PdfPageText(pageNumber: 2, pageCount: 2, text: '\n'),
        ],
      ),
    );

    final events = await parser.parse(_request()).toList();

    expect(
      (events.last as ParseFailed).failure.code,
      AppFailureCode.ocrRequired,
    );
  });

  test('honors cancellation before another page is emitted', () async {
    final cancellation = ParseCancellationToken();
    final parser = PdfDocumentParser(
      extractor: _FakePdfExtractor(
        pages: const [
          PdfPageText(pageNumber: 1, pageCount: 2, text: 'Page one.'),
          PdfPageText(pageNumber: 2, pageCount: 2, text: 'Page two.'),
        ],
        onPageEmitted: (page) {
          if (page.pageNumber == 1) cancellation.cancel();
        },
      ),
    );

    final events = await parser
        .parse(_request(cancellationToken: cancellation))
        .toList();

    expect(events.whereType<ParsedBlockEvent>().length, 1);
    expect((events.last as ParseFailed).failure.code, AppFailureCode.cancelled);
  });

  test('times out a stalled native extractor', () async {
    final parser = PdfDocumentParser(
      extractor: const _NeverPdfExtractor(),
      timeout: const Duration(milliseconds: 20),
    );

    final events = await parser.parse(_request()).toList();

    expect((events.last as ParseFailed).failure.code, AppFailureCode.timeout);
  });
}

ParseRequest _request({ParseCancellationToken? cancellationToken}) =>
    ParseRequest(
      bytes: Uint8List(0),
      sourceName: 'lesson.pdf',
      localPath: 'sandbox/lesson.pdf',
      cancellationToken: cancellationToken,
    );

class _FakePdfExtractor implements PdfTextExtractor {
  const _FakePdfExtractor({
    this.pages = const [],
    this.error,
    this.onPageEmitted,
  });

  final List<PdfPageText> pages;
  final PdfExtractionException? error;
  final void Function(PdfPageText page)? onPageEmitted;

  @override
  Stream<PdfPageText> extract(
    String path, {
    required ParseCancellationToken cancellationToken,
  }) async* {
    if (error != null) throw error!;
    for (final page in pages) {
      if (cancellationToken.isCancelled) return;
      yield page;
      onPageEmitted?.call(page);
    }
  }
}

class _NeverPdfExtractor implements PdfTextExtractor {
  const _NeverPdfExtractor();

  @override
  Stream<PdfPageText> extract(
    String path, {
    required ParseCancellationToken cancellationToken,
  }) async* {
    await Completer<void>().future;
  }
}
