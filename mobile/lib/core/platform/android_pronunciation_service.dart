import 'package:flutter/services.dart';

import 'pronunciation_service.dart';

class AndroidPronunciationService implements PronunciationService {
  AndroidPronunciationService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(PronunciationChannel.name);

  final MethodChannel _channel;

  @override
  Future<PronunciationResult> speak(String text) async {
    if (text.trim().isEmpty) return PronunciationResult.unavailable;
    try {
      final result = await _channel.invokeMethod<String>('speak', {
        'text': text,
      });
      return result == 'spoken'
          ? PronunciationResult.spoken
          : PronunciationResult.unavailable;
    } on PlatformException {
      return PronunciationResult.unavailable;
    } on MissingPluginException {
      return PronunciationResult.unavailable;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _channel.invokeMethod<void>('stop');
    } on PlatformException {
      // A missing local voice is intentionally not a network fallback.
    } on MissingPluginException {
      // The platform channel is unavailable outside Android.
    }
  }
}
