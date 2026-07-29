// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DocumentsTable extends Documents
    with TableInfo<$DocumentsTable, Document> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceNameMeta = const VerificationMeta(
    'sourceName',
  );
  @override
  late final GeneratedColumn<String> sourceName = GeneratedColumn<String>(
    'source_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageCountMeta = const VerificationMeta(
    'pageCount',
  );
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
    'page_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wordCountMeta = const VerificationMeta(
    'wordCount',
  );
  @override
  late final GeneratedColumn<int> wordCount = GeneratedColumn<int>(
    'word_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _paragraphCountMeta = const VerificationMeta(
    'paragraphCount',
  );
  @override
  late final GeneratedColumn<int> paragraphCount = GeneratedColumn<int>(
    'paragraph_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _parseStatusMeta = const VerificationMeta(
    'parseStatus',
  );
  @override
  late final GeneratedColumn<String> parseStatus = GeneratedColumn<String>(
    'parse_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parseProgressMeta = const VerificationMeta(
    'parseProgress',
  );
  @override
  late final GeneratedColumn<double> parseProgress = GeneratedColumn<double>(
    'parse_progress',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _failureCodeMeta = const VerificationMeta(
    'failureCode',
  );
  @override
  late final GeneratedColumn<String> failureCode = GeneratedColumn<String>(
    'failure_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _failureMessageMeta = const VerificationMeta(
    'failureMessage',
  );
  @override
  late final GeneratedColumn<String> failureMessage = GeneratedColumn<String>(
    'failure_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastReadLocatorMeta = const VerificationMeta(
    'lastReadLocator',
  );
  @override
  late final GeneratedColumn<String> lastReadLocator = GeneratedColumn<String>(
    'last_read_locator',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _readProgressMeta = const VerificationMeta(
    'readProgress',
  );
  @override
  late final GeneratedColumn<double> readProgress = GeneratedColumn<double>(
    'read_progress',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastOpenedAtMeta = const VerificationMeta(
    'lastOpenedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastOpenedAt = GeneratedColumn<DateTime>(
    'last_opened_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    format,
    sourceName,
    localPath,
    contentHash,
    fileSize,
    pageCount,
    wordCount,
    paragraphCount,
    parseStatus,
    parseProgress,
    failureCode,
    failureMessage,
    lastReadLocator,
    readProgress,
    createdAt,
    updatedAt,
    lastOpenedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<Document> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    if (data.containsKey('source_name')) {
      context.handle(
        _sourceNameMeta,
        sourceName.isAcceptableOrUnknown(data['source_name']!, _sourceNameMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceNameMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentHashMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
    }
    if (data.containsKey('page_count')) {
      context.handle(
        _pageCountMeta,
        pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta),
      );
    }
    if (data.containsKey('word_count')) {
      context.handle(
        _wordCountMeta,
        wordCount.isAcceptableOrUnknown(data['word_count']!, _wordCountMeta),
      );
    }
    if (data.containsKey('paragraph_count')) {
      context.handle(
        _paragraphCountMeta,
        paragraphCount.isAcceptableOrUnknown(
          data['paragraph_count']!,
          _paragraphCountMeta,
        ),
      );
    }
    if (data.containsKey('parse_status')) {
      context.handle(
        _parseStatusMeta,
        parseStatus.isAcceptableOrUnknown(
          data['parse_status']!,
          _parseStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_parseStatusMeta);
    }
    if (data.containsKey('parse_progress')) {
      context.handle(
        _parseProgressMeta,
        parseProgress.isAcceptableOrUnknown(
          data['parse_progress']!,
          _parseProgressMeta,
        ),
      );
    }
    if (data.containsKey('failure_code')) {
      context.handle(
        _failureCodeMeta,
        failureCode.isAcceptableOrUnknown(
          data['failure_code']!,
          _failureCodeMeta,
        ),
      );
    }
    if (data.containsKey('failure_message')) {
      context.handle(
        _failureMessageMeta,
        failureMessage.isAcceptableOrUnknown(
          data['failure_message']!,
          _failureMessageMeta,
        ),
      );
    }
    if (data.containsKey('last_read_locator')) {
      context.handle(
        _lastReadLocatorMeta,
        lastReadLocator.isAcceptableOrUnknown(
          data['last_read_locator']!,
          _lastReadLocatorMeta,
        ),
      );
    }
    if (data.containsKey('read_progress')) {
      context.handle(
        _readProgressMeta,
        readProgress.isAcceptableOrUnknown(
          data['read_progress']!,
          _readProgressMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('last_opened_at')) {
      context.handle(
        _lastOpenedAtMeta,
        lastOpenedAt.isAcceptableOrUnknown(
          data['last_opened_at']!,
          _lastOpenedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Document map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Document(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
      sourceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_name'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      )!,
      pageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_count'],
      ),
      wordCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_count'],
      )!,
      paragraphCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paragraph_count'],
      )!,
      parseStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parse_status'],
      )!,
      parseProgress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}parse_progress'],
      )!,
      failureCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}failure_code'],
      ),
      failureMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}failure_message'],
      ),
      lastReadLocator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_read_locator'],
      ),
      readProgress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}read_progress'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastOpenedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_opened_at'],
      ),
    );
  }

  @override
  $DocumentsTable createAlias(String alias) {
    return $DocumentsTable(attachedDatabase, alias);
  }
}

class Document extends DataClass implements Insertable<Document> {
  final String id;
  final String title;
  final String format;
  final String sourceName;
  final String localPath;
  final String contentHash;
  final int fileSize;
  final int? pageCount;
  final int wordCount;
  final int paragraphCount;
  final String parseStatus;
  final double parseProgress;
  final String? failureCode;
  final String? failureMessage;
  final String? lastReadLocator;
  final double readProgress;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastOpenedAt;
  const Document({
    required this.id,
    required this.title,
    required this.format,
    required this.sourceName,
    required this.localPath,
    required this.contentHash,
    required this.fileSize,
    this.pageCount,
    required this.wordCount,
    required this.paragraphCount,
    required this.parseStatus,
    required this.parseProgress,
    this.failureCode,
    this.failureMessage,
    this.lastReadLocator,
    required this.readProgress,
    required this.createdAt,
    required this.updatedAt,
    this.lastOpenedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['format'] = Variable<String>(format);
    map['source_name'] = Variable<String>(sourceName);
    map['local_path'] = Variable<String>(localPath);
    map['content_hash'] = Variable<String>(contentHash);
    map['file_size'] = Variable<int>(fileSize);
    if (!nullToAbsent || pageCount != null) {
      map['page_count'] = Variable<int>(pageCount);
    }
    map['word_count'] = Variable<int>(wordCount);
    map['paragraph_count'] = Variable<int>(paragraphCount);
    map['parse_status'] = Variable<String>(parseStatus);
    map['parse_progress'] = Variable<double>(parseProgress);
    if (!nullToAbsent || failureCode != null) {
      map['failure_code'] = Variable<String>(failureCode);
    }
    if (!nullToAbsent || failureMessage != null) {
      map['failure_message'] = Variable<String>(failureMessage);
    }
    if (!nullToAbsent || lastReadLocator != null) {
      map['last_read_locator'] = Variable<String>(lastReadLocator);
    }
    map['read_progress'] = Variable<double>(readProgress);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastOpenedAt != null) {
      map['last_opened_at'] = Variable<DateTime>(lastOpenedAt);
    }
    return map;
  }

