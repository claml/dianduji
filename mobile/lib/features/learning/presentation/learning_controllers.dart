import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../phrases/domain/phrase_type.dart';
import '../data/csv_export_service.dart';
import '../data/learning_repository.dart';
import '../domain/csv_exporter.dart';

class VocabularyController extends ChangeNotifier {
  VocabularyController(this._repository, this._csvExportService) {
    _listen();
  }

  final LearningRepository _repository;
  final CsvExportService _csvExportService;
  VocabularyQuery _query = const VocabularyQuery();
  List<VocabularyListItem> entries = const [];
  StreamSubscription<List<VocabularyListItem>>? _subscription;

  VocabularyQuery get query => _query;

  void search(String value) => _changeQuery(
    VocabularyQuery(filter: _query.filter, sort: _query.sort, search: value),
  );

  void filter(VocabularyFilter value) => _changeQuery(
    VocabularyQuery(filter: value, sort: _query.sort, search: _query.search),
  );

  void sort(VocabularySort value) => _changeQuery(
    VocabularyQuery(filter: _query.filter, sort: value, search: _query.search),
  );

  Future<void> add(ManualVocabularyDraft draft) =>
      _repository.addManualVocabulary(draft);

  Future<void> setProficiency(String lemma, VocabularyProficiency value) =>
      _repository.updateProficiency(lemma, value);

  Future<void> delete(String lemma) => _repository.deleteVocabulary(lemma);

  Future<CsvExportResult> exportCsv() => _csvExportService.exportVocabulary(
    entries.map(
      (entry) => VocabularyExportRow(
        word: entry.displayWord,
        phonetic: entry.phonetic,
        partOfSpeech: entry.partOfSpeech,
        definition: entry.definition,
        proficiency: _proficiencyLabel(entry.proficiency),
        lookupCount: entry.lookupCount,
        source: entry.sourceAvailability == SourceAvailability.deleted
            ? '原文档已删除'
            : entry.sourceTitle,
      ),
    ),
  );

  void _changeQuery(VocabularyQuery value) {
    _query = value;
    notifyListeners();
    _listen();
  }

  void _listen() {
    unawaited(_subscription?.cancel());
    _subscription = _repository.watchVocabulary(_query).listen((value) {
      entries = value;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}

class PhraseBookController extends ChangeNotifier {
  PhraseBookController(this._repository) {
    _listen();
  }

  final LearningRepository _repository;
  SavedPhraseQuery _query = const SavedPhraseQuery();
  List<SavedPhraseListItem> entries = const [];
  StreamSubscription<List<SavedPhraseListItem>>? _subscription;

  SavedPhraseQuery get query => _query;

  void search(String value) =>
      _changeQuery(SavedPhraseQuery(type: _query.type, search: value));

  void filter(PhraseType? type) =>
      _changeQuery(SavedPhraseQuery(type: type, search: _query.search));

  Future<void> delete(String key) => _repository.deleteSavedPhrase(key);

  void _changeQuery(SavedPhraseQuery value) {
    _query = value;
    notifyListeners();
    _listen();
  }

  void _listen() {
    unawaited(_subscription?.cancel());
    _subscription = _repository.watchSavedPhrases(_query).listen((value) {
      entries = value;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}

String _proficiencyLabel(VocabularyProficiency value) => switch (value) {
  VocabularyProficiency.known => '认识',
  VocabularyProficiency.vague => '模糊',
  VocabularyProficiency.unknown => '陌生',
};
