import 'dart:async';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/platform/pdf_text_extractor.dart';
import '../../domain/models/parsed_block.dart';
import '../../domain/parsers/document_parser.dart';

class PdfDocumentParser implements DocumentParser {
  const PdfDocumentParser({
    required this.extractor,
    this.timeout = const Duration(minutes: 2),
  });

  final PdfTextExtractor extractor;
  final Duration timeout;

  @override
  Stream<ParseEvent> parse(ParseRequest request) async* {
    yield const ParseProgress(0);
    final path = request.localPath;
    if (path == null || path.isEmpty) {
      yield const ParseFailed(
        AppFailure(AppFailureCode.fileUnavailable, 'PDF 沙箱路径不可用。'),
      );
      return;
    }
    final cancellation = request.cancellationToken ?? ParseCancellationToken();
    var blockCount = 0;
    var expectedPage = 1;
    final pages = StreamIterator(
      extractor.extract(path, cancellationToken: cancellation),
    );

    try {
      while (await pages.moveNext().timeout(timeout)) {
        final page = pages.current;
        if (cancellation.isCancelled) {
          yield const ParseFailed(
            AppFailure(AppFailureCode.cancelled, '已取消 PDF 解析。'),
          );
          return;
        }
        if (page.pageNumber != expectedPage ||
            page.pageCount < page.pageNumber) {
          yield const ParseFailed(
            AppFailure(AppFailureCode.unknown, 'PDF 页面顺序无效。'),
          );
          return;
        }
        expectedPage++;
        if (page.text.trim().isNotEmpty) {
          yield ParsedBlockEvent(
            ParsedBlock(text: page.text, sourceIndex: page.pageNumber - 1),
          );
          blockCount++;
        }
        yield ParseProgress(page.pageNumber / page.pageCount);
      }

      if (cancellation.isCancelled) {
        yield const ParseFailed(
          AppFailure(AppFailureCode.cancelled, '已取消 PDF 解析。'),
        );
      } else if (blockCount == 0) {
        yield const ParseFailed(
          AppFailure(AppFailureCode.ocrRequired, 'PDF 中没有可提取文本，可能是扫描件，需要 OCR。'),
        );
      } else {
        yield ParseSucceeded(blockCount: blockCount);
      }
    } on TimeoutException catch (error) {
      cancellation.cancel();
      yield ParseFailed(
        AppFailure(AppFailureCode.timeout, 'PDF 解析超时。', cause: error),
      );
    } on PdfExtractionException catch (error) {
      yield ParseFailed(_mapExtractionFailure(error));
    } on Object catch (error) {
      yield ParseFailed(
        AppFailure(AppFailureCode.unknown, 'PDF 解析失败。', cause: error),
      );
    } finally {
      unawaited(pages.cancel());
    }
  }
}

AppFailure _mapExtractionFailure(PdfExtractionException exception) {
  return switch (exception.error) {
    PdfExtractionError.encrypted => const AppFailure(
      AppFailureCode.encryptedPdf,
      'PDF 已加密，请先移除密码。',
    ),
    PdfExtractionError.corrupt => AppFailure(
      AppFailureCode.unsupportedFormat,
      'PDF 文件损坏。',
      cause: exception,
    ),
    PdfExtractionError.unavailable => AppFailure(
      AppFailureCode.fileUnavailable,
      'PDF 文件不可用。',
      cause: exception,
    ),
    PdfExtractionError.cancelled => const AppFailure(
      AppFailureCode.cancelled,
      '已取消 PDF 解析。',
    ),
    PdfExtractionError.unknown => AppFailure(
      AppFailureCode.unknown,
      'PDF 解析失败。',
      cause: exception,
    ),
  };
}
