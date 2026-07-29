import 'dart:io';

abstract interface class CacheCleanupService {
  Future<void> clearRebuildableCaches();
}

class DirectoryCacheCleanupService implements CacheCleanupService {
  const DirectoryCacheCleanupService({required this.appSupportDirectory});

  static const rebuildableCacheNames = <String>[
    'dictionary-cache',
    'parser-cache',
  ];

  final Directory appSupportDirectory;

  @override
  Future<void> clearRebuildableCaches() async {
    if (!await appSupportDirectory.exists()) return;

    final lexicalRootPath = _normalize(appSupportDirectory.absolute.path);
    final rootPath = _normalize(
      await appSupportDirectory.resolveSymbolicLinks(),
    );
    for (final name in rebuildableCacheNames) {
      final directory = Directory(
        '${appSupportDirectory.absolute.path}${Platform.pathSeparator}$name',
      );
      if (!_isStrictChild(
        _normalize(directory.absolute.path),
        lexicalRootPath,
      )) {
        throw StateError(
          'Cache path is outside the application support directory.',
        );
      }
      if (!await directory.exists()) continue;

      final resolvedPath = _normalize(await directory.resolveSymbolicLinks());
      if (!_isStrictChild(resolvedPath, rootPath)) {
        throw StateError(
          'Cache path resolves outside the application support directory.',
        );
      }
      await directory.delete(recursive: true);
    }
  }

  static String _normalize(String path) {
    var normalized = path.replaceAll(RegExp(r'[\\/]+'), Platform.pathSeparator);
    while (normalized.endsWith(Platform.pathSeparator)) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return Platform.isWindows ? normalized.toLowerCase() : normalized;
  }

  static bool _isStrictChild(String path, String root) =>
      path.startsWith('$root${Platform.pathSeparator}');
}
