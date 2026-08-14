import 'dart:async';
import 'dart:math' as math;

import 'package:dian_du_ji/app/app.dart';
import 'package:dian_du_ji/app/providers.dart';
import 'package:dian_du_ji/core/platform/pdf_text_extractor.dart';
import 'package:dian_du_ji/features/documents/data/drift_document_repository.dart';
import 'package:dian_du_ji/features/documents/data/file_picker_document_picker.dart';
import 'package:dian_du_ji/features/documents/data/services/file_intake_service.dart';
import 'package:dian_du_ji/features/documents/domain/document_models.dart';
import 'package:dian_du_ji/features/documents/domain/import_document_use_case.dart';
import 'package:dian_du_ji/features/documents/presentation/document_import_controller.dart';
import 'package:dian_du_ji/features/dictionary/data/dictionary_repository.dart';
import 'package:dian_du_ji/features/dictionary/domain/user_dictionary_repository.dart';
import 'package:dian_du_ji/features/learning/data/learning_repository.dart';
import 'package:dian_du_ji/features/settings/data/reading_settings.dart';
import 'package:dian_du_ji/features/settings/data/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Night-theme regression gate: every page background must be dark and every
/// primary scaffold text color light when the reader theme is night.
void main() {
  testWidgets('night theme darkens every page background', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final settings = _SettingsRepository()
      ..value = ReadingSettings(theme: ReaderTheme.night);
    await tester.pumpWidget(_app(settings));
    await tester.pumpAndSettle();

    final pages = <String, List<String>>{
      '文档': ['文档'],
      '生词': ['生词本'],
      '短语': ['短语本'],
      '设置': ['阅读外观'],
    };
    for (final entry in pages.entries) {
      await tester.tap(find.text(entry.key).last);
      await tester.pumpAndSettle();
      expect(find.text(entry.value.first), findsWidgets);

      final context = tester.element(find.byType(Scaffold).first);
      final theme = Theme.of(context);
      final background = theme.scaffoldBackgroundColor;
      expect(
        _luminance(background),
        lessThan(0.2),
        reason: '${entry.key} page background should be dark in night mode, '
            'got $background',
      );
      expect(
        _luminance(theme.colorScheme.onSurface),
        greaterThan(0.5),
        reason: '${entry.key} page text should be light in night mode',
      );
    }
  });

  testWidgets('night theme darkens the reader document surface', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final settings = _SettingsRepository()
      ..value = ReadingSettings(theme: ReaderTheme.night);
    await tester.pumpWidget(_app(settings));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold).first);
    final theme = Theme.of(context);
    expect(_luminance(theme.colorScheme.surface), lessThan(0.2));
    expect(_luminance(theme.colorScheme.onSurface), greaterThan(0.5));
  });
}

Widget _app(_SettingsRepository settings) => ProviderScope(
  overrides: [
    documentImportControllerProvider.overrideWith((ref) {
      final controller = DocumentImportController(
        picker: const _Picker(),
        importer: const _Importer(),
        repository: const _Repository(),
      );
      return controller;
    }),
    learningRepositoryProvider.overrideWithValue(const _LearningRepository()),
    settingsRepositoryProvider.overrideWithValue(settings),
    userDictionaryProvider.overrideWithValue(const _UserDictionary()),
  ],
  child: const DianDuJiApp(),
);

double _luminance(Color color) {
  double channel(double value) {
    final linear = value <= 0.03928
        ? value / 12.92
        : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
    return linear;
  }

  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

class _Picker implements DocumentPicker {
  const _Picker();
  @override
  Future<SelectedFile?> pickDocument() async => null;
}

class _Importer implements DocumentImporter {
  const _Importer();
  @override
  Stream<ImportState> start(
    SelectedFile file, {
    ParseCancellationToken? cancellationToken,
  }) => const Stream.empty();
  @override
  Stream<ImportState> retry(
    String id,
    SelectedFile file, {
    ParseCancellationToken? cancellationToken,
  }) => const Stream.empty();
}

class _Repository implements DocumentRepository {
  const _Repository();
  @override
  Future<void> deleteDocument(String id) async {}
  @override
  Future<StoredReaderDocument> loadReaderDocument(String id) =>
      throw UnimplementedError();
  @override
  Future<void> recoverInterruptedImports() async {}
  @override
  Future<void> saveProgress(locator, double progress) async {}
  @override
  Stream<List<DocumentSummary>> watchDocuments() => const Stream.empty();
}

class _SettingsRepository implements SettingsRepository {
  final _changes = StreamController<ReadingSettings>.broadcast();
  ReadingSettings value = ReadingSettings();

  @override
  Future<ReadingSettings> load() async => value;

  @override
  Future<void> save(ReadingSettings settings) async {
    value = settings;
    _changes.add(settings);
  }

  @override
  Stream<ReadingSettings> watch() async* {
    yield value;
    yield* _changes.stream;
  }

  void dispose() => _changes.close();
}

class _LearningRepository implements LearningRepository {
  const _LearningRepository();

  @override
  Stream<List<VocabularyListItem>> watchVocabulary(VocabularyQuery query) =>
      const Stream.empty();

  @override
  Stream<List<SavedPhraseListItem>> watchSavedPhrases(SavedPhraseQuery query) =>
      const Stream.empty();

  @override
  Future<void> addManualVocabulary(ManualVocabularyDraft draft) async {}

  @override
  Future<void> deleteSavedPhrase(String phraseKey) async {}

  @override
  Future<void> deleteVocabulary(String lemma) async {}

  @override
  Future<void> recordLookup({
    required String surface,
    required DictionaryEntry entry,
    required LearningContext context,
  }) async {}

  @override
  Future<void> savePhrase(SavedPhraseDraft phrase) async {}

  @override
  Future<void> updateProficiency(
    String lemma,
    VocabularyProficiency value,
  ) async {}
}

class _UserDictionary implements UserDictionaryStore {
  const _UserDictionary();

  @override
  Future<void> applyEnrichment(List<EnrichedDictionaryEntry> entries) async {}

  @override
  Future<void> clearCandidates() async {}

  @override
  Future<void> collectCandidate(String surface, {String source = ''}) async {}

  @override
  Future<void> saveManualEntry(ManualDictionaryEntry entry) async {}

  @override
  Future<List<ManualDictionaryEntry>> listManualEntries() async => const [];

  @override
  Future<void> deleteManualEntry(String surface) async {}

  @override
  Future<DictionaryEntry?> lookupConfirmed(String surface) async => null;

  @override
  Future<int> pendingCandidateCount() async => 0;

  @override
  Future<List<UserDictionaryCandidate>> pendingCandidates() async => const [];
}
