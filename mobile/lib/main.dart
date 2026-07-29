import 'package:dian_du_ji/app/app.dart';
import 'package:dian_du_ji/app/app_runtime.dart';
import 'package:dian_du_ji/app/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final runtime = await initializeAppRuntime();
    await runtime.database.documentsDao.recoverInterruptedImports(
      failureCode: 'storage',
      failureMessage: '导入在本机中断，请重试。',
    );
    final supportDirectory = await getApplicationSupportDirectory();
    runApp(
      ProviderScope(
        overrides: [
          appRuntimeProvider.overrideWith((ref) {
            ref.onDispose(() => runtime.close());
            return runtime;
          }),
          appSupportDirectoryProvider.overrideWithValue(supportDirectory),
        ],
        child: const DianDuJiApp(),
      ),
    );
  } on Object catch (error) {
    runApp(_StartupErrorApp(error: error));
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
