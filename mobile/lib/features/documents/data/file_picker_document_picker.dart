import 'package:file_picker/file_picker.dart';

import '../../../core/errors/app_failure.dart';
import 'services/file_intake_service.dart';

abstract interface class DocumentPicker {
  Future<SelectedFile?> pickDocument();
}

class FilePickerDocumentPicker implements DocumentPicker {
  const FilePickerDocumentPicker();

  @override
  Future<SelectedFile?> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['txt', 'pdf', 'docx'],
      allowMultiple: false,
      withData: false,
    );
    if (result == null) return null;
    final file = result.files.single;
    final path = file.path;
    if (path == null) {
      throw const AppFailure(
        AppFailureCode.fileUnavailable,
        '\u7cfb\u7edf\u6ca1\u6709\u63d0\u4f9b\u53ef\u8bfb\u53d6\u7684\u6587\u4ef6\u8def\u5f84\uff0c\u8bf7\u91cd\u65b0\u9009\u62e9\u6587\u4ef6\u3002',
      );
    }
    return SelectedFile(path: path, originalName: file.name);
  }
}
