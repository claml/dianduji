enum PhraseType {
  phrasalVerb,
  prepositionalPhrase,
  collocation,
  idiom;

  String get storageValue => name;
}

abstract final class PhraseTypeCodec {
  static PhraseType fromStorage(String value) {
    return PhraseType.values.firstWhere(
      (type) => type.storageValue == value,
      orElse: () => throw FormatException('Unknown phrase type: $value'),
    );
  }
}
