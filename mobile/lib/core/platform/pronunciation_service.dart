enum PronunciationResult { spoken, unavailable }

abstract interface class PronunciationService {
  Future<PronunciationResult> speak(String text);
  Future<void> stop();
}

abstract final class PronunciationChannel {
  static const name = 'com.dianduji.dian_du_ji/pronunciation';
}
