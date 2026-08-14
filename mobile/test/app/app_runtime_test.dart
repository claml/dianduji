import 'dart:io';

import 'package:dian_du_ji/app/app_runtime.dart';
import 'package:dian_du_ji/core/database/app_database.dart';
import 'package:dian_du_ji/features/dictionary/data/dictionary_repository.dart';
import 'package:dian_du_ji/features/phrases/domain/phrase_recognizer.dart';
import 'package:dian_du_ji/main.dart' show initializeApplication;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('closes partial runtime resources when phrase loading fails', () async {
    final directory = await Directory.systemTemp.createTemp('runtime-test-');
    final database = _RecordingDatabase();
    final dictionaryDatabase = sqlite3.openInMemory();
    try {
      await expectLater(
        initializeAppRuntime(
          databaseFactory: () => database,
          supportDirectoryProvider: () async => directory,
          dictionaryOpener: (_) async =>
              DictionaryRepository(dictionaryDatabase),
          phraseRecognizerLoader: () async => throw StateError('bad phrases'),
        ),
        throwsStateError,
      );

      expect(database.closeCount, 1);
      expect(() => dictionaryDatabase.select('SELECT 1'), throwsA(anything));
    } finally {
      await directory.delete(recursive: true);
    }
  });

  test('closes runtime once when interrupted import recovery fails', () async {
    final runtime = _runtime();
    var rendered = 0;

    await initializeApplication(
      runtimeInitializer: () async => runtime.value,
      recoverInterruptedImports: (_) async => throw StateError('recovery'),
      supportDirectoryProvider: () async => Directory.systemTemp,
      runApplication: (_) => rendered++,
    );

    expect(runtime.database.closeCount, 1);
    expect(() => runtime.dictionary.select('SELECT 1'), throwsA(anything));
    expect(rendered, 1);
  });

  test('closes runtime once when support-directory setup fails', () async {
    final runtime = _runtime();
    var rendered = 0;

    await initializeApplication(
      runtimeInitializer: () async => runtime.value,
      recoverInterruptedImports: (_) async {},
      supportDirectoryProvider: () async => throw StateError('support'),
      runApplication: (_) => rendered++,
    );

    expect(runtime.database.closeCount, 1);
    expect(() => runtime.dictionary.select('SELECT 1'), throwsA(anything));
    expect(rendered, 1);
  });
}

_RuntimeFixture _runtime() {
  final dictionary = sqlite3.openInMemory();
  final database = _RecordingDatabase();
  return _RuntimeFixture(
    database,
    dictionary,
    AppRuntime(
      database: database,
      dictionary: DictionaryRepository(dictionary),
      phraseRecognizer: PhraseRecognizer(const []),
      specializedIndex: null,
    ),
  );
}

class _RuntimeFixture {
  const _RuntimeFixture(this.database, this.dictionary, this.value);

  final _RecordingDatabase database;
  final Database dictionary;
  final AppRuntime value;
}

class _RecordingDatabase extends AppDatabase {
  _RecordingDatabase() : super(NativeDatabase.memory());

  var closeCount = 0;

  @override
  Future<void> close() async {
    closeCount++;
    await super.close();
  }
}
