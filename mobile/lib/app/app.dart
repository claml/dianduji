import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const _DocumentLibraryShell(),
    ),
  ],
);

class DianDuJiApp extends StatelessWidget {
  const DianDuJiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: '点读机',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3D7AED),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

class _DocumentLibraryShell extends StatelessWidget {
  const _DocumentLibraryShell();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('文档')),
      body: Center(
        child: FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('导入文档'),
        ),
      ),
    );
  }
}
