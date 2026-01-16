import 'dart:io';
import 'package:file_picker/file_picker.dart';

class AudioImportService {
  /// Permite importar un audio desde el dispositivo
  static Future<File?> pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result == null || result.files.single.path == null) {
      return null;
    }

    return File(result.files.single.path!);
  }
}
