import 'dart:io';
import 'dart:typed_data';

import '../domain/detect_file_format.dart';
import '../domain/file_format.dart';
import '../domain/import_document_use_case.dart';
import 'services/file_intake_service.dart';

class DefaultImportIntake implements ImportIntake {
  const DefaultImportIntake(this._files);

  final FileIntakeService _files;

  @override
  Future<PreparedImportFile> prepare(SelectedFile selectedFile) async {
    final intake = await _files.copyIntoSandbox(selectedFile);
    final sandboxFile = File(intake.localPath);
    final magicBytes = await _readMagicBytes(sandboxFile);
    final expectedFormat = _formatFromMagic(magicBytes);
    final bytes = await sandboxFile.readAsBytes();
    final detectedFormat = detectFileFormat(bytes, intake.originalName);
    if (expectedFormat != null && expectedFormat != detectedFormat) {
      throw StateError('Sandbox format detection disagreed with file magic.');
    }
    return PreparedImportFile(
      intake: intake,
      format: detectedFormat,
      bytes: bytes,
    );
  }

  Future<Uint8List> _readMagicBytes(File file) async {
    final stream = file.openRead(0, 8);
    final bytes = <int>[];
    await for (final chunk in stream) {
      bytes.addAll(chunk);
      if (bytes.length >= 8) break;
    }
    return Uint8List.fromList(bytes);
  }

  FileFormat? _formatFromMagic(Uint8List bytes) {
    if (_startsWith(bytes, const [0x25, 0x50, 0x44, 0x46, 0x2d])) {
      return FileFormat.pdf;
    }
    if (_startsWith(bytes, const [0x50, 0x4b])) return FileFormat.docx;
    return null;
  }
}

bool _startsWith(Uint8List bytes, List<int> prefix) {
  if (bytes.length < prefix.length) return false;
  for (var index = 0; index < prefix.length; index++) {
    if (bytes[index] != prefix[index]) return false;
  }
  return true;
}
