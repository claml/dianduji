import 'dart:async';
import 'dart:io';

import 'package:dian_du_ji/core/errors/app_failure.dart';
import 'package:dian_du_ji/features/documents/data/default_document_parser_resolver.dart';
import 'package:dian_du_ji/features/documents/data/default_import_intake.dart';
import 'package:dian_du_ji/features/documents/data/drift_document_repository.dart';
import 'package:dian_du_ji/features/documents/data/file_picker_document_picker.dart';
import 'package:dian_du_ji/features/documents/data/services/file_intake_service.dart';
import 'package:dian_du_ji/features/documents/domain/document_models.dart';
import 'package:dian_du_ji/features/documents/domain/import_document_use_case.dart';
import 'package:dian_du_ji/features/documents/domain/models/parsed_block.dart';
import 'package:dian_du_ji/features/documents/presentation/document_import_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'UTF-8, GB18030, and DOCX fixtures import through the controller',
    (tester) async {
      final supportDirectory = await getApplicationSupportDirectory();
      final fixtureDirectory = Directory(
        '${supportDirectory.path}${Platform.pathSeparator}import-fixtures',
      );
      await fixtureDirectory.create(recursive: true);
      addTearDown(() => fixtureDirectory.delete(recursive: true));
      final store = _FixtureStore();
      final importer = ImportDocumentUseCase(
        intake: DefaultImportIntake(
          FileIntakeService(
            sandboxDirectory: Directory(
              '${fixtureDirectory.path}${Platform.pathSeparator}sandbox',
            ),
          ),
        ),
        parsers: DefaultDocumentParserResolver(),
        store: store,
        createId: () => 'fixture-${store.created.length + 1}',
      );
      final controller = DocumentImportController(
        picker: const _NoSystemPicker(),
        importer: importer,
        repository: _FixtureRepository(),
      );
      addTearDown(controller.dispose);

      for (final name in const [
        'sample_utf8.txt',
        'sample_gb18030.txt',
        'sample.docx',
      ]) {
        final target = File(
          '${fixtureDirectory.path}${Platform.pathSeparator}$name',
        );
        await target.writeAsBytes(
          (await rootBundle.load(
            'integration_test/fixtures/$name',
          )).buffer.asUint8List(),
        );
        await controller.importSelectedFile(
          SelectedFile(path: target.path, originalName: name),
        );
      }

      expect(store.completed, hasLength(3));
      expect(
        controller.state.imports.values.every(
          (state) => state.status == ImportStatus.completed,
        ),
        isTrue,
      );
      expect(
        store.blocks.values
            .expand((blocks) => blocks)
            .map((block) => block.text)
            .join('\n'),
        contains('Hello'),
      );
    },
  );
}

class _NoSystemPicker implements DocumentPicker {
  const _NoSystemPicker();

  @override
  Future<SelectedFile?> pickDocument() async => null;
}

class _FixtureStore implements DocumentImportStore {
  final created = <ImportDocumentRecord>[];
  final completed = <String>[];
  final blocks = <String, List<ParsedBlock>>{};

  @override
  Future<void> clearStructure(String documentId) async =>
      blocks.remove(documentId);

  @override
  Future<void> createQueued(ImportDocumentRecord record) async =>
      created.add(record);

  @override
  Future<String?> findByContentHash(String hash) async => null;

  @override
  Future<void> markCancelled(String documentId) async {}

  @override
  Future<void> markCompleted(String documentId) async =>
      completed.add(documentId);

  @override
  Future<void> markFailed(String documentId, AppFailure failure) async {}

  @override
  Future<void> markParsing(String documentId) async {}

  @override
  Future<void> replaceStructure(
    String documentId,
    List<ParsedBlock> parsedBlocks,
  ) async {
    blocks[documentId] = parsedBlocks;
  }
}

class _FixtureRepository implements DocumentRepository {
  @override
  Future<void> deleteDocument(String documentId) async {}

  @override
  Future<StoredReaderDocument> loadReaderDocument(String documentId) =>
      throw UnimplementedError();

  @override
  Future<void> recoverInterruptedImports() async {}

  @override
  Future<void> saveProgress(locator, double progress) async {}

  @override
  Stream<List<DocumentSummary>> watchDocuments() => const Stream.empty();
}
