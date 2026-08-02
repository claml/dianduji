import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers.dart';
import '../features/documents/presentation/document_library_page.dart';
import '../features/learning/presentation/learning_pages.dart';
import '../features/settings/data/reading_settings.dart';
import '../features/settings/presentation/persisted_settings_page.dart';
import '../features/reader/presentation/reader_page.dart';

class DianDuJiApp extends ConsumerStatefulWidget {
  const DianDuJiApp({super.key});

  @override
  ConsumerState<DianDuJiApp> createState() => _DianDuJiAppState();
}

class _DianDuJiAppState extends ConsumerState<DianDuJiApp> {
  var _selectedIndex = 0;
  late final GoRouter _router;
  late final ValueNotifier<_AppShellState> _shell;

  @override
  void initState() {
    super.initState();
    _shell = ValueNotifier(_AppShellState(selectedIndex: _selectedIndex));
    _router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => ValueListenableBuilder(
            valueListenable: _shell,
            builder: (context, shell, child) => _AppHome(
              selectedIndex: shell.selectedIndex,
              onSelected: _select,
              onOpenDocument: _openDocument,
            ),
          ),
        ),
        GoRoute(
          path: '/reader/:documentId',
          builder: (context, state) =>
              ReaderPage(documentId: state.pathParameters['documentId']!),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(readingSettingsProvider).settings;
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: '点读机',
      theme: settings?.theme == ReaderTheme.eyeCare
          ? _theme(const Color(0xFF6D7D47), const Color(0xFFF5F3E8))
          : _theme(const Color(0xFF3D7AED), const Color(0xFFFBFCFE)),
      darkTheme: _darkTheme(),
      themeMode: settings?.theme == ReaderTheme.night
          ? ThemeMode.dark
          : ThemeMode.light,
      routerConfig: _router,
    );
  }

  @override
  void dispose() {
    _shell.dispose();
    _router.dispose();
    super.dispose();
  }

  void _select(int index) {
    _selectedIndex = index;
    _shell.value = _AppShellState(selectedIndex: index);
  }

  void _openDocument(String documentId) => _router.push('/reader/$documentId');
}

class _AppShellState {
  const _AppShellState({required this.selectedIndex});

  final int selectedIndex;
}

class _AppHome extends StatelessWidget {
  const _AppHome({
    required this.selectedIndex,
    required this.onSelected,
    required this.onOpenDocument,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final ValueChanged<String> onOpenDocument;

  @override
  Widget build(BuildContext context) {
    final content = switch (selectedIndex) {
      0 => DocumentLibraryPage(onOpen: onOpenDocument),
      1 => const VocabularyPage(),
      2 => const PhraseBookPage(),
      _ => const PersistedSettingsPage(),
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return Row(
            children: [
              NavigationRail(
                selectedIndex: selectedIndex,
                labelType: NavigationRailLabelType.all,
                onDestinationSelected: onSelected,
                destinations: _railDestinations,
              ),
              const VerticalDivider(width: 1),
              Expanded(child: content),
            ],
          );
        }
        return Scaffold(
          body: content,
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onSelected,
            destinations: _bottomDestinations,
          ),
        );
      },
    );
  }
}

ThemeData _theme(Color seed, Color surface) {
  const graphite = Color(0xFF252A32);
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: seed, surface: surface),
    scaffoldBackgroundColor: surface,
    textTheme: ThemeData.light().textTheme.apply(
      bodyColor: graphite,
      displayColor: graphite,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    useMaterial3: true,
  );
}

ThemeData _darkTheme() => ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF7BA4FF),
    brightness: Brightness.dark,
    surface: const Color(0xFF16191E),
  ),
  scaffoldBackgroundColor: const Color(0xFF16191E),
  useMaterial3: true,
);

const _railDestinations = [
  NavigationRailDestination(
    icon: Icon(Icons.folder_outlined),
    selectedIcon: Icon(Icons.folder_rounded),
    label: Text('文档'),
  ),
  NavigationRailDestination(
    icon: Icon(Icons.school_outlined),
    label: Text('生词'),
  ),
  NavigationRailDestination(
    icon: Icon(Icons.bookmark_border_rounded),
    label: Text('短语'),
  ),
  NavigationRailDestination(
    icon: Icon(Icons.settings_outlined),
    label: Text('设置'),
  ),
];

const _bottomDestinations = [
  NavigationDestination(icon: Icon(Icons.folder_rounded), label: '文档'),
  NavigationDestination(icon: Icon(Icons.school_outlined), label: '生词'),
  NavigationDestination(icon: Icon(Icons.bookmark_border_rounded), label: '短语'),
  NavigationDestination(icon: Icon(Icons.settings_outlined), label: '设置'),
];
