import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/app_failure.dart';

class SelectedFile {
  const SelectedFile({required this.path, required this.originalName});

  final String path;
  final String originalName;
}

class IntakeFile {
  const IntakeFile({
    required this.originalName,
    required this.localPath,
    required this.sha256,
    required this.byteSize,
    required this.wasDuplicate,
  });

  final String originalName;
  final String localPath;
  final String sha256;
  final int byteSize;
  final bool wasDuplicate;
}

class FileIntakeService {
  FileIntakeService({required this.sandboxDirectory, Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final Directory sandboxDirectory;
  final Uuid _uuid;

  Future<IntakeFile> copyIntoSandbox(SelectedFile input) async {
    final source = File(input.path);
    if (!await source.exists()) {
      throw AppFailure(
        AppFailureCode.fileUnavailable,
        '无法读取文件“${input.originalName}”。',
      );
    }

    await sandboxDirectory.create(recursive: true);
    final temporary = File(
      '${sandboxDirectory.path}${Platform.pathSeparator}.${_uuid.v4()}.part',
    );
    final output = temporary.openWrite();
    Digest? digest;
    final digestSink = sha256.startChunkedConversion(
      _DigestSink((value) => digest = value),
    );
    var byteSize = 0;

    try {
      await for (final chunk in source.openRead()) {
        byteSize += chunk.length;
        digestSink.add(chunk);
        output.add(chunk);
      }
      digestSink.close();
      await output.close();

      final hash = digest.toString();
      final destination = File(
        '${sandboxDirectory.path}${Platform.pathSeparator}$hash.bin',
      );
      if (await destination.exists()) {
        await temporary.delete();
        return IntakeFile(
          originalName: input.originalName,
          localPath: destination.path,
          sha256: hash,
          byteSize: byteSize,
          wasDuplicate: true,
        );
      }

      await temporary.rename(destination.path);
      return IntakeFile(
        originalName: input.originalName,
        localPath: destination.path,
        sha256: hash,
        byteSize: byteSize,
        wasDuplicate: false,
      );
    } on AppFailure {
      rethrow;
    } on Object catch (error) {
      await output.close();
      if (await temporary.exists()) await temporary.delete();
      throw AppFailure(
        AppFailureCode.storage,
        '复制文件“${input.originalName}”失败。',
        cause: error,
      );
    }
  }
}

class _DigestSink implements Sink<Digest> {
  _DigestSink(this.onDigest);

  final void Function(Digest digest) onDigest;

  @override
  void add(Digest data) => onDigest(data);

  @override
  void close() {}
}
