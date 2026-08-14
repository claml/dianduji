@Tags(['benchmark'])
library;

import 'dart:io';

import 'package:dian_du_ji/features/dictionary/data/dictionary_asset_store.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Dictionary lookup performance smoke gate.
///
/// Opens the real bundled ECDICT dictionary through the same
/// [DictionaryAssetStore] path the app uses, then measures 1,000 indexed
/// lookups. The approved reference budget is under 10ms per lookup on the
/// BTK-W00 tablet; on the host this is a smoke gate that catches pathological
/// regressions (for example accidental full-table scans).
///
/// Host note: the benchmark lives in `test/` instead of `tool/` because the
/// sqlite3 package 3.5+ loads its native library through Dart native assets,
/// which `dart run` cannot provide on hosts without a C toolchain, while
/// `flutter test` resolves them from the Flutter build.
/// Tagged `benchmark`: a performance smoke gate whose budget is measured
/// against the reference device (BTK-W00 tablet); CI excludes it via
/// `--exclude-tags benchmark` because shared runners are not comparable.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('1,000 ECDICT lookups stay within the per-lookup budget', () async {
    final supportDirectory = Directory.systemTemp.createTempSync(
      'dianduji-dict-benchmark-',
    );
    addTearDown(() => supportDirectory.deleteSync(recursive: true));
    final store = DictionaryAssetStore(
      supportDirectory: supportDirectory,
      assetReader: rootBundle.load,
    );
    final repository = await store.open();
    addTearDown(() => repository.database.close());

    const probes = [
      'hello',
      'science',
      'begin',
      'observation',
      'computer',
      'cell',
      'protein',
      'synthesis',
      'experiment',
      'data',
    ];

    // Warm up caches and page the dictionary file.
    for (final probe in probes) {
      expect(await repository.lookup(probe), isNotNull);
    }

    const rounds = 1000;
    final stopwatch = Stopwatch()..start();
    var found = 0;
    for (var i = 0; i < rounds; i++) {
      if (await repository.lookup(probes[i % probes.length]) != null) {
        found++;
      }
    }
    stopwatch.stop();

    final perLookupMicros = stopwatch.elapsedMicroseconds / rounds;
    // ignore: avoid_print
    print(
      'DICTIONARY_BENCHMARK '
      '{"device": "${Platform.operatingSystem}", '
      '"buildMode": "test", '
      '"rounds": $rounds, '
      '"found": $found, '
      '"totalMs": ${stopwatch.elapsedMilliseconds}, '
      '"perLookupMicros": ${perLookupMicros.toStringAsFixed(1)}, '
      '"pass": ${perLookupMicros < 10 * 1000}}',
    );

    expect(perLookupMicros, lessThan(10 * 1000),
        reason: 'per-lookup budget is 10ms on the reference device');
  });
}
