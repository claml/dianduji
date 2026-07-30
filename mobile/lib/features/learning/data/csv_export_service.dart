import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../domain/csv_exporter.dart';

typedef SaveCsvFile =
    Future<String?> Function({
      required String fileName,
      required FileType type,
      required List<String> allowedExtensions,
      required Uint8List bytes,
    });

abstract interface class CsvDestinationPicker {
  Future<String?> saveCsv({
    required String suggestedName,
    required Uint8List bytes,
  });
}

class FilePickerCsvDestinationPicker implements CsvDestinationPicker {
  const FilePickerCsvDestinationPicker({this.saveFile});

  final SaveCsvFile? saveFile;

  @override
  Future<String?> saveCsv({
    required String suggestedName,
    required Uint8List bytes,
  }) => (saveFile ?? _saveWithFilePicker)(
    fileName: suggestedName,
    type: FileType.custom,
    allowedExtensions: const ['csv'],
    bytes: bytes,
  );

  static Future<String?> _saveWithFilePicker({
    required String fileName,
    required FileType type,
    required List<String> allowedExtensions,
    required Uint8List bytes,
  }) => FilePicker.platform.saveFile(
    fileName: fileName,
    type: type,
    allowedExtensions: allowedExtensions,
    bytes: bytes,
  );
}

sealed class CsvExportResult {
  const CsvExportResult();
  const factory CsvExportResult.cancelled() = CsvExportCancelled;
  const factory CsvExportResult.saved(String path) = CsvExportSaved;
}

class CsvExportCancelled extends CsvExportResult {
  const CsvExportCancelled();
}

class CsvExportSaved extends CsvExportResult {
  const CsvExportSaved(this.path);
  final String path;
}

class CsvExportService {
  const CsvExportService({required this.destination});

  final CsvDestinationPicker destination;

  Future<CsvExportResult> exportVocabulary(
    Iterable<VocabularyExportRow> rows,
  ) async {
    final bytes = exportVocabularyCsv(rows);
    final path = await destination.saveCsv(
      suggestedName: '点读机生词.csv',
      bytes: bytes,
    );
    if (path == null) return const CsvExportResult.cancelled();
    return CsvExportResult.saved(path);
  }
}
