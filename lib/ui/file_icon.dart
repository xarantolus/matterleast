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

/// The colour of a file's type tile; white text on each reads at 4.5:1.
Color fileTypeColor(String extension) => switch (extension.toLowerCase()) {
  'pdf' => const Color(0xFFC62828),
  'doc' || 'docx' || 'odt' || 'rtf' => const Color(0xFF1565C0),
  'xls' || 'xlsx' || 'csv' || 'ods' => const Color(0xFF2E7D32),
  'ppt' || 'pptx' || 'odp' => const Color(0xFFBF360C),
  'zip' || 'gz' || 'tar' || '7z' || 'rar' => const Color(0xFF7A5C00),
  'mp3' ||
  'ogg' ||
  'wav' ||
  'm4a' ||
  'flac' ||
  'aac' => const Color(0xFF6A1B9A),
  'txt' ||
  'md' ||
  'json' ||
  'xml' ||
  'yaml' ||
  'html' => const Color(0xFF00695C),
  _ => const Color(0xFF546E7A),
};
