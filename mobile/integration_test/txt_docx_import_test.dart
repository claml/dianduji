import 'dart:io';

import 'package:dian_du_ji/app/app_runtime.dart';
import 'package:dian_du_ji/core/database/app_database.dart';
import 'package:dian_du_ji/features/documents/data/default_document_parser_resolver.dart';
import 'package:dian_du_ji/features/documents/data/default_import_intake.dart';
import 'package:dian_du_ji/features/documents/data/drift_document_import_store.dart';
import 'package:dian_du_ji/features/documents/data/drift_document_repository.dart';
import 'package:dian_du_ji/features/documents/data/file_picker_document_picker.dart';
import 'package:dian_du_ji/features/documents/data/services/file_intake_service.dart';
import 'package:dian_du_ji/features/documents/domain/document_structure_builder.dart';
import 'package:dian_du_ji/features/documents/domain/import_document_use_case.dart';
import 'package:dian_du_ji/features/documents/presentation/document_import_controller.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('UTF-8, GB18030, and DOCX remain readable after runtime restart', (
    tester,
  ) async {
    final supportDirectory = await getApplicationSupportDirectory();
    final runId = DateTime.now().microsecondsSinceEpoch;
    final fixtureDirectory = Directory(
      '${supportDirectory.path}${Platform.pathSeparator}import-fixtures-$runId',
    );
    await fixtureDirectory.create(recursive: true);
    addTearDown(() => fixtureDirectory.delete(recursive: true));
    final databaseName = 'dianduji_import_restart_$runId';
    AppDatabase databaseFactory() =>
        AppDatabase(driftDatabase(name: databaseName));

    final firstRuntime = await initializeAppRuntime(
      databaseFactory: databaseFactory,
      supportDirectoryProvider: () async => supportDirectory,
    );
    final firstRepository = DriftDocumentRepository(firstRuntime.database);
    final importedIds = <String>[];
    final importer = ImportDocumentUseCase(
      intake: DefaultImportIntake(
        FileIntakeService(
          sandboxDirectory: Directory(
            '${fixtureDirectory.path}${Platform.pathSeparator}sandbox',
          ),
        ),
      ),
      parsers: DefaultDocumentParserResolver(),
      store: DriftDocumentImportStore(
        database: firstRuntime.database,
        builder: DocumentStructureBuilder(
          dictionary: firstRuntime.dictionary,
          phraseRecognizer: firstRuntime.phraseRecognizer,
        ),
      ),
      createId: () {
        final id = 'fixture-$runId-${importedIds.length + 1}';
        importedIds.add(id);
        return id;
      },
    );
    final controller = DocumentImportController(
      picker: const _NoSystemPicker(),
      importer: importer,
      repository: firstRepository,
    );

    try {
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

      expect(importedIds, hasLength(3));
      expect(
        controller.state.imports.values.every(
          (state) => state.status == ImportStatus.completed,
        ),
        isTrue,
      );
    } finally {
      controller.dispose();
      await firstRuntime.close();
    }

    final restartedRuntime = await initializeAppRuntime(
      databaseFactory: databaseFactory,
      supportDirectoryProvider: () async => supportDirectory,
    );
    final restartedRepository = DriftDocumentRepository(
      restartedRuntime.database,
    );
    try {
      final restored = await Future.wait(
        importedIds.map(restartedRepository.loadReaderDocument),
      );
      final restoredText = restored
          .expand((document) => document.sentences)
          .map((sentence) => sentence.text)
          .join('\n');
      expect(restoredText, contains('Hello from UTF-8.'));
      expect(restoredText, contains('你好'));
      expect(restoredText, contains('Hello from DOCX.'));
    } finally {
      await restartedRuntime.close();
    }
  });
}

class _NoSystemPicker implements DocumentPicker {
  const _NoSystemPicker();

  @override
  Future<SelectedFile?> pickDocument() async => null;
}
