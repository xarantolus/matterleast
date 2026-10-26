import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/post_files.dart';

/// The icon for a file of [kind], wherever a file is listed.
IconData fileIcon(FileKind kind, String extension) => switch (kind) {
  FileKind.pdf => Icons.picture_as_pdf_outlined,
  FileKind.text => Icons.description_outlined,
  FileKind.image || FileKind.gif => Icons.image_outlined,
  FileKind.video => Icons.movie_outlined,
  FileKind.other => switch (extension.toLowerCase()) {
    'zip' || 'gz' || 'tar' || '7z' || 'rar' => Icons.folder_zip_outlined,
    'mp3' || 'ogg' || 'wav' || 'm4a' || 'flac' => Icons.audio_file_outlined,
    'xls' || 'xlsx' || 'csv' || 'ods' => Icons.table_chart_outlined,
    _ => Icons.insert_drive_file_outlined,
  },
};
