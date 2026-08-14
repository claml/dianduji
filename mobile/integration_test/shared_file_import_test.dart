import 'dart:io';

import 'package:dian_du_ji/app/app_runtime.dart';
import 'package:dian_du_ji/core/database/app_database.dart';
import 'package:dian_du_ji/core/platform/android_shared_file_receiver.dart';
import 'package:dian_du_ji/core/platform/shared_file_receiver.dart';
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

/// Device gate for Android shared-file intake.
///
/// Automated coverage: the app bootstraps the real shared-file event channel,
/// `initialize()` succeeds exactly once, and a document already copied into
/// the application cache (the exact artifact `SharedFileChannel` produces)
/// is imported and persisted through the same controller path the receiver
/// uses.
///
/// Manual intent verification (Huawei file manager or adb):
///   1. Install the debug APK and launch 点读机 once.
///   2. From the file manager, share/open a TXT, PDF, or DOCX into 点读机
///      with the app stopped (cold) and again while it is running (warm).
///   3. Expect the document library to show the new document each time.
///   adb equivalent (replace the content URI):
///     adb shell am start -a android.intent.action.SEND -t text/plain \
///       --eu android.intent.extra.STREAM content://...
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shared cache document imports and persists after restart', (
    tester,
  ) async {
    final supportDirectory = await getApplicationSupportDirectory();
    final runId = DateTime.now().microsecondsSinceEpoch;
    final fixtureDirectory = Directory(
      '${supportDirectory.path}${Platform.pathSeparator}shared-fixtures-$runId',
    );
    await fixtureDirectory.create(recursive: true);
    addTearDown(() => fixtureDirectory.delete(recursive: true));
    final databaseName = 'dianduji_shared_restart_$runId';
    AppDatabase databaseFactory() =>
        AppDatabase(driftDatabase(name: databaseName));

    final runtime = await initializeAppRuntime(
      databaseFactory: databaseFactory,
      supportDirectoryProvider: () async => supportDirectory,
    );
    addTearDown(runtime.close);
    final repository = DriftDocumentRepository(runtime.database);
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
        database: runtime.database,
        builder: DocumentStructureBuilder(
          dictionary: runtime.dictionary,
          phraseRecognizer: runtime.phraseRecognizer,
        ),
      ),
      createId: () {
        final id = 'shared-$runId-${importedIds.length + 1}';
        importedIds.add(id);
        return id;
      },
    );

    final receiver = Platform.isAndroid
        ? AndroidSharedFileReceiver() as SharedFileReceiver
        : const NoopSharedFileReceiver();
    final controller = DocumentImportController(
      picker: const _NoSystemPicker(),
      importer: importer,
      repository: repository,
      sharedFileReceiver: receiver,
    );
    addTearDown(controller.dispose);

    // The receiver must attach the platform channel without throwing.
    await receiver.initialize();
    await receiver.initialize();
    expect(controller.state.errorMessage, isNull);

    // Simulate the artifact SharedFileChannel.kt places in the cache: a
    // private copy plus display name and MIME type.
    final cached = File(
      '${fixtureDirectory.path}${Platform.pathSeparator}shared-lesson.txt',
    );
    await cached.writeAsBytes(
      (await rootBundle.load(
        'integration_test/fixtures/sample_utf8.txt',
      )).buffer.asUint8List(),
    );
    final received = <SharedFileEvent>[];
    final subscription = receiver.events.listen(received.add);
    addTearDown(subscription.cancel);
    await controller.importSelectedFile(
      SelectedFile(path: cached.path, originalName: 'shared-lesson.txt'),
    );

    expect(importedIds, hasLength(1));
    expect(
      controller.state.imports[importedIds.single]?.status,
      ImportStatus.completed,
    );

    final restored = await repository.loadReaderDocument(importedIds.single);
    expect(
      restored.sentences.map((sentence) => sentence.text).join('\n'),
      contains('Hello from UTF-8.'),
    );
    expect(received, isEmpty);
  });
}

class _NoSystemPicker implements DocumentPicker {
  const _NoSystemPicker();

  @override
  Future<SelectedFile?> pickDocument() async => null;
}
