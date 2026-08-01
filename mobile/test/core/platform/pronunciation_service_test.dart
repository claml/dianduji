import 'package:dian_du_ji/core/platform/android_pronunciation_service.dart';
import 'package:dian_du_ji/core/platform/pronunciation_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(PronunciationChannel.name);

  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null),
  );

  test(
    'maps unavailable local voice to an explicit unavailable result',
    () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => 'unavailable');

      expect(
        await AndroidPronunciationService().speak('word'),
        PronunciationResult.unavailable,
      );
    },
  );

  test('sends text to the offline pronunciation channel', () async {
    MethodCall? received;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          received = call;
          return 'spoken';
        });

    expect(
      await AndroidPronunciationService().speak('word'),
      PronunciationResult.spoken,
    );
    expect(received?.method, 'speak');
    expect(received?.arguments, {'text': 'word'});
  });
}
