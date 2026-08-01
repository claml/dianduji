import 'dart:async';

import 'package:dian_du_ji/features/dictionary/data/dictionary_repository.dart';
import 'package:dian_du_ji/features/learning/data/learning_repository.dart';
import 'package:dian_du_ji/features/dictionary/presentation/translation_view_model.dart';
import 'package:dian_du_ji/features/documents/data/drift_document_repository.dart';
import 'package:dian_du_ji/features/documents/domain/document_models.dart';
import 'package:dian_du_ji/features/phrases/domain/phrase_recognizer.dart';
import 'package:dian_du_ji/features/phrases/domain/phrase_type.dart';
import 'package:dian_du_ji/features/reader/domain/reading_locator.dart';
import 'package:dian_du_ji/features/reader/domain/reader_selection.dart';
import 'package:dian_du_ji/features/reader/presentation/reader_controller.dart';
import 'package:dian_du_ji/features/settings/data/reading_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _Documents documents;
  late _Dictionary dictionary;
  late ReaderController controller;

  setUp(() {
    documents = _Documents();
    dictionary = _Dictionary();
    controller = ReaderController(
      documents: documents,
      translation: TranslationViewModel(
        dictionary: dictionary,
        learning: const _Learning(),
        phraseRecognizer: PhraseRecognizer(const []),
      ),
      settings: ReadingSettings(),
      progressDelay: Duration.zero,
    );
  });

  test(
    'loads stored sentences in ordinal order and restores by locator',
    () async {
      documents.document = _document(lastLocator: _locator('s1', 2));

      await controller.open('doc-1');

      expect(controller.state.sentences.map((sentence) => sentence.id), [
        's1',
        's2',
      ]);
      expect(controller.state.restoredSentenceId, 's1');
      expect(controller.state.restoredLocalOffset, 2);
    },
  );

  test('tap selects immediately and dispatches exactly one lookup', () async {
    documents.document = _document();
    dictionary.pending = Completer<DictionaryEntry?>();
    await controller.open('doc-1');

    final future = controller.selectToken(sentenceId: 's1', tokenId: 't2');

    expect(controller.state.selectedTokenId, 't2');
    expect(controller.state.selectedSentenceId, 's1');
    expect(dictionary.calls, 1);
    dictionary.pending!.complete(null);
    await future;
  });

  test('selects a visible PDF word without inventing stored ids', () async {
    documents.document = _document();
    await controller.open('doc-1');

    await controller.selectExternalWord(
      const ReaderSelection(
        surface: 'Models',
        normalized: 'models',
        contextText: 'Foundation Models improve language understanding.',
        pageNumber: 1,
        startOffset: 11,
        endOffset: 17,
      ),
    );

    expect(controller.state.selection?.surface, 'Models');
    expect(controller.state.selectedSentenceId, isNull);
    expect(controller.state.selectedTokenId, isNull);
    expect(controller.translation.state.surface, 'Models');
    expect(dictionary.surfaces, ['Models']);
    expect(
      () => controller.savePhrase(
        const PhraseMatch(
          key: 'foundation-models',
          surface: 'Foundation Models',
          type: PhraseType.collocation,
          meaning: '基础模型',
          confidence: 1,
          startTokenOrdinal: 0,
          endTokenOrdinal: 1,
        ),
      ),
      throwsStateError,
    );
  });

  test('restores and saves PDF page progress', () async {
    documents.document = StoredReaderDocument(
      id: 'doc-1',
      title: 'Paper',
      format: 'pdf',
      localPath: 'paper.pdf',
      readProgress: 0.4,
      sentences: const [],
      lastLocator: const ReadingLocator(
        documentId: 'doc-1',
        paragraphId: '',
        sentenceId: '',
        localOffset: 0,
        pageNumber: 4,
      ),
    );
    await controller.open('doc-1');

    expect(controller.state.restoredPageNumber, 4);
    controller.updatePdfReadingPosition(
      pageNumber: 6,
      pageCount: 10,
      localOffset: 11,
    );
    await controller.forceSave();

    expect(documents.saved.single.$1.pageNumber, 6);
    expect(documents.saved.single.$1.localOffset, 11);
    expect(documents.saved.single.$2, 0.6);
  });

  test(
    'records a sentence locator, force-saves it, and never saves after dispose',
    () async {
      documents.document = _document();
      await controller.open('doc-1');

      controller.updateReadingPosition(
        sentenceId: 's2',
        localOffset: 3,
        progress: 0.8,
      );
      await controller.forceSave();
      expect(documents.saved, [(_locator('s2', 3), 0.8)]);

      controller.dispose();
      controller.updateReadingPosition(
        sentenceId: 's1',
        localOffset: 0,
        progress: 0.2,
      );
      await Future<void>.delayed(Duration.zero);
      expect(documents.saved, [(_locator('s2', 3), 0.8)]);
    },
  );

  test(
    'saves a selected phrase once with the selected sentence context',
    () async {
      final learning = _SavingLearning();
      controller = ReaderController(
        documents: documents,
        translation: TranslationViewModel(
          dictionary: dictionary,
          learning: learning,
          phraseRecognizer: PhraseRecognizer(const []),
        ),
        settings: ReadingSettings(),
      );
      await controller.open('doc-1');
      await controller.selectToken(sentenceId: 's1', tokenId: 't2');

      await controller.savePhrase(
        const PhraseMatch(
          key: 'first-word',
          surface: 'First word',
          type: PhraseType.collocation,
          meaning: '第一词',
          confidence: 1,
          startTokenOrdinal: 0,
          endTokenOrdinal: 1,
        ),
      );

      expect(learning.saved, hasLength(1));
      expect(learning.saved.single.context.documentId, 'doc-1');
      expect(learning.saved.single.context.documentTitle, 'Lesson');
      expect(learning.saved.single.contextSentence, 'First word.');
    },
  );
}

