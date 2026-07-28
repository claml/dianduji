import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:dian_du_ji/core/errors/app_failure.dart';
import 'package:dian_du_ji/features/documents/data/services/file_intake_service.dart';
import 'package:dian_du_ji/features/documents/domain/detect_file_format.dart';
import 'package:dian_du_ji/features/documents/domain/file_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('file format detection', () {
    test('uses PDF magic bytes even when extension is wrong', () {
      final bytes = Uint8List.fromList('%PDF-1.7\ncontent'.codeUnits);

      expect(detectFileFormat(bytes, 'lesson.txt'), FileFormat.pdf);
    });

    test('recognizes DOCX by required ZIP entry', () {
      final archive = Archive()
        ..addFile(ArchiveFile('[Content_Types].xml', 8, '<Types/>'.codeUnits));
      final bytes = Uint8List.fromList(ZipEncoder().encode(archive));

      expect(detectFileFormat(bytes, 'lesson.bin'), FileFormat.docx);
    });

    test('recognizes plain UTF text without trusting its extension', () {
      final bytes = Uint8List.fromList(utf8.encode('Hello，世界'));

      expect(detectFileFormat(bytes, 'lesson.data'), FileFormat.txt);
    });

    test('rejects unsupported binary data', () {
      final bytes = Uint8List.fromList([0, 159, 146, 150, 0, 1]);

      expect(
        () => detectFileFormat(bytes, 'lesson.bin'),
        throwsA(
          isA<AppFailure>().having(
            (failure) => failure.code,
            'code',
            AppFailureCode.unsupportedFormat,
          ),
        ),
      );
    });
  });

  group('sandbox intake', () {
    late Directory temporaryDirectory;
    late Directory sandboxDirectory;

    setUp(() async {
      temporaryDirectory = await Directory.systemTemp.createTemp(
        'dian_du_ji_intake_test_',
      );
      sandboxDirectory = Directory(
        '${temporaryDirectory.path}${Platform.pathSeparator}sandbox',
      );
    });

    tearDown(() async {
      await temporaryDirectory.delete(recursive: true);
    });

    test('copies source into sandbox before the source disappears', () async {
      final source = File(
        '${temporaryDirectory.path}${Platform.pathSeparator}lesson.txt',
      );
      await source.writeAsString('Hello world');
      final service = FileIntakeService(sandboxDirectory: sandboxDirectory);

      final intake = await service.copyIntoSandbox(
        SelectedFile(path: source.path, originalName: 'lesson.txt'),
      );
      await source.delete();

      expect(intake.byteSize, 11);
      expect(
        intake.sha256,
        '64ec88ca00b268e5ba1a35678a1b5316d212f4f366b2477232534a8aeca37f3c',
      );
      expect(await File(intake.localPath).readAsString(), 'Hello world');
      expect(intake.wasDuplicate, isFalse);
    });

    test('reuses the sandbox file when content hash is duplicated', () async {
      final first = File(
        '${temporaryDirectory.path}${Platform.pathSeparator}first.txt',
      );
      final second = File(
        '${temporaryDirectory.path}${Platform.pathSeparator}second.txt',
      );
      await first.writeAsString('same bytes');
      await second.writeAsString('same bytes');
      final service = FileIntakeService(sandboxDirectory: sandboxDirectory);

      final original = await service.copyIntoSandbox(
        SelectedFile(path: first.path, originalName: 'first.txt'),
      );
      final duplicate = await service.copyIntoSandbox(
        SelectedFile(path: second.path, originalName: 'second.txt'),
      );

      expect(duplicate.sha256, original.sha256);
      expect(duplicate.localPath, original.localPath);
      expect(duplicate.wasDuplicate, isTrue);
      expect(
        await sandboxDirectory.list().where((item) => item is File).length,
        1,
      );
    });
  });
}
