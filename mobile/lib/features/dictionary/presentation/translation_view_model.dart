import 'package:flutter/foundation.dart';

import '../../learning/data/learning_repository.dart';
import '../../phrases/domain/phrase_recognizer.dart';
import '../../documents/domain/models/parsed_block.dart';
import '../data/dictionary_repository.dart';

export '../../learning/data/learning_repository.dart'
    show LearningContext, LearningRepository, SavedPhraseDraft;

enum TranslationStatus { idle, loading, found, notFound, failed }

class TranslationState {
  const TranslationState({
    this.status = TranslationStatus.idle,
    this.surface = '',
    this.entry,
    this.phrases = const [],
    this.errorMessage,
  });

  final TranslationStatus status;
  final String surface;
  final DictionaryEntry? entry;
  final List<PhraseMatch> phrases;
  final String? errorMessage;
}

class TranslationViewModel extends ChangeNotifier {
  TranslationViewModel({
    required this.dictionary,
    required this.learning,
    required this.phraseRecognizer,
  });

  final DictionaryLookup dictionary;
  final LearningRepository learning;
  final PhraseRecognizer phraseRecognizer;

  TranslationState _state = const TranslationState();
  var _requestGeneration = 0;

  TranslationState get state => _state;

  Future<void> lookup({
    required List<TokenSpan> tokens,
    required int selectedTokenOrdinal,
  }) async {
    if (selectedTokenOrdinal < 0 || selectedTokenOrdinal >= tokens.length) {
      throw RangeError.index(
        selectedTokenOrdinal,
        tokens,
        'selectedTokenOrdinal',
      );
    }
    final generation = ++_requestGeneration;
    final selected = tokens[selectedTokenOrdinal];
    _setState(
      TranslationState(
        status: TranslationStatus.loading,
        surface: selected.surface,
      ),
    );

    try {
      final entry = await dictionary.lookup(selected.surface);
      if (generation != _requestGeneration) return;
      final phrases = phraseRecognizer.coveringToken(
        phraseRecognizer.recognize(tokens),
        selectedTokenOrdinal,
      );
      if (entry == null) {
        _setState(
          TranslationState(
            status: TranslationStatus.notFound,
            surface: selected.surface,
            phrases: phrases,
          ),
        );
        return;
      }

      _setState(
        TranslationState(
          status: TranslationStatus.found,
          surface: selected.surface,
          entry: entry,
          phrases: phrases,
        ),
      );
      if (entry.definitionChinese.trim().isNotEmpty) {
        await learning.recordLookup(
          surface: selected.surface,
          entry: entry,
          context: const LearningContext(),
        );
      }
    } on Object catch (error) {
      if (generation != _requestGeneration) return;
      _setState(
        TranslationState(
          status: TranslationStatus.failed,
          surface: selected.surface,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void clear() {
    _requestGeneration++;
    _setState(const TranslationState());
  }

  void _setState(TranslationState value) {
    _state = value;
    notifyListeners();
  }
}
