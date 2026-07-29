import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers.dart';
import '../features/documents/presentation/document_library_page.dart';
import '../features/learning/presentation/phrase_book_screen.dart';
import '../features/learning/presentation/vocabulary_screen.dart';
import '../features/settings/data/reading_settings.dart';
import '../features/settings/presentation/settings_screen.dart';

class DianDuJiApp extends StatefulWidget {
  const DianDuJiApp({super.key});

  @override
  State<DianDuJiApp> createState() => _DianDuJiAppState();
}

class _DianDuJiAppState extends State<DianDuJiApp> {
  ReadingSettings _settings = ReadingSettings();
  var _selectedIndex = 0;
  late final GoRouter _router;
  late final ValueNotifier<_AppShellState> _shell;

  @override
  void initState() {
    super.initState();
    _shell = ValueNotifier(
      _AppShellState(selectedIndex: _selectedIndex, settings: _settings),
    );
    _router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => ValueListenableBuilder(
            valueListenable: _shell,
            builder: (context, shell, child) => _AppHome(
              selectedIndex: shell.selectedIndex,
              settings: shell.settings,
              onSelected: _select,
              onSettingsChanged: _changeSettings,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: '点读机',
      theme: _settings.theme == ReaderTheme.eyeCare
          ? _theme(const Color(0xFF6D7D47), const Color(0xFFF5F3E8))
          : _theme(const Color(0xFF3D7AED), const Color(0xFFFBFCFE)),
      darkTheme: _darkTheme(),
      themeMode: _settings.theme == ReaderTheme.night
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
    _shell.value = _AppShellState(selectedIndex: index, settings: _settings);
  }

  void _changeSettings(ReadingSettings settings) {
    setState(() => _settings = settings);
    _shell.value = _AppShellState(
      selectedIndex: _selectedIndex,
      settings: settings,
    );
  }
}

class _AppShellState {
  const _AppShellState({required this.selectedIndex, required this.settings});

  final int selectedIndex;
  final ReadingSettings settings;
}

class _AppHome extends StatelessWidget {
  const _AppHome({
    required this.selectedIndex,
    required this.settings,
    required this.onSelected,
    required this.onSettingsChanged,
  });

  final int selectedIndex;
  final ReadingSettings settings;
  final ValueChanged<int> onSelected;
  final ValueChanged<ReadingSettings> onSettingsChanged;

  @override
  Widget build(BuildContext context) {
    final content = switch (selectedIndex) {
      0 => DocumentLibraryPage(
        controllerLoader: () => ProviderScope.containerOf(
          context,
        ).read(documentImportControllerProvider),
      ),
      1 => const VocabularyScreen(entries: []),
      2 => const PhraseBookScreen(phrases: []),
      _ => SettingsScreen(initial: settings, onChanged: onSettingsChanged),
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
