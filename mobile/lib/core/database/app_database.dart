import 'package:drift/drift.dart';

part 'app_database.g.dart';

class Documents extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get format => text()();
  TextColumn get sourceName => text()();
  TextColumn get localPath => text()();
  TextColumn get contentHash => text().unique()();
  IntColumn get fileSize => integer()();
  IntColumn get pageCount => integer().nullable()();
  IntColumn get wordCount => integer().withDefault(const Constant(0))();
  IntColumn get paragraphCount => integer().withDefault(const Constant(0))();
  TextColumn get parseStatus => text()();
  RealColumn get parseProgress => real().withDefault(const Constant(0))();
  TextColumn get failureCode => text().nullable()();
  TextColumn get failureMessage => text().nullable()();
  TextColumn get lastReadLocator => text().nullable()();
  RealColumn get readProgress => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastOpenedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Paragraphs extends Table {
  TextColumn get id => text()();
  TextColumn get documentId =>
      text().references(Documents, #id, onDelete: KeyAction.cascade)();
  IntColumn get ordinal => integer()();
  TextColumn get body => text().named('text')();
  TextColumn get style => text().withDefault(const Constant('body'))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {documentId, ordinal},
  ];
}

class Sentences extends Table {
  TextColumn get id => text()();
  TextColumn get documentId =>
      text().references(Documents, #id, onDelete: KeyAction.cascade)();
  TextColumn get paragraphId =>
      text().references(Paragraphs, #id, onDelete: KeyAction.cascade)();
  IntColumn get ordinal => integer()();
  TextColumn get body => text().named('text')();
  IntColumn get startOffset => integer()();
  IntColumn get endOffset => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Tokens extends Table {
  TextColumn get id => text()();
  TextColumn get documentId =>
      text().references(Documents, #id, onDelete: KeyAction.cascade)();
  TextColumn get sentenceId =>
      text().references(Sentences, #id, onDelete: KeyAction.cascade)();
  IntColumn get ordinal => integer()();
  TextColumn get surface => text()();
  TextColumn get normalized => text()();
  TextColumn get lemma => text()();
  TextColumn get partOfSpeech => text().withDefault(const Constant(''))();
  IntColumn get startOffset => integer()();
  IntColumn get endOffset => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PhraseOccurrences extends Table {
  TextColumn get id => text()();
  TextColumn get documentId =>
      text().references(Documents, #id, onDelete: KeyAction.cascade)();
  TextColumn get sentenceId =>
      text().references(Sentences, #id, onDelete: KeyAction.cascade)();
  TextColumn get phraseKey => text()();
  TextColumn get surface => text()();
  TextColumn get type => text()();
  TextColumn get meaning => text()();
  RealColumn get confidence => real()();
  IntColumn get startTokenOrdinal => integer()();
  IntColumn get endTokenOrdinal => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

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
  TextColumn get sourceDocumentId => text().nullable()();
  TextColumn get sourceDocumentTitle =>
      text().withDefault(const Constant(''))();
  TextColumn get contextSentence => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SavedPhrases extends Table {
  TextColumn get id => text()();
  TextColumn get phraseKey => text().unique()();
  TextColumn get surface => text()();
  TextColumn get type => text()();
  TextColumn get meaning => text()();
  TextColumn get contextSentence => text()();
  TextColumn get sourceDocumentId => text().nullable()();
  TextColumn get sourceDocumentTitle => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
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

class SavedPhraseRecord {
  const SavedPhraseRecord({
    required this.id,
    required this.phraseKey,
    required this.surface,
    required this.type,
    required this.meaning,
    required this.contextSentence,
    required this.sourceDocumentTitle,
    required this.createdAt,
    this.sourceDocumentId,
  });

  final String id;
  final String phraseKey;
  final String surface;
  final String type;
  final String meaning;
  final String contextSentence;
  final String? sourceDocumentId;
  final String sourceDocumentTitle;
  final DateTime createdAt;
}

@DriftDatabase(
  tables: [
    Documents,
    Paragraphs,
    Sentences,
    Tokens,
    PhraseOccurrences,
    VocabularyEntries,
    SavedPhrases,
    AppSettings,
  ],
  daos: [DocumentsDao, LearningDao, SettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

@DriftAccessor(
  tables: [Documents, Paragraphs, Sentences, Tokens, PhraseOccurrences],
)
class DocumentsDao extends DatabaseAccessor<AppDatabase>
    with _$DocumentsDaoMixin {
  DocumentsDao(super.attachedDatabase);

  Future<void> deleteDocument(String documentId) {
    return transaction(() async {
      await (delete(documents)..where((row) => row.id.equals(documentId))).go();
    });
  }

  Future<int> countDocuments() async => (await select(documents).get()).length;

  Future<int> countStructureFor(String documentId) async {
    final rows = await Future.wait<int>([
      (select(paragraphs)..where((row) => row.documentId.equals(documentId)))
          .get()
          .then((items) => items.length),
      (select(sentences)..where((row) => row.documentId.equals(documentId)))
          .get()
          .then((items) => items.length),
      (select(tokens)..where((row) => row.documentId.equals(documentId)))
          .get()
          .then((items) => items.length),
      (select(phraseOccurrences)
            ..where((row) => row.documentId.equals(documentId)))
          .get()
          .then((items) => items.length),
    ]);
    return rows.fold<int>(0, (total, count) => total + count);
  }
}

@DriftAccessor(tables: [VocabularyEntries, SavedPhrases])
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

      await (update(
        vocabularyEntries,
      )..where((row) => row.id.equals(existing.id))).write(
        VocabularyEntriesCompanion(
          lookupCount: Value(existing.lookupCount + 1),
          lastLookupAt: Value(now),
        ),
      );
    });
  }

  Future<VocabularyEntry?> findByLemma(String lemma) {
    return (select(
      vocabularyEntries,
    )..where((row) => row.lemma.equals(lemma))).getSingleOrNull();
  }

  Future<int> countVocabulary() async {
    final count = vocabularyEntries.id.count();
    final row = await (selectOnly(
      vocabularyEntries,
    )..addColumns([count])).getSingle();
    return row.read(count) ?? 0;
  }

  Future<int> countSavedPhrases() async {
    final count = savedPhrases.id.count();
    final row = await (selectOnly(
      savedPhrases,
    )..addColumns([count])).getSingle();
    return row.read(count) ?? 0;
  }

  Future<void> savePhrase(SavedPhraseRecord record) {
    return transaction(() async {
      final existing = await findPhrase(record.phraseKey);
      if (existing == null) {
        await into(savedPhrases).insert(
          SavedPhrasesCompanion.insert(
            id: record.id,
            phraseKey: record.phraseKey,
            surface: record.surface,
            type: record.type,
            meaning: record.meaning,
            contextSentence: record.contextSentence,
            sourceDocumentId: Value(record.sourceDocumentId),
            sourceDocumentTitle: record.sourceDocumentTitle,
            createdAt: record.createdAt,
          ),
        );
        return;
      }
      await (update(
        savedPhrases,
      )..where((row) => row.phraseKey.equals(record.phraseKey))).write(
        SavedPhrasesCompanion(
          surface: Value(record.surface),
          type: Value(record.type),
          meaning: Value(record.meaning),
          contextSentence: Value(record.contextSentence),
          sourceDocumentId: Value(record.sourceDocumentId),
          sourceDocumentTitle: Value(record.sourceDocumentTitle),
        ),
      );
    });
  }

  Future<SavedPhrase?> findPhrase(String phraseKey) {
    return (select(
      savedPhrases,
    )..where((row) => row.phraseKey.equals(phraseKey))).getSingleOrNull();
  }
}

@DriftAccessor(tables: [AppSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.attachedDatabase);

  Future<void> setValue(String key, String value) {
    return into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(key: key, value: value),
    );
  }

  Future<String?> getValue(String key) async {
    final row = await (select(
      appSettings,
    )..where((row) => row.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<int> countSettings() async => (await select(appSettings).get()).length;
}
