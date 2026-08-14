import 'dart:convert';

import '../database/app_database.dart';
import 'online_translation_cache.dart';
import 'online_translation_gateway.dart';

/// Drift-backed [OnlineTranslationCacheStore].
class DriftOnlineTranslationCache implements OnlineTranslationCacheStore {
  DriftOnlineTranslationCache(this.database);

  final AppDatabase database;

  @override
  Future<OnlineTranslationResult?> read(String cacheKey) async {
    final row = await (database.select(database.onlineTranslationCache)
          ..where((entry) => entry.cacheKey.equals(cacheKey)))
        .getSingleOrNull();
    if (row == null) return null;
    return OnlineTranslationResult.fromJson(jsonDecode(row.payload));
  }

  @override
  Future<void> write(
    String cacheKey,
    String term,
    OnlineTranslationResult result,
  ) async {
    await database
        .into(database.onlineTranslationCache)
        .insertOnConflictUpdate(
          OnlineTranslationCacheCompanion.insert(
            cacheKey: cacheKey,
            term: term,
            payload: jsonEncode(result.toJson()),
            fetchedAt: DateTime.now(),
          ),
        );
  }

  @override
  Future<void> clear() async {
    await database.delete(database.onlineTranslationCache).go();
  }
}
