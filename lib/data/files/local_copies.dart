import 'dart:io';

import 'package:matterleast/log.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Short-lived copies of files in the app's cache folder: what other apps
/// share (copied by receive_sharing_intent straight into the cache folder),
/// what the pickers copy (`file_picker/<stamp>/`, image_picker's `<uuid>/`
/// and loose files), and files handed to other apps
/// (`images/<server>/handoff/<file id>/`).
abstract final class LocalCopies {
  static const serverCachesFolder = 'images';
  static const handoffFolder = 'handoff';

  /// Copies older than this are deleted on start-up.
  static const maxAge = Duration(days: 1);

  static Future<String> cacheDirectory() async =>
      (await getTemporaryDirectory()).path;

  /// [path] with links and `..` resolved when it is a regular file, else
  /// null.
  static String? resolveFile(String path) {
    try {
      final resolved = File(path).resolveSymbolicLinksSync();
      return FileSystemEntity.isFileSync(resolved) ? resolved : null;
    } on FileSystemException {
      return null;
    }
  }

  /// [cacheDir] with links resolved, as plugin copies are checked against.
  static String resolveDirectory(String cacheDir) {
    try {
      return Directory(cacheDir).resolveSymbolicLinksSync();
    } on FileSystemException {
      return p.normalize(cacheDir);
    }
  }

  /// Deletes the share plugin's copies among [paths]; anything else is left
  /// alone.
  static Future<void> deleteShared(
    String cacheDir,
    Iterable<String> paths,
  ) async {
    final root = resolveDirectory(cacheDir);
    for (final path in paths) {
      final resolved = resolveFile(path);
      if (resolved != null && isPluginCopy(root, resolved)) {
        await _delete(resolved);
      }
    }
  }

  /// Deletes every loose file in the cache folder: share and camera copies.
  static Future<void> clearLooseFiles(String cacheDir) async {
    for (final path in _children(cacheDir)) {
      if (FileSystemEntity.isFileSync(path) &&
          !FileSystemEntity.isLinkSync(path)) {
        await _delete(path);
      }
    }
  }

  /// Deletes the picker's copy at [path], if it is one.
  static Future<void> deletePicked(String cacheDir, String path) async {
    final copy = pickerCopyOf(cacheDir, path);
    if (copy == null) return;
    // A name directly in the cache folder may be a cache, not a copy.
    if (p.equals(p.dirname(copy), cacheDir) &&
        !FileSystemEntity.isFileSync(copy)) {
      return;
    }
    await _delete(copy);
  }

  /// Deletes copies older than [maxAge], e.g. those of a share that was
  /// never finished because the app was closed.
  static Future<void> sweep(String cacheDir, DateTime now) async {
    final candidates = <String>[
      ..._children(cacheDir),
      ..._children(p.join(cacheDir, 'file_picker')),
      ..._children(p.join(cacheDir, handoffFolder)),
      for (final server in _children(p.join(cacheDir, serverCachesFolder)))
        ..._children(p.join(server, handoffFolder)),
    ];
    for (final path in candidates) {
      final stat = FileStat.statSync(path);
      if (stat.type == FileSystemEntityType.notFound ||
          FileSystemEntity.isLinkSync(path)) {
        continue;
      }
      final isFile = stat.type == FileSystemEntityType.file;
      if (isStaleCopy(cacheDir, path, stat.modified, now, isFile: isFile)) {
        await _delete(path);
      }
    }
  }

  static List<String> _children(String dir) {
    try {
      return [for (final e in Directory(dir).listSync()) e.path];
    } on FileSystemException {
      return const [];
    }
  }

  static Future<void> _delete(String path) async {
    try {
      final type = FileSystemEntity.typeSync(path, followLinks: false);
      if (type == FileSystemEntityType.directory) {
        await Directory(path).delete(recursive: true);
      } else if (type != FileSystemEntityType.notFound) {
        await File(path).delete();
      }
    } on FileSystemException catch (e) {
      Log.warn('files', 'Deleting a temporary copy failed', e.osError);
    }
  }
}

final _uuid = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
);

/// Pure: [path] split into segments below [dir], or null when it is not
/// inside it. `..` steps are resolved first.
List<String>? _below(String dir, String path) {
  final root = p.normalize(dir);
  final normal = p.normalize(path);
  if (!p.isAbsolute(normal) || !p.isWithin(root, normal)) return null;
  return p.split(p.relative(normal, from: root));
}

/// Pure: whether the shared file at [path] is a copy the share plugin made:
/// a file directly in [cacheDir]. Both must have links and `..` resolved.
/// Anything else may be another of the app's own files, which a share must
/// never send or delete.
bool isPluginCopy(String cacheDir, String path) {
  final parts = _below(cacheDir, path);
  return parts != null && parts.length == 1;
}

/// Pure: what to delete for the picker copy at [path] (its own folder, or
/// the loose file for a camera shot or resized picture), or null when
/// [path] is not one.
String? pickerCopyOf(String cacheDir, String path) {
  final parts = _below(cacheDir, path);
  if (parts == null) return null;
  final root = p.normalize(cacheDir);
  return switch (parts) {
    ['file_picker', final stamp, _, ...] => p.join(root, 'file_picker', stamp),
    [final folder, _] when _uuid.hasMatch(folder) => p.join(root, folder),
    [final file] => p.join(root, file),
    _ => null,
  };
}

/// Pure: whether the start-up sweep deletes [path], last changed at
/// [modified]: a temporary copy older than [LocalCopies.maxAge]. Loose
/// files in the cache folder are all copies (shares, camera shots, resized
/// pictures); folders there are caches unless image_picker named them.
bool isStaleCopy(
  String cacheDir,
  String path,
  DateTime modified,
  DateTime now, {
  required bool isFile,
}) {
  if (now.difference(modified) <= LocalCopies.maxAge) return false;
  final parts = _below(cacheDir, path);
  if (parts == null) return false;
  return switch (parts) {
    ['file_picker', _] || [LocalCopies.handoffFolder, _] => true,
    [LocalCopies.serverCachesFolder, _, LocalCopies.handoffFolder, _] => true,
    [final name] => isFile || _uuid.hasMatch(name),
    _ => false,
  };
}