StoredReaderDocument _document({ReadingLocator? lastLocator}) =>
    StoredReaderDocument(
      id: 'doc-1',
      title: 'Lesson',
      readProgress: 0.2,
      lastLocator: lastLocator,
      sentences: const [
        StoredReaderSentence(
          id: 's2',
          paragraphId: 'p1',
          ordinal: 2,
          text: 'Second.',
          startOffset: 8,
          endOffset: 15,
          tokens: [
            StoredReaderToken(
              id: 't3',
              ordinal: 0,
              surface: 'Second',
              normalized: 'second',
              lemma: 'second',
              startOffset: 0,
              endOffset: 6,
            ),
          ],
        ),
        StoredReaderSentence(
          id: 's1',
          paragraphId: 'p1',
          ordinal: 1,
          text: 'First word.',
          startOffset: 0,
          endOffset: 7,
          tokens: [
            StoredReaderToken(
              id: 't1',
              ordinal: 0,
              surface: 'First',
              normalized: 'first',
              lemma: 'first',
              startOffset: 0,
              endOffset: 5,
            ),
            StoredReaderToken(
              id: 't2',
              ordinal: 1,
              surface: 'word',
              normalized: 'word',
              lemma: 'word',
              startOffset: 6,
              endOffset: 10,
            ),
          ],
        ),
      ],
    );

ReadingLocator _locator(String sentenceId, int offset) => ReadingLocator(
  documentId: 'doc-1',
  paragraphId: 'p1',
  sentenceId: sentenceId,
  localOffset: offset,
);

class _Dictionary implements DictionaryLookup {
  var calls = 0;
  final surfaces = <String>[];
  Completer<DictionaryEntry?>? pending;
  @override
  Future<DictionaryEntry?> lookup(String surface) {
    calls++;
    surfaces.add(surface);
    return pending?.future ?? Future.value(null);
  }
}

class _Documents implements DocumentRepository {
  StoredReaderDocument document = _document();
  final saved = <(ReadingLocator, double)>[];
  @override
  Future<void> deleteDocument(String id) async {}
  @override
  Future<StoredReaderDocument> loadReaderDocument(String id) async => document;
  @override
  Future<void> recoverInterruptedImports() async {}
  @override
  Future<void> saveProgress(ReadingLocator locator, double progress) async =>
      saved.add((locator, progress));
  @override
  Stream<List<DocumentSummary>> watchDocuments() => const Stream.empty();
}

class _Learning implements LearningRepository {
  const _Learning();
  @override
  Future<void> recordLookup({
    required String surface,
    required DictionaryEntry entry,
    required LearningContext context,
  }) async {}
  @override
  Future<void> savePhrase(SavedPhraseDraft phrase) async {}
  @override
  Stream<List<VocabularyListItem>> watchVocabulary(VocabularyQuery query) =>
      const Stream.empty();
  @override
  Stream<List<SavedPhraseListItem>> watchSavedPhrases(SavedPhraseQuery query) =>
      const Stream.empty();
  @override
  Future<void> addManualVocabulary(ManualVocabularyDraft draft) async {}
  @override
  Future<void> updateProficiency(
    String lemma,
    VocabularyProficiency value,
  ) async {}
  @override
  Future<void> deleteVocabulary(String lemma) async {}
  @override
  Future<void> deleteSavedPhrase(String phraseKey) async {}
}

class _SavingLearning implements LearningRepository {
  final saved = <SavedPhraseDraft>[];
  @override
  Future<void> recordLookup({
    required String surface,
    required DictionaryEntry entry,
    required LearningContext context,
  }) async {}
  @override
  Future<void> savePhrase(SavedPhraseDraft phrase) async => saved.add(phrase);
  @override
  Stream<List<VocabularyListItem>> watchVocabulary(VocabularyQuery query) =>
      const Stream.empty();
  @override
  Stream<List<SavedPhraseListItem>> watchSavedPhrases(SavedPhraseQuery query) =>
      const Stream.empty();
  @override
  Future<void> addManualVocabulary(ManualVocabularyDraft draft) async {}
  @override
  Future<void> updateProficiency(
    String lemma,
    VocabularyProficiency value,
  ) async {}
  @override
  Future<void> deleteVocabulary(String lemma) async {}
  @override
  Future<void> deleteSavedPhrase(String phraseKey) async {}
}
