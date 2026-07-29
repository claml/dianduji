import 'dart:convert';

class ReadingLocator {
  const ReadingLocator({
    required this.documentId,
    required this.paragraphId,
    required this.sentenceId,
    required this.localOffset,
  });

  final String documentId;
  final String paragraphId;
  final String sentenceId;
  final int localOffset;

  String encode() => jsonEncode({
    'documentId': documentId,
    'paragraphId': paragraphId,
    'sentenceId': sentenceId,
    'localOffset': localOffset,
  });

  factory ReadingLocator.decode(String value) {
    final json = jsonDecode(value);
    if (json is! Map<String, Object?> ||
        json['documentId'] is! String ||
        json['paragraphId'] is! String ||
        json['sentenceId'] is! String ||
        json['localOffset'] is! int) {
      throw const FormatException('Invalid reading locator.');
    }
    return ReadingLocator(
      documentId: json['documentId']! as String,
      paragraphId: json['paragraphId']! as String,
      sentenceId: json['sentenceId']! as String,
      localOffset: json['localOffset']! as int,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ReadingLocator &&
      other.documentId == documentId &&
      other.paragraphId == paragraphId &&
      other.sentenceId == sentenceId &&
      other.localOffset == localOffset;

  @override
  int get hashCode =>
      Object.hash(documentId, paragraphId, sentenceId, localOffset);
}
