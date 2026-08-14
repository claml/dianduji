import 'package:flutter/foundation.dart';

import '../../dictionary/presentation/translation_view_model.dart';
import '../../documents/data/drift_document_repository.dart';
import '../../documents/domain/document_models.dart';
import '../../documents/domain/models/parsed_block.dart';
import '../../settings/data/reading_settings.dart';
import '../../phrases/domain/phrase_recognizer.dart';
import '../domain/reading_locator.dart';
import '../domain/reader_selection.dart';
import 'reader_view_model.dart';

class ReaderState {
  const ReaderState({
    this.document,
    this.sentences = const [],
    this.selectedSentenceId,
    this.selectedTokenId,
    this.selection,
    this.restoredSentenceId,
    this.restoredLocalOffset = 0,
    this.restoredPageNumber = 1,
    this.isLoading = false,
    this.error,
  });

  final StoredReaderDocument? document;
  final List<StoredReaderSentence> sentences;
  final String? selectedSentenceId;
  final String? selectedTokenId;
  final ReaderSelection? selection;
  final String? restoredSentenceId;
  final int restoredLocalOffset;
  final int restoredPageNumber;
  final bool isLoading;
  final Object? error;

  StoredReaderSentence requireSentence(String id) => sentences.firstWhere(
    (sentence) => sentence.id == id,
    orElse: () => throw StateError('Unknown sentence: $id'),
  );

  StoredReaderToken requireToken(String sentenceId, String tokenId) =>
      requireSentence(sentenceId).tokens.firstWhere(
        (token) => token.id == tokenId,
        orElse: () => throw StateError('Unknown token: $tokenId'),
      );

