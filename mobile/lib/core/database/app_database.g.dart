// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VocabularyEntriesTable extends VocabularyEntries
    with TableInfo<$VocabularyEntriesTable, VocabularyEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VocabularyEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lemmaMeta = const VerificationMeta('lemma');
  @override
  late final GeneratedColumn<String> lemma = GeneratedColumn<String>(
    'lemma',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _displayWordMeta = const VerificationMeta(
    'displayWord',
  );
  @override
  late final GeneratedColumn<String> displayWord = GeneratedColumn<String>(
    'display_word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneticMeta = const VerificationMeta(
    'phonetic',
  );
  @override
  late final GeneratedColumn<String> phonetic = GeneratedColumn<String>(
    'phonetic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _partOfSpeechMeta = const VerificationMeta(
    'partOfSpeech',
  );
  @override
  late final GeneratedColumn<String> partOfSpeech = GeneratedColumn<String>(
    'part_of_speech',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _definitionMeta = const VerificationMeta(
    'definition',
  );
  @override
  late final GeneratedColumn<String> definition = GeneratedColumn<String>(
    'definition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _proficiencyMeta = const VerificationMeta(
    'proficiency',
  );
  @override
  late final GeneratedColumn<int> proficiency = GeneratedColumn<int>(
    'proficiency',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _lookupCountMeta = const VerificationMeta(
    'lookupCount',
  );
  @override
  late final GeneratedColumn<int> lookupCount = GeneratedColumn<int>(
    'lookup_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _firstLookupAtMeta = const VerificationMeta(
    'firstLookupAt',
  );
  @override
  late final GeneratedColumn<DateTime> firstLookupAt =
      GeneratedColumn<DateTime>(
        'first_lookup_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _lastLookupAtMeta = const VerificationMeta(
    'lastLookupAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastLookupAt = GeneratedColumn<DateTime>(
    'last_lookup_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lemma,
    displayWord,
    phonetic,
    partOfSpeech,
    definition,
    proficiency,
    lookupCount,
    firstLookupAt,
    lastLookupAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vocabulary_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<VocabularyEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('lemma')) {
      context.handle(
        _lemmaMeta,
        lemma.isAcceptableOrUnknown(data['lemma']!, _lemmaMeta),
      );
    } else if (isInserting) {
      context.missing(_lemmaMeta);
    }
    if (data.containsKey('display_word')) {
      context.handle(
        _displayWordMeta,
        displayWord.isAcceptableOrUnknown(
          data['display_word']!,
          _displayWordMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayWordMeta);
    }
    if (data.containsKey('phonetic')) {
      context.handle(
        _phoneticMeta,
        phonetic.isAcceptableOrUnknown(data['phonetic']!, _phoneticMeta),
      );
    }
    if (data.containsKey('part_of_speech')) {
      context.handle(
        _partOfSpeechMeta,
        partOfSpeech.isAcceptableOrUnknown(
          data['part_of_speech']!,
          _partOfSpeechMeta,
        ),
      );
    }
    if (data.containsKey('definition')) {
      context.handle(
        _definitionMeta,
        definition.isAcceptableOrUnknown(data['definition']!, _definitionMeta),
      );
    }
    if (data.containsKey('proficiency')) {
      context.handle(
        _proficiencyMeta,
        proficiency.isAcceptableOrUnknown(
          data['proficiency']!,
          _proficiencyMeta,
        ),
      );
    }
    if (data.containsKey('lookup_count')) {
      context.handle(
        _lookupCountMeta,
        lookupCount.isAcceptableOrUnknown(
          data['lookup_count']!,
          _lookupCountMeta,
        ),
      );
    }
    if (data.containsKey('first_lookup_at')) {
      context.handle(
        _firstLookupAtMeta,
        firstLookupAt.isAcceptableOrUnknown(
          data['first_lookup_at']!,
          _firstLookupAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstLookupAtMeta);
    }
    if (data.containsKey('last_lookup_at')) {
      context.handle(
        _lastLookupAtMeta,
        lastLookupAt.isAcceptableOrUnknown(
          data['last_lookup_at']!,
          _lastLookupAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastLookupAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VocabularyEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VocabularyEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      lemma: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lemma'],
      )!,
      displayWord: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_word'],
      )!,
      phonetic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phonetic'],
      )!,
      partOfSpeech: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part_of_speech'],
      )!,
      definition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition'],
      )!,
      proficiency: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}proficiency'],
      )!,
      lookupCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lookup_count'],
      )!,
      firstLookupAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_lookup_at'],
      )!,
      lastLookupAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_lookup_at'],
      )!,
    );
  }

  @override
  $VocabularyEntriesTable createAlias(String alias) {
    return $VocabularyEntriesTable(attachedDatabase, alias);
  }
}

