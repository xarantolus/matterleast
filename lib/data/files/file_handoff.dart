import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:file_picker/file_picker.dart';
import 'package:matterleast/domain/post_files.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

/// Hands a downloaded file to the rest of the phone: other apps, the share
/// sheet and the shared Downloads, Pictures or Movies folders. Cached files
/// have generated names, so each hand-off uses a copy under the file's own
/// name, in the server's hand-off folder.
abstract final class FileHandoff {
  static Future<File> _namedCopy(
    File cached,
    PostFile file,
    String directory,
  ) async {
    final dir = Directory(p.join(directory, file.id));
    await dir.create(recursive: true);
    return cached.copy(p.join(dir.path, _safeName(file)));
  }

  /// Opens the file in an app that can show it; false when none can.
  static Future<bool> open(File cached, PostFile file, String directory) async {
    final copy = await _namedCopy(cached, file, directory);
    return FileDownloader().openFile(
      filePath: copy.path,
      mimeType: _mime(file),
    );
  }

  /// Asks where to save the file (desktop), then writes it there; the path,
  /// or null when the person cancelled.
  static Future<String?> saveAs(File cached, PostFile file) async {
    final uri = await FilePicker.saveFile(
      fileName: _safeName(file),
      bytes: await cached.readAsBytes(),
      mimeType: _mime(file) ?? 'application/octet-stream',
    );
    return uri?.toFilePath();
  }

  static Future<void> share(
    File cached,
    PostFile file,
    String directory,
  ) async {
    final copy = await _namedCopy(cached, file, directory);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(copy.path, mimeType: _mime(file))]),
    );
  }

  /// Copies the file into the shared folder for its kind; the path there,
  /// or null when it failed.
  static Future<String?> save(
    File cached,
    PostFile file,
    String directory,
  ) async {
    final copy = await _namedCopy(cached, file, directory);
    return FileDownloader().moveFileToSharedStorage(
      copy.path,
      switch (file.kind) {
        FileKind.image || FileKind.gif => SharedStorage.images,
        FileKind.video => SharedStorage.video,
        _ => SharedStorage.downloads,
      },
      mimeType: _mime(file),
    );
  }
}

String? _mime(PostFile file) => file.mimeType.isEmpty ? null : file.mimeType;

/// Pure: [file]'s name as a file name every platform accepts, never empty.
String _safeName(PostFile file) =>
    safeFileName(file.name, file.id, file.extension);

final _unsafe = RegExp(r'[/\\:*?"<>|\x00-\x1f\x7f]');
final _deviceName = RegExp(
  r'^(con|prn|aux|nul|com[1-9]|lpt[1-9])(\..*)?$',
  caseSensitive: false,
);
const _longestName = 120;

/// Pure: [name] without characters Windows or Linux reject, trailing dots
/// and spaces, or a device name; [id] and [extension] stand in when nothing
/// usable is left.
String safeFileName(String name, String id, String extension) {
  var safe = name.replaceAll(_unsafe, '_').trim();
  safe = safe.replaceFirst(RegExp(r'[. ]+$'), '');
  if (safe.isEmpty || safe == '.' || safe == '..') {
    return extension.isEmpty ? id : '$id.$extension';
  }
  if (_deviceName.hasMatch(safe)) safe = '_$safe';
  if (safe.length > _longestName) {
    final dot = safe.lastIndexOf('.');
    final ext = dot > 0 && safe.length - dot <= 16 ? safe.substring(dot) : '';
    safe = safe.substring(0, _longestName - ext.length) + ext;
  }
  return safe;
}
