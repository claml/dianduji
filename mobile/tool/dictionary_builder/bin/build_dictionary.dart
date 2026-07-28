import 'dart:io';

import '../dictionary_builder.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.length < 3) {
    stderr.writeln(
      'Usage: dart run tool/dictionary_builder/bin/build_dictionary.dart '
      '<ecdict.csv> <output.sqlite> <source-revision> [maximum-entries]',
    );
    exitCode = 64;
    return;
  }
  final report = await buildDictionary(
    sourceCsv: File(arguments[0]),
    outputDatabase: File(arguments[1]),
    sourceRevision: arguments[2],
    maximumEntries: arguments.length > 3 ? int.parse(arguments[3]) : 60000,
  );
  stdout.writeln('entries=${report.entryCount}');
  stdout.writeln('sha256=${report.sha256}');
  stdout.writeln('source_sha256=${report.sourceSha256}');
}
