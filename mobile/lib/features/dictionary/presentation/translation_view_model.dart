import 'package:flutter/foundation.dart';

import '../../../core/network/online_translation_gateway.dart';
import '../../learning/data/learning_repository.dart';
import '../../phrases/domain/phrase_recognizer.dart';
import '../../documents/domain/models/parsed_block.dart';
import '../data/dictionary_repository.dart';
import '../domain/layered_lookup.dart';
import '../domain/specialized_terms.dart';
import '../domain/term_candidate_recognizer.dart';
import '../domain/user_dictionary_repository.dart';

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
    this.fromUserDictionary = false,
    this.sentenceTranslation = '',
    this.sentenceTranslationStatus = OnlineTranslationStatus.none,
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

  /// Whether [entry] came from the user-grown dictionary.
  final bool fromUserDictionary;

  /// Whole-sentence translation requested explicitly by the user.
  final String sentenceTranslation;
  final OnlineTranslationStatus sentenceTranslationStatus;

  /// The term surface to present first (the matched term, else the tapped
  /// word).
  String get displaySurface => matchedCandidate?.surface ?? surface;

  TranslationState copyWith({
    TranslationStatus? status,
    String? surface,
    DictionaryEntry? entry,
    List<PhraseMatch>? phrases,
    String? errorMessage,
    String? sentence,
    SpecializedTerm? specializedTerm,
    TermCandidate? matchedCandidate,
    OnlineTranslationResult? onlineResult,
    OnlineTranslationStatus? onlineStatus,
    bool? fromUserDictionary,
    String? sentenceTranslation,
    OnlineTranslationStatus? sentenceTranslationStatus,
  }) {
    return TranslationState(
      status: status ?? this.status,
      surface: surface ?? this.surface,
      entry: entry ?? this.entry,
      phrases: phrases ?? this.phrases,
      errorMessage: errorMessage ?? this.errorMessage,
      sentence: sentence ?? this.sentence,
      specializedTerm: specializedTerm ?? this.specializedTerm,
      matchedCandidate: matchedCandidate ?? this.matchedCandidate,
      onlineResult: onlineResult ?? this.onlineResult,
      onlineStatus: onlineStatus ?? this.onlineStatus,
      fromUserDictionary: fromUserDictionary ?? this.fromUserDictionary,
      sentenceTranslation: sentenceTranslation ?? this.sentenceTranslation,
      sentenceTranslationStatus:
          sentenceTranslationStatus ?? this.sentenceTranslationStatus,
    );
  }
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
    UserDictionaryStore? userDictionary,
  }) : _layered = LayeredLookup(
         general: dictionary,
         specialized: specializedIndex,
         userDictionary: userDictionary,
       ),
       _userDictionary = userDictionary,
       // ignore: prefer_initializing_formals — private field, public name.
       _onlineEnabled = onlineEnabled;

  final DictionaryLookup dictionary;
  final LearningRepository learning;
  final PhraseRecognizer phraseRecognizer;
  final LayeredLookup _layered;
  final List<SpecializedDomain> enabledDomains;
  final OnlineTranslationGateway? onlineGateway;
  final UserDictionaryStore? _userDictionary;
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
      final entry = result.userEntry ?? result.generalEntry;
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
          fromUserDictionary: result.userEntry != null,
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
    if (!_onlineEnabled || gateway == null) {
      debugPrint(
        'ONLINE_LOOKUP skipped: enabled=$_onlineEnabled gateway=${gateway != null}',
      );
      return null;
    }
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
      debugPrint('ONLINE_LOOKUP ok: term=$term');
      // Grow the user dictionary: every online-translated word becomes a
      // candidate for later LLM enrichment and offline reuse.
      await _userDictionary?.collectCandidate(
        term,
        source: 'online-translation',
      );
      return result;
    } on Object catch (error) {
      // Online failure is non-fatal: keep the local result and mark the
      // supplement unavailable. The stale-request generation guard already
      // drops out-of-order responses. The term is logged (not the sentence)
      // so failures stay diagnosable without leaking document text.
      debugPrint('ONLINE_LOOKUP failed: term=$term error=$error');
      return null;
    }
  }

  void clear() {
    _requestGeneration++;
    _setState(const TranslationState());
  }

  /// Saves a user-written definition into the user dictionary. The reader
  /// card shows the entry on the next tap of the same word.
  Future<void> saveManualDefinition(ManualDictionaryEntry entry) async {
    await _userDictionary?.saveManualEntry(entry);
  }

  /// Translates the current sentence explicitly (whole-sentence translation).
  /// Requires the online gateway and the user's online switch; results are
  /// shown in the card below the original sentence.
  Future<void> translateSentence() async {
    final gateway = onlineGateway;
    final sentence = _state.sentence;
    if (!_onlineEnabled || gateway == null || sentence.isEmpty) return;
    final generation = ++_requestGeneration;
    _setState(
      _state.copyWith(
        sentenceTranslationStatus: OnlineTranslationStatus.loading,
      ),
    );
    try {
      final result = await gateway.translate(
        OnlineTranslationRequest(
          term: _state.displaySurface,
          sentence: sentence,
          domain: _state.matchedCandidate?.domain,
        ),
      );
      if (generation != _requestGeneration) return;
      _setState(
        _state.copyWith(
          sentenceTranslation: result.sentenceTranslation,
          sentenceTranslationStatus: OnlineTranslationStatus.available,
        ),
      );
    } on Object {
      if (generation != _requestGeneration) return;
      _setState(
        _state.copyWith(
          sentenceTranslationStatus: OnlineTranslationStatus.unavailable,
        ),
      );
    }
  }

  void _setState(TranslationState value) {
    _state = value;
    notifyListeners();
  }
}
