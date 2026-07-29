import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../domain/csv_exporter.dart';

abstract interface class CsvDestinationPicker {
  Future<String?> saveCsv({required String suggestedName});
}

abstract interface class CsvFileWriter {
  Future<void> write(String path, Uint8List bytes);
}

class FilePickerCsvDestinationPicker implements CsvDestinationPicker {
  const FilePickerCsvDestinationPicker();

  @override
  Future<String?> saveCsv({required String suggestedName}) =>
      FilePicker.platform.saveFile(
        fileName: suggestedName,
        type: FileType.custom,
        allowedExtensions: const ['csv'],
      );
}

class LocalCsvFileWriter implements CsvFileWriter {
  const LocalCsvFileWriter();

  @override
  Future<void> write(String path, Uint8List bytes) =>
      File(path).writeAsBytes(bytes, flush: true);
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
  const CsvExportService({
    required this.destinationPicker,
    required this.writer,
  });

  final CsvDestinationPicker destinationPicker;
  final CsvFileWriter writer;

  Future<CsvExportResult> exportVocabulary(
    Iterable<VocabularyExportRow> rows,
  ) async {
    final path = await destinationPicker.saveCsv(suggestedName: '点读机生词.csv');
    if (path == null) return const CsvExportResult.cancelled();
    await writer.write(path, exportVocabularyCsv(rows));
    return CsvExportResult.saved(path);
  }
}
