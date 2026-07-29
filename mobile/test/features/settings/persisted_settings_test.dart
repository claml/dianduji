import 'dart:io';
import 'dart:async';

import 'package:dian_du_ji/app/providers.dart';
import 'package:dian_du_ji/features/settings/data/cache_cleanup_service.dart';
import 'package:dian_du_ji/features/settings/data/reading_settings.dart';
import 'package:dian_du_ji/features/settings/data/settings_repository.dart';
import 'package:dian_du_ji/features/settings/presentation/persisted_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('persists theme, font, line height and auto-save changes', (
    tester,
  ) async {
    final repository = _SettingsRepository();
    addTearDown(repository.dispose);
    await tester.pumpWidget(
      _settingsApp(_RecordingCacheCleanupService(), repository: repository),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('护眼'));
    await tester.pumpAndSettle();
    tester.widgetList<Slider>(find.byType(Slider)).first.onChanged!(20);
    await tester.pumpAndSettle();
    tester.widgetList<Slider>(find.byType(Slider)).last.onChanged!(1.8);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(
      repository.value,
      ReadingSettings(
        theme: ReaderTheme.eyeCare,
        fontSize: 20,
        lineHeight: 1.8,
        autoSaveVocabulary: false,
      ),
    );
  });

  testWidgets('cancelled cache cleanup performs no deletion', (tester) async {
    final cleanup = _RecordingCacheCleanupService();
    await tester.pumpWidget(_settingsApp(cleanup));

    await tester.tap(find.text('清理可重建缓存'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    expect(cleanup.calls, 0);
  });

  testWidgets('confirmed cache cleanup invokes the service exactly once', (
    tester,
  ) async {
    final cleanup = _RecordingCacheCleanupService();
    await tester.pumpWidget(_settingsApp(cleanup));

    await tester.tap(find.text('清理可重建缓存'));
    await tester.pumpAndSettle();
    expect(find.text('清理缓存？'), findsOneWidget);
    expect(find.text('不会删除文档、生词或短语。'), findsOneWidget);

    await tester.tap(find.text('确认'));
    await tester.pumpAndSettle();

    expect(cleanup.calls, 1);
  });

  test('production cleanup only deletes bounded rebuildable caches', () async {
    final sandbox = await Directory.systemTemp.createTemp(
      'cache-cleanup-test-',
    );
    addTearDown(() => sandbox.delete(recursive: true));
    final support = Directory('${sandbox.path}${Platform.pathSeparator}support')
      ..createSync();
    final dictionaryCache = Directory(
      '${support.path}${Platform.pathSeparator}dictionary-cache',
    )..createSync();
    final parserCache = Directory(
      '${support.path}${Platform.pathSeparator}parser-cache',
    )..createSync();
    final documents = Directory(
      '${support.path}${Platform.pathSeparator}documents',
    )..createSync();
    File(
      '${dictionaryCache.path}${Platform.pathSeparator}index.bin',
    ).writeAsStringSync('rebuildable');
    File(
      '${parserCache.path}${Platform.pathSeparator}page.bin',
    ).writeAsStringSync('rebuildable');
    File(
      '${documents.path}${Platform.pathSeparator}book.txt',
    ).writeAsStringSync('learning asset');
    final database = File(
      '${support.path}${Platform.pathSeparator}dian_du_ji.sqlite',
    )..writeAsStringSync('persistent data');

    await DirectoryCacheCleanupService(
      appSupportDirectory: support,
    ).clearRebuildableCaches();

    expect(dictionaryCache.existsSync(), isFalse);
    expect(parserCache.existsSync(), isFalse);
    expect(documents.existsSync(), isTrue);
    expect(database.existsSync(), isTrue);
  });
}

Widget _settingsApp(
  CacheCleanupService cleanup, {
  _SettingsRepository? repository,
}) => ProviderScope(
  overrides: [
    settingsRepositoryProvider.overrideWithValue(
      repository ?? _SettingsRepository(),
    ),
    cacheCleanupServiceProvider.overrideWithValue(cleanup),
  ],
  child: const MaterialApp(home: PersistedSettingsPage()),
);

class _RecordingCacheCleanupService implements CacheCleanupService {
  var calls = 0;

  @override
  Future<void> clearRebuildableCaches() async => calls++;
}

class _SettingsRepository implements SettingsRepository {
  final _changes = StreamController<ReadingSettings>.broadcast();
  var value = ReadingSettings();

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
