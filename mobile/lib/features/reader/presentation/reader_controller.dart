import 'package:flutter/foundation.dart';

import '../../dictionary/presentation/translation_view_model.dart';
import '../../documents/data/drift_document_repository.dart';
import '../../documents/domain/document_models.dart';
import '../../documents/domain/models/parsed_block.dart';
import '../../settings/data/reading_settings.dart';
import '../../phrases/domain/phrase_recognizer.dart';
import '../domain/reading_locator.dart';
import 'reader_view_model.dart';

class ReaderState {
  const ReaderState({
    this.document,
    this.sentences = const [],
    this.selectedSentenceId,
    this.selectedTokenId,
    this.restoredSentenceId,
    this.restoredLocalOffset = 0,
    this.isLoading = false,
    this.error,
  });

  final StoredReaderDocument? document;
  final List<StoredReaderSentence> sentences;
  final String? selectedSentenceId;
  final String? selectedTokenId;
  final String? restoredSentenceId;
  final int restoredLocalOffset;
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
    String? restoredSentenceId,
    int? restoredLocalOffset,
    bool? isLoading,
    Object? error,
  }) => ReaderState(
    document: document ?? this.document,
    sentences: sentences ?? this.sentences,
    selectedSentenceId: selectedSentenceId ?? this.selectedSentenceId,
    selectedTokenId: selectedTokenId ?? this.selectedTokenId,
    restoredSentenceId: restoredSentenceId ?? this.restoredSentenceId,
    restoredLocalOffset: restoredLocalOffset ?? this.restoredLocalOffset,
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
      _setState(ReaderState(
        document: document,
        sentences: sentences,
        restoredSentenceId: locator?.sentenceId,
        restoredLocalOffset: locator?.localOffset ?? 0,
      ));
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
    _setState(_state.copyWith(
      selectedSentenceId: sentenceId,
      selectedTokenId: tokenId,
    ));
    await translation.lookup(
      tokens: sentence.tokens
          .map((token) => TokenSpan(
            surface: token.surface,
            normalized: token.normalized,
            start: token.startOffset,
            end: token.endOffset,
          ))
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

  void closeTranslation() {
    translation.clear();
    _setState(ReaderState(
      document: _state.document,
      sentences: _state.sentences,
      restoredSentenceId: _state.restoredSentenceId,
      restoredLocalOffset: _state.restoredLocalOffset,
    ));
  }

  Future<void> savePhrase(PhraseMatch phrase) {
    final sentenceId = _state.selectedSentenceId;
    if (sentenceId == null) throw StateError('No selected sentence.');
    final sentence = _state.requireSentence(sentenceId);
    return translation.learning.savePhrase(SavedPhraseDraft(
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
    ));
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

  Future<void> forceSave() => _disposed ? Future.value() : _progress.forceSave();

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
