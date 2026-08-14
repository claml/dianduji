import 'package:dian_du_ji/core/network/online_translation_gateway.dart';
import 'package:dian_du_ji/features/dictionary/domain/specialized_terms.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('short sentences are disclosed verbatim', () {
    const request = OnlineTranslationRequest(
      term: 'random forest',
      sentence: 'A random forest classifies samples.',
    );

    expect(request.disclosedSentence, 'A random forest classifies samples.');
  });

  test('long sentences are capped at 1000 chars and centered on the term', () {
    final padding = 'word ' * 400; // 2000 chars
    final request = OnlineTranslationRequest(
      term: 'TARGET',
      sentence: '${padding}TARGET$padding',
    );

    final disclosed = request.disclosedSentence;
    expect(disclosed.runes.length, OnlineTranslationRequest.maxSentenceLength);
    expect(disclosed, contains('TARGET'));
  });

  test('long sentences without the term keep the first 1000 chars', () {
    final padding = 'word ' * 400;
    final request = OnlineTranslationRequest(
      term: 'absent',
      sentence: padding,
    );

    final disclosed = request.disclosedSentence;
    expect(disclosed.runes.length, OnlineTranslationRequest.maxSentenceLength);
    expect(disclosed, startsWith('word word word'));
  });

  test('request exposes domain as a tag', () {
    const request = OnlineTranslationRequest(
      term: 'mitochondria',
      sentence: 'mitochondria produce ATP',
      domain: SpecializedDomain.biology,
    );

    expect(request.domain, SpecializedDomain.biology);
    expect(request.targetLanguage, 'zh');
  });
}
