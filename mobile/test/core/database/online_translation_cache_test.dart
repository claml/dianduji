import 'package:dian_du_ji/core/database/app_database.dart';
import 'package:dian_du_ji/core/network/drift_online_translation_cache.dart';
import 'package:dian_du_ji/core/network/online_translation_cache.dart';
import 'package:dian_du_ji/core/network/online_translation_gateway.dart';
import 'package:dian_du_ji/features/dictionary/domain/specialized_terms.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftOnlineTranslationCache cache;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    cache = DriftOnlineTranslationCache(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('round-trips a structured result through the cache', () async {
    const result = OnlineTranslationResult(
      termTranslation: '随机森林',
      sentenceTranslation: '随机森林对样本进行分类。',
      domainGloss: '机器学习集成方法',
      examples: [OnlineExample(source: 'RF reduces variance', translation: '随机森林降低方差')],
      sourceId: 'gateway',
      cacheVersion: '1',
    );

    await cache.write('key-1', 'random forest', result);
    final read = await cache.read('key-1');

    expect(read, isNotNull);
    expect(read!.termTranslation, '随机森林');
    expect(read.sentenceTranslation, '随机森林对样本进行分类。');
    expect(read.examples.single.source, 'RF reduces variance');
  });

  test('read misses cleanly and clear empties the table', () async {
    expect(await cache.read('missing'), isNull);

    await cache.write(
      'key-1',
      'x',
      const OnlineTranslationResult(
        termTranslation: 't',
        sentenceTranslation: 's',
        sourceId: 'g',
        cacheVersion: '1',
      ),
    );
    expect(await cache.read('key-1'), isNotNull);

    await cache.clear();
    expect(await cache.read('key-1'), isNull);
  });

  test('cache key is deterministic and domain/sentence sensitive', () {
    final a = onlineTranslationCacheKey(
      term: 'Random Forest',
      sentence: 'a random forest',
      targetLanguage: 'zh',
      domain: SpecializedDomain.computerScience,
      serviceVersion: '1',
    );
    final b = onlineTranslationCacheKey(
      term: 'random forest',
      sentence: 'a random forest',
      targetLanguage: 'zh',
      domain: SpecializedDomain.computerScience,
      serviceVersion: '1',
    );
    final c = onlineTranslationCacheKey(
      term: 'random forest',
      sentence: 'a different sentence',
      targetLanguage: 'zh',
      domain: SpecializedDomain.computerScience,
      serviceVersion: '1',
    );

    expect(a, b); // normalization: case-insensitive term
    expect(a, isNot(c)); // sentence digest changes the key
  });
}
