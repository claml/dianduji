import 'dart:typed_data';

import 'package:dian_du_ji/features/learning/data/csv_export_service.dart';
import 'package:dian_du_ji/features/learning/domain/csv_exporter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cancelled destination is an explicit result', () async {
    final destination = _Destination(null);
    final result = await CsvExportService(
      destination: destination,
    ).exportVocabulary(const []);

    expect(result, isA<CsvExportCancelled>());
    expect(destination.calls, 1);
    expect(destination.bytes, isNotEmpty);
  });

  test(
    'service sends exact RFC CSV bytes to the selected destination',
    () async {
      final destination = _Destination('selected.csv');
      final row = const VocabularyExportRow(
        word: 'a',
        phonetic: '',
        partOfSpeech: '',
        definition: '中文, "x"\r\ny',
        proficiency: '陌生',
        lookupCount: 1,
        source: '',
      );

      final result = await CsvExportService(
        destination: destination,
      ).exportVocabulary([row]);

      expect(result, isA<CsvExportSaved>());
      expect(destination.bytes, exportVocabularyCsv([row]));
    },
  );

  test(
    'production file picker adapter always forwards nonempty bytes',
    () async {
      Uint8List? receivedBytes;
      String? receivedName;
      final destination = FilePickerCsvDestinationPicker(
        saveFile:
            ({
              required String fileName,
              required FileType type,
              required List<String> allowedExtensions,
              required Uint8List bytes,
            }) async {
              receivedName = fileName;
              receivedBytes = bytes;
              expect(type, FileType.custom);
              expect(allowedExtensions, ['csv']);
              return 'content://saved.csv';
            },
      );

      final result = await destination.saveCsv(
        suggestedName: '点读机生词.csv',
        bytes: Uint8List.fromList([1, 2, 3]),
      );

      expect(result, 'content://saved.csv');
      expect(receivedName, '点读机生词.csv');
      expect(receivedBytes, [1, 2, 3]);
    },
  );
}

class _Destination implements CsvDestinationPicker {
  _Destination(this.path);

  final String? path;
  var calls = 0;
  Uint8List bytes = Uint8List(0);

  @override
  Future<String?> saveCsv({
    required String suggestedName,
    required Uint8List bytes,
  }) async {
    calls++;
    this.bytes = bytes;
    return path;
  }
}