class VocabularyEntry extends DataClass implements Insertable<VocabularyEntry> {
  final String id;
  final String lemma;
  final String displayWord;
  final String phonetic;
  final String partOfSpeech;
  final String definition;
  final int proficiency;
  final int lookupCount;
  final DateTime firstLookupAt;
  final DateTime lastLookupAt;
  const VocabularyEntry({
    required this.id,
    required this.lemma,
    required this.displayWord,
    required this.phonetic,
    required this.partOfSpeech,
    required this.definition,
    required this.proficiency,
    required this.lookupCount,
    required this.firstLookupAt,
    required this.lastLookupAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['lemma'] = Variable<String>(lemma);
    map['display_word'] = Variable<String>(displayWord);
    map['phonetic'] = Variable<String>(phonetic);
    map['part_of_speech'] = Variable<String>(partOfSpeech);
    map['definition'] = Variable<String>(definition);
    map['proficiency'] = Variable<int>(proficiency);
    map['lookup_count'] = Variable<int>(lookupCount);
    map['first_lookup_at'] = Variable<DateTime>(firstLookupAt);
    map['last_lookup_at'] = Variable<DateTime>(lastLookupAt);
    return map;
  }

  VocabularyEntriesCompanion toCompanion(bool nullToAbsent) {
    return VocabularyEntriesCompanion(
      id: Value(id),
      lemma: Value(lemma),
      displayWord: Value(displayWord),
      phonetic: Value(phonetic),
      partOfSpeech: Value(partOfSpeech),
      definition: Value(definition),
      proficiency: Value(proficiency),
      lookupCount: Value(lookupCount),
      firstLookupAt: Value(firstLookupAt),
      lastLookupAt: Value(lastLookupAt),
    );
  }

  factory VocabularyEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VocabularyEntry(
      id: serializer.fromJson<String>(json['id']),
      lemma: serializer.fromJson<String>(json['lemma']),
      displayWord: serializer.fromJson<String>(json['displayWord']),
      phonetic: serializer.fromJson<String>(json['phonetic']),
      partOfSpeech: serializer.fromJson<String>(json['partOfSpeech']),
      definition: serializer.fromJson<String>(json['definition']),
      proficiency: serializer.fromJson<int>(json['proficiency']),
      lookupCount: serializer.fromJson<int>(json['lookupCount']),
      firstLookupAt: serializer.fromJson<DateTime>(json['firstLookupAt']),
      lastLookupAt: serializer.fromJson<DateTime>(json['lastLookupAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'lemma': serializer.toJson<String>(lemma),
      'displayWord': serializer.toJson<String>(displayWord),
      'phonetic': serializer.toJson<String>(phonetic),
      'partOfSpeech': serializer.toJson<String>(partOfSpeech),
      'definition': serializer.toJson<String>(definition),
      'proficiency': serializer.toJson<int>(proficiency),
      'lookupCount': serializer.toJson<int>(lookupCount),
      'firstLookupAt': serializer.toJson<DateTime>(firstLookupAt),
      'lastLookupAt': serializer.toJson<DateTime>(lastLookupAt),
    };
  }

  VocabularyEntry copyWith({
    String? id,
    String? lemma,
    String? displayWord,
    String? phonetic,
    String? partOfSpeech,
    String? definition,
    int? proficiency,
    int? lookupCount,
    DateTime? firstLookupAt,
    DateTime? lastLookupAt,
  }) => VocabularyEntry(
    id: id ?? this.id,
    lemma: lemma ?? this.lemma,
    displayWord: displayWord ?? this.displayWord,
    phonetic: phonetic ?? this.phonetic,
    partOfSpeech: partOfSpeech ?? this.partOfSpeech,
    definition: definition ?? this.definition,
    proficiency: proficiency ?? this.proficiency,
    lookupCount: lookupCount ?? this.lookupCount,
    firstLookupAt: firstLookupAt ?? this.firstLookupAt,
    lastLookupAt: lastLookupAt ?? this.lastLookupAt,
  );
  VocabularyEntry copyWithCompanion(VocabularyEntriesCompanion data) {
    return VocabularyEntry(
      id: data.id.present ? data.id.value : this.id,
      lemma: data.lemma.present ? data.lemma.value : this.lemma,
      displayWord: data.displayWord.present
          ? data.displayWord.value
          : this.displayWord,
      phonetic: data.phonetic.present ? data.phonetic.value : this.phonetic,
      partOfSpeech: data.partOfSpeech.present
          ? data.partOfSpeech.value
          : this.partOfSpeech,
      definition: data.definition.present
          ? data.definition.value
          : this.definition,
      proficiency: data.proficiency.present
          ? data.proficiency.value
          : this.proficiency,
      lookupCount: data.lookupCount.present
          ? data.lookupCount.value
          : this.lookupCount,
      firstLookupAt: data.firstLookupAt.present
          ? data.firstLookupAt.value
          : this.firstLookupAt,
      lastLookupAt: data.lastLookupAt.present
          ? data.lastLookupAt.value
          : this.lastLookupAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VocabularyEntry(')
          ..write('id: $id, ')
          ..write('lemma: $lemma, ')
          ..write('displayWord: $displayWord, ')
          ..write('phonetic: $phonetic, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('definition: $definition, ')
          ..write('proficiency: $proficiency, ')
          ..write('lookupCount: $lookupCount, ')
          ..write('firstLookupAt: $firstLookupAt, ')
          ..write('lastLookupAt: $lastLookupAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    lemma,
    displayWord,
    phonetic,
    partOfSpeech,
    definition,
    proficiency,
    lookupCount,
    firstLookupAt,
    lastLookupAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VocabularyEntry &&
          other.id == this.id &&
          other.lemma == this.lemma &&
          other.displayWord == this.displayWord &&
          other.phonetic == this.phonetic &&
          other.partOfSpeech == this.partOfSpeech &&
          other.definition == this.definition &&
          other.proficiency == this.proficiency &&
          other.lookupCount == this.lookupCount &&
          other.firstLookupAt == this.firstLookupAt &&
          other.lastLookupAt == this.lastLookupAt);
}

class VocabularyEntriesCompanion extends UpdateCompanion<VocabularyEntry> {
  final Value<String> id;
  final Value<String> lemma;
  final Value<String> displayWord;
  final Value<String> phonetic;
  final Value<String> partOfSpeech;
  final Value<String> definition;
  final Value<int> proficiency;
  final Value<int> lookupCount;
  final Value<DateTime> firstLookupAt;
  final Value<DateTime> lastLookupAt;
  final Value<int> rowid;
  const VocabularyEntriesCompanion({
    this.id = const Value.absent(),
    this.lemma = const Value.absent(),
    this.displayWord = const Value.absent(),
    this.phonetic = const Value.absent(),
    this.partOfSpeech = const Value.absent(),
    this.definition = const Value.absent(),
    this.proficiency = const Value.absent(),
    this.lookupCount = const Value.absent(),
    this.firstLookupAt = const Value.absent(),
    this.lastLookupAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VocabularyEntriesCompanion.insert({
    required String id,
    required String lemma,
    required String displayWord,
    this.phonetic = const Value.absent(),
    this.partOfSpeech = const Value.absent(),
    this.definition = const Value.absent(),
    this.proficiency = const Value.absent(),
    this.lookupCount = const Value.absent(),
    required DateTime firstLookupAt,
    required DateTime lastLookupAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       lemma = Value(lemma),
       displayWord = Value(displayWord),
       firstLookupAt = Value(firstLookupAt),
       lastLookupAt = Value(lastLookupAt);
  static Insertable<VocabularyEntry> custom({
    Expression<String>? id,
    Expression<String>? lemma,
    Expression<String>? displayWord,
    Expression<String>? phonetic,
    Expression<String>? partOfSpeech,
    Expression<String>? definition,
    Expression<int>? proficiency,
    Expression<int>? lookupCount,
    Expression<DateTime>? firstLookupAt,
    Expression<DateTime>? lastLookupAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lemma != null) 'lemma': lemma,
      if (displayWord != null) 'display_word': displayWord,
      if (phonetic != null) 'phonetic': phonetic,
      if (partOfSpeech != null) 'part_of_speech': partOfSpeech,
      if (definition != null) 'definition': definition,
      if (proficiency != null) 'proficiency': proficiency,
      if (lookupCount != null) 'lookup_count': lookupCount,
      if (firstLookupAt != null) 'first_lookup_at': firstLookupAt,
      if (lastLookupAt != null) 'last_lookup_at': lastLookupAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VocabularyEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? lemma,
    Value<String>? displayWord,
    Value<String>? phonetic,
    Value<String>? partOfSpeech,
    Value<String>? definition,
    Value<int>? proficiency,
    Value<int>? lookupCount,
    Value<DateTime>? firstLookupAt,
    Value<DateTime>? lastLookupAt,
    Value<int>? rowid,
  }) {
    return VocabularyEntriesCompanion(
      id: id ?? this.id,
      lemma: lemma ?? this.lemma,
      displayWord: displayWord ?? this.displayWord,
      phonetic: phonetic ?? this.phonetic,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      definition: definition ?? this.definition,
      proficiency: proficiency ?? this.proficiency,
      lookupCount: lookupCount ?? this.lookupCount,
      firstLookupAt: firstLookupAt ?? this.firstLookupAt,
      lastLookupAt: lastLookupAt ?? this.lastLookupAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (lemma.present) {
      map['lemma'] = Variable<String>(lemma.value);
    }
    if (displayWord.present) {
      map['display_word'] = Variable<String>(displayWord.value);
    }
    if (phonetic.present) {
      map['phonetic'] = Variable<String>(phonetic.value);
    }
    if (partOfSpeech.present) {
      map['part_of_speech'] = Variable<String>(partOfSpeech.value);
    }
    if (definition.present) {
      map['definition'] = Variable<String>(definition.value);
    }
    if (proficiency.present) {
      map['proficiency'] = Variable<int>(proficiency.value);
    }
    if (lookupCount.present) {
      map['lookup_count'] = Variable<int>(lookupCount.value);
    }
    if (firstLookupAt.present) {
      map['first_lookup_at'] = Variable<DateTime>(firstLookupAt.value);
    }
    if (lastLookupAt.present) {
      map['last_lookup_at'] = Variable<DateTime>(lastLookupAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VocabularyEntriesCompanion(')
          ..write('id: $id, ')
          ..write('lemma: $lemma, ')
          ..write('displayWord: $displayWord, ')
          ..write('phonetic: $phonetic, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('definition: $definition, ')
          ..write('proficiency: $proficiency, ')
          ..write('lookupCount: $lookupCount, ')
          ..write('firstLookupAt: $firstLookupAt, ')
          ..write('lastLookupAt: $lastLookupAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VocabularyEntriesTable vocabularyEntries =
      $VocabularyEntriesTable(this);
  late final LearningDao learningDao = LearningDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [vocabularyEntries];
}

typedef $$VocabularyEntriesTableCreateCompanionBuilder =
    VocabularyEntriesCompanion Function({
      required String id,
      required String lemma,
      required String displayWord,
      Value<String> phonetic,
      Value<String> partOfSpeech,
      Value<String> definition,
      Value<int> proficiency,
      Value<int> lookupCount,
      required DateTime firstLookupAt,
      required DateTime lastLookupAt,
      Value<int> rowid,
    });
typedef $$VocabularyEntriesTableUpdateCompanionBuilder =
    VocabularyEntriesCompanion Function({
      Value<String> id,
      Value<String> lemma,
      Value<String> displayWord,
      Value<String> phonetic,
      Value<String> partOfSpeech,
      Value<String> definition,
      Value<int> proficiency,
      Value<int> lookupCount,
      Value<DateTime> firstLookupAt,
      Value<DateTime> lastLookupAt,
      Value<int> rowid,
    });

class $$VocabularyEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $VocabularyEntriesTable> {
  $$VocabularyEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lemma => $composableBuilder(
    column: $table.lemma,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayWord => $composableBuilder(
    column: $table.displayWord,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phonetic => $composableBuilder(
    column: $table.phonetic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get proficiency => $composableBuilder(
    column: $table.proficiency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lookupCount => $composableBuilder(
    column: $table.lookupCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstLookupAt => $composableBuilder(
    column: $table.firstLookupAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastLookupAt => $composableBuilder(
    column: $table.lastLookupAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VocabularyEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $VocabularyEntriesTable> {
  $$VocabularyEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lemma => $composableBuilder(
    column: $table.lemma,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayWord => $composableBuilder(
    column: $table.displayWord,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phonetic => $composableBuilder(
    column: $table.phonetic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get proficiency => $composableBuilder(
    column: $table.proficiency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lookupCount => $composableBuilder(
    column: $table.lookupCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstLookupAt => $composableBuilder(
    column: $table.firstLookupAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastLookupAt => $composableBuilder(
    column: $table.lastLookupAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VocabularyEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VocabularyEntriesTable> {
  $$VocabularyEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lemma =>
      $composableBuilder(column: $table.lemma, builder: (column) => column);

  GeneratedColumn<String> get displayWord => $composableBuilder(
    column: $table.displayWord,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phonetic =>
      $composableBuilder(column: $table.phonetic, builder: (column) => column);

  GeneratedColumn<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => column,
  );

  GeneratedColumn<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => column,
  );

  GeneratedColumn<int> get proficiency => $composableBuilder(
    column: $table.proficiency,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lookupCount => $composableBuilder(
    column: $table.lookupCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get firstLookupAt => $composableBuilder(
    column: $table.firstLookupAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastLookupAt => $composableBuilder(
    column: $table.lastLookupAt,
    builder: (column) => column,
  );
}

class $$VocabularyEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VocabularyEntriesTable,
          VocabularyEntry,
          $$VocabularyEntriesTableFilterComposer,
          $$VocabularyEntriesTableOrderingComposer,
          $$VocabularyEntriesTableAnnotationComposer,
          $$VocabularyEntriesTableCreateCompanionBuilder,
          $$VocabularyEntriesTableUpdateCompanionBuilder,
          (
            VocabularyEntry,
            BaseReferences<
              _$AppDatabase,
              $VocabularyEntriesTable,
              VocabularyEntry
            >,
          ),
          VocabularyEntry,
          PrefetchHooks Function()
        > {
  $$VocabularyEntriesTableTableManager(
    _$AppDatabase db,
    $VocabularyEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VocabularyEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VocabularyEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VocabularyEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> lemma = const Value.absent(),
                Value<String> displayWord = const Value.absent(),
                Value<String> phonetic = const Value.absent(),
                Value<String> partOfSpeech = const Value.absent(),
                Value<String> definition = const Value.absent(),
                Value<int> proficiency = const Value.absent(),
                Value<int> lookupCount = const Value.absent(),
                Value<DateTime> firstLookupAt = const Value.absent(),
                Value<DateTime> lastLookupAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VocabularyEntriesCompanion(
                id: id,
                lemma: lemma,
                displayWord: displayWord,
                phonetic: phonetic,
                partOfSpeech: partOfSpeech,
                definition: definition,
                proficiency: proficiency,
                lookupCount: lookupCount,
                firstLookupAt: firstLookupAt,
                lastLookupAt: lastLookupAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String lemma,
                required String displayWord,
                Value<String> phonetic = const Value.absent(),
                Value<String> partOfSpeech = const Value.absent(),
                Value<String> definition = const Value.absent(),
                Value<int> proficiency = const Value.absent(),
                Value<int> lookupCount = const Value.absent(),
                required DateTime firstLookupAt,
                required DateTime lastLookupAt,
                Value<int> rowid = const Value.absent(),
              }) => VocabularyEntriesCompanion.insert(
                id: id,
                lemma: lemma,
                displayWord: displayWord,
                phonetic: phonetic,
                partOfSpeech: partOfSpeech,
                definition: definition,
                proficiency: proficiency,
                lookupCount: lookupCount,
                firstLookupAt: firstLookupAt,
                lastLookupAt: lastLookupAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VocabularyEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VocabularyEntriesTable,
      VocabularyEntry,
      $$VocabularyEntriesTableFilterComposer,
      $$VocabularyEntriesTableOrderingComposer,
      $$VocabularyEntriesTableAnnotationComposer,
      $$VocabularyEntriesTableCreateCompanionBuilder,
      $$VocabularyEntriesTableUpdateCompanionBuilder,
      (
        VocabularyEntry,
        BaseReferences<_$AppDatabase, $VocabularyEntriesTable, VocabularyEntry>,
      ),
      VocabularyEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VocabularyEntriesTableTableManager get vocabularyEntries =>
      $$VocabularyEntriesTableTableManager(_db, _db.vocabularyEntries);
}

mixin _$LearningDaoMixin on DatabaseAccessor<AppDatabase> {
  $VocabularyEntriesTable get vocabularyEntries =>
      attachedDatabase.vocabularyEntries;
  LearningDaoManager get managers => LearningDaoManager(this);
}

class LearningDaoManager {
  final _$LearningDaoMixin _db;
  LearningDaoManager(this._db);
  $$VocabularyEntriesTableTableManager get vocabularyEntries =>
      $$VocabularyEntriesTableTableManager(
        _db.attachedDatabase,
        _db.vocabularyEntries,
      );
}
