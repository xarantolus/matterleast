import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
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

/// Pure: [file]'s name without path separators, never empty.
String _safeName(PostFile file) {
  final name = file.name.replaceAll(RegExp(r'[/\\\x00]'), '_').trim();
  if (name.isNotEmpty && name != '.' && name != '..') return name;
  return file.extension.isEmpty ? file.id : '${file.id}.${file.extension}';
}
