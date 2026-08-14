import 'package:flutter/foundation.dart';

import '../../learning/data/learning_repository.dart';
import '../../phrases/domain/phrase_recognizer.dart';
import '../../documents/domain/models/parsed_block.dart';
import '../data/dictionary_repository.dart';
import '../domain/layered_lookup.dart';
import '../domain/specialized_terms.dart';
import '../domain/term_candidate_recognizer.dart';

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
    this.sentence = '',
    this.specializedTerm,
    this.matchedCandidate,
  });

  final TranslationStatus status;
  final String surface;
  final DictionaryEntry? entry;
  final List<PhraseMatch> phrases;
  final String? errorMessage;

  /// The full sentence containing the tapped word, for the card's context.
  final String sentence;

  /// The specialized-dictionary hit, when present.
  final SpecializedTerm? specializedTerm;

  /// The multi-word term that produced [specializedTerm], if any.
  final TermCandidate? matchedCandidate;

  /// The term surface to present first (the matched term, else the tapped
  /// word).
  String get displaySurface => matchedCandidate?.surface ?? surface;
}

class TranslationViewModel extends ChangeNotifier {
  TranslationViewModel({
    required this.dictionary,
    required this.learning,
    required this.phraseRecognizer,
    SpecializedTermIndex? specializedIndex,
    this.enabledDomains = SpecializedDomain.values,
  }) : _layered = LayeredLookup(
         general: dictionary,
         specialized: specializedIndex,
       );

  final DictionaryLookup dictionary;
  final LearningRepository learning;
  final PhraseRecognizer phraseRecognizer;
  final LayeredLookup _layered;
  final List<SpecializedDomain> enabledDomains;

  TranslationState _state = const TranslationState();
  var _requestGeneration = 0;

  TranslationState get state => _state;

  Future<void> lookup({
    required List<TokenSpan> tokens,
    required int selectedTokenOrdinal,
    LearningContext context = const LearningContext(),
    bool autoSaveVocabulary = true,
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
    final sentence = tokens.map((token) => token.surface).join(' ');
    _setState(
      TranslationState(
        status: TranslationStatus.loading,
        surface: selected.surface,
        sentence: sentence,
      ),
    );

    try {
      final result = await _layered.lookup(
        tokens: tokens,
        tappedOrdinal: selectedTokenOrdinal,
        enabledDomains: enabledDomains,
      );
      if (generation != _requestGeneration) return;
      final phrases = phraseRecognizer.coveringToken(
        phraseRecognizer.recognize(tokens),
        selectedTokenOrdinal,
      );
      final entry = result.generalEntry;
      if (entry == null && result.specializedTerm == null) {
        _setState(
          TranslationState(
            status: TranslationStatus.notFound,
            surface: selected.surface,
            sentence: sentence,
            phrases: phrases,
          ),
        );
        return;
      }

      _setState(
        TranslationState(
          status: TranslationStatus.found,
          surface: selected.surface,
          sentence: sentence,
          entry: entry,
          specializedTerm: result.specializedTerm,
          matchedCandidate: result.matchedCandidate,
          phrases: phrases,
        ),
      );
      if (autoSaveVocabulary &&
          entry != null &&
          entry.definitionChinese.trim().isNotEmpty) {
        await learning.recordLookup(
          surface: selected.surface,
          entry: entry,
          context: context,
        );
      }
    } on Object catch (error) {
      if (generation != _requestGeneration) return;
      _setState(
        TranslationState(
          status: TranslationStatus.failed,
          surface: selected.surface,
          sentence: sentence,
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
