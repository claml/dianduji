import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/documents/presentation/document_library_screen.dart';

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) =>
          const DocumentLibraryScreen(state: DocumentLibraryState()),
    ),
  ],
);

class DianDuJiApp extends StatelessWidget {
  const DianDuJiApp({super.key});

  @override
  Widget build(BuildContext context) {
    const graphite = Color(0xFF252A32);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: '点读机',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3D7AED),
          surface: const Color(0xFFFBFCFE),
        ),
        scaffoldBackgroundColor: const Color(0xFFFBFCFE),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: graphite,
          displayColor: graphite,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(48, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
