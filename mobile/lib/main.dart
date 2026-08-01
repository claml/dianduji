import 'dart:io';

import 'package:dian_du_ji/app/app.dart';
import 'package:dian_du_ji/app/app_runtime.dart';
import 'package:dian_du_ji/app/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await pdfrxFlutterInitialize();
  await initializeApplication(
    runtimeInitializer: initializeAppRuntime,
    recoverInterruptedImports: (runtime) {
      return runtime.database.documentsDao.recoverInterruptedImports(
        failureCode: 'storage',
        failureMessage: '导入在本机中断，请重试。',
      );
    },
    supportDirectoryProvider: getApplicationSupportDirectory,
    runApplication: runApp,
  );
}

Future<void> initializeApplication({
  required Future<AppRuntime> Function() runtimeInitializer,
  required Future<void> Function(AppRuntime runtime) recoverInterruptedImports,
  required Future<Directory> Function() supportDirectoryProvider,
  required void Function(Widget app) runApplication,
}) async {
  AppRuntime? runtime;
  try {
    final initializedRuntime = await runtimeInitializer();
    runtime = initializedRuntime;
    await recoverInterruptedImports(initializedRuntime);
    final supportDirectory = await supportDirectoryProvider();
    runApplication(
      ProviderScope(
        overrides: [
          appRuntimeProvider.overrideWith((ref) {
            ref.onDispose(() => initializedRuntime.close());
            return initializedRuntime;
          }),
          appSupportDirectoryProvider.overrideWithValue(supportDirectory),
        ],
        child: const DianDuJiApp(),
      ),
    );
  } on Object catch (error) {
    if (runtime != null) await runtime.close();
    runApplication(_StartupErrorApp(error: error));
  }
}

class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('启动失败，无法初始化离线资源。请检查存储空间后重试。\n$error'),
        ),
      ),
    ),
  );
}
