import 'package:drift/drift.dart';

part 'app_database.g.dart';

class VocabularyEntries extends Table {
  TextColumn get id => text()();
  TextColumn get lemma => text().unique()();
  TextColumn get displayWord => text()();
  TextColumn get phonetic => text().withDefault(const Constant(''))();
  TextColumn get partOfSpeech => text().withDefault(const Constant(''))();
  TextColumn get definition => text().withDefault(const Constant(''))();
  IntColumn get proficiency => integer().withDefault(const Constant(2))();
  IntColumn get lookupCount => integer().withDefault(const Constant(1))();
  DateTimeColumn get firstLookupAt => dateTime()();
  DateTimeColumn get lastLookupAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LookupRecord {
  const LookupRecord({
    required this.surface,
    required this.lemma,
    required this.phonetic,
    required this.partOfSpeech,
    required this.definition,
  });

  final String surface;
  final String lemma;
  final String phonetic;
  final String partOfSpeech;
  final String definition;
}

@DriftDatabase(tables: [VocabularyEntries], daos: [LearningDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;
}

@DriftAccessor(tables: [VocabularyEntries])
class LearningDao extends DatabaseAccessor<AppDatabase>
    with _$LearningDaoMixin {
  LearningDao(super.attachedDatabase);

  Future<void> recordLookup(LookupRecord record) {
    return transaction(() async {
      final existing = await findByLemma(record.lemma);
      final now = DateTime.now();

      if (existing == null) {
        await into(vocabularyEntries).insert(
          VocabularyEntriesCompanion.insert(
            id: record.lemma,
            lemma: record.lemma,
            displayWord: record.surface,
            phonetic: Value(record.phonetic),
            partOfSpeech: Value(record.partOfSpeech),
            definition: Value(record.definition),
            firstLookupAt: now,
            lastLookupAt: now,
          ),
        );
        return;
      }

      await (update(vocabularyEntries)
            ..where((row) => row.id.equals(existing.id)))
          .write(
        VocabularyEntriesCompanion(
          lookupCount: Value(existing.lookupCount + 1),
          lastLookupAt: Value(now),
        ),
      );
    });
  }

  Future<VocabularyEntry?> findByLemma(String lemma) {
    return (select(vocabularyEntries)..where((row) => row.lemma.equals(lemma)))
        .getSingleOrNull();
  }

  Future<int> countVocabulary() async {
    final count = vocabularyEntries.id.count();
    final row = await (selectOnly(vocabularyEntries)..addColumns([count]))
        .getSingle();
    return row.read(count) ?? 0;
  }
}
