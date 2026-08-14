import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../data/dictionary_repository.dart';
import '../domain/user_dictionary_repository.dart';

/// Drift-backed [UserDictionaryStore].
class DriftUserDictionary implements UserDictionaryStore {
  DriftUserDictionary(this._database);

  final AppDatabase _database;

  @override
  Future<DictionaryEntry?> lookupConfirmed(String surface) async {
    var lemma = normalizeUserLemma(surface);
    var row = await (_database.select(_database.userDictionary)
          ..where((entry) => entry.lemma.equals(lemma))
          ..where((entry) => entry.status.equals('confirmed')))
        .getSingleOrNull();
    // Dehyphenation fallback for merged soft-wrap words (per-formance).
    if (row == null && lemma.contains('-')) {
      lemma = lemma.replaceAll('-', '');
      row = await (_database.select(_database.userDictionary)
            ..where((entry) => entry.lemma.equals(lemma))
            ..where((entry) => entry.status.equals('confirmed')))
          .getSingleOrNull();
    }
    if (row == null) return null;
    return DictionaryEntry(
      word: row.surface,
      phonetic: row.phonetic,
      partOfSpeech: row.partOfSpeech,
      definitionEnglish: row.definitionEnglish,
      definitionChinese: row.definitionChinese,
    );
  }

  @override
  Future<void> collectCandidate(String surface, {String source = ''}) async {
    final lemma = normalizeUserLemma(surface);
    if (lemma.isEmpty) return;
    // InsertOrIgnore on conflict: an existing row (candidate or confirmed) is
    // never overwritten, so a confirmed entry can never be downgraded.
    await _database.into(_database.userDictionary).insert(
      UserDictionaryCompanion.insert(
        lemma: lemma,
        surface: surface.trim(),
        status: Value('candidate'),
        source: Value(source),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  @override
  Future<int> pendingCandidateCount() async {
    final count = countAll();
    final query = _database.selectOnly(_database.userDictionary)
      ..addColumns([count])
      ..where(_database.userDictionary.status.equals('candidate'));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  @override
  Future<List<UserDictionaryCandidate>> pendingCandidates() async {
    final rows = await (_database.select(_database.userDictionary)
          ..where((entry) => entry.status.equals('candidate'))
          ..orderBy([(entry) => OrderingTerm.asc(entry.createdAt)]))
        .get();
    return [
      for (final row in rows)
        UserDictionaryCandidate(
          lemma: row.lemma,
          surface: row.surface,
          source: row.source,
          createdAt: row.createdAt,
        ),
    ];
  }

  @override
  Future<void> applyEnrichment(List<EnrichedDictionaryEntry> entries) async {
    await _database.transaction(() async {
      for (final enriched in entries) {
        final lemma = normalizeUserLemma(enriched.surface);
        if (lemma.isEmpty) continue;
        if (!enriched.isValid) {
          await (_database.delete(_database.userDictionary)
                ..where((entry) => entry.lemma.equals(lemma))
                ..where((entry) => entry.status.equals('candidate')))
              .go();
          continue;
        }
        await _database.into(_database.userDictionary).insertOnConflictUpdate(
          UserDictionaryCompanion.insert(
            lemma: lemma,
            surface: enriched.surface.trim(),
            phonetic: Value(enriched.phonetic),
            partOfSpeech: Value(enriched.partOfSpeech),
            definitionEnglish: Value(enriched.definitionEnglish),
            definitionChinese: Value(enriched.definitionChinese),
            status: Value('confirmed'),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }
    });
  }

  @override
  Future<void> clearCandidates() async {
    await (_database.delete(_database.userDictionary)
          ..where((entry) => entry.status.equals('candidate')))
        .go();
  }
}
