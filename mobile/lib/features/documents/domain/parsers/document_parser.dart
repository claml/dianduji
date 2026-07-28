import 'dart:typed_data';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/platform/pdf_text_extractor.dart';
import '../models/parsed_block.dart';

class ParseRequest {
  const ParseRequest({
    required this.bytes,
    required this.sourceName,
    this.localPath,
    this.cancellationToken,
  });

  final Uint8List bytes;
  final String sourceName;
  final String? localPath;
  final ParseCancellationToken? cancellationToken;
}

sealed class ParseEvent {
  const ParseEvent();
}

class ParseProgress extends ParseEvent {
  const ParseProgress(this.progress);

  final double progress;
}

class ParsedBlockEvent extends ParseEvent {
  const ParsedBlockEvent(this.block);

  final ParsedBlock block;
}

sealed class ParseTerminalEvent extends ParseEvent {
  const ParseTerminalEvent();
}

class ParseSucceeded extends ParseTerminalEvent {
  const ParseSucceeded({required this.blockCount});

  final int blockCount;
}

class ParseFailed extends ParseTerminalEvent {
  const ParseFailed(this.failure);

  final AppFailure failure;
}

abstract interface class DocumentParser {
  Stream<ParseEvent> parse(ParseRequest request);
}
