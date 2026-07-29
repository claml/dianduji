import 'dart:typed_data';

import 'package:dian_du_ji/features/learning/data/csv_export_service.dart';
import 'package:dian_du_ji/features/learning/domain/csv_exporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cancelled destination performs no write', () async {
    final writer = _Writer();
    final result = await CsvExportService(
      destinationPicker: _Picker(null),
      writer: writer,
    ).exportVocabulary(const []);
    expect(result, isA<CsvExportCancelled>());
    expect(writer.writes, isEmpty);
  });

  test('writes RFC CSV bytes only after a destination is selected', () async {
    final writer = _Writer();
    await CsvExportService(
      destinationPicker: _Picker('selected.csv'),
      writer: writer,
    ).exportVocabulary(const [
      VocabularyExportRow(
        word: 'a',
        phonetic: '',
        partOfSpeech: '',
        definition: '中文, "x"\r\ny',
        proficiency: '陌生',
        lookupCount: 1,
        source: '',
      ),
    ]);
    expect(writer.writes.single.$1, 'selected.csv');
    expect(writer.writes.single.$2.take(3), isNot([0xef, 0xbb, 0xbf]));
  });
}

class _Picker implements CsvDestinationPicker {
  const _Picker(this.path);
  final String? path;
  @override
  Future<String?> saveCsv({required String suggestedName}) async => path;
}

class _Writer implements CsvFileWriter {
  final writes = <(String, Uint8List)>[];
  @override
  Future<void> write(String path, Uint8List bytes) async =>
      writes.add((path, bytes));
}
