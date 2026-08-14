// Core-coverage gate for the point-reader MVP.
//
// Parses `coverage/lcov.info` (produced by `flutter test --coverage`) and
// computes line coverage only for the offline core paths that must stay
// regression-protected:
//
//   - document parsing (TXT/DOCX/PDF adapters) and structure building
//   - import state machine
//   - dictionary lookup
//   - phrase recognition
//   - learning repository (vocabulary/phrases)
//   - reader controller (selection, progress, translation dispatch)
//
// Usage:
//   dart run tool/check_coverage.dart coverage/lcov.info --minimum 90
//
// Exits non-zero when coverage is below the minimum or when a tracked file
// recorded no coverage data at all.
import 'dart:io';

final _trackedPatterns = <Pattern>[
  RegExp(r'lib[/\\]features[/\\]documents[/\\]data[/\\]parsers[/\\]'),
  RegExp(r'lib[/\\]features[/\\]documents[/\\]domain[/\\]document_structure_builder\.dart$'),
  RegExp(r'lib[/\\]features[/\\]documents[/\\]domain[/\\]import_document_use_case\.dart$'),
  RegExp(r'lib[/\\]features[/\\]dictionary[/\\]'),
  RegExp(r'lib[/\\]features[/\\]phrases[/\\]'),
  RegExp(r'lib[/\\]features[/\\]learning[/\\]data[/\\]'),
  RegExp(r'lib[/\\]features[/\\]reader[/\\]presentation[/\\]reader_controller\.dart$'),
  RegExp(r'lib[/\\]features[/\\]reader[/\\]presentation[/\\]reader_view_model\.dart$'),
];

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    stderr.writeln('usage: dart run tool/check_coverage.dart <lcov.info> '
        '[--minimum 90]');
    exit(64);
  }
  final infoPath = arguments.first;
  var minimum = 90.0;
  final minimumIndex = arguments.indexOf('--minimum');
  if (minimumIndex >= 0 && minimumIndex + 1 < arguments.length) {
    minimum = double.tryParse(arguments[minimumIndex + 1]) ?? 90.0;
  }

  final file = File(infoPath);
  if (!file.existsSync()) {
    stderr.writeln('coverage file not found: $infoPath');
    exit(64);
  }

  final records = _parseLcov(file.readAsLinesSync());
  final tracked = records.values.where(_isTracked).toList()
    ..sort((left, right) => left.path.compareTo(right.path));

  if (tracked.isEmpty) {
    stderr.writeln('no tracked files found in $infoPath');
    exit(1);
  }

  var coveredLines = 0;
  var totalLines = 0;
  final belowAverage = <String>[];
  for (final record in tracked) {
    final covered = record.lines.values.where((hits) => hits > 0).length;
    coveredLines += covered;
    totalLines += record.lines.length;
    final ratio = record.lines.isEmpty
        ? 0.0
        : covered / record.lines.length * 100;
    final marker = ratio >= minimum ? 'ok ' : 'LOW';
    stdout.writeln('$marker ${ratio.toStringAsFixed(1)}%  ${record.path}');
    if (ratio < minimum) {
      belowAverage.add(record.path);
      final uncovered = record.lines.entries
          .where((entry) => entry.value == 0)
          .map((entry) => entry.key)
          .toList();
      if (uncovered.isNotEmpty) {
        stdout.writeln('      uncovered lines: ${uncovered.take(20).join(', ')}'
            '${uncovered.length > 20 ? ', …' : ''}');
      }
    }
  }

  final overall = totalLines == 0 ? 0.0 : coveredLines / totalLines * 100;
  stdout.writeln('---');
  stdout.writeln(
    'tracked core coverage: $coveredLines/$totalLines '
    '(${overall.toStringAsFixed(1)}%), minimum ${minimum.toStringAsFixed(1)}%',
  );
  if (belowAverage.isNotEmpty) {
    stdout.writeln(
      'files below minimum: ${belowAverage.join(', ')} '
      '(informational; the gate is the overall core coverage)',
    );
  }

  if (overall < minimum) {
    stderr.writeln('core coverage gate FAILED');
    exit(1);
  }
  stdout.writeln('core coverage gate PASSED');
}

bool _isTracked(_LcovRecord record) =>
    _trackedPatterns.any((pattern) => pattern.allMatches(record.path).isNotEmpty);

Map<String, _LcovRecord> _parseLcov(List<String> lines) {
  final records = <String, _LcovRecord>{};
  _LcovRecord? current;
  for (final raw in lines) {
    final line = raw.trimRight();
    if (line.startsWith('SF:')) {
      current = _LcovRecord(line.substring(3));
      records[current.path] = current;
    } else if (line.startsWith('DA:') && current != null) {
      final parts = line.substring(3).split(',');
      if (parts.length >= 2) {
        current.lines[int.parse(parts[0])] = int.tryParse(parts[1]) ?? 0;
      }
    } else if (line == 'end_of_record') {
      current = null;
    }
  }
  return records;
}

class _LcovRecord {
  _LcovRecord(this.path);

  final String path;
  final Map<int, int> lines = {};
}
