import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:charset/charset.dart';

import '../../../core/errors/app_failure.dart';
import 'file_format.dart';

FileFormat detectFileFormat(Uint8List bytes, String fileName) {
  if (_startsWith(bytes, const [0x25, 0x50, 0x44, 0x46, 0x2d])) {
    return FileFormat.pdf;
  }

  if (_startsWith(bytes, const [0x50, 0x4b])) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes, verify: true);
      if (archive.files.any((entry) => entry.name == '[Content_Types].xml')) {
        return FileFormat.docx;
      }
    } on Object {
      throw const AppFailure(
        AppFailureCode.unsupportedFormat,
        '文件是无效或不受支持的 ZIP/DOCX。',
      );
    }
    throw const AppFailure(
      AppFailureCode.unsupportedFormat,
      '普通 ZIP 文件不是可导入的 DOCX 文档。',
    );
  }

  if (_looksLikeUtfText(bytes)) return FileFormat.txt;

  throw AppFailure(AppFailureCode.unsupportedFormat, '不支持文件“$fileName”的格式。');
}

bool _startsWith(Uint8List bytes, List<int> signature) {
  if (bytes.length < signature.length) return false;
  for (var index = 0; index < signature.length; index++) {
    if (bytes[index] != signature[index]) return false;
  }
  return true;
}

bool _looksLikeUtfText(Uint8List bytes) {
  if (bytes.any((byte) => byte == 0)) return false;
  try {
    utf8.decode(bytes, allowMalformed: false);
    return true;
  } on FormatException {
    try {
      final decoded = const GbkCodec(allowMalformed: false).decode(bytes);
      return !decoded.contains('\uFFFD');
    } on FormatException {
      return false;
    }
  }
}