  DocumentsCompanion toCompanion(bool nullToAbsent) {
    return DocumentsCompanion(
      id: Value(id),
      title: Value(title),
      format: Value(format),
      sourceName: Value(sourceName),
      localPath: Value(localPath),
      contentHash: Value(contentHash),
      fileSize: Value(fileSize),
      pageCount: pageCount == null && nullToAbsent
          ? const Value.absent()
          : Value(pageCount),
      wordCount: Value(wordCount),
      paragraphCount: Value(paragraphCount),
      parseStatus: Value(parseStatus),
      parseProgress: Value(parseProgress),
      failureCode: failureCode == null && nullToAbsent
          ? const Value.absent()
          : Value(failureCode),
      failureMessage: failureMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(failureMessage),
      lastReadLocator: lastReadLocator == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReadLocator),
      readProgress: Value(readProgress),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastOpenedAt: lastOpenedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastOpenedAt),
    );
  }

  factory Document.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Document(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      format: serializer.fromJson<String>(json['format']),
      sourceName: serializer.fromJson<String>(json['sourceName']),
      localPath: serializer.fromJson<String>(json['localPath']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      pageCount: serializer.fromJson<int?>(json['pageCount']),
      wordCount: serializer.fromJson<int>(json['wordCount']),
      paragraphCount: serializer.fromJson<int>(json['paragraphCount']),
      parseStatus: serializer.fromJson<String>(json['parseStatus']),
      parseProgress: serializer.fromJson<double>(json['parseProgress']),
      failureCode: serializer.fromJson<String?>(json['failureCode']),
      failureMessage: serializer.fromJson<String?>(json['failureMessage']),
      lastReadLocator: serializer.fromJson<String?>(json['lastReadLocator']),
      readProgress: serializer.fromJson<double>(json['readProgress']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastOpenedAt: serializer.fromJson<DateTime?>(json['lastOpenedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'format': serializer.toJson<String>(format),
      'sourceName': serializer.toJson<String>(sourceName),
      'localPath': serializer.toJson<String>(localPath),
      'contentHash': serializer.toJson<String>(contentHash),
      'fileSize': serializer.toJson<int>(fileSize),
      'pageCount': serializer.toJson<int?>(pageCount),
      'wordCount': serializer.toJson<int>(wordCount),
      'paragraphCount': serializer.toJson<int>(paragraphCount),
      'parseStatus': serializer.toJson<String>(parseStatus),
      'parseProgress': serializer.toJson<double>(parseProgress),
      'failureCode': serializer.toJson<String?>(failureCode),
      'failureMessage': serializer.toJson<String?>(failureMessage),
      'lastReadLocator': serializer.toJson<String?>(lastReadLocator),
      'readProgress': serializer.toJson<double>(readProgress),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastOpenedAt': serializer.toJson<DateTime?>(lastOpenedAt),
    };
  }

  Document copyWith({
    String? id,
    String? title,
    String? format,
    String? sourceName,
    String? localPath,
    String? contentHash,
    int? fileSize,
    Value<int?> pageCount = const Value.absent(),
    int? wordCount,
    int? paragraphCount,
    String? parseStatus,
    double? parseProgress,
    Value<String?> failureCode = const Value.absent(),
    Value<String?> failureMessage = const Value.absent(),
    Value<String?> lastReadLocator = const Value.absent(),
    double? readProgress,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastOpenedAt = const Value.absent(),
  }) => Document(
    id: id ?? this.id,
    title: title ?? this.title,
    format: format ?? this.format,
    sourceName: sourceName ?? this.sourceName,
    localPath: localPath ?? this.localPath,
    contentHash: contentHash ?? this.contentHash,
    fileSize: fileSize ?? this.fileSize,
    pageCount: pageCount.present ? pageCount.value : this.pageCount,
    wordCount: wordCount ?? this.wordCount,
    paragraphCount: paragraphCount ?? this.paragraphCount,
    parseStatus: parseStatus ?? this.parseStatus,
    parseProgress: parseProgress ?? this.parseProgress,
    failureCode: failureCode.present ? failureCode.value : this.failureCode,
    failureMessage: failureMessage.present
        ? failureMessage.value
        : this.failureMessage,
    lastReadLocator: lastReadLocator.present
        ? lastReadLocator.value
        : this.lastReadLocator,
    readProgress: readProgress ?? this.readProgress,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastOpenedAt: lastOpenedAt.present ? lastOpenedAt.value : this.lastOpenedAt,
  );
  Document copyWithCompanion(DocumentsCompanion data) {
    return Document(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      format: data.format.present ? data.format.value : this.format,
      sourceName: data.sourceName.present
          ? data.sourceName.value
          : this.sourceName,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      wordCount: data.wordCount.present ? data.wordCount.value : this.wordCount,
      paragraphCount: data.paragraphCount.present
          ? data.paragraphCount.value
          : this.paragraphCount,
      parseStatus: data.parseStatus.present
          ? data.parseStatus.value
          : this.parseStatus,
      parseProgress: data.parseProgress.present
          ? data.parseProgress.value
          : this.parseProgress,
      failureCode: data.failureCode.present
          ? data.failureCode.value
          : this.failureCode,
      failureMessage: data.failureMessage.present
          ? data.failureMessage.value
          : this.failureMessage,
      lastReadLocator: data.lastReadLocator.present
          ? data.lastReadLocator.value
          : this.lastReadLocator,
      readProgress: data.readProgress.present
          ? data.readProgress.value
          : this.readProgress,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastOpenedAt: data.lastOpenedAt.present
          ? data.lastOpenedAt.value
          : this.lastOpenedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Document(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('format: $format, ')
          ..write('sourceName: $sourceName, ')
          ..write('localPath: $localPath, ')
          ..write('contentHash: $contentHash, ')
          ..write('fileSize: $fileSize, ')
          ..write('pageCount: $pageCount, ')
          ..write('wordCount: $wordCount, ')
          ..write('paragraphCount: $paragraphCount, ')
          ..write('parseStatus: $parseStatus, ')
          ..write('parseProgress: $parseProgress, ')
          ..write('failureCode: $failureCode, ')
          ..write('failureMessage: $failureMessage, ')
          ..write('lastReadLocator: $lastReadLocator, ')
          ..write('readProgress: $readProgress, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastOpenedAt: $lastOpenedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    format,
    sourceName,
    localPath,
    contentHash,
    fileSize,
    pageCount,
    wordCount,
    paragraphCount,
    parseStatus,
    parseProgress,
    failureCode,
    failureMessage,
    lastReadLocator,
    readProgress,
    createdAt,
    updatedAt,
    lastOpenedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Document &&
          other.id == this.id &&
          other.title == this.title &&
          other.format == this.format &&
          other.sourceName == this.sourceName &&
          other.localPath == this.localPath &&
          other.contentHash == this.contentHash &&
          other.fileSize == this.fileSize &&
          other.pageCount == this.pageCount &&
          other.wordCount == this.wordCount &&
          other.paragraphCount == this.paragraphCount &&
          other.parseStatus == this.parseStatus &&
          other.parseProgress == this.parseProgress &&
          other.failureCode == this.failureCode &&
          other.failureMessage == this.failureMessage &&
          other.lastReadLocator == this.lastReadLocator &&
          other.readProgress == this.readProgress &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastOpenedAt == this.lastOpenedAt);
}

class DocumentsCompanion extends UpdateCompanion<Document> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> format;
  final Value<String> sourceName;
  final Value<String> localPath;
  final Value<String> contentHash;
  final Value<int> fileSize;
  final Value<int?> pageCount;
  final Value<int> wordCount;
  final Value<int> paragraphCount;
  final Value<String> parseStatus;
  final Value<double> parseProgress;
  final Value<String?> failureCode;
  final Value<String?> failureMessage;
  final Value<String?> lastReadLocator;
  final Value<double> readProgress;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastOpenedAt;
  final Value<int> rowid;
  const DocumentsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.format = const Value.absent(),
    this.sourceName = const Value.absent(),
    this.localPath = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.paragraphCount = const Value.absent(),
    this.parseStatus = const Value.absent(),
    this.parseProgress = const Value.absent(),
    this.failureCode = const Value.absent(),
    this.failureMessage = const Value.absent(),
    this.lastReadLocator = const Value.absent(),
    this.readProgress = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastOpenedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentsCompanion.insert({
    required String id,
    required String title,
    required String format,
    required String sourceName,
    required String localPath,
    required String contentHash,
    required int fileSize,
    this.pageCount = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.paragraphCount = const Value.absent(),
    required String parseStatus,
    this.parseProgress = const Value.absent(),
    this.failureCode = const Value.absent(),
    this.failureMessage = const Value.absent(),
    this.lastReadLocator = const Value.absent(),
    this.readProgress = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.lastOpenedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       format = Value(format),
       sourceName = Value(sourceName),
       localPath = Value(localPath),
       contentHash = Value(contentHash),
       fileSize = Value(fileSize),
       parseStatus = Value(parseStatus),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Document> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? format,
    Expression<String>? sourceName,
    Expression<String>? localPath,
    Expression<String>? contentHash,
    Expression<int>? fileSize,
    Expression<int>? pageCount,
    Expression<int>? wordCount,
    Expression<int>? paragraphCount,
    Expression<String>? parseStatus,
    Expression<double>? parseProgress,
    Expression<String>? failureCode,
    Expression<String>? failureMessage,
    Expression<String>? lastReadLocator,
    Expression<double>? readProgress,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastOpenedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (format != null) 'format': format,
      if (sourceName != null) 'source_name': sourceName,
      if (localPath != null) 'local_path': localPath,
      if (contentHash != null) 'content_hash': contentHash,
      if (fileSize != null) 'file_size': fileSize,
      if (pageCount != null) 'page_count': pageCount,
      if (wordCount != null) 'word_count': wordCount,
      if (paragraphCount != null) 'paragraph_count': paragraphCount,
      if (parseStatus != null) 'parse_status': parseStatus,
      if (parseProgress != null) 'parse_progress': parseProgress,
      if (failureCode != null) 'failure_code': failureCode,
      if (failureMessage != null) 'failure_message': failureMessage,
      if (lastReadLocator != null) 'last_read_locator': lastReadLocator,
      if (readProgress != null) 'read_progress': readProgress,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastOpenedAt != null) 'last_opened_at': lastOpenedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? format,
    Value<String>? sourceName,
    Value<String>? localPath,
    Value<String>? contentHash,
    Value<int>? fileSize,
    Value<int?>? pageCount,
    Value<int>? wordCount,
    Value<int>? paragraphCount,
    Value<String>? parseStatus,
    Value<double>? parseProgress,
    Value<String?>? failureCode,
    Value<String?>? failureMessage,
    Value<String?>? lastReadLocator,
    Value<double>? readProgress,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastOpenedAt,
    Value<int>? rowid,
  }) {
    return DocumentsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      format: format ?? this.format,
      sourceName: sourceName ?? this.sourceName,
      localPath: localPath ?? this.localPath,
      contentHash: contentHash ?? this.contentHash,
      fileSize: fileSize ?? this.fileSize,
      pageCount: pageCount ?? this.pageCount,
      wordCount: wordCount ?? this.wordCount,
      paragraphCount: paragraphCount ?? this.paragraphCount,
      parseStatus: parseStatus ?? this.parseStatus,
      parseProgress: parseProgress ?? this.parseProgress,
      failureCode: failureCode ?? this.failureCode,
      failureMessage: failureMessage ?? this.failureMessage,
      lastReadLocator: lastReadLocator ?? this.lastReadLocator,
      readProgress: readProgress ?? this.readProgress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (sourceName.present) {
      map['source_name'] = Variable<String>(sourceName.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (wordCount.present) {
      map['word_count'] = Variable<int>(wordCount.value);
    }
    if (paragraphCount.present) {
      map['paragraph_count'] = Variable<int>(paragraphCount.value);
    }
    if (parseStatus.present) {
      map['parse_status'] = Variable<String>(parseStatus.value);
    }
    if (parseProgress.present) {
      map['parse_progress'] = Variable<double>(parseProgress.value);
    }
    if (failureCode.present) {
      map['failure_code'] = Variable<String>(failureCode.value);
    }
    if (failureMessage.present) {
      map['failure_message'] = Variable<String>(failureMessage.value);
    }
    if (lastReadLocator.present) {
      map['last_read_locator'] = Variable<String>(lastReadLocator.value);
    }
    if (readProgress.present) {
      map['read_progress'] = Variable<double>(readProgress.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastOpenedAt.present) {
      map['last_opened_at'] = Variable<DateTime>(lastOpenedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('format: $format, ')
          ..write('sourceName: $sourceName, ')
          ..write('localPath: $localPath, ')
          ..write('contentHash: $contentHash, ')
          ..write('fileSize: $fileSize, ')
          ..write('pageCount: $pageCount, ')
          ..write('wordCount: $wordCount, ')
          ..write('paragraphCount: $paragraphCount, ')
          ..write('parseStatus: $parseStatus, ')
          ..write('parseProgress: $parseProgress, ')
          ..write('failureCode: $failureCode, ')
          ..write('failureMessage: $failureMessage, ')
          ..write('lastReadLocator: $lastReadLocator, ')
          ..write('readProgress: $readProgress, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastOpenedAt: $lastOpenedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ParagraphsTable extends Paragraphs
    with TableInfo<$ParagraphsTable, Paragraph> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParagraphsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES documents (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ordinalMeta = const VerificationMeta(
    'ordinal',
  );
  @override
  late final GeneratedColumn<int> ordinal = GeneratedColumn<int>(
    'ordinal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _styleMeta = const VerificationMeta('style');
  @override
  late final GeneratedColumn<String> style = GeneratedColumn<String>(
    'style',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('body'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, documentId, ordinal, body, style];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'paragraphs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Paragraph> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('ordinal')) {
      context.handle(
        _ordinalMeta,
        ordinal.isAcceptableOrUnknown(data['ordinal']!, _ordinalMeta),
      );
    } else if (isInserting) {
      context.missing(_ordinalMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['text']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('style')) {
      context.handle(
        _styleMeta,
        style.isAcceptableOrUnknown(data['style']!, _styleMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {documentId, ordinal},
  ];
  @override
  Paragraph map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Paragraph(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      ordinal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordinal'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      style: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}style'],
      )!,
    );
  }

  @override
  $ParagraphsTable createAlias(String alias) {
    return $ParagraphsTable(attachedDatabase, alias);
  }
}

class Paragraph extends DataClass implements Insertable<Paragraph> {
  final String id;
  final String documentId;
  final int ordinal;
  final String body;
  final String style;
  const Paragraph({
    required this.id,
    required this.documentId,
    required this.ordinal,
    required this.body,
    required this.style,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['document_id'] = Variable<String>(documentId);
    map['ordinal'] = Variable<int>(ordinal);
    map['text'] = Variable<String>(body);
    map['style'] = Variable<String>(style);
    return map;
  }

  ParagraphsCompanion toCompanion(bool nullToAbsent) {
    return ParagraphsCompanion(
      id: Value(id),
      documentId: Value(documentId),
      ordinal: Value(ordinal),
      body: Value(body),
      style: Value(style),
    );
  }

  factory Paragraph.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Paragraph(
      id: serializer.fromJson<String>(json['id']),
      documentId: serializer.fromJson<String>(json['documentId']),
      ordinal: serializer.fromJson<int>(json['ordinal']),
      body: serializer.fromJson<String>(json['body']),
      style: serializer.fromJson<String>(json['style']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'documentId': serializer.toJson<String>(documentId),
      'ordinal': serializer.toJson<int>(ordinal),
      'body': serializer.toJson<String>(body),
      'style': serializer.toJson<String>(style),
    };
  }

  Paragraph copyWith({
    String? id,
    String? documentId,
    int? ordinal,
    String? body,
    String? style,
  }) => Paragraph(
    id: id ?? this.id,
    documentId: documentId ?? this.documentId,
    ordinal: ordinal ?? this.ordinal,
    body: body ?? this.body,
    style: style ?? this.style,
  );
  Paragraph copyWithCompanion(ParagraphsCompanion data) {
    return Paragraph(
      id: data.id.present ? data.id.value : this.id,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      ordinal: data.ordinal.present ? data.ordinal.value : this.ordinal,
      body: data.body.present ? data.body.value : this.body,
      style: data.style.present ? data.style.value : this.style,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Paragraph(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('ordinal: $ordinal, ')
          ..write('body: $body, ')
          ..write('style: $style')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, documentId, ordinal, body, style);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Paragraph &&
          other.id == this.id &&
          other.documentId == this.documentId &&
          other.ordinal == this.ordinal &&
          other.body == this.body &&
          other.style == this.style);
}

class ParagraphsCompanion extends UpdateCompanion<Paragraph> {
  final Value<String> id;
  final Value<String> documentId;
  final Value<int> ordinal;
  final Value<String> body;
  final Value<String> style;
  final Value<int> rowid;
  const ParagraphsCompanion({
    this.id = const Value.absent(),
    this.documentId = const Value.absent(),
    this.ordinal = const Value.absent(),
    this.body = const Value.absent(),
    this.style = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ParagraphsCompanion.insert({
    required String id,
    required String documentId,
    required int ordinal,
    required String body,
    this.style = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       documentId = Value(documentId),
       ordinal = Value(ordinal),
       body = Value(body);
  static Insertable<Paragraph> custom({
    Expression<String>? id,
    Expression<String>? documentId,
    Expression<int>? ordinal,
    Expression<String>? body,
    Expression<String>? style,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentId != null) 'document_id': documentId,
      if (ordinal != null) 'ordinal': ordinal,
      if (body != null) 'text': body,
      if (style != null) 'style': style,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ParagraphsCompanion copyWith({
    Value<String>? id,
    Value<String>? documentId,
    Value<int>? ordinal,
    Value<String>? body,
    Value<String>? style,
    Value<int>? rowid,
  }) {
    return ParagraphsCompanion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      ordinal: ordinal ?? this.ordinal,
      body: body ?? this.body,
      style: style ?? this.style,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (ordinal.present) {
      map['ordinal'] = Variable<int>(ordinal.value);
    }
    if (body.present) {
      map['text'] = Variable<String>(body.value);
    }
    if (style.present) {
      map['style'] = Variable<String>(style.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ParagraphsCompanion(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('ordinal: $ordinal, ')
          ..write('body: $body, ')
          ..write('style: $style, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SentencesTable extends Sentences
    with TableInfo<$SentencesTable, Sentence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SentencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES documents (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _paragraphIdMeta = const VerificationMeta(
    'paragraphId',
  );
  @override
  late final GeneratedColumn<String> paragraphId = GeneratedColumn<String>(
    'paragraph_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES paragraphs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ordinalMeta = const VerificationMeta(
    'ordinal',
  );
  @override
  late final GeneratedColumn<int> ordinal = GeneratedColumn<int>(
    'ordinal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startOffsetMeta = const VerificationMeta(
    'startOffset',
  );
  @override
  late final GeneratedColumn<int> startOffset = GeneratedColumn<int>(
    'start_offset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endOffsetMeta = const VerificationMeta(
    'endOffset',
  );
  @override
  late final GeneratedColumn<int> endOffset = GeneratedColumn<int>(
    'end_offset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    documentId,
    paragraphId,
    ordinal,
    body,
    startOffset,
    endOffset,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sentences';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sentence> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('paragraph_id')) {
      context.handle(
        _paragraphIdMeta,
        paragraphId.isAcceptableOrUnknown(
          data['paragraph_id']!,
          _paragraphIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paragraphIdMeta);
    }
    if (data.containsKey('ordinal')) {
      context.handle(
        _ordinalMeta,
        ordinal.isAcceptableOrUnknown(data['ordinal']!, _ordinalMeta),
      );
    } else if (isInserting) {
      context.missing(_ordinalMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['text']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('start_offset')) {
      context.handle(
        _startOffsetMeta,
        startOffset.isAcceptableOrUnknown(
          data['start_offset']!,
          _startOffsetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startOffsetMeta);
    }
    if (data.containsKey('end_offset')) {
      context.handle(
        _endOffsetMeta,
        endOffset.isAcceptableOrUnknown(data['end_offset']!, _endOffsetMeta),
      );
    } else if (isInserting) {
      context.missing(_endOffsetMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sentence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sentence(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      paragraphId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paragraph_id'],
      )!,
      ordinal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordinal'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      startOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_offset'],
      )!,
      endOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_offset'],
      )!,
    );
  }

  @override
  $SentencesTable createAlias(String alias) {
    return $SentencesTable(attachedDatabase, alias);
  }
}

class Sentence extends DataClass implements Insertable<Sentence> {
  final String id;
  final String documentId;
  final String paragraphId;
  final int ordinal;
  final String body;
  final int startOffset;
  final int endOffset;
  const Sentence({
    required this.id,
    required this.documentId,
    required this.paragraphId,
    required this.ordinal,
    required this.body,
    required this.startOffset,
    required this.endOffset,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['document_id'] = Variable<String>(documentId);
    map['paragraph_id'] = Variable<String>(paragraphId);
    map['ordinal'] = Variable<int>(ordinal);
    map['text'] = Variable<String>(body);
    map['start_offset'] = Variable<int>(startOffset);
    map['end_offset'] = Variable<int>(endOffset);
    return map;
  }

  SentencesCompanion toCompanion(bool nullToAbsent) {
    return SentencesCompanion(
      id: Value(id),
      documentId: Value(documentId),
      paragraphId: Value(paragraphId),
      ordinal: Value(ordinal),
      body: Value(body),
      startOffset: Value(startOffset),
      endOffset: Value(endOffset),
    );
  }

  factory Sentence.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sentence(
      id: serializer.fromJson<String>(json['id']),
      documentId: serializer.fromJson<String>(json['documentId']),
      paragraphId: serializer.fromJson<String>(json['paragraphId']),
      ordinal: serializer.fromJson<int>(json['ordinal']),
      body: serializer.fromJson<String>(json['body']),
      startOffset: serializer.fromJson<int>(json['startOffset']),
      endOffset: serializer.fromJson<int>(json['endOffset']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'documentId': serializer.toJson<String>(documentId),
      'paragraphId': serializer.toJson<String>(paragraphId),
      'ordinal': serializer.toJson<int>(ordinal),
      'body': serializer.toJson<String>(body),
      'startOffset': serializer.toJson<int>(startOffset),
      'endOffset': serializer.toJson<int>(endOffset),
    };
  }

  Sentence copyWith({
    String? id,
    String? documentId,
    String? paragraphId,
    int? ordinal,
    String? body,
    int? startOffset,
    int? endOffset,
  }) => Sentence(
    id: id ?? this.id,
    documentId: documentId ?? this.documentId,
    paragraphId: paragraphId ?? this.paragraphId,
    ordinal: ordinal ?? this.ordinal,
    body: body ?? this.body,
    startOffset: startOffset ?? this.startOffset,
    endOffset: endOffset ?? this.endOffset,
  );
  Sentence copyWithCompanion(SentencesCompanion data) {
    return Sentence(
      id: data.id.present ? data.id.value : this.id,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      paragraphId: data.paragraphId.present
          ? data.paragraphId.value
          : this.paragraphId,
      ordinal: data.ordinal.present ? data.ordinal.value : this.ordinal,
      body: data.body.present ? data.body.value : this.body,
      startOffset: data.startOffset.present
          ? data.startOffset.value
          : this.startOffset,
      endOffset: data.endOffset.present ? data.endOffset.value : this.endOffset,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sentence(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('paragraphId: $paragraphId, ')
          ..write('ordinal: $ordinal, ')
          ..write('body: $body, ')
          ..write('startOffset: $startOffset, ')
          ..write('endOffset: $endOffset')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    documentId,
    paragraphId,
    ordinal,
    body,
    startOffset,
    endOffset,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sentence &&
          other.id == this.id &&
          other.documentId == this.documentId &&
          other.paragraphId == this.paragraphId &&
          other.ordinal == this.ordinal &&
          other.body == this.body &&
          other.startOffset == this.startOffset &&
          other.endOffset == this.endOffset);
}

class SentencesCompanion extends UpdateCompanion<Sentence> {
  final Value<String> id;
  final Value<String> documentId;
  final Value<String> paragraphId;
  final Value<int> ordinal;
  final Value<String> body;
  final Value<int> startOffset;
  final Value<int> endOffset;
  final Value<int> rowid;
  const SentencesCompanion({
    this.id = const Value.absent(),
    this.documentId = const Value.absent(),
    this.paragraphId = const Value.absent(),
    this.ordinal = const Value.absent(),
    this.body = const Value.absent(),
    this.startOffset = const Value.absent(),
    this.endOffset = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SentencesCompanion.insert({
    required String id,
    required String documentId,
    required String paragraphId,
    required int ordinal,
    required String body,
    required int startOffset,
    required int endOffset,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       documentId = Value(documentId),
       paragraphId = Value(paragraphId),
       ordinal = Value(ordinal),
       body = Value(body),
       startOffset = Value(startOffset),
       endOffset = Value(endOffset);
  static Insertable<Sentence> custom({
    Expression<String>? id,
    Expression<String>? documentId,
    Expression<String>? paragraphId,
    Expression<int>? ordinal,
    Expression<String>? body,
    Expression<int>? startOffset,
    Expression<int>? endOffset,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentId != null) 'document_id': documentId,
      if (paragraphId != null) 'paragraph_id': paragraphId,
      if (ordinal != null) 'ordinal': ordinal,
      if (body != null) 'text': body,
      if (startOffset != null) 'start_offset': startOffset,
      if (endOffset != null) 'end_offset': endOffset,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SentencesCompanion copyWith({
    Value<String>? id,
    Value<String>? documentId,
    Value<String>? paragraphId,
    Value<int>? ordinal,
    Value<String>? body,
    Value<int>? startOffset,
    Value<int>? endOffset,
    Value<int>? rowid,
  }) {
    return SentencesCompanion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      paragraphId: paragraphId ?? this.paragraphId,
      ordinal: ordinal ?? this.ordinal,
      body: body ?? this.body,
      startOffset: startOffset ?? this.startOffset,
      endOffset: endOffset ?? this.endOffset,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (paragraphId.present) {
      map['paragraph_id'] = Variable<String>(paragraphId.value);
    }
    if (ordinal.present) {
      map['ordinal'] = Variable<int>(ordinal.value);
    }
    if (body.present) {
      map['text'] = Variable<String>(body.value);
    }
    if (startOffset.present) {
      map['start_offset'] = Variable<int>(startOffset.value);
    }
    if (endOffset.present) {
      map['end_offset'] = Variable<int>(endOffset.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SentencesCompanion(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('paragraphId: $paragraphId, ')
          ..write('ordinal: $ordinal, ')
          ..write('body: $body, ')
          ..write('startOffset: $startOffset, ')
          ..write('endOffset: $endOffset, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TokensTable extends Tokens with TableInfo<$TokensTable, Token> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TokensTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES documents (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sentenceIdMeta = const VerificationMeta(
    'sentenceId',
  );
  @override
  late final GeneratedColumn<String> sentenceId = GeneratedColumn<String>(
    'sentence_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sentences (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ordinalMeta = const VerificationMeta(
    'ordinal',
  );
  @override
  late final GeneratedColumn<int> ordinal = GeneratedColumn<int>(
    'ordinal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _surfaceMeta = const VerificationMeta(
    'surface',
  );
  @override
  late final GeneratedColumn<String> surface = GeneratedColumn<String>(
    'surface',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedMeta = const VerificationMeta(
    'normalized',
  );
  @override
  late final GeneratedColumn<String> normalized = GeneratedColumn<String>(
    'normalized',
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
  static const VerificationMeta _startOffsetMeta = const VerificationMeta(
    'startOffset',
  );
  @override
  late final GeneratedColumn<int> startOffset = GeneratedColumn<int>(
    'start_offset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endOffsetMeta = const VerificationMeta(
    'endOffset',
  );
  @override
  late final GeneratedColumn<int> endOffset = GeneratedColumn<int>(
    'end_offset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    documentId,
    sentenceId,
    ordinal,
    surface,
    normalized,
    lemma,
    partOfSpeech,
    startOffset,
    endOffset,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tokens';
  @override
  VerificationContext validateIntegrity(
    Insertable<Token> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('sentence_id')) {
      context.handle(
        _sentenceIdMeta,
        sentenceId.isAcceptableOrUnknown(data['sentence_id']!, _sentenceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sentenceIdMeta);
    }
    if (data.containsKey('ordinal')) {
      context.handle(
        _ordinalMeta,
        ordinal.isAcceptableOrUnknown(data['ordinal']!, _ordinalMeta),
      );
    } else if (isInserting) {
      context.missing(_ordinalMeta);
    }
    if (data.containsKey('surface')) {
      context.handle(
        _surfaceMeta,
        surface.isAcceptableOrUnknown(data['surface']!, _surfaceMeta),
      );
    } else if (isInserting) {
      context.missing(_surfaceMeta);
    }
    if (data.containsKey('normalized')) {
      context.handle(
        _normalizedMeta,
        normalized.isAcceptableOrUnknown(data['normalized']!, _normalizedMeta),
      );
    } else if (isInserting) {
      context.missing(_normalizedMeta);
    }
    if (data.containsKey('lemma')) {
      context.handle(
        _lemmaMeta,
        lemma.isAcceptableOrUnknown(data['lemma']!, _lemmaMeta),
      );
    } else if (isInserting) {
      context.missing(_lemmaMeta);
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
    if (data.containsKey('start_offset')) {
      context.handle(
        _startOffsetMeta,
        startOffset.isAcceptableOrUnknown(
          data['start_offset']!,
          _startOffsetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startOffsetMeta);
    }
    if (data.containsKey('end_offset')) {
      context.handle(
        _endOffsetMeta,
        endOffset.isAcceptableOrUnknown(data['end_offset']!, _endOffsetMeta),
      );
    } else if (isInserting) {
      context.missing(_endOffsetMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Token map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Token(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      sentenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sentence_id'],
      )!,
      ordinal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordinal'],
      )!,
      surface: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}surface'],
      )!,
      normalized: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized'],
      )!,
      lemma: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lemma'],
      )!,
      partOfSpeech: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part_of_speech'],
      )!,
      startOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_offset'],
      )!,
      endOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_offset'],
      )!,
    );
  }

  @override
  $TokensTable createAlias(String alias) {
    return $TokensTable(attachedDatabase, alias);
  }
}

class Token extends DataClass implements Insertable<Token> {
  final String id;
  final String documentId;
  final String sentenceId;
  final int ordinal;
  final String surface;
  final String normalized;
  final String lemma;
  final String partOfSpeech;
  final int startOffset;
  final int endOffset;
  const Token({
    required this.id,
    required this.documentId,
    required this.sentenceId,
    required this.ordinal,
    required this.surface,
    required this.normalized,
    required this.lemma,
    required this.partOfSpeech,
    required this.startOffset,
    required this.endOffset,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['document_id'] = Variable<String>(documentId);
    map['sentence_id'] = Variable<String>(sentenceId);
    map['ordinal'] = Variable<int>(ordinal);
    map['surface'] = Variable<String>(surface);
    map['normalized'] = Variable<String>(normalized);
    map['lemma'] = Variable<String>(lemma);
    map['part_of_speech'] = Variable<String>(partOfSpeech);
    map['start_offset'] = Variable<int>(startOffset);
    map['end_offset'] = Variable<int>(endOffset);
    return map;
  }

  TokensCompanion toCompanion(bool nullToAbsent) {
    return TokensCompanion(
      id: Value(id),
      documentId: Value(documentId),
      sentenceId: Value(sentenceId),
      ordinal: Value(ordinal),
      surface: Value(surface),
      normalized: Value(normalized),
      lemma: Value(lemma),
      partOfSpeech: Value(partOfSpeech),
      startOffset: Value(startOffset),
      endOffset: Value(endOffset),
    );
  }

  factory Token.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Token(
      id: serializer.fromJson<String>(json['id']),
      documentId: serializer.fromJson<String>(json['documentId']),
      sentenceId: serializer.fromJson<String>(json['sentenceId']),
      ordinal: serializer.fromJson<int>(json['ordinal']),
      surface: serializer.fromJson<String>(json['surface']),
      normalized: serializer.fromJson<String>(json['normalized']),
      lemma: serializer.fromJson<String>(json['lemma']),
      partOfSpeech: serializer.fromJson<String>(json['partOfSpeech']),
      startOffset: serializer.fromJson<int>(json['startOffset']),
      endOffset: serializer.fromJson<int>(json['endOffset']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'documentId': serializer.toJson<String>(documentId),
      'sentenceId': serializer.toJson<String>(sentenceId),
      'ordinal': serializer.toJson<int>(ordinal),
      'surface': serializer.toJson<String>(surface),
      'normalized': serializer.toJson<String>(normalized),
      'lemma': serializer.toJson<String>(lemma),
      'partOfSpeech': serializer.toJson<String>(partOfSpeech),
      'startOffset': serializer.toJson<int>(startOffset),
      'endOffset': serializer.toJson<int>(endOffset),
    };
  }

  Token copyWith({
    String? id,
    String? documentId,
    String? sentenceId,
    int? ordinal,
    String? surface,
    String? normalized,
    String? lemma,
    String? partOfSpeech,
    int? startOffset,
    int? endOffset,
  }) => Token(
    id: id ?? this.id,
    documentId: documentId ?? this.documentId,
    sentenceId: sentenceId ?? this.sentenceId,
    ordinal: ordinal ?? this.ordinal,
    surface: surface ?? this.surface,
    normalized: normalized ?? this.normalized,
    lemma: lemma ?? this.lemma,
    partOfSpeech: partOfSpeech ?? this.partOfSpeech,
    startOffset: startOffset ?? this.startOffset,
    endOffset: endOffset ?? this.endOffset,
  );
  Token copyWithCompanion(TokensCompanion data) {
    return Token(
      id: data.id.present ? data.id.value : this.id,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      sentenceId: data.sentenceId.present
          ? data.sentenceId.value
          : this.sentenceId,
      ordinal: data.ordinal.present ? data.ordinal.value : this.ordinal,
      surface: data.surface.present ? data.surface.value : this.surface,
      normalized: data.normalized.present
          ? data.normalized.value
          : this.normalized,
      lemma: data.lemma.present ? data.lemma.value : this.lemma,
      partOfSpeech: data.partOfSpeech.present
          ? data.partOfSpeech.value
          : this.partOfSpeech,
      startOffset: data.startOffset.present
          ? data.startOffset.value
          : this.startOffset,
      endOffset: data.endOffset.present ? data.endOffset.value : this.endOffset,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Token(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('sentenceId: $sentenceId, ')
          ..write('ordinal: $ordinal, ')
          ..write('surface: $surface, ')
          ..write('normalized: $normalized, ')
          ..write('lemma: $lemma, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('startOffset: $startOffset, ')
          ..write('endOffset: $endOffset')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    documentId,
    sentenceId,
    ordinal,
    surface,
    normalized,
    lemma,
    partOfSpeech,
    startOffset,
    endOffset,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Token &&
          other.id == this.id &&
          other.documentId == this.documentId &&
          other.sentenceId == this.sentenceId &&
          other.ordinal == this.ordinal &&
          other.surface == this.surface &&
          other.normalized == this.normalized &&
          other.lemma == this.lemma &&
          other.partOfSpeech == this.partOfSpeech &&
          other.startOffset == this.startOffset &&
          other.endOffset == this.endOffset);
}

class TokensCompanion extends UpdateCompanion<Token> {
  final Value<String> id;
  final Value<String> documentId;
  final Value<String> sentenceId;
  final Value<int> ordinal;
  final Value<String> surface;
  final Value<String> normalized;
  final Value<String> lemma;
  final Value<String> partOfSpeech;
  final Value<int> startOffset;
  final Value<int> endOffset;
  final Value<int> rowid;
  const TokensCompanion({
    this.id = const Value.absent(),
    this.documentId = const Value.absent(),
    this.sentenceId = const Value.absent(),
    this.ordinal = const Value.absent(),
    this.surface = const Value.absent(),
    this.normalized = const Value.absent(),
    this.lemma = const Value.absent(),
    this.partOfSpeech = const Value.absent(),
    this.startOffset = const Value.absent(),
    this.endOffset = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TokensCompanion.insert({
    required String id,
    required String documentId,
    required String sentenceId,
    required int ordinal,
    required String surface,
    required String normalized,
    required String lemma,
    this.partOfSpeech = const Value.absent(),
    required int startOffset,
    required int endOffset,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       documentId = Value(documentId),
       sentenceId = Value(sentenceId),
       ordinal = Value(ordinal),
       surface = Value(surface),
       normalized = Value(normalized),
       lemma = Value(lemma),
       startOffset = Value(startOffset),
       endOffset = Value(endOffset);
  static Insertable<Token> custom({
    Expression<String>? id,
    Expression<String>? documentId,
    Expression<String>? sentenceId,
    Expression<int>? ordinal,
    Expression<String>? surface,
    Expression<String>? normalized,
    Expression<String>? lemma,
    Expression<String>? partOfSpeech,
    Expression<int>? startOffset,
    Expression<int>? endOffset,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentId != null) 'document_id': documentId,
      if (sentenceId != null) 'sentence_id': sentenceId,
      if (ordinal != null) 'ordinal': ordinal,
      if (surface != null) 'surface': surface,
      if (normalized != null) 'normalized': normalized,
      if (lemma != null) 'lemma': lemma,
      if (partOfSpeech != null) 'part_of_speech': partOfSpeech,
      if (startOffset != null) 'start_offset': startOffset,
      if (endOffset != null) 'end_offset': endOffset,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TokensCompanion copyWith({
    Value<String>? id,
    Value<String>? documentId,
    Value<String>? sentenceId,
    Value<int>? ordinal,
    Value<String>? surface,
    Value<String>? normalized,
    Value<String>? lemma,
    Value<String>? partOfSpeech,
    Value<int>? startOffset,
    Value<int>? endOffset,
    Value<int>? rowid,
  }) {
    return TokensCompanion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      sentenceId: sentenceId ?? this.sentenceId,
      ordinal: ordinal ?? this.ordinal,
      surface: surface ?? this.surface,
      normalized: normalized ?? this.normalized,
      lemma: lemma ?? this.lemma,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      startOffset: startOffset ?? this.startOffset,
      endOffset: endOffset ?? this.endOffset,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (sentenceId.present) {
      map['sentence_id'] = Variable<String>(sentenceId.value);
    }
    if (ordinal.present) {
      map['ordinal'] = Variable<int>(ordinal.value);
    }
    if (surface.present) {
      map['surface'] = Variable<String>(surface.value);
    }
    if (normalized.present) {
      map['normalized'] = Variable<String>(normalized.value);
    }
    if (lemma.present) {
      map['lemma'] = Variable<String>(lemma.value);
    }
    if (partOfSpeech.present) {
      map['part_of_speech'] = Variable<String>(partOfSpeech.value);
    }
    if (startOffset.present) {
      map['start_offset'] = Variable<int>(startOffset.value);
    }
    if (endOffset.present) {
      map['end_offset'] = Variable<int>(endOffset.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TokensCompanion(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('sentenceId: $sentenceId, ')
          ..write('ordinal: $ordinal, ')
          ..write('surface: $surface, ')
          ..write('normalized: $normalized, ')
          ..write('lemma: $lemma, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('startOffset: $startOffset, ')
          ..write('endOffset: $endOffset, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhraseOccurrencesTable extends PhraseOccurrences
    with TableInfo<$PhraseOccurrencesTable, PhraseOccurrence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhraseOccurrencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES documents (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sentenceIdMeta = const VerificationMeta(
    'sentenceId',
  );
  @override
  late final GeneratedColumn<String> sentenceId = GeneratedColumn<String>(
    'sentence_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sentences (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _phraseKeyMeta = const VerificationMeta(
    'phraseKey',
  );
  @override
  late final GeneratedColumn<String> phraseKey = GeneratedColumn<String>(
    'phrase_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _surfaceMeta = const VerificationMeta(
    'surface',
  );
  @override
  late final GeneratedColumn<String> surface = GeneratedColumn<String>(
    'surface',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meaningMeta = const VerificationMeta(
    'meaning',
  );
  @override
  late final GeneratedColumn<String> meaning = GeneratedColumn<String>(
    'meaning',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTokenOrdinalMeta = const VerificationMeta(
    'startTokenOrdinal',
  );
  @override
  late final GeneratedColumn<int> startTokenOrdinal = GeneratedColumn<int>(
    'start_token_ordinal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTokenOrdinalMeta = const VerificationMeta(
    'endTokenOrdinal',
  );
  @override
  late final GeneratedColumn<int> endTokenOrdinal = GeneratedColumn<int>(
    'end_token_ordinal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    documentId,
    sentenceId,
    phraseKey,
    surface,
    type,
    meaning,
    confidence,
    startTokenOrdinal,
    endTokenOrdinal,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'phrase_occurrences';
  @override
  VerificationContext validateIntegrity(
    Insertable<PhraseOccurrence> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('sentence_id')) {
      context.handle(
        _sentenceIdMeta,
        sentenceId.isAcceptableOrUnknown(data['sentence_id']!, _sentenceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sentenceIdMeta);
    }
    if (data.containsKey('phrase_key')) {
      context.handle(
        _phraseKeyMeta,
        phraseKey.isAcceptableOrUnknown(data['phrase_key']!, _phraseKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_phraseKeyMeta);
    }
    if (data.containsKey('surface')) {
      context.handle(
        _surfaceMeta,
        surface.isAcceptableOrUnknown(data['surface']!, _surfaceMeta),
      );
    } else if (isInserting) {
      context.missing(_surfaceMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('meaning')) {
      context.handle(
        _meaningMeta,
        meaning.isAcceptableOrUnknown(data['meaning']!, _meaningMeta),
      );
    } else if (isInserting) {
      context.missing(_meaningMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('start_token_ordinal')) {
      context.handle(
        _startTokenOrdinalMeta,
        startTokenOrdinal.isAcceptableOrUnknown(
          data['start_token_ordinal']!,
          _startTokenOrdinalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startTokenOrdinalMeta);
    }
    if (data.containsKey('end_token_ordinal')) {
      context.handle(
        _endTokenOrdinalMeta,
        endTokenOrdinal.isAcceptableOrUnknown(
          data['end_token_ordinal']!,
          _endTokenOrdinalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_endTokenOrdinalMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PhraseOccurrence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhraseOccurrence(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      sentenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sentence_id'],
      )!,
      phraseKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phrase_key'],
      )!,
      surface: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}surface'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      meaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      startTokenOrdinal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_token_ordinal'],
      )!,
      endTokenOrdinal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_token_ordinal'],
      )!,
    );
  }

  @override
  $PhraseOccurrencesTable createAlias(String alias) {
    return $PhraseOccurrencesTable(attachedDatabase, alias);
  }
}

class PhraseOccurrence extends DataClass
    implements Insertable<PhraseOccurrence> {
  final String id;
  final String documentId;
  final String sentenceId;
  final String phraseKey;
  final String surface;
  final String type;
  final String meaning;
  final double confidence;
  final int startTokenOrdinal;
  final int endTokenOrdinal;
  const PhraseOccurrence({
    required this.id,
    required this.documentId,
    required this.sentenceId,
    required this.phraseKey,
    required this.surface,
    required this.type,
    required this.meaning,
    required this.confidence,
    required this.startTokenOrdinal,
    required this.endTokenOrdinal,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['document_id'] = Variable<String>(documentId);
    map['sentence_id'] = Variable<String>(sentenceId);
    map['phrase_key'] = Variable<String>(phraseKey);
    map['surface'] = Variable<String>(surface);
    map['type'] = Variable<String>(type);
    map['meaning'] = Variable<String>(meaning);
    map['confidence'] = Variable<double>(confidence);
    map['start_token_ordinal'] = Variable<int>(startTokenOrdinal);
    map['end_token_ordinal'] = Variable<int>(endTokenOrdinal);
    return map;
  }

  PhraseOccurrencesCompanion toCompanion(bool nullToAbsent) {
    return PhraseOccurrencesCompanion(
      id: Value(id),
      documentId: Value(documentId),
      sentenceId: Value(sentenceId),
      phraseKey: Value(phraseKey),
      surface: Value(surface),
      type: Value(type),
      meaning: Value(meaning),
      confidence: Value(confidence),
      startTokenOrdinal: Value(startTokenOrdinal),
      endTokenOrdinal: Value(endTokenOrdinal),
    );
  }

  factory PhraseOccurrence.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhraseOccurrence(
      id: serializer.fromJson<String>(json['id']),
      documentId: serializer.fromJson<String>(json['documentId']),
      sentenceId: serializer.fromJson<String>(json['sentenceId']),
      phraseKey: serializer.fromJson<String>(json['phraseKey']),
      surface: serializer.fromJson<String>(json['surface']),
      type: serializer.fromJson<String>(json['type']),
      meaning: serializer.fromJson<String>(json['meaning']),
      confidence: serializer.fromJson<double>(json['confidence']),
      startTokenOrdinal: serializer.fromJson<int>(json['startTokenOrdinal']),
      endTokenOrdinal: serializer.fromJson<int>(json['endTokenOrdinal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'documentId': serializer.toJson<String>(documentId),
      'sentenceId': serializer.toJson<String>(sentenceId),
      'phraseKey': serializer.toJson<String>(phraseKey),
      'surface': serializer.toJson<String>(surface),
      'type': serializer.toJson<String>(type),
      'meaning': serializer.toJson<String>(meaning),
      'confidence': serializer.toJson<double>(confidence),
      'startTokenOrdinal': serializer.toJson<int>(startTokenOrdinal),
      'endTokenOrdinal': serializer.toJson<int>(endTokenOrdinal),
    };
  }

  PhraseOccurrence copyWith({
    String? id,
    String? documentId,
    String? sentenceId,
    String? phraseKey,
    String? surface,
    String? type,
    String? meaning,
    double? confidence,
    int? startTokenOrdinal,
    int? endTokenOrdinal,
  }) => PhraseOccurrence(
    id: id ?? this.id,
    documentId: documentId ?? this.documentId,
    sentenceId: sentenceId ?? this.sentenceId,
    phraseKey: phraseKey ?? this.phraseKey,
    surface: surface ?? this.surface,
    type: type ?? this.type,
    meaning: meaning ?? this.meaning,
    confidence: confidence ?? this.confidence,
    startTokenOrdinal: startTokenOrdinal ?? this.startTokenOrdinal,
    endTokenOrdinal: endTokenOrdinal ?? this.endTokenOrdinal,
  );
  PhraseOccurrence copyWithCompanion(PhraseOccurrencesCompanion data) {
    return PhraseOccurrence(
      id: data.id.present ? data.id.value : this.id,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      sentenceId: data.sentenceId.present
          ? data.sentenceId.value
          : this.sentenceId,
      phraseKey: data.phraseKey.present ? data.phraseKey.value : this.phraseKey,
      surface: data.surface.present ? data.surface.value : this.surface,
      type: data.type.present ? data.type.value : this.type,
      meaning: data.meaning.present ? data.meaning.value : this.meaning,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      startTokenOrdinal: data.startTokenOrdinal.present
          ? data.startTokenOrdinal.value
          : this.startTokenOrdinal,
      endTokenOrdinal: data.endTokenOrdinal.present
          ? data.endTokenOrdinal.value
          : this.endTokenOrdinal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhraseOccurrence(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('sentenceId: $sentenceId, ')
          ..write('phraseKey: $phraseKey, ')
          ..write('surface: $surface, ')
          ..write('type: $type, ')
          ..write('meaning: $meaning, ')
          ..write('confidence: $confidence, ')
          ..write('startTokenOrdinal: $startTokenOrdinal, ')
          ..write('endTokenOrdinal: $endTokenOrdinal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    documentId,
    sentenceId,
    phraseKey,
    surface,
    type,
    meaning,
    confidence,
    startTokenOrdinal,
    endTokenOrdinal,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhraseOccurrence &&
          other.id == this.id &&
          other.documentId == this.documentId &&
          other.sentenceId == this.sentenceId &&
          other.phraseKey == this.phraseKey &&
          other.surface == this.surface &&
          other.type == this.type &&
          other.meaning == this.meaning &&
          other.confidence == this.confidence &&
          other.startTokenOrdinal == this.startTokenOrdinal &&
          other.endTokenOrdinal == this.endTokenOrdinal);
}

class PhraseOccurrencesCompanion extends UpdateCompanion<PhraseOccurrence> {
  final Value<String> id;
  final Value<String> documentId;
  final Value<String> sentenceId;
  final Value<String> phraseKey;
  final Value<String> surface;
  final Value<String> type;
  final Value<String> meaning;
  final Value<double> confidence;
  final Value<int> startTokenOrdinal;
  final Value<int> endTokenOrdinal;
  final Value<int> rowid;
  const PhraseOccurrencesCompanion({
    this.id = const Value.absent(),
    this.documentId = const Value.absent(),
    this.sentenceId = const Value.absent(),
    this.phraseKey = const Value.absent(),
    this.surface = const Value.absent(),
    this.type = const Value.absent(),
    this.meaning = const Value.absent(),
    this.confidence = const Value.absent(),
    this.startTokenOrdinal = const Value.absent(),
    this.endTokenOrdinal = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhraseOccurrencesCompanion.insert({
    required String id,
    required String documentId,
    required String sentenceId,
    required String phraseKey,
    required String surface,
    required String type,
    required String meaning,
    required double confidence,
    required int startTokenOrdinal,
    required int endTokenOrdinal,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       documentId = Value(documentId),
       sentenceId = Value(sentenceId),
       phraseKey = Value(phraseKey),
       surface = Value(surface),
       type = Value(type),
       meaning = Value(meaning),
       confidence = Value(confidence),
       startTokenOrdinal = Value(startTokenOrdinal),
       endTokenOrdinal = Value(endTokenOrdinal);
  static Insertable<PhraseOccurrence> custom({
    Expression<String>? id,
    Expression<String>? documentId,
    Expression<String>? sentenceId,
    Expression<String>? phraseKey,
    Expression<String>? surface,
    Expression<String>? type,
    Expression<String>? meaning,
    Expression<double>? confidence,
    Expression<int>? startTokenOrdinal,
    Expression<int>? endTokenOrdinal,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentId != null) 'document_id': documentId,
      if (sentenceId != null) 'sentence_id': sentenceId,
      if (phraseKey != null) 'phrase_key': phraseKey,
      if (surface != null) 'surface': surface,
      if (type != null) 'type': type,
      if (meaning != null) 'meaning': meaning,
      if (confidence != null) 'confidence': confidence,
      if (startTokenOrdinal != null) 'start_token_ordinal': startTokenOrdinal,
      if (endTokenOrdinal != null) 'end_token_ordinal': endTokenOrdinal,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhraseOccurrencesCompanion copyWith({
    Value<String>? id,
    Value<String>? documentId,
    Value<String>? sentenceId,
    Value<String>? phraseKey,
    Value<String>? surface,
    Value<String>? type,
    Value<String>? meaning,
    Value<double>? confidence,
    Value<int>? startTokenOrdinal,
    Value<int>? endTokenOrdinal,
    Value<int>? rowid,
  }) {
    return PhraseOccurrencesCompanion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      sentenceId: sentenceId ?? this.sentenceId,
      phraseKey: phraseKey ?? this.phraseKey,
      surface: surface ?? this.surface,
      type: type ?? this.type,
      meaning: meaning ?? this.meaning,
      confidence: confidence ?? this.confidence,
      startTokenOrdinal: startTokenOrdinal ?? this.startTokenOrdinal,
      endTokenOrdinal: endTokenOrdinal ?? this.endTokenOrdinal,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (sentenceId.present) {
      map['sentence_id'] = Variable<String>(sentenceId.value);
    }
    if (phraseKey.present) {
      map['phrase_key'] = Variable<String>(phraseKey.value);
    }
    if (surface.present) {
      map['surface'] = Variable<String>(surface.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (meaning.present) {
      map['meaning'] = Variable<String>(meaning.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (startTokenOrdinal.present) {
      map['start_token_ordinal'] = Variable<int>(startTokenOrdinal.value);
    }
    if (endTokenOrdinal.present) {
      map['end_token_ordinal'] = Variable<int>(endTokenOrdinal.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhraseOccurrencesCompanion(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('sentenceId: $sentenceId, ')
          ..write('phraseKey: $phraseKey, ')
          ..write('surface: $surface, ')
          ..write('type: $type, ')
          ..write('meaning: $meaning, ')
          ..write('confidence: $confidence, ')
          ..write('startTokenOrdinal: $startTokenOrdinal, ')
          ..write('endTokenOrdinal: $endTokenOrdinal, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

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
  static const VerificationMeta _sourceDocumentIdMeta = const VerificationMeta(
    'sourceDocumentId',
  );
  @override
  late final GeneratedColumn<String> sourceDocumentId = GeneratedColumn<String>(
    'source_document_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceDocumentTitleMeta =
      const VerificationMeta('sourceDocumentTitle');
  @override
  late final GeneratedColumn<String> sourceDocumentTitle =
      GeneratedColumn<String>(
        'source_document_title',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _contextSentenceMeta = const VerificationMeta(
    'contextSentence',
  );
  @override
  late final GeneratedColumn<String> contextSentence = GeneratedColumn<String>(
    'context_sentence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    sourceDocumentId,
    sourceDocumentTitle,
    contextSentence,
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
    if (data.containsKey('source_document_id')) {
      context.handle(
        _sourceDocumentIdMeta,
        sourceDocumentId.isAcceptableOrUnknown(
          data['source_document_id']!,
          _sourceDocumentIdMeta,
        ),
      );
    }
    if (data.containsKey('source_document_title')) {
      context.handle(
        _sourceDocumentTitleMeta,
        sourceDocumentTitle.isAcceptableOrUnknown(
          data['source_document_title']!,
          _sourceDocumentTitleMeta,
        ),
      );
    }
    if (data.containsKey('context_sentence')) {
      context.handle(
        _contextSentenceMeta,
        contextSentence.isAcceptableOrUnknown(
          data['context_sentence']!,
          _contextSentenceMeta,
        ),
      );
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
      sourceDocumentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_document_id'],
      ),
      sourceDocumentTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_document_title'],
      )!,
      contextSentence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_sentence'],
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
  final String? sourceDocumentId;
  final String sourceDocumentTitle;
  final String contextSentence;
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
    this.sourceDocumentId,
    required this.sourceDocumentTitle,
    required this.contextSentence,
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
    if (!nullToAbsent || sourceDocumentId != null) {
      map['source_document_id'] = Variable<String>(sourceDocumentId);
    }
    map['source_document_title'] = Variable<String>(sourceDocumentTitle);
    map['context_sentence'] = Variable<String>(contextSentence);
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
      sourceDocumentId: sourceDocumentId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceDocumentId),
      sourceDocumentTitle: Value(sourceDocumentTitle),
      contextSentence: Value(contextSentence),
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
      sourceDocumentId: serializer.fromJson<String?>(json['sourceDocumentId']),
      sourceDocumentTitle: serializer.fromJson<String>(
        json['sourceDocumentTitle'],
      ),
      contextSentence: serializer.fromJson<String>(json['contextSentence']),
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
      'sourceDocumentId': serializer.toJson<String?>(sourceDocumentId),
      'sourceDocumentTitle': serializer.toJson<String>(sourceDocumentTitle),
      'contextSentence': serializer.toJson<String>(contextSentence),
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
    Value<String?> sourceDocumentId = const Value.absent(),
    String? sourceDocumentTitle,
    String? contextSentence,
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
    sourceDocumentId: sourceDocumentId.present
        ? sourceDocumentId.value
        : this.sourceDocumentId,
    sourceDocumentTitle: sourceDocumentTitle ?? this.sourceDocumentTitle,
    contextSentence: contextSentence ?? this.contextSentence,
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
      sourceDocumentId: data.sourceDocumentId.present
          ? data.sourceDocumentId.value
          : this.sourceDocumentId,
      sourceDocumentTitle: data.sourceDocumentTitle.present
          ? data.sourceDocumentTitle.value
          : this.sourceDocumentTitle,
      contextSentence: data.contextSentence.present
          ? data.contextSentence.value
          : this.contextSentence,
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
          ..write('lastLookupAt: $lastLookupAt, ')
          ..write('sourceDocumentId: $sourceDocumentId, ')
          ..write('sourceDocumentTitle: $sourceDocumentTitle, ')
          ..write('contextSentence: $contextSentence')
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
    sourceDocumentId,
    sourceDocumentTitle,
    contextSentence,
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
          other.lastLookupAt == this.lastLookupAt &&
          other.sourceDocumentId == this.sourceDocumentId &&
          other.sourceDocumentTitle == this.sourceDocumentTitle &&
          other.contextSentence == this.contextSentence);
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
  final Value<String?> sourceDocumentId;
  final Value<String> sourceDocumentTitle;
  final Value<String> contextSentence;
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
    this.sourceDocumentId = const Value.absent(),
    this.sourceDocumentTitle = const Value.absent(),
    this.contextSentence = const Value.absent(),
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
    this.sourceDocumentId = const Value.absent(),
    this.sourceDocumentTitle = const Value.absent(),
    this.contextSentence = const Value.absent(),
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
    Expression<String>? sourceDocumentId,
    Expression<String>? sourceDocumentTitle,
    Expression<String>? contextSentence,
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
      if (sourceDocumentId != null) 'source_document_id': sourceDocumentId,
      if (sourceDocumentTitle != null)
        'source_document_title': sourceDocumentTitle,
      if (contextSentence != null) 'context_sentence': contextSentence,
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
    Value<String?>? sourceDocumentId,
    Value<String>? sourceDocumentTitle,
    Value<String>? contextSentence,
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
      sourceDocumentId: sourceDocumentId ?? this.sourceDocumentId,
      sourceDocumentTitle: sourceDocumentTitle ?? this.sourceDocumentTitle,
      contextSentence: contextSentence ?? this.contextSentence,
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
    if (sourceDocumentId.present) {
      map['source_document_id'] = Variable<String>(sourceDocumentId.value);
    }
    if (sourceDocumentTitle.present) {
      map['source_document_title'] = Variable<String>(
        sourceDocumentTitle.value,
      );
    }
    if (contextSentence.present) {
      map['context_sentence'] = Variable<String>(contextSentence.value);
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
          ..write('sourceDocumentId: $sourceDocumentId, ')
          ..write('sourceDocumentTitle: $sourceDocumentTitle, ')
          ..write('contextSentence: $contextSentence, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavedPhrasesTable extends SavedPhrases
    with TableInfo<$SavedPhrasesTable, SavedPhrase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedPhrasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phraseKeyMeta = const VerificationMeta(
    'phraseKey',
  );
  @override
  late final GeneratedColumn<String> phraseKey = GeneratedColumn<String>(
    'phrase_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _surfaceMeta = const VerificationMeta(
    'surface',
  );
  @override
  late final GeneratedColumn<String> surface = GeneratedColumn<String>(
    'surface',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meaningMeta = const VerificationMeta(
    'meaning',
  );
  @override
  late final GeneratedColumn<String> meaning = GeneratedColumn<String>(
    'meaning',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextSentenceMeta = const VerificationMeta(
    'contextSentence',
  );
  @override
  late final GeneratedColumn<String> contextSentence = GeneratedColumn<String>(
    'context_sentence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceDocumentIdMeta = const VerificationMeta(
    'sourceDocumentId',
  );
  @override
  late final GeneratedColumn<String> sourceDocumentId = GeneratedColumn<String>(
    'source_document_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceDocumentTitleMeta =
      const VerificationMeta('sourceDocumentTitle');
  @override
  late final GeneratedColumn<String> sourceDocumentTitle =
      GeneratedColumn<String>(
        'source_document_title',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    phraseKey,
    surface,
    type,
    meaning,
    contextSentence,
    sourceDocumentId,
    sourceDocumentTitle,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_phrases';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedPhrase> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('phrase_key')) {
      context.handle(
        _phraseKeyMeta,
        phraseKey.isAcceptableOrUnknown(data['phrase_key']!, _phraseKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_phraseKeyMeta);
    }
    if (data.containsKey('surface')) {
      context.handle(
        _surfaceMeta,
        surface.isAcceptableOrUnknown(data['surface']!, _surfaceMeta),
      );
    } else if (isInserting) {
      context.missing(_surfaceMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('meaning')) {
      context.handle(
        _meaningMeta,
        meaning.isAcceptableOrUnknown(data['meaning']!, _meaningMeta),
      );
    } else if (isInserting) {
      context.missing(_meaningMeta);
    }
    if (data.containsKey('context_sentence')) {
      context.handle(
        _contextSentenceMeta,
        contextSentence.isAcceptableOrUnknown(
          data['context_sentence']!,
          _contextSentenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contextSentenceMeta);
    }
    if (data.containsKey('source_document_id')) {
      context.handle(
        _sourceDocumentIdMeta,
        sourceDocumentId.isAcceptableOrUnknown(
          data['source_document_id']!,
          _sourceDocumentIdMeta,
        ),
      );
    }
    if (data.containsKey('source_document_title')) {
      context.handle(
        _sourceDocumentTitleMeta,
        sourceDocumentTitle.isAcceptableOrUnknown(
          data['source_document_title']!,
          _sourceDocumentTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceDocumentTitleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedPhrase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedPhrase(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      phraseKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phrase_key'],
      )!,
      surface: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}surface'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      meaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning'],
      )!,
      contextSentence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_sentence'],
      )!,
      sourceDocumentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_document_id'],
      ),
      sourceDocumentTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_document_title'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SavedPhrasesTable createAlias(String alias) {
    return $SavedPhrasesTable(attachedDatabase, alias);
  }
}

class SavedPhrase extends DataClass implements Insertable<SavedPhrase> {
  final String id;
  final String phraseKey;
  final String surface;
  final String type;
  final String meaning;
  final String contextSentence;
  final String? sourceDocumentId;
  final String sourceDocumentTitle;
  final DateTime createdAt;
  const SavedPhrase({
    required this.id,
    required this.phraseKey,
    required this.surface,
    required this.type,
    required this.meaning,
    required this.contextSentence,
    this.sourceDocumentId,
    required this.sourceDocumentTitle,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['phrase_key'] = Variable<String>(phraseKey);
    map['surface'] = Variable<String>(surface);
    map['type'] = Variable<String>(type);
    map['meaning'] = Variable<String>(meaning);
    map['context_sentence'] = Variable<String>(contextSentence);
    if (!nullToAbsent || sourceDocumentId != null) {
      map['source_document_id'] = Variable<String>(sourceDocumentId);
    }
    map['source_document_title'] = Variable<String>(sourceDocumentTitle);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SavedPhrasesCompanion toCompanion(bool nullToAbsent) {
    return SavedPhrasesCompanion(
      id: Value(id),
      phraseKey: Value(phraseKey),
      surface: Value(surface),
      type: Value(type),
      meaning: Value(meaning),
      contextSentence: Value(contextSentence),
      sourceDocumentId: sourceDocumentId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceDocumentId),
      sourceDocumentTitle: Value(sourceDocumentTitle),
      createdAt: Value(createdAt),
    );
  }

  factory SavedPhrase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedPhrase(
      id: serializer.fromJson<String>(json['id']),
      phraseKey: serializer.fromJson<String>(json['phraseKey']),
      surface: serializer.fromJson<String>(json['surface']),
      type: serializer.fromJson<String>(json['type']),
      meaning: serializer.fromJson<String>(json['meaning']),
      contextSentence: serializer.fromJson<String>(json['contextSentence']),
      sourceDocumentId: serializer.fromJson<String?>(json['sourceDocumentId']),
      sourceDocumentTitle: serializer.fromJson<String>(
        json['sourceDocumentTitle'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'phraseKey': serializer.toJson<String>(phraseKey),
      'surface': serializer.toJson<String>(surface),
      'type': serializer.toJson<String>(type),
      'meaning': serializer.toJson<String>(meaning),
      'contextSentence': serializer.toJson<String>(contextSentence),
      'sourceDocumentId': serializer.toJson<String?>(sourceDocumentId),
      'sourceDocumentTitle': serializer.toJson<String>(sourceDocumentTitle),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SavedPhrase copyWith({
    String? id,
    String? phraseKey,
    String? surface,
    String? type,
    String? meaning,
    String? contextSentence,
    Value<String?> sourceDocumentId = const Value.absent(),
    String? sourceDocumentTitle,
    DateTime? createdAt,
  }) => SavedPhrase(
    id: id ?? this.id,
    phraseKey: phraseKey ?? this.phraseKey,
    surface: surface ?? this.surface,
    type: type ?? this.type,
    meaning: meaning ?? this.meaning,
    contextSentence: contextSentence ?? this.contextSentence,
    sourceDocumentId: sourceDocumentId.present
        ? sourceDocumentId.value
        : this.sourceDocumentId,
    sourceDocumentTitle: sourceDocumentTitle ?? this.sourceDocumentTitle,
    createdAt: createdAt ?? this.createdAt,
  );
  SavedPhrase copyWithCompanion(SavedPhrasesCompanion data) {
    return SavedPhrase(
      id: data.id.present ? data.id.value : this.id,
      phraseKey: data.phraseKey.present ? data.phraseKey.value : this.phraseKey,
      surface: data.surface.present ? data.surface.value : this.surface,
      type: data.type.present ? data.type.value : this.type,
      meaning: data.meaning.present ? data.meaning.value : this.meaning,
      contextSentence: data.contextSentence.present
          ? data.contextSentence.value
          : this.contextSentence,
      sourceDocumentId: data.sourceDocumentId.present
          ? data.sourceDocumentId.value
          : this.sourceDocumentId,
      sourceDocumentTitle: data.sourceDocumentTitle.present
          ? data.sourceDocumentTitle.value
          : this.sourceDocumentTitle,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedPhrase(')
          ..write('id: $id, ')
          ..write('phraseKey: $phraseKey, ')
          ..write('surface: $surface, ')
          ..write('type: $type, ')
          ..write('meaning: $meaning, ')
          ..write('contextSentence: $contextSentence, ')
          ..write('sourceDocumentId: $sourceDocumentId, ')
          ..write('sourceDocumentTitle: $sourceDocumentTitle, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    phraseKey,
    surface,
    type,
    meaning,
    contextSentence,
    sourceDocumentId,
    sourceDocumentTitle,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedPhrase &&
          other.id == this.id &&
          other.phraseKey == this.phraseKey &&
          other.surface == this.surface &&
          other.type == this.type &&
          other.meaning == this.meaning &&
          other.contextSentence == this.contextSentence &&
          other.sourceDocumentId == this.sourceDocumentId &&
          other.sourceDocumentTitle == this.sourceDocumentTitle &&
          other.createdAt == this.createdAt);
}

class SavedPhrasesCompanion extends UpdateCompanion<SavedPhrase> {
  final Value<String> id;
  final Value<String> phraseKey;
  final Value<String> surface;
  final Value<String> type;
  final Value<String> meaning;
  final Value<String> contextSentence;
  final Value<String?> sourceDocumentId;
  final Value<String> sourceDocumentTitle;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SavedPhrasesCompanion({
    this.id = const Value.absent(),
    this.phraseKey = const Value.absent(),
    this.surface = const Value.absent(),
    this.type = const Value.absent(),
    this.meaning = const Value.absent(),
    this.contextSentence = const Value.absent(),
    this.sourceDocumentId = const Value.absent(),
    this.sourceDocumentTitle = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedPhrasesCompanion.insert({
    required String id,
    required String phraseKey,
    required String surface,
    required String type,
    required String meaning,
    required String contextSentence,
    this.sourceDocumentId = const Value.absent(),
    required String sourceDocumentTitle,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       phraseKey = Value(phraseKey),
       surface = Value(surface),
       type = Value(type),
       meaning = Value(meaning),
       contextSentence = Value(contextSentence),
       sourceDocumentTitle = Value(sourceDocumentTitle),
       createdAt = Value(createdAt);
  static Insertable<SavedPhrase> custom({
    Expression<String>? id,
    Expression<String>? phraseKey,
    Expression<String>? surface,
    Expression<String>? type,
    Expression<String>? meaning,
    Expression<String>? contextSentence,
    Expression<String>? sourceDocumentId,
    Expression<String>? sourceDocumentTitle,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (phraseKey != null) 'phrase_key': phraseKey,
      if (surface != null) 'surface': surface,
      if (type != null) 'type': type,
      if (meaning != null) 'meaning': meaning,
      if (contextSentence != null) 'context_sentence': contextSentence,
      if (sourceDocumentId != null) 'source_document_id': sourceDocumentId,
      if (sourceDocumentTitle != null)
        'source_document_title': sourceDocumentTitle,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedPhrasesCompanion copyWith({
    Value<String>? id,
    Value<String>? phraseKey,
    Value<String>? surface,
    Value<String>? type,
    Value<String>? meaning,
    Value<String>? contextSentence,
    Value<String?>? sourceDocumentId,
    Value<String>? sourceDocumentTitle,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SavedPhrasesCompanion(
      id: id ?? this.id,
      phraseKey: phraseKey ?? this.phraseKey,
      surface: surface ?? this.surface,
      type: type ?? this.type,
      meaning: meaning ?? this.meaning,
      contextSentence: contextSentence ?? this.contextSentence,
      sourceDocumentId: sourceDocumentId ?? this.sourceDocumentId,
      sourceDocumentTitle: sourceDocumentTitle ?? this.sourceDocumentTitle,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (phraseKey.present) {
      map['phrase_key'] = Variable<String>(phraseKey.value);
    }
    if (surface.present) {
      map['surface'] = Variable<String>(surface.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (meaning.present) {
      map['meaning'] = Variable<String>(meaning.value);
    }
    if (contextSentence.present) {
      map['context_sentence'] = Variable<String>(contextSentence.value);
    }
    if (sourceDocumentId.present) {
      map['source_document_id'] = Variable<String>(sourceDocumentId.value);
    }
    if (sourceDocumentTitle.present) {
      map['source_document_title'] = Variable<String>(
        sourceDocumentTitle.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedPhrasesCompanion(')
          ..write('id: $id, ')
          ..write('phraseKey: $phraseKey, ')
          ..write('surface: $surface, ')
          ..write('type: $type, ')
          ..write('meaning: $meaning, ')
          ..write('contextSentence: $contextSentence, ')
          ..write('sourceDocumentId: $sourceDocumentId, ')
          ..write('sourceDocumentTitle: $sourceDocumentTitle, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DocumentsTable documents = $DocumentsTable(this);
  late final $ParagraphsTable paragraphs = $ParagraphsTable(this);
  late final $SentencesTable sentences = $SentencesTable(this);
  late final $TokensTable tokens = $TokensTable(this);
  late final $PhraseOccurrencesTable phraseOccurrences =
      $PhraseOccurrencesTable(this);
  late final $VocabularyEntriesTable vocabularyEntries =
      $VocabularyEntriesTable(this);
  late final $SavedPhrasesTable savedPhrases = $SavedPhrasesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final DocumentsDao documentsDao = DocumentsDao(this as AppDatabase);
  late final LearningDao learningDao = LearningDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    documents,
    paragraphs,
    sentences,
    tokens,
    phraseOccurrences,
    vocabularyEntries,
    savedPhrases,
    appSettings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'documents',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('paragraphs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'documents',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sentences', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'paragraphs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sentences', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'documents',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tokens', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sentences',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tokens', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'documents',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('phrase_occurrences', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sentences',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('phrase_occurrences', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$DocumentsTableCreateCompanionBuilder =
    DocumentsCompanion Function({
      required String id,
      required String title,
      required String format,
      required String sourceName,
      required String localPath,
      required String contentHash,
      required int fileSize,
      Value<int?> pageCount,
      Value<int> wordCount,
      Value<int> paragraphCount,
      required String parseStatus,
      Value<double> parseProgress,
      Value<String?> failureCode,
      Value<String?> failureMessage,
      Value<String?> lastReadLocator,
      Value<double> readProgress,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> lastOpenedAt,
      Value<int> rowid,
    });
typedef $$DocumentsTableUpdateCompanionBuilder =
    DocumentsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> format,
      Value<String> sourceName,
      Value<String> localPath,
      Value<String> contentHash,
      Value<int> fileSize,
      Value<int?> pageCount,
      Value<int> wordCount,
      Value<int> paragraphCount,
      Value<String> parseStatus,
      Value<double> parseProgress,
      Value<String?> failureCode,
      Value<String?> failureMessage,
      Value<String?> lastReadLocator,
      Value<double> readProgress,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastOpenedAt,
      Value<int> rowid,
    });

final class $$DocumentsTableReferences
    extends BaseReferences<_$AppDatabase, $DocumentsTable, Document> {
  $$DocumentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ParagraphsTable, List<Paragraph>>
  _paragraphsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.paragraphs,
    aliasName: 'documents__id__paragraphs__document_id',
  );

  $$ParagraphsTableProcessedTableManager get paragraphsRefs {
    final manager = $$ParagraphsTableTableManager(
      $_db,
      $_db.paragraphs,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paragraphsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SentencesTable, List<Sentence>>
  _sentencesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sentences,
    aliasName: 'documents__id__sentences__document_id',
  );

  $$SentencesTableProcessedTableManager get sentencesRefs {
    final manager = $$SentencesTableTableManager(
      $_db,
      $_db.sentences,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sentencesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TokensTable, List<Token>> _tokensRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tokens,
    aliasName: 'documents__id__tokens__document_id',
  );

  $$TokensTableProcessedTableManager get tokensRefs {
    final manager = $$TokensTableTableManager(
      $_db,
      $_db.tokens,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tokensRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PhraseOccurrencesTable, List<PhraseOccurrence>>
  _phraseOccurrencesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.phraseOccurrences,
        aliasName: 'documents__id__phrase_occurrences__document_id',
      );

  $$PhraseOccurrencesTableProcessedTableManager get phraseOccurrencesRefs {
    final manager = $$PhraseOccurrencesTableTableManager(
      $_db,
      $_db.phraseOccurrences,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _phraseOccurrencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wordCount => $composableBuilder(
    column: $table.wordCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paragraphCount => $composableBuilder(
    column: $table.paragraphCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parseStatus => $composableBuilder(
    column: $table.parseStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get parseProgress => $composableBuilder(
    column: $table.parseProgress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get failureCode => $composableBuilder(
    column: $table.failureCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get failureMessage => $composableBuilder(
    column: $table.failureMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastReadLocator => $composableBuilder(
    column: $table.lastReadLocator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get readProgress => $composableBuilder(
    column: $table.readProgress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> paragraphsRefs(
    Expression<bool> Function($$ParagraphsTableFilterComposer f) f,
  ) {
    final $$ParagraphsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paragraphs,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParagraphsTableFilterComposer(
            $db: $db,
            $table: $db.paragraphs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sentencesRefs(
    Expression<bool> Function($$SentencesTableFilterComposer f) f,
  ) {
    final $$SentencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sentences,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SentencesTableFilterComposer(
            $db: $db,
            $table: $db.sentences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tokensRefs(
    Expression<bool> Function($$TokensTableFilterComposer f) f,
  ) {
    final $$TokensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tokens,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TokensTableFilterComposer(
            $db: $db,
            $table: $db.tokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> phraseOccurrencesRefs(
    Expression<bool> Function($$PhraseOccurrencesTableFilterComposer f) f,
  ) {
    final $$PhraseOccurrencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.phraseOccurrences,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhraseOccurrencesTableFilterComposer(
            $db: $db,
            $table: $db.phraseOccurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wordCount => $composableBuilder(
    column: $table.wordCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paragraphCount => $composableBuilder(
    column: $table.paragraphCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parseStatus => $composableBuilder(
    column: $table.parseStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get parseProgress => $composableBuilder(
    column: $table.parseProgress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get failureCode => $composableBuilder(
    column: $table.failureCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get failureMessage => $composableBuilder(
    column: $table.failureMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastReadLocator => $composableBuilder(
    column: $table.lastReadLocator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get readProgress => $composableBuilder(
    column: $table.readProgress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<int> get wordCount =>
      $composableBuilder(column: $table.wordCount, builder: (column) => column);

  GeneratedColumn<int> get paragraphCount => $composableBuilder(
    column: $table.paragraphCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parseStatus => $composableBuilder(
    column: $table.parseStatus,
    builder: (column) => column,
  );

  GeneratedColumn<double> get parseProgress => $composableBuilder(
    column: $table.parseProgress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get failureCode => $composableBuilder(
    column: $table.failureCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get failureMessage => $composableBuilder(
    column: $table.failureMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastReadLocator => $composableBuilder(
    column: $table.lastReadLocator,
    builder: (column) => column,
  );

  GeneratedColumn<double> get readProgress => $composableBuilder(
    column: $table.readProgress,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => column,
  );

  Expression<T> paragraphsRefs<T extends Object>(
    Expression<T> Function($$ParagraphsTableAnnotationComposer a) f,
  ) {
    final $$ParagraphsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paragraphs,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParagraphsTableAnnotationComposer(
            $db: $db,
            $table: $db.paragraphs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sentencesRefs<T extends Object>(
    Expression<T> Function($$SentencesTableAnnotationComposer a) f,
  ) {
    final $$SentencesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sentences,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SentencesTableAnnotationComposer(
            $db: $db,
            $table: $db.sentences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tokensRefs<T extends Object>(
    Expression<T> Function($$TokensTableAnnotationComposer a) f,
  ) {
    final $$TokensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tokens,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TokensTableAnnotationComposer(
            $db: $db,
            $table: $db.tokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> phraseOccurrencesRefs<T extends Object>(
    Expression<T> Function($$PhraseOccurrencesTableAnnotationComposer a) f,
  ) {
    final $$PhraseOccurrencesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.phraseOccurrences,
          getReferencedColumn: (t) => t.documentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PhraseOccurrencesTableAnnotationComposer(
                $db: $db,
                $table: $db.phraseOccurrences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$DocumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DocumentsTable,
          Document,
          $$DocumentsTableFilterComposer,
          $$DocumentsTableOrderingComposer,
          $$DocumentsTableAnnotationComposer,
          $$DocumentsTableCreateCompanionBuilder,
          $$DocumentsTableUpdateCompanionBuilder,
          (Document, $$DocumentsTableReferences),
          Document,
          PrefetchHooks Function({
            bool paragraphsRefs,
            bool sentencesRefs,
            bool tokensRefs,
            bool phraseOccurrencesRefs,
          })
        > {
  $$DocumentsTableTableManager(_$AppDatabase db, $DocumentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<String> sourceName = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<int> fileSize = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<int> wordCount = const Value.absent(),
                Value<int> paragraphCount = const Value.absent(),
                Value<String> parseStatus = const Value.absent(),
                Value<double> parseProgress = const Value.absent(),
                Value<String?> failureCode = const Value.absent(),
                Value<String?> failureMessage = const Value.absent(),
                Value<String?> lastReadLocator = const Value.absent(),
                Value<double> readProgress = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastOpenedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentsCompanion(
                id: id,
                title: title,
                format: format,
                sourceName: sourceName,
                localPath: localPath,
                contentHash: contentHash,
                fileSize: fileSize,
                pageCount: pageCount,
                wordCount: wordCount,
                paragraphCount: paragraphCount,
                parseStatus: parseStatus,
                parseProgress: parseProgress,
                failureCode: failureCode,
                failureMessage: failureMessage,
                lastReadLocator: lastReadLocator,
                readProgress: readProgress,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastOpenedAt: lastOpenedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String format,
                required String sourceName,
                required String localPath,
                required String contentHash,
                required int fileSize,
                Value<int?> pageCount = const Value.absent(),
                Value<int> wordCount = const Value.absent(),
                Value<int> paragraphCount = const Value.absent(),
                required String parseStatus,
                Value<double> parseProgress = const Value.absent(),
                Value<String?> failureCode = const Value.absent(),
                Value<String?> failureMessage = const Value.absent(),
                Value<String?> lastReadLocator = const Value.absent(),
                Value<double> readProgress = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> lastOpenedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentsCompanion.insert(
                id: id,
                title: title,
                format: format,
                sourceName: sourceName,
                localPath: localPath,
                contentHash: contentHash,
                fileSize: fileSize,
                pageCount: pageCount,
                wordCount: wordCount,
                paragraphCount: paragraphCount,
                parseStatus: parseStatus,
                parseProgress: parseProgress,
                failureCode: failureCode,
                failureMessage: failureMessage,
                lastReadLocator: lastReadLocator,
                readProgress: readProgress,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastOpenedAt: lastOpenedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DocumentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                paragraphsRefs = false,
                sentencesRefs = false,
                tokensRefs = false,
                phraseOccurrencesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (paragraphsRefs) db.paragraphs,
                    if (sentencesRefs) db.sentences,
                    if (tokensRefs) db.tokens,
                    if (phraseOccurrencesRefs) db.phraseOccurrences,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (paragraphsRefs)
                        await $_getPrefetchedData<
                          Document,
                          $DocumentsTable,
                          Paragraph
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentsTableReferences
                              ._paragraphsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).paragraphsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sentencesRefs)
                        await $_getPrefetchedData<
                          Document,
                          $DocumentsTable,
                          Sentence
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentsTableReferences
                              ._sentencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).sentencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tokensRefs)
                        await $_getPrefetchedData<
                          Document,
                          $DocumentsTable,
                          Token
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentsTableReferences
                              ._tokensRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).tokensRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (phraseOccurrencesRefs)
                        await $_getPrefetchedData<
                          Document,
                          $DocumentsTable,
                          PhraseOccurrence
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentsTableReferences
                              ._phraseOccurrencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).phraseOccurrencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DocumentsTable,
      Document,
      $$DocumentsTableFilterComposer,
      $$DocumentsTableOrderingComposer,
      $$DocumentsTableAnnotationComposer,
      $$DocumentsTableCreateCompanionBuilder,
      $$DocumentsTableUpdateCompanionBuilder,
      (Document, $$DocumentsTableReferences),
      Document,
      PrefetchHooks Function({
        bool paragraphsRefs,
        bool sentencesRefs,
        bool tokensRefs,
        bool phraseOccurrencesRefs,
      })
    >;
typedef $$ParagraphsTableCreateCompanionBuilder =
    ParagraphsCompanion Function({
      required String id,
      required String documentId,
      required int ordinal,
      required String body,
      Value<String> style,
      Value<int> rowid,
    });
typedef $$ParagraphsTableUpdateCompanionBuilder =
    ParagraphsCompanion Function({
      Value<String> id,
      Value<String> documentId,
      Value<int> ordinal,
      Value<String> body,
      Value<String> style,
      Value<int> rowid,
    });

final class $$ParagraphsTableReferences
    extends BaseReferences<_$AppDatabase, $ParagraphsTable, Paragraph> {
  $$ParagraphsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DocumentsTable _documentIdTable(_$AppDatabase db) =>
      db.documents.createAlias('paragraphs__document_id__documents__id');

  $$DocumentsTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<String>('document_id')!;

    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SentencesTable, List<Sentence>>
  _sentencesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sentences,
    aliasName: 'paragraphs__id__sentences__paragraph_id',
  );

  $$SentencesTableProcessedTableManager get sentencesRefs {
    final manager = $$SentencesTableTableManager(
      $_db,
      $_db.sentences,
    ).filter((f) => f.paragraphId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sentencesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ParagraphsTableFilterComposer
    extends Composer<_$AppDatabase, $ParagraphsTable> {
  $$ParagraphsTableFilterComposer({
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

  ColumnFilters<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get style => $composableBuilder(
    column: $table.style,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentsTableFilterComposer get documentId {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> sentencesRefs(
    Expression<bool> Function($$SentencesTableFilterComposer f) f,
  ) {
    final $$SentencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sentences,
      getReferencedColumn: (t) => t.paragraphId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SentencesTableFilterComposer(
            $db: $db,
            $table: $db.sentences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ParagraphsTableOrderingComposer
    extends Composer<_$AppDatabase, $ParagraphsTable> {
  $$ParagraphsTableOrderingComposer({
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

  ColumnOrderings<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get style => $composableBuilder(
    column: $table.style,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentsTableOrderingComposer get documentId {
    final $$DocumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableOrderingComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ParagraphsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ParagraphsTable> {
  $$ParagraphsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ordinal =>
      $composableBuilder(column: $table.ordinal, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get style =>
      $composableBuilder(column: $table.style, builder: (column) => column);

  $$DocumentsTableAnnotationComposer get documentId {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> sentencesRefs<T extends Object>(
    Expression<T> Function($$SentencesTableAnnotationComposer a) f,
  ) {
    final $$SentencesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sentences,
      getReferencedColumn: (t) => t.paragraphId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SentencesTableAnnotationComposer(
            $db: $db,
            $table: $db.sentences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ParagraphsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ParagraphsTable,
          Paragraph,
          $$ParagraphsTableFilterComposer,
          $$ParagraphsTableOrderingComposer,
          $$ParagraphsTableAnnotationComposer,
          $$ParagraphsTableCreateCompanionBuilder,
          $$ParagraphsTableUpdateCompanionBuilder,
          (Paragraph, $$ParagraphsTableReferences),
          Paragraph,
          PrefetchHooks Function({bool documentId, bool sentencesRefs})
        > {
  $$ParagraphsTableTableManager(_$AppDatabase db, $ParagraphsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ParagraphsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ParagraphsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ParagraphsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> documentId = const Value.absent(),
                Value<int> ordinal = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> style = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ParagraphsCompanion(
                id: id,
                documentId: documentId,
                ordinal: ordinal,
                body: body,
                style: style,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String documentId,
                required int ordinal,
                required String body,
                Value<String> style = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ParagraphsCompanion.insert(
                id: id,
                documentId: documentId,
                ordinal: ordinal,
                body: body,
                style: style,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ParagraphsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({documentId = false, sentencesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (sentencesRefs) db.sentences],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (documentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.documentId,
                                referencedTable: $$ParagraphsTableReferences
                                    ._documentIdTable(db),
                                referencedColumn: $$ParagraphsTableReferences
                                    ._documentIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sentencesRefs)
                    await $_getPrefetchedData<
                      Paragraph,
                      $ParagraphsTable,
                      Sentence
                    >(
                      currentTable: table,
                      referencedTable: $$ParagraphsTableReferences
                          ._sentencesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ParagraphsTableReferences(
                            db,
                            table,
                            p0,
                          ).sentencesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.paragraphId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ParagraphsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ParagraphsTable,
      Paragraph,
      $$ParagraphsTableFilterComposer,
      $$ParagraphsTableOrderingComposer,
      $$ParagraphsTableAnnotationComposer,
      $$ParagraphsTableCreateCompanionBuilder,
      $$ParagraphsTableUpdateCompanionBuilder,
      (Paragraph, $$ParagraphsTableReferences),
      Paragraph,
      PrefetchHooks Function({bool documentId, bool sentencesRefs})
    >;
typedef $$SentencesTableCreateCompanionBuilder =
    SentencesCompanion Function({
      required String id,
      required String documentId,
      required String paragraphId,
      required int ordinal,
      required String body,
      required int startOffset,
      required int endOffset,
      Value<int> rowid,
    });
typedef $$SentencesTableUpdateCompanionBuilder =
    SentencesCompanion Function({
      Value<String> id,
      Value<String> documentId,
      Value<String> paragraphId,
      Value<int> ordinal,
      Value<String> body,
      Value<int> startOffset,
      Value<int> endOffset,
      Value<int> rowid,
    });

final class $$SentencesTableReferences
    extends BaseReferences<_$AppDatabase, $SentencesTable, Sentence> {
  $$SentencesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DocumentsTable _documentIdTable(_$AppDatabase db) =>
      db.documents.createAlias('sentences__document_id__documents__id');

  $$DocumentsTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<String>('document_id')!;

    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ParagraphsTable _paragraphIdTable(_$AppDatabase db) =>
      db.paragraphs.createAlias('sentences__paragraph_id__paragraphs__id');

  $$ParagraphsTableProcessedTableManager get paragraphId {
    final $_column = $_itemColumn<String>('paragraph_id')!;

    final manager = $$ParagraphsTableTableManager(
      $_db,
      $_db.paragraphs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paragraphIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TokensTable, List<Token>> _tokensRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tokens,
    aliasName: 'sentences__id__tokens__sentence_id',
  );

  $$TokensTableProcessedTableManager get tokensRefs {
    final manager = $$TokensTableTableManager(
      $_db,
      $_db.tokens,
    ).filter((f) => f.sentenceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tokensRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PhraseOccurrencesTable, List<PhraseOccurrence>>
  _phraseOccurrencesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.phraseOccurrences,
        aliasName: 'sentences__id__phrase_occurrences__sentence_id',
      );

  $$PhraseOccurrencesTableProcessedTableManager get phraseOccurrencesRefs {
    final manager = $$PhraseOccurrencesTableTableManager(
      $_db,
      $_db.phraseOccurrences,
    ).filter((f) => f.sentenceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _phraseOccurrencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SentencesTableFilterComposer
    extends Composer<_$AppDatabase, $SentencesTable> {
  $$SentencesTableFilterComposer({
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

  ColumnFilters<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startOffset => $composableBuilder(
    column: $table.startOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endOffset => $composableBuilder(
    column: $table.endOffset,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentsTableFilterComposer get documentId {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ParagraphsTableFilterComposer get paragraphId {
    final $$ParagraphsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paragraphId,
      referencedTable: $db.paragraphs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParagraphsTableFilterComposer(
            $db: $db,
            $table: $db.paragraphs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> tokensRefs(
    Expression<bool> Function($$TokensTableFilterComposer f) f,
  ) {
    final $$TokensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tokens,
      getReferencedColumn: (t) => t.sentenceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TokensTableFilterComposer(
            $db: $db,
            $table: $db.tokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> phraseOccurrencesRefs(
    Expression<bool> Function($$PhraseOccurrencesTableFilterComposer f) f,
  ) {
    final $$PhraseOccurrencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.phraseOccurrences,
      getReferencedColumn: (t) => t.sentenceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhraseOccurrencesTableFilterComposer(
            $db: $db,
            $table: $db.phraseOccurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SentencesTableOrderingComposer
    extends Composer<_$AppDatabase, $SentencesTable> {
  $$SentencesTableOrderingComposer({
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

  ColumnOrderings<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startOffset => $composableBuilder(
    column: $table.startOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endOffset => $composableBuilder(
    column: $table.endOffset,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentsTableOrderingComposer get documentId {
    final $$DocumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableOrderingComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ParagraphsTableOrderingComposer get paragraphId {
    final $$ParagraphsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paragraphId,
      referencedTable: $db.paragraphs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParagraphsTableOrderingComposer(
            $db: $db,
            $table: $db.paragraphs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SentencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SentencesTable> {
  $$SentencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ordinal =>
      $composableBuilder(column: $table.ordinal, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<int> get startOffset => $composableBuilder(
    column: $table.startOffset,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endOffset =>
      $composableBuilder(column: $table.endOffset, builder: (column) => column);

  $$DocumentsTableAnnotationComposer get documentId {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ParagraphsTableAnnotationComposer get paragraphId {
    final $$ParagraphsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paragraphId,
      referencedTable: $db.paragraphs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParagraphsTableAnnotationComposer(
            $db: $db,
            $table: $db.paragraphs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> tokensRefs<T extends Object>(
    Expression<T> Function($$TokensTableAnnotationComposer a) f,
  ) {
    final $$TokensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tokens,
      getReferencedColumn: (t) => t.sentenceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TokensTableAnnotationComposer(
            $db: $db,
            $table: $db.tokens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> phraseOccurrencesRefs<T extends Object>(
    Expression<T> Function($$PhraseOccurrencesTableAnnotationComposer a) f,
  ) {
    final $$PhraseOccurrencesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.phraseOccurrences,
          getReferencedColumn: (t) => t.sentenceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PhraseOccurrencesTableAnnotationComposer(
                $db: $db,
                $table: $db.phraseOccurrences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SentencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SentencesTable,
          Sentence,
          $$SentencesTableFilterComposer,
          $$SentencesTableOrderingComposer,
          $$SentencesTableAnnotationComposer,
          $$SentencesTableCreateCompanionBuilder,
          $$SentencesTableUpdateCompanionBuilder,
          (Sentence, $$SentencesTableReferences),
          Sentence,
          PrefetchHooks Function({
            bool documentId,
            bool paragraphId,
            bool tokensRefs,
            bool phraseOccurrencesRefs,
          })
        > {
  $$SentencesTableTableManager(_$AppDatabase db, $SentencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SentencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SentencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SentencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> documentId = const Value.absent(),
                Value<String> paragraphId = const Value.absent(),
                Value<int> ordinal = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int> startOffset = const Value.absent(),
                Value<int> endOffset = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SentencesCompanion(
                id: id,
                documentId: documentId,
                paragraphId: paragraphId,
                ordinal: ordinal,
                body: body,
                startOffset: startOffset,
                endOffset: endOffset,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String documentId,
                required String paragraphId,
                required int ordinal,
                required String body,
                required int startOffset,
                required int endOffset,
                Value<int> rowid = const Value.absent(),
              }) => SentencesCompanion.insert(
                id: id,
                documentId: documentId,
                paragraphId: paragraphId,
                ordinal: ordinal,
                body: body,
                startOffset: startOffset,
                endOffset: endOffset,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SentencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                documentId = false,
                paragraphId = false,
                tokensRefs = false,
                phraseOccurrencesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tokensRefs) db.tokens,
                    if (phraseOccurrencesRefs) db.phraseOccurrences,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (documentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.documentId,
                                    referencedTable: $$SentencesTableReferences
                                        ._documentIdTable(db),
                                    referencedColumn: $$SentencesTableReferences
                                        ._documentIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (paragraphId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.paragraphId,
                                    referencedTable: $$SentencesTableReferences
                                        ._paragraphIdTable(db),
                                    referencedColumn: $$SentencesTableReferences
                                        ._paragraphIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tokensRefs)
                        await $_getPrefetchedData<
                          Sentence,
                          $SentencesTable,
                          Token
                        >(
                          currentTable: table,
                          referencedTable: $$SentencesTableReferences
                              ._tokensRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SentencesTableReferences(
                                db,
                                table,
                                p0,
                              ).tokensRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sentenceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (phraseOccurrencesRefs)
                        await $_getPrefetchedData<
                          Sentence,
                          $SentencesTable,
                          PhraseOccurrence
                        >(
                          currentTable: table,
                          referencedTable: $$SentencesTableReferences
                              ._phraseOccurrencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SentencesTableReferences(
                                db,
                                table,
                                p0,
                              ).phraseOccurrencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sentenceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SentencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SentencesTable,
      Sentence,
      $$SentencesTableFilterComposer,
      $$SentencesTableOrderingComposer,
      $$SentencesTableAnnotationComposer,
      $$SentencesTableCreateCompanionBuilder,
      $$SentencesTableUpdateCompanionBuilder,
      (Sentence, $$SentencesTableReferences),
      Sentence,
      PrefetchHooks Function({
        bool documentId,
        bool paragraphId,
        bool tokensRefs,
        bool phraseOccurrencesRefs,
      })
    >;
typedef $$TokensTableCreateCompanionBuilder =
    TokensCompanion Function({
      required String id,
      required String documentId,
      required String sentenceId,
      required int ordinal,
      required String surface,
      required String normalized,
      required String lemma,
      Value<String> partOfSpeech,
      required int startOffset,
      required int endOffset,
      Value<int> rowid,
    });
typedef $$TokensTableUpdateCompanionBuilder =
    TokensCompanion Function({
      Value<String> id,
      Value<String> documentId,
      Value<String> sentenceId,
      Value<int> ordinal,
      Value<String> surface,
      Value<String> normalized,
      Value<String> lemma,
      Value<String> partOfSpeech,
      Value<int> startOffset,
      Value<int> endOffset,
      Value<int> rowid,
    });

final class $$TokensTableReferences
    extends BaseReferences<_$AppDatabase, $TokensTable, Token> {
  $$TokensTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DocumentsTable _documentIdTable(_$AppDatabase db) =>
      db.documents.createAlias('tokens__document_id__documents__id');

  $$DocumentsTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<String>('document_id')!;

    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SentencesTable _sentenceIdTable(_$AppDatabase db) =>
      db.sentences.createAlias('tokens__sentence_id__sentences__id');

  $$SentencesTableProcessedTableManager get sentenceId {
    final $_column = $_itemColumn<String>('sentence_id')!;

    final manager = $$SentencesTableTableManager(
      $_db,
      $_db.sentences,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sentenceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TokensTableFilterComposer
    extends Composer<_$AppDatabase, $TokensTable> {
  $$TokensTableFilterComposer({
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

  ColumnFilters<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get surface => $composableBuilder(
    column: $table.surface,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalized => $composableBuilder(
    column: $table.normalized,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lemma => $composableBuilder(
    column: $table.lemma,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startOffset => $composableBuilder(
    column: $table.startOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endOffset => $composableBuilder(
    column: $table.endOffset,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentsTableFilterComposer get documentId {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SentencesTableFilterComposer get sentenceId {
    final $$SentencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sentenceId,
      referencedTable: $db.sentences,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SentencesTableFilterComposer(
            $db: $db,
            $table: $db.sentences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TokensTableOrderingComposer
    extends Composer<_$AppDatabase, $TokensTable> {
  $$TokensTableOrderingComposer({
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

  ColumnOrderings<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get surface => $composableBuilder(
    column: $table.surface,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalized => $composableBuilder(
    column: $table.normalized,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lemma => $composableBuilder(
    column: $table.lemma,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startOffset => $composableBuilder(
    column: $table.startOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endOffset => $composableBuilder(
    column: $table.endOffset,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentsTableOrderingComposer get documentId {
    final $$DocumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableOrderingComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SentencesTableOrderingComposer get sentenceId {
    final $$SentencesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sentenceId,
      referencedTable: $db.sentences,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SentencesTableOrderingComposer(
            $db: $db,
            $table: $db.sentences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TokensTableAnnotationComposer
    extends Composer<_$AppDatabase, $TokensTable> {
  $$TokensTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ordinal =>
      $composableBuilder(column: $table.ordinal, builder: (column) => column);

  GeneratedColumn<String> get surface =>
      $composableBuilder(column: $table.surface, builder: (column) => column);

  GeneratedColumn<String> get normalized => $composableBuilder(
    column: $table.normalized,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lemma =>
      $composableBuilder(column: $table.lemma, builder: (column) => column);

  GeneratedColumn<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startOffset => $composableBuilder(
    column: $table.startOffset,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endOffset =>
      $composableBuilder(column: $table.endOffset, builder: (column) => column);

  $$DocumentsTableAnnotationComposer get documentId {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SentencesTableAnnotationComposer get sentenceId {
    final $$SentencesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sentenceId,
      referencedTable: $db.sentences,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SentencesTableAnnotationComposer(
            $db: $db,
            $table: $db.sentences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TokensTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TokensTable,
          Token,
          $$TokensTableFilterComposer,
          $$TokensTableOrderingComposer,
          $$TokensTableAnnotationComposer,
          $$TokensTableCreateCompanionBuilder,
          $$TokensTableUpdateCompanionBuilder,
          (Token, $$TokensTableReferences),
          Token,
          PrefetchHooks Function({bool documentId, bool sentenceId})
        > {
  $$TokensTableTableManager(_$AppDatabase db, $TokensTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TokensTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TokensTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TokensTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> documentId = const Value.absent(),
                Value<String> sentenceId = const Value.absent(),
                Value<int> ordinal = const Value.absent(),
                Value<String> surface = const Value.absent(),
                Value<String> normalized = const Value.absent(),
                Value<String> lemma = const Value.absent(),
                Value<String> partOfSpeech = const Value.absent(),
                Value<int> startOffset = const Value.absent(),
                Value<int> endOffset = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TokensCompanion(
                id: id,
                documentId: documentId,
                sentenceId: sentenceId,
                ordinal: ordinal,
                surface: surface,
                normalized: normalized,
                lemma: lemma,
                partOfSpeech: partOfSpeech,
                startOffset: startOffset,
                endOffset: endOffset,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String documentId,
                required String sentenceId,
                required int ordinal,
                required String surface,
                required String normalized,
                required String lemma,
                Value<String> partOfSpeech = const Value.absent(),
                required int startOffset,
                required int endOffset,
                Value<int> rowid = const Value.absent(),
              }) => TokensCompanion.insert(
                id: id,
                documentId: documentId,
                sentenceId: sentenceId,
                ordinal: ordinal,
                surface: surface,
                normalized: normalized,
                lemma: lemma,
                partOfSpeech: partOfSpeech,
                startOffset: startOffset,
                endOffset: endOffset,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TokensTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({documentId = false, sentenceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (documentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.documentId,
                                referencedTable: $$TokensTableReferences
                                    ._documentIdTable(db),
                                referencedColumn: $$TokensTableReferences
                                    ._documentIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (sentenceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sentenceId,
                                referencedTable: $$TokensTableReferences
                                    ._sentenceIdTable(db),
                                referencedColumn: $$TokensTableReferences
                                    ._sentenceIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TokensTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TokensTable,
      Token,
      $$TokensTableFilterComposer,
      $$TokensTableOrderingComposer,
      $$TokensTableAnnotationComposer,
      $$TokensTableCreateCompanionBuilder,
      $$TokensTableUpdateCompanionBuilder,
      (Token, $$TokensTableReferences),
      Token,
      PrefetchHooks Function({bool documentId, bool sentenceId})
    >;
typedef $$PhraseOccurrencesTableCreateCompanionBuilder =
    PhraseOccurrencesCompanion Function({
      required String id,
      required String documentId,
      required String sentenceId,
      required String phraseKey,
      required String surface,
      required String type,
      required String meaning,
      required double confidence,
      required int startTokenOrdinal,
      required int endTokenOrdinal,
      Value<int> rowid,
    });
typedef $$PhraseOccurrencesTableUpdateCompanionBuilder =
    PhraseOccurrencesCompanion Function({
      Value<String> id,
      Value<String> documentId,
      Value<String> sentenceId,
      Value<String> phraseKey,
      Value<String> surface,
      Value<String> type,
      Value<String> meaning,
      Value<double> confidence,
      Value<int> startTokenOrdinal,
      Value<int> endTokenOrdinal,
      Value<int> rowid,
    });

final class $$PhraseOccurrencesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PhraseOccurrencesTable,
          PhraseOccurrence
        > {
  $$PhraseOccurrencesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DocumentsTable _documentIdTable(_$AppDatabase db) => db.documents
      .createAlias('phrase_occurrences__document_id__documents__id');

  $$DocumentsTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<String>('document_id')!;

    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SentencesTable _sentenceIdTable(_$AppDatabase db) => db.sentences
      .createAlias('phrase_occurrences__sentence_id__sentences__id');

  $$SentencesTableProcessedTableManager get sentenceId {
    final $_column = $_itemColumn<String>('sentence_id')!;

    final manager = $$SentencesTableTableManager(
      $_db,
      $_db.sentences,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sentenceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PhraseOccurrencesTableFilterComposer
    extends Composer<_$AppDatabase, $PhraseOccurrencesTable> {
  $$PhraseOccurrencesTableFilterComposer({
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

  ColumnFilters<String> get phraseKey => $composableBuilder(
    column: $table.phraseKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get surface => $composableBuilder(
    column: $table.surface,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startTokenOrdinal => $composableBuilder(
    column: $table.startTokenOrdinal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endTokenOrdinal => $composableBuilder(
    column: $table.endTokenOrdinal,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentsTableFilterComposer get documentId {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SentencesTableFilterComposer get sentenceId {
    final $$SentencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sentenceId,
      referencedTable: $db.sentences,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SentencesTableFilterComposer(
            $db: $db,
            $table: $db.sentences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhraseOccurrencesTableOrderingComposer
    extends Composer<_$AppDatabase, $PhraseOccurrencesTable> {
  $$PhraseOccurrencesTableOrderingComposer({
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

  ColumnOrderings<String> get phraseKey => $composableBuilder(
    column: $table.phraseKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get surface => $composableBuilder(
    column: $table.surface,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startTokenOrdinal => $composableBuilder(
    column: $table.startTokenOrdinal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endTokenOrdinal => $composableBuilder(
    column: $table.endTokenOrdinal,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentsTableOrderingComposer get documentId {
    final $$DocumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableOrderingComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SentencesTableOrderingComposer get sentenceId {
    final $$SentencesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sentenceId,
      referencedTable: $db.sentences,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SentencesTableOrderingComposer(
            $db: $db,
            $table: $db.sentences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhraseOccurrencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhraseOccurrencesTable> {
  $$PhraseOccurrencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get phraseKey =>
      $composableBuilder(column: $table.phraseKey, builder: (column) => column);

  GeneratedColumn<String> get surface =>
      $composableBuilder(column: $table.surface, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get meaning =>
      $composableBuilder(column: $table.meaning, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startTokenOrdinal => $composableBuilder(
    column: $table.startTokenOrdinal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endTokenOrdinal => $composableBuilder(
    column: $table.endTokenOrdinal,
    builder: (column) => column,
  );

  $$DocumentsTableAnnotationComposer get documentId {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SentencesTableAnnotationComposer get sentenceId {
    final $$SentencesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sentenceId,
      referencedTable: $db.sentences,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SentencesTableAnnotationComposer(
            $db: $db,
            $table: $db.sentences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhraseOccurrencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhraseOccurrencesTable,
          PhraseOccurrence,
          $$PhraseOccurrencesTableFilterComposer,
          $$PhraseOccurrencesTableOrderingComposer,
          $$PhraseOccurrencesTableAnnotationComposer,
          $$PhraseOccurrencesTableCreateCompanionBuilder,
          $$PhraseOccurrencesTableUpdateCompanionBuilder,
          (PhraseOccurrence, $$PhraseOccurrencesTableReferences),
          PhraseOccurrence,
          PrefetchHooks Function({bool documentId, bool sentenceId})
        > {
  $$PhraseOccurrencesTableTableManager(
    _$AppDatabase db,
    $PhraseOccurrencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhraseOccurrencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhraseOccurrencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhraseOccurrencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> documentId = const Value.absent(),
                Value<String> sentenceId = const Value.absent(),
                Value<String> phraseKey = const Value.absent(),
                Value<String> surface = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> meaning = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<int> startTokenOrdinal = const Value.absent(),
                Value<int> endTokenOrdinal = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhraseOccurrencesCompanion(
                id: id,
                documentId: documentId,
                sentenceId: sentenceId,
                phraseKey: phraseKey,
                surface: surface,
                type: type,
                meaning: meaning,
                confidence: confidence,
                startTokenOrdinal: startTokenOrdinal,
                endTokenOrdinal: endTokenOrdinal,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String documentId,
                required String sentenceId,
                required String phraseKey,
                required String surface,
                required String type,
                required String meaning,
                required double confidence,
                required int startTokenOrdinal,
                required int endTokenOrdinal,
                Value<int> rowid = const Value.absent(),
              }) => PhraseOccurrencesCompanion.insert(
                id: id,
                documentId: documentId,
                sentenceId: sentenceId,
                phraseKey: phraseKey,
                surface: surface,
                type: type,
                meaning: meaning,
                confidence: confidence,
                startTokenOrdinal: startTokenOrdinal,
                endTokenOrdinal: endTokenOrdinal,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PhraseOccurrencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({documentId = false, sentenceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (documentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.documentId,
                                referencedTable:
                                    $$PhraseOccurrencesTableReferences
                                        ._documentIdTable(db),
                                referencedColumn:
                                    $$PhraseOccurrencesTableReferences
                                        ._documentIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (sentenceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sentenceId,
                                referencedTable:
                                    $$PhraseOccurrencesTableReferences
                                        ._sentenceIdTable(db),
                                referencedColumn:
                                    $$PhraseOccurrencesTableReferences
                                        ._sentenceIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PhraseOccurrencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhraseOccurrencesTable,
      PhraseOccurrence,
      $$PhraseOccurrencesTableFilterComposer,
      $$PhraseOccurrencesTableOrderingComposer,
      $$PhraseOccurrencesTableAnnotationComposer,
      $$PhraseOccurrencesTableCreateCompanionBuilder,
      $$PhraseOccurrencesTableUpdateCompanionBuilder,
      (PhraseOccurrence, $$PhraseOccurrencesTableReferences),
      PhraseOccurrence,
      PrefetchHooks Function({bool documentId, bool sentenceId})
    >;
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
      Value<String?> sourceDocumentId,
      Value<String> sourceDocumentTitle,
      Value<String> contextSentence,
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
      Value<String?> sourceDocumentId,
      Value<String> sourceDocumentTitle,
      Value<String> contextSentence,
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

  ColumnFilters<String> get sourceDocumentId => $composableBuilder(
    column: $table.sourceDocumentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceDocumentTitle => $composableBuilder(
    column: $table.sourceDocumentTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextSentence => $composableBuilder(
    column: $table.contextSentence,
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

  ColumnOrderings<String> get sourceDocumentId => $composableBuilder(
    column: $table.sourceDocumentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceDocumentTitle => $composableBuilder(
    column: $table.sourceDocumentTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextSentence => $composableBuilder(
    column: $table.contextSentence,
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

  GeneratedColumn<String> get sourceDocumentId => $composableBuilder(
    column: $table.sourceDocumentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceDocumentTitle => $composableBuilder(
    column: $table.sourceDocumentTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contextSentence => $composableBuilder(
    column: $table.contextSentence,
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
                Value<String?> sourceDocumentId = const Value.absent(),
                Value<String> sourceDocumentTitle = const Value.absent(),
                Value<String> contextSentence = const Value.absent(),
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
                sourceDocumentId: sourceDocumentId,
                sourceDocumentTitle: sourceDocumentTitle,
                contextSentence: contextSentence,
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
                Value<String?> sourceDocumentId = const Value.absent(),
                Value<String> sourceDocumentTitle = const Value.absent(),
                Value<String> contextSentence = const Value.absent(),
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
                sourceDocumentId: sourceDocumentId,
                sourceDocumentTitle: sourceDocumentTitle,
                contextSentence: contextSentence,
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
typedef $$SavedPhrasesTableCreateCompanionBuilder =
    SavedPhrasesCompanion Function({
      required String id,
      required String phraseKey,
      required String surface,
      required String type,
      required String meaning,
      required String contextSentence,
      Value<String?> sourceDocumentId,
      required String sourceDocumentTitle,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SavedPhrasesTableUpdateCompanionBuilder =
    SavedPhrasesCompanion Function({
      Value<String> id,
      Value<String> phraseKey,
      Value<String> surface,
      Value<String> type,
      Value<String> meaning,
      Value<String> contextSentence,
      Value<String?> sourceDocumentId,
      Value<String> sourceDocumentTitle,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$SavedPhrasesTableFilterComposer
    extends Composer<_$AppDatabase, $SavedPhrasesTable> {
  $$SavedPhrasesTableFilterComposer({
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

  ColumnFilters<String> get phraseKey => $composableBuilder(
    column: $table.phraseKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get surface => $composableBuilder(
    column: $table.surface,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextSentence => $composableBuilder(
    column: $table.contextSentence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceDocumentId => $composableBuilder(
    column: $table.sourceDocumentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceDocumentTitle => $composableBuilder(
    column: $table.sourceDocumentTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavedPhrasesTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedPhrasesTable> {
  $$SavedPhrasesTableOrderingComposer({
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

  ColumnOrderings<String> get phraseKey => $composableBuilder(
    column: $table.phraseKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get surface => $composableBuilder(
    column: $table.surface,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextSentence => $composableBuilder(
    column: $table.contextSentence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceDocumentId => $composableBuilder(
    column: $table.sourceDocumentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceDocumentTitle => $composableBuilder(
    column: $table.sourceDocumentTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedPhrasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedPhrasesTable> {
  $$SavedPhrasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get phraseKey =>
      $composableBuilder(column: $table.phraseKey, builder: (column) => column);

  GeneratedColumn<String> get surface =>
      $composableBuilder(column: $table.surface, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get meaning =>
      $composableBuilder(column: $table.meaning, builder: (column) => column);

  GeneratedColumn<String> get contextSentence => $composableBuilder(
    column: $table.contextSentence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceDocumentId => $composableBuilder(
    column: $table.sourceDocumentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceDocumentTitle => $composableBuilder(
    column: $table.sourceDocumentTitle,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SavedPhrasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedPhrasesTable,
          SavedPhrase,
          $$SavedPhrasesTableFilterComposer,
          $$SavedPhrasesTableOrderingComposer,
          $$SavedPhrasesTableAnnotationComposer,
          $$SavedPhrasesTableCreateCompanionBuilder,
          $$SavedPhrasesTableUpdateCompanionBuilder,
          (
            SavedPhrase,
            BaseReferences<_$AppDatabase, $SavedPhrasesTable, SavedPhrase>,
          ),
          SavedPhrase,
          PrefetchHooks Function()
        > {
  $$SavedPhrasesTableTableManager(_$AppDatabase db, $SavedPhrasesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedPhrasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedPhrasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedPhrasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> phraseKey = const Value.absent(),
                Value<String> surface = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> meaning = const Value.absent(),
                Value<String> contextSentence = const Value.absent(),
                Value<String?> sourceDocumentId = const Value.absent(),
                Value<String> sourceDocumentTitle = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedPhrasesCompanion(
                id: id,
                phraseKey: phraseKey,
                surface: surface,
                type: type,
                meaning: meaning,
                contextSentence: contextSentence,
                sourceDocumentId: sourceDocumentId,
                sourceDocumentTitle: sourceDocumentTitle,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String phraseKey,
                required String surface,
                required String type,
                required String meaning,
                required String contextSentence,
                Value<String?> sourceDocumentId = const Value.absent(),
                required String sourceDocumentTitle,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SavedPhrasesCompanion.insert(
                id: id,
                phraseKey: phraseKey,
                surface: surface,
                type: type,
                meaning: meaning,
                contextSentence: contextSentence,
                sourceDocumentId: sourceDocumentId,
                sourceDocumentTitle: sourceDocumentTitle,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedPhrasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedPhrasesTable,
      SavedPhrase,
      $$SavedPhrasesTableFilterComposer,
      $$SavedPhrasesTableOrderingComposer,
      $$SavedPhrasesTableAnnotationComposer,
      $$SavedPhrasesTableCreateCompanionBuilder,
      $$SavedPhrasesTableUpdateCompanionBuilder,
      (
        SavedPhrase,
        BaseReferences<_$AppDatabase, $SavedPhrasesTable, SavedPhrase>,
      ),
      SavedPhrase,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DocumentsTableTableManager get documents =>
      $$DocumentsTableTableManager(_db, _db.documents);
  $$ParagraphsTableTableManager get paragraphs =>
      $$ParagraphsTableTableManager(_db, _db.paragraphs);
  $$SentencesTableTableManager get sentences =>
      $$SentencesTableTableManager(_db, _db.sentences);
  $$TokensTableTableManager get tokens =>
      $$TokensTableTableManager(_db, _db.tokens);
  $$PhraseOccurrencesTableTableManager get phraseOccurrences =>
      $$PhraseOccurrencesTableTableManager(_db, _db.phraseOccurrences);
  $$VocabularyEntriesTableTableManager get vocabularyEntries =>
      $$VocabularyEntriesTableTableManager(_db, _db.vocabularyEntries);
  $$SavedPhrasesTableTableManager get savedPhrases =>
      $$SavedPhrasesTableTableManager(_db, _db.savedPhrases);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}

mixin _$DocumentsDaoMixin on DatabaseAccessor<AppDatabase> {
  $DocumentsTable get documents => attachedDatabase.documents;
  $ParagraphsTable get paragraphs => attachedDatabase.paragraphs;
  $SentencesTable get sentences => attachedDatabase.sentences;
  $TokensTable get tokens => attachedDatabase.tokens;
  $PhraseOccurrencesTable get phraseOccurrences =>
      attachedDatabase.phraseOccurrences;
  DocumentsDaoManager get managers => DocumentsDaoManager(this);
}

class DocumentsDaoManager {
  final _$DocumentsDaoMixin _db;
  DocumentsDaoManager(this._db);
  $$DocumentsTableTableManager get documents =>
      $$DocumentsTableTableManager(_db.attachedDatabase, _db.documents);
  $$ParagraphsTableTableManager get paragraphs =>
      $$ParagraphsTableTableManager(_db.attachedDatabase, _db.paragraphs);
  $$SentencesTableTableManager get sentences =>
      $$SentencesTableTableManager(_db.attachedDatabase, _db.sentences);
  $$TokensTableTableManager get tokens =>
      $$TokensTableTableManager(_db.attachedDatabase, _db.tokens);
  $$PhraseOccurrencesTableTableManager get phraseOccurrences =>
      $$PhraseOccurrencesTableTableManager(
        _db.attachedDatabase,
        _db.phraseOccurrences,
      );
}

mixin _$LearningDaoMixin on DatabaseAccessor<AppDatabase> {
  $VocabularyEntriesTable get vocabularyEntries =>
      attachedDatabase.vocabularyEntries;
  $SavedPhrasesTable get savedPhrases => attachedDatabase.savedPhrases;
  $DocumentsTable get documents => attachedDatabase.documents;
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
  $$SavedPhrasesTableTableManager get savedPhrases =>
      $$SavedPhrasesTableTableManager(_db.attachedDatabase, _db.savedPhrases);
  $$DocumentsTableTableManager get documents =>
      $$DocumentsTableTableManager(_db.attachedDatabase, _db.documents);
}

mixin _$SettingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $AppSettingsTable get appSettings => attachedDatabase.appSettings;
  SettingsDaoManager get managers => SettingsDaoManager(this);
}

class SettingsDaoManager {
  final _$SettingsDaoMixin _db;
  SettingsDaoManager(this._db);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db.attachedDatabase, _db.appSettings);
}
