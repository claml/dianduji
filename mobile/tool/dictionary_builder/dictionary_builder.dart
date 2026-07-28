import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:sqlite3/sqlite3.dart';

class DictionaryBuildReport {
  const DictionaryBuildReport({
    required this.entryCount,
    required this.sha256,
    required this.sourceSha256,
  });

  final int entryCount;
  final String sha256;
  final String sourceSha256;
}

Future<DictionaryBuildReport> buildDictionary({
  required File sourceCsv,
  required File outputDatabase,
  required String sourceRevision,
  int maximumEntries = 60000,
}) async {
  if (maximumEntries < 1) {
    throw ArgumentError.value(maximumEntries, 'maximumEntries');
  }
  await outputDatabase.parent.create(recursive: true);
  if (await outputDatabase.exists()) await outputDatabase.delete();

  final sourceDigest = await sha256.bind(sourceCsv.openRead()).first;
  final database = sqlite3.open(outputDatabase.path);
  try {
    database.execute('''
PRAGMA journal_mode = OFF;
PRAGMA synchronous = OFF;
CREATE TABLE raw_entries (
  word TEXT PRIMARY KEY,
  phonetic TEXT NOT NULL,
  definition_english TEXT NOT NULL,
  definition_chinese TEXT NOT NULL,
  part_of_speech TEXT NOT NULL,
  collins INTEGER NOT NULL,
  oxford INTEGER NOT NULL,
  tag TEXT NOT NULL,
  frequency INTEGER NOT NULL,
  exchange TEXT NOT NULL
);
''');
    final insert = database.prepare('''
INSERT OR REPLACE INTO raw_entries VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
''');
    try {
      final lines = sourceCsv
          .openRead()
          .transform(utf8.decoder)
          .transform(const LineSplitter());
      List<String>? headers;
      var pending = 0;
      database.execute('BEGIN');
      await for (final line in lines) {
        if (headers == null) {
          headers = _parseCsvLine(line);
          continue;
        }
        if (line.trim().isEmpty) continue;
        final fields = _parseCsvLine(line);
        if (fields.length != headers.length) continue;
        final row = <String, String>{
          for (var index = 0; index < headers.length; index++)
            headers[index]: fields[index],
        };
        final word = (row['word'] ?? '').trim().toLowerCase();
        final translation = (row['translation'] ?? '').trim();
        if (word.isEmpty || translation.isEmpty) continue;
        insert.execute([
          word,
          row['phonetic'] ?? '',
          (row['definition'] ?? '').replaceAll(r'\n', '\n'),
          translation.replaceAll(r'\n', '\n'),
          row['pos'] ?? '',
          int.tryParse(row['collins'] ?? '') ?? 0,
          int.tryParse(row['oxford'] ?? '') ?? 0,
          row['tag'] ?? '',
          int.tryParse(row['frq'] ?? '') ?? 0,
          row['exchange'] ?? '',
        ]);
        pending++;
        if (pending == 5000) {
          database.execute('COMMIT');
          database.execute('BEGIN');
          pending = 0;
        }
      }
      database.execute('COMMIT');
    } catch (_) {
      database.execute('ROLLBACK');
      rethrow;
    } finally {
      insert.close();
    }

    database.execute('''
CREATE TABLE entries (
  word TEXT PRIMARY KEY,
  phonetic TEXT NOT NULL,
  part_of_speech TEXT NOT NULL,
  definition_english TEXT NOT NULL,
  definition_chinese TEXT NOT NULL
) WITHOUT ROWID;
INSERT INTO entries
SELECT word, phonetic, part_of_speech, definition_english,
       definition_chinese
FROM raw_entries
ORDER BY CASE WHEN tag <> '' THEN 1 ELSE 0 END DESC,
         oxford DESC,
         collins DESC,
         CASE WHEN frequency > 0 THEN frequency ELSE 2147483647 END ASC,
         word ASC
LIMIT $maximumEntries;
CREATE TABLE lemmas (
  form TEXT PRIMARY KEY,
  lemma TEXT NOT NULL
) WITHOUT ROWID;
CREATE TABLE metadata (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
) WITHOUT ROWID;
''');

    final variants = database.select('''
SELECT word, exchange FROM raw_entries
WHERE word IN (SELECT word FROM entries) AND exchange <> ''
''');
    final insertLemma = database.prepare(
      'INSERT OR IGNORE INTO lemmas(form, lemma) VALUES (?, ?)',
    );
    try {
      database.execute('BEGIN');
      for (final row in variants) {
        final lemma = row['word'] as String;
        for (final part in (row['exchange'] as String).split('/')) {
          final separator = part.indexOf(':');
          if (separator < 0) continue;
          for (final form in part.substring(separator + 1).split(',')) {
            final normalized = form.trim().toLowerCase();
            if (normalized.isNotEmpty && normalized != lemma) {
              insertLemma.execute([normalized, lemma]);
            }
          }
        }
      }
      database.execute('COMMIT');
    } catch (_) {
      database.execute('ROLLBACK');
      rethrow;
    } finally {
      insertLemma.close();
    }

    final entryCount =
        database.select('SELECT COUNT(*) AS count FROM entries').single['count']
            as int;
    final metadata = database.prepare(
      'INSERT INTO metadata(key, value) VALUES (?, ?)',
    );
    try {
      metadata.execute(['source_revision', sourceRevision]);
      metadata.execute(['source_sha256', sourceDigest.toString()]);
      metadata.execute(['entry_count', entryCount.toString()]);
    } finally {
      metadata.close();
    }
    database.execute('DROP TABLE raw_entries');
    database.execute('VACUUM');
  } finally {
    database.close();
  }

  final outputDigest = await sha256.bind(outputDatabase.openRead()).first;
  final databaseForCount = sqlite3.open(
    outputDatabase.path,
    mode: OpenMode.readOnly,
  );
  final entryCount =
      databaseForCount
              .select('SELECT COUNT(*) AS count FROM entries')
              .single['count']
          as int;
  databaseForCount.close();
  return DictionaryBuildReport(
    entryCount: entryCount,
    sha256: outputDigest.toString(),
    sourceSha256: sourceDigest.toString(),
  );
}

List<String> _parseCsvLine(String line) {
  final fields = <String>[];
  final buffer = StringBuffer();
  var quoted = false;
  for (var index = 0; index < line.length; index++) {
    final character = line[index];
    if (character == '"') {
      if (quoted && index + 1 < line.length && line[index + 1] == '"') {
        buffer.write('"');
        index++;
      } else {
        quoted = !quoted;
      }
    } else if (character == ',' && !quoted) {
      fields.add(buffer.toString());
      buffer.clear();
    } else {
      buffer.write(character);
    }
  }
  fields.add(buffer.toString());
  return fields;
}
