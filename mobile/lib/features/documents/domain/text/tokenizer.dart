import '../models/parsed_block.dart';

final _wordPattern = RegExp(
  r"[A-Za-z]+(?:['’][A-Za-z]+)*(?:-[A-Za-z]+(?:['’][A-Za-z]+)*)*",
  unicode: true,
);

List<TokenSpan> tokenize(String sentence) {
  return _wordPattern
      .allMatches(sentence)
      .map((match) {
        final surface = match.group(0)!;
        return TokenSpan(
          surface: surface,
          normalized: surface.replaceAll('’', "'").toLowerCase(),
          start: match.start,
          end: match.end,
        );
      })
      .toList(growable: false);
}
