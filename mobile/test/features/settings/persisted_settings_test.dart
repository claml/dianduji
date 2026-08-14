import 'dart:io';
import 'dart:async';

import 'package:dian_du_ji/app/providers.dart';
import 'package:dian_du_ji/features/settings/data/cache_cleanup_service.dart';
import 'package:dian_du_ji/features/settings/data/reading_settings.dart';
import 'package:dian_du_ji/features/settings/data/settings_repository.dart';
import 'package:dian_du_ji/features/settings/presentation/persisted_settings_page.dart';
import 'package:dian_du_ji/features/settings/presentation/persisted_settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'does not expose writable defaults while settings are loading',
    () async {
      final repository = _ControllableSettingsRepository()..delayLoad();
      final controller = PersistedSettingsController(repository);

      expect(controller.state.isLoading, isTrue);
      expect(controller.state.settings, isNull);
      expect(() => controller.updateFontSize(20), throwsA(isA<StateError>()));
      expect(repository.saved, isEmpty);

      repository.completeLoad(ReadingSettings(fontSize: 18));
      await controller.ready;
      expect(controller.state.settings?.fontSize, 18);
    },
  );

  test(
    'rapid edits compose optimistically and saves stay serialized',
    () async {
      final repository = _ControllableSettingsRepository();
      final controller = PersistedSettingsController(repository);
      await controller.ready;

      final saves = [
        controller.updateTheme(ReaderTheme.eyeCare),
        controller.updateFontSize(20),
        controller.updateLineHeight(1.8),
        controller.updateAutoSaveVocabulary(false),
      ];
      expect(
        controller.state.settings,
        ReadingSettings(
          theme: ReaderTheme.eyeCare,
          fontSize: 20,
          lineHeight: 1.8,
          autoSaveVocabulary: false,
        ),
      );
      await Future.wait(saves);

      expect(repository.maxConcurrentSaves, 1);
      expect(repository.saved.last, controller.state.settings);
    },
  );

  test(
    'a failed save is reported until a later generation saves the latest settings',
    () async {
      final repository = _QueuedSaveSettingsRepository()
        ..enqueueFailure(StateError('disk full'))
        ..enqueueSuccess()
        ..enqueueSuccess()
        ..enqueueSuccess();
      final controller = PersistedSettingsController(repository);
      await controller.ready;

      final failed = controller.updateTheme(ReaderTheme.eyeCare);
      final font = controller.updateFontSize(20);
      final lineHeight = controller.updateLineHeight(1.8);
      final autoSave = controller.updateAutoSaveVocabulary(false);

      await repository.waitForAttempt(1);
      repository.completeNext();
      await expectLater(failed, throwsA(isA<StateError>()));

      expect(controller.state.saveError, isA<StateError>());
      expect(repository.value, ReadingSettings());
      expect(
        controller.state.settings,
        ReadingSettings(
          theme: ReaderTheme.eyeCare,
          fontSize: 20,
          lineHeight: 1.8,
          autoSaveVocabulary: false,
        ),
      );

      await repository.waitForAttempt(2);
      repository.completeNext();
      await repository.waitForAttempt(3);
      repository.completeNext();
      await repository.waitForAttempt(4);
      repository.completeNext();
      await Future.wait([font, lineHeight, autoSave]);

      expect(controller.state.saveError, isNull);
      expect(
        repository.value,
        ReadingSettings(
          theme: ReaderTheme.eyeCare,
          fontSize: 20,
          lineHeight: 1.8,
          autoSaveVocabulary: false,
        ),
      );
    },
  );

  test(
    'pending successful retry completes safely after controller disposal',
    () async {
      final repository = _QueuedSaveSettingsRepository()
        ..enqueueFailure(StateError('disk full'))
        ..enqueueSuccess();
      final controller = PersistedSettingsController(repository);
      await controller.ready;

      final failed = controller.updateTheme(ReaderTheme.eyeCare);
      final expectedFailure = expectLater(failed, throwsA(isA<StateError>()));
      await repository.waitForAttempt(1);
      repository.completeNext();
      await expectedFailure;

      final retry = controller.retrySave();
      await repository.waitForAttempt(2);
      controller.dispose();
      repository.completeNext();

      await retry;
      await Future<void>.delayed(Duration.zero);
    },
  );

  test(
    'pending failed save reports its error safely after controller disposal',
    () async {
      final repository = _QueuedSaveSettingsRepository()
        ..enqueueFailure(StateError('disk full'));
      final controller = PersistedSettingsController(repository);
      await controller.ready;

      final save = controller.updateTheme(ReaderTheme.eyeCare);
      final expectedFailure = expectLater(save, throwsA(isA<StateError>()));
      await repository.waitForAttempt(1);
      controller.dispose();
      repository.completeNext();

      await expectedFailure;
      await Future<void>.delayed(Duration.zero);
    },
  );

  testWidgets(
    'save failure is accessible, retryable, and does not look saved',
    (tester) async {
      final repository = _QueuedSaveSettingsRepository()
        ..enqueueFailure(StateError('disk full'))
        ..enqueueSuccess();
      await tester.pumpWidget(
        _settingsApp(_RecordingCacheCleanupService(), repository: repository),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SwitchListTile).first);
      await repository.waitForAttempt(1);
      repository.completeNext();
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('设置保存失败，请重试'), findsOneWidget);
      expect(find.text('保存失败，请重试'), findsOneWidget);
      expect(repository.value.autoSaveVocabulary, isTrue);
      expect(
        tester.getSize(find.widgetWithText(FilledButton, '重试保存')).height,
        greaterThanOrEqualTo(48),
      );

      await tester.tap(find.text('重试保存'));
      await repository.waitForAttempt(2);
      repository.completeNext();
      await tester.pumpAndSettle();

      expect(find.text('保存失败，请重试'), findsNothing);
      expect(repository.value.autoSaveVocabulary, isFalse);
    },
  );

  testWidgets('loading and load failure never show editable defaults', (
    tester,
  ) async {
    final repository = _ControllableSettingsRepository()..delayLoad();
    await tester.pumpWidget(
      _settingsApp(_RecordingCacheCleanupService(), repository: repository),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('自动收录生词'), findsNothing);

    repository.failLoad(StateError('disk unavailable'));
    await tester.pumpAndSettle();
    expect(find.text('设置加载失败'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
    expect(find.byType(SwitchListTile), findsNothing);

    repository.allowLoad(ReadingSettings());
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(find.text('自动收录生词'), findsOneWidget);
  });

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
    await tester.tap(find.byType(SwitchListTile).first);
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

  testWidgets('privacy and license tiles open their dialogs', (tester) async {
    final cleanup = _RecordingCacheCleanupService();
    await tester.pumpWidget(_settingsApp(cleanup));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('隐私说明'), 120);
    await tester.tap(find.text('隐私说明'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('本应用的所有功能均在本机离线完成'),
      findsOneWidget,
    );
    expect(find.textContaining('不收集、不上传文档内容'), findsOneWidget);
    await tester.tap(find.text('知道了'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('开源许可证'), 120);
    await tester.tap(find.text('开源许可证'));
    await tester.pumpAndSettle();
    expect(find.textContaining('ECDICT 英汉词典'), findsOneWidget);
    await tester.tap(find.text('关闭'));
    await tester.pumpAndSettle();
  });

  testWidgets('cancelled cache cleanup performs no deletion', (tester) async {
    final cleanup = _RecordingCacheCleanupService();
    await tester.pumpWidget(_settingsApp(cleanup));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('清理可重建缓存'), 120);
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
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('清理可重建缓存'), 120);
    await tester.tap(find.text('清理可重建缓存'));
    await tester.pumpAndSettle();
    expect(find.text('清理缓存？'), findsOneWidget);
    expect(find.text('不会删除文档、生词或短语。'), findsOneWidget);

    await tester.tap(find.text('确认'));
    await tester.pumpAndSettle();

    expect(cleanup.calls, 1);
  });

  testWidgets('cache cleanup failure is visible and remains recoverable', (
    tester,
  ) async {
    final cleanup = _RecordingCacheCleanupService()..error = StateError('io');
    await tester.pumpWidget(_settingsApp(cleanup));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('清理可重建缓存'), 120);
    await tester.tap(find.text('清理可重建缓存'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认'));
    await tester.pumpAndSettle();

    expect(find.text('缓存清理失败，请重试'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('online translation switch requires first-use consent', (
    tester,
  ) async {
    final repository = _SettingsRepository();
    addTearDown(repository.dispose);
    await tester.pumpWidget(
      _settingsApp(_RecordingCacheCleanupService(), repository: repository),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('在线翻译'), 120);
    await tester.tap(find.byType(SwitchListTile).at(1));
    await tester.pumpAndSettle();
    expect(find.text('开启在线翻译'), findsOneWidget);
    expect(find.textContaining('不会上传'), findsOneWidget);

    // Cancelling leaves both the switch and consent off.
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(repository.value.onlineTranslationEnabled, isFalse);
    expect(repository.value.onlineTranslationConsented, isFalse);

    // Agreeing turns both on.
    await tester.tap(find.byType(SwitchListTile).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('同意并开启'));
    await tester.pumpAndSettle();
    expect(repository.value.onlineTranslationEnabled, isTrue);
    expect(repository.value.onlineTranslationConsented, isTrue);
  });

  testWidgets('online translation switch turns off without re-consent', (
    tester,
  ) async {
    final repository = _SettingsRepository()
      ..value = ReadingSettings(
        onlineTranslationEnabled: true,
        onlineTranslationConsented: true,
      );
    addTearDown(repository.dispose);
    await tester.pumpWidget(
      _settingsApp(_RecordingCacheCleanupService(), repository: repository),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('在线翻译'), 120);
    await tester.tap(find.byType(SwitchListTile).at(1));
    await tester.pumpAndSettle();

    expect(repository.value.onlineTranslationEnabled, isFalse);
    expect(repository.value.onlineTranslationConsented, isTrue);
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
  SettingsRepository? repository,
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
  Object? error;

  @override
  Future<void> clearRebuildableCaches() async {
    calls++;
    if (error != null) throw error!;
  }
}

class _ControllableSettingsRepository implements SettingsRepository {
  Completer<ReadingSettings>? _load;
  ReadingSettings value = ReadingSettings();
  final saved = <ReadingSettings>[];
  var concurrentSaves = 0;
  var maxConcurrentSaves = 0;

  void delayLoad() => _load = Completer<ReadingSettings>();
  void completeLoad(ReadingSettings settings) => _load!.complete(settings);
  void failLoad(Object error) => _load!.completeError(error);
  void allowLoad(ReadingSettings settings) {
    value = settings;
    _load = null;
  }

  @override
  Future<ReadingSettings> load() => _load?.future ?? Future.value(value);

  @override
  Future<void> save(ReadingSettings settings) async {
    concurrentSaves++;
    maxConcurrentSaves = maxConcurrentSaves < concurrentSaves
        ? concurrentSaves
        : maxConcurrentSaves;
    await Future<void>.delayed(Duration.zero);
    value = settings;
    saved.add(settings);
    concurrentSaves--;
  }

  @override
  Stream<ReadingSettings> watch() => Stream.value(value);
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

class _QueuedSaveSettingsRepository implements SettingsRepository {
  final _attempts = <Completer<void>>[];
  final _outcomes = <Object?>[];
  final _attemptCount = StreamController<int>.broadcast();
  var value = ReadingSettings();

  void enqueueFailure(Object error) => _outcomes.add(error);
  void enqueueSuccess() => _outcomes.add(null);

  Future<void> waitForAttempt(int count) async {
    if (_attempts.length >= count) return;
    await _attemptCount.stream.firstWhere((value) => value >= count);
  }

  void completeNext() {
    final attempt = _attempts.firstWhere((attempt) => !attempt.isCompleted);
    final outcome = _outcomes.removeAt(0);
    if (outcome == null) {
      attempt.complete();
    } else {
      attempt.completeError(outcome);
    }
  }

  @override
  Future<ReadingSettings> load() async => value;

  @override
  Future<void> save(ReadingSettings settings) async {
    final attempt = Completer<void>();
    _attempts.add(attempt);
    _attemptCount.add(_attempts.length);
    await attempt.future;
    value = settings;
  }

  @override
  Stream<ReadingSettings> watch() => Stream.value(value);
}
