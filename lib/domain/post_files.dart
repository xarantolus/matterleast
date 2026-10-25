import 'dart:convert';
import 'dart:typed_data';

import 'package:matterleast/api/generated/export.dart' as api;

/// How a file attached to a message is shown and opened.
enum FileKind { image, gif, video, pdf, text, other }

/// A file attached to a message.
class PostFile {
  const PostFile({
    required this.id,
    required this.name,
    this.extension = '',
    this.mimeType = '',
    this.size = 0,
    this.width,
    this.height,
    this.hasPreview = false,
    this.miniPreview,
  });

  factory PostFile.from(api.FileInfo f) => PostFile(
    id: f.id ?? '',
    name: f.name ?? '',
    extension: (f.extensionValue ?? '').toLowerCase(),
    mimeType: (f.mimeType ?? '').toLowerCase(),
    size: f.size ?? 0,
    width: f.width,
    height: f.height,
    hasPreview: f.hasPreviewImage ?? false,
    miniPreview: _base64(f.miniPreview),
  );

  final String id;
  final String name;
  final String extension;
  final String mimeType;
  final int size;
  final int? width;
  final int? height;
  final bool hasPreview;

  /// A tiny JPEG the server makes of an image, to blur while it loads.
  final Uint8List? miniPreview;

  FileKind get kind => fileKindOf(extension: extension, mimeType: mimeType);

  bool get isMedia =>
      kind == FileKind.image || kind == FileKind.gif || kind == FileKind.video;
}

Uint8List? _base64(String? value) {
  if (value == null || value.isEmpty) return null;
  try {
    return base64Decode(value);
  } on FormatException {
    return null;
  }
}

const _images = {'jpg', 'jpeg', 'png', 'webp', 'bmp', 'heic', 'heif'};
const _videos = {'mp4', 'm4v', 'webm', 'mkv', '3gp', 'mov'};
const _texts = {
  'txt', 'md', 'markdown', 'log', 'csv', 'tsv', 'json', 'yaml', 'yml', //
  'xml', 'html', 'css', 'js', 'ts', 'dart', 'py', 'go', 'java', 'kt', 'c',
  'h', 'cpp', 'hpp', 'cs', 'rs', 'rb', 'php', 'sh', 'sql', 'swift', 'toml',
  'ini', 'conf', 'diff', 'patch',
};

/// Pure: how a file is shown, by its extension and then its type.
FileKind fileKindOf({required String extension, required String mimeType}) {
  final ext = extension.toLowerCase();
  if (ext == 'gif' || mimeType == 'image/gif') return FileKind.gif;
  if (_images.contains(ext)) return FileKind.image;
  if (_videos.contains(ext)) return FileKind.video;
  if (ext == 'pdf' || mimeType == 'application/pdf') return FileKind.pdf;
  if (_texts.contains(ext)) return FileKind.text;
  if (mimeType.startsWith('image/') && mimeType != 'image/svg+xml') {
    return FileKind.image;
  }
  if (mimeType.startsWith('video/')) return FileKind.video;
  if (mimeType.startsWith('text/')) return FileKind.text;
  return FileKind.other;
}

/// The code highlighter's language for a text file's extension.
String languageOfExtension(String extension) => switch (extension) {
  'txt' || 'log' || 'csv' || 'tsv' => '',
  'md' => 'markdown',
  'yml' => 'yaml',
  'js' => 'javascript',
  'ts' => 'typescript',
  'py' => 'python',
  'kt' => 'kotlin',
  'rs' => 'rust',
  'rb' => 'ruby',
  'sh' => 'bash',
  'h' || 'hpp' => 'cpp',
  'cs' => 'csharp',
  'conf' => 'ini',
  'patch' => 'diff',
  _ => extension,
};

/// Pure: [bytes] as people read sizes, such as "1.4 MB".
String formatBytes(int bytes) {
  const units = ['B', 'KB', 'MB', 'GB'];
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  if (unit == 0) return '$bytes B';
  final digits = value < 10 ? 1 : 0;
  return '${value.toStringAsFixed(digits)} ${units[unit]}';
}

/// Pure: the indexes of up to four media tiles by row, and how many items
/// don't get a tile. One fills the row; three are one wide over two.
({List<List<int>> rows, int hidden}) mediaGridRows(int count) {
  final shown = count > 4 ? 4 : count;
  final rows = switch (shown) {
    0 => <List<int>>[],
    1 => [
      [0],
    ],
    2 => [
      [0, 1],
    ],
    3 => [
      [0],
      [1, 2],
    ],
    _ => [
      [0, 1],
      [2, 3],
    ],
  };
  return (rows: rows, hidden: count - shown);
}

/// Pure: whether the gallery should swap the preview for the original at
/// [scale]: the original has more pixels than the preview, and the screen
/// now shows more than the preview has.
bool needsOriginal({
  required PostFile file,
  required double scale,
  required double shownWidth,
  required double pixelRatio,
}) {
  final width = file.width ?? 0;
  if (!file.hasPreview || width <= previewWidth) return false;
  return shownWidth * pixelRatio * scale > previewWidth;
}

/// The widest preview the server makes.
const previewWidth = 1920;
