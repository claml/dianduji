import 'package:flutter/foundation.dart';

import '../../../core/network/online_translation_gateway.dart';
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

/// Whether an online translation supplement is present, in flight, or
/// unavailable (offline/disabled).
enum OnlineTranslationStatus { none, loading, available, unavailable }

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
    this.onlineResult,
    this.onlineStatus = OnlineTranslationStatus.none,
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

  /// The online translation supplement, when it has arrived.
  final OnlineTranslationResult? onlineResult;

  final OnlineTranslationStatus onlineStatus;

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
    this.onlineGateway,
    // ignore: prefer_initializing_formals — private field, public name.
    bool onlineEnabled = false,
  }) : _layered = LayeredLookup(
         general: dictionary,
         specialized: specializedIndex,
       ),
       // ignore: prefer_initializing_formals — private field, public name.
       _onlineEnabled = onlineEnabled;

  final DictionaryLookup dictionary;
  final LearningRepository learning;
  final PhraseRecognizer phraseRecognizer;
  final LayeredLookup _layered;
  final List<SpecializedDomain> enabledDomains;
  final OnlineTranslationGateway? onlineGateway;
  var _onlineEnabled = false;

  /// Updates the online fallback switch at runtime (e.g. when the settings
  /// page toggles it while the reader is open).
  set onlineEnabled(bool value) => _onlineEnabled = value;

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
        final online = await _lookupOnline(
          tokens: tokens,
          selectedTokenOrdinal: selectedTokenOrdinal,
          matchedCandidate: result.matchedCandidate,
          sentence: sentence,
          generation: generation,
        );
        if (generation != _requestGeneration) return;
        if (online != null) {
          _setState(
            TranslationState(
              status: TranslationStatus.found,
              surface: selected.surface,
              sentence: sentence,
              phrases: phrases,
              matchedCandidate: result.matchedCandidate,
              onlineResult: online,
              onlineStatus: OnlineTranslationStatus.available,
            ),
          );
          return;
        }
        _setState(
          TranslationState(
            status: TranslationStatus.notFound,
            surface: selected.surface,
            sentence: sentence,
            phrases: phrases,
            onlineStatus:
                !_onlineEnabled || onlineGateway == null
                ? OnlineTranslationStatus.none
                : OnlineTranslationStatus.unavailable,
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

  Future<OnlineTranslationResult?> _lookupOnline({
    required List<TokenSpan> tokens,
    required int selectedTokenOrdinal,
    required TermCandidate? matchedCandidate,
    required String sentence,
    required int generation,
  }) async {
    final gateway = onlineGateway;
    if (!_onlineEnabled || gateway == null) return null;
    final term = matchedCandidate?.surface ?? tokens[selectedTokenOrdinal].surface;
    try {
      final result = await gateway.translate(
        OnlineTranslationRequest(
          term: term,
          sentence: sentence,
          domain: matchedCandidate?.domain,
        ),
      );
      if (generation != _requestGeneration) return null;
      return result;
    } on Object {
      // Online failure is non-fatal: keep the local result and mark the
      // supplement unavailable. The stale-request generation guard already
      // drops out-of-order responses.
      return null;
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