  ReaderState copyWith({
    StoredReaderDocument? document,
    List<StoredReaderSentence>? sentences,
    String? selectedSentenceId,
    String? selectedTokenId,
    ReaderSelection? selection,
    String? restoredSentenceId,
    int? restoredLocalOffset,
    int? restoredPageNumber,
    bool? isLoading,
    Object? error,
  }) => ReaderState(
    document: document ?? this.document,
    sentences: sentences ?? this.sentences,
    selectedSentenceId: selectedSentenceId ?? this.selectedSentenceId,
    selectedTokenId: selectedTokenId ?? this.selectedTokenId,
    selection: selection ?? this.selection,
    restoredSentenceId: restoredSentenceId ?? this.restoredSentenceId,
    restoredLocalOffset: restoredLocalOffset ?? this.restoredLocalOffset,
    restoredPageNumber: restoredPageNumber ?? this.restoredPageNumber,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

class ReaderController extends ChangeNotifier {
  ReaderController({
    required this.documents,
    required this.translation,
    required this.settings,
    Duration progressDelay = const Duration(milliseconds: 750),
  }) : _progress = ReaderProgressController(
         store: _DocumentProgressStore(documents),
         saveDelay: progressDelay,
       ) {
    translation.addListener(_onTranslationChanged);
  }

  final DocumentRepository documents;
  final TranslationViewModel translation;
  final ReaderProgressController _progress;
  ReadingSettings settings;
  ReaderState _state = const ReaderState();
  var _disposed = false;

  ReaderState get state => _state;
  void updateSettings(ReadingSettings value) => settings = value;

  Future<void> open(String documentId) async {
    if (_disposed) return;
    _setState(const ReaderState(isLoading: true));
    try {
      final document = await documents.loadReaderDocument(documentId);
      if (_disposed) return;
      final sentences = [...document.sentences]
        ..sort((left, right) => left.ordinal.compareTo(right.ordinal));
      final locator = document.lastLocator;
      _setState(
        ReaderState(
          document: document,
          sentences: sentences,
          restoredSentenceId: locator?.sentenceId,
          restoredLocalOffset: locator?.localOffset ?? 0,
          restoredPageNumber: locator?.pageNumber ?? 1,
        ),
      );
    } on Object catch (error) {
      if (!_disposed) _setState(ReaderState(error: error));
    }
  }

  Future<void> selectToken({
    required String sentenceId,
    required String tokenId,
  }) async {
    if (_disposed) return;
    final sentence = _state.requireSentence(sentenceId);
    final selected = _state.requireToken(sentenceId, tokenId);
    _setState(
      _state.copyWith(
        selectedSentenceId: sentenceId,
        selectedTokenId: tokenId,
        selection: ReaderSelection(
          surface: selected.surface,
          normalized: selected.normalized,
          contextText: sentence.text,
          startOffset: selected.startOffset,
          endOffset: selected.endOffset,
          sentenceId: sentenceId,
          tokenId: tokenId,
        ),
      ),
    );
    await translation.lookup(
      tokens: sentence.tokens
          .map(
            (token) => TokenSpan(
              surface: token.surface,
              normalized: token.normalized,
              start: token.startOffset,
              end: token.endOffset,
            ),
          )
          .toList(growable: false),
      selectedTokenOrdinal: selected.ordinal,
      context: LearningContext(
        documentId: _state.document?.id,
        documentTitle: _state.document?.title ?? '',
        sentence: sentence.text,
      ),
      autoSaveVocabulary: settings.autoSaveVocabulary,
    );
  }

  Future<void> selectExternalWord(ReaderSelection selection) async {
    if (_disposed) return;
    final resolved = await _resolveLineBreakWord(selection);
    _setState(
      ReaderState(
        document: _state.document,
        sentences: _state.sentences,
        selection: resolved,
        restoredSentenceId: _state.restoredSentenceId,
        restoredLocalOffset: _state.restoredLocalOffset,
        restoredPageNumber: _state.restoredPageNumber,
      ),
    );
    await translation.lookup(
      tokens: [
        TokenSpan(
          surface: resolved.surface,
          normalized: resolved.normalized,
          start: resolved.startOffset,
          end: resolved.endOffset,
        ),
      ],
      selectedTokenOrdinal: 0,
      context: LearningContext(
        documentId: _state.document?.id,
        documentTitle: _state.document?.title ?? '',
        sentence: resolved.contextText,
      ),
      autoSaveVocabulary: settings.autoSaveVocabulary,
    );
  }

  /// When the tapped word sits at a visual line break with a dropped hyphen
  /// (PDF engines often strip the break hyphen), try the joined forms against
  /// the dictionary first; the split halves only stay if the dictionary does
  /// not know any joined candidate.
  Future<ReaderSelection> _resolveLineBreakWord(
    ReaderSelection selection,
  ) async {
    final candidates = lineBreakJoinedCandidates(
      selection.contextText,
      selection.surface,
    );
    for (final joined in candidates) {
      if (joined == selection.surface) continue;
      final entry = await translation.dictionary.lookup(joined);
      if (entry == null) continue;
      return ReaderSelection(
        surface: joined,
        normalized: joined.toLowerCase().replaceAll('\u2019', "'"),
        contextText: selection.contextText,
        startOffset: selection.startOffset,
        endOffset: selection.endOffset,
        sentenceId: selection.sentenceId,
        tokenId: selection.tokenId,
        pageNumber: selection.pageNumber,
      );
    }
    return selection;
  }

  void closeTranslation() {
    translation.clear();
    _setState(
      ReaderState(
        document: _state.document,
        sentences: _state.sentences,
        restoredSentenceId: _state.restoredSentenceId,
        restoredLocalOffset: _state.restoredLocalOffset,
        restoredPageNumber: _state.restoredPageNumber,
      ),
    );
  }

  Future<void> savePhrase(PhraseMatch phrase) {
    final sentenceId = _state.selectedSentenceId;
    if (sentenceId == null) throw StateError('No selected sentence.');
    final sentence = _state.requireSentence(sentenceId);
    return translation.learning.savePhrase(
      SavedPhraseDraft(
        key: phrase.key,
        surface: phrase.surface,
        type: phrase.type,
        meaning: phrase.meaning,
        contextSentence: sentence.text,
        context: LearningContext(
          documentId: _state.document?.id,
          documentTitle: _state.document?.title ?? '',
          sentence: sentence.text,
        ),
      ),
    );
  }

  void updateReadingPosition({
    required String sentenceId,
    required int localOffset,
    required double progress,
  }) {
    if (_disposed || _state.document == null) return;
    final sentence = _state.requireSentence(sentenceId);
    _progress.update(
      ReadingLocator(
        documentId: _state.document!.id,
        paragraphId: sentence.paragraphId,
        sentenceId: sentence.id,
        localOffset: localOffset.clamp(0, sentence.text.length).toInt(),
      ),
      progress,
    );
  }

  void updatePdfReadingPosition({
    required int pageNumber,
    required int pageCount,
    int localOffset = 0,
  }) {
    if (_disposed || _state.document == null || pageNumber < 1) return;
    final safePageCount = pageCount < pageNumber ? pageNumber : pageCount;
    _progress.update(
      ReadingLocator(
        documentId: _state.document!.id,
        paragraphId: '',
        sentenceId: '',
        localOffset: localOffset < 0 ? 0 : localOffset,
        pageNumber: pageNumber,
      ),
      (pageNumber / safePageCount).clamp(0.0, 1.0),
    );
  }

  Future<void> forceSave() =>
      _disposed ? Future.value() : _progress.forceSave();

  void _onTranslationChanged() {
    if (!_disposed) notifyListeners();
  }

  void _setState(ReaderState value) {
    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    translation.removeListener(_onTranslationChanged);
    _progress.dispose();
    super.dispose();
  }
}

class _DocumentProgressStore implements ReadingProgressStore {
  const _DocumentProgressStore(this._documents);
  final DocumentRepository _documents;
  @override
  Future<void> save(ReadingLocator locator, double progress) =>
      _documents.saveProgress(locator, progress);
}
