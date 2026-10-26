import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/data/images/image_rules.dart';
import 'package:matterleast/domain/post_files.dart';
import 'package:path/path.dart' as p;

class FileTooLargeException implements Exception {
  const FileTooLargeException(this.limit);

  final int limit;

  @override
  String toString() => 'File is larger than ${formatBytes(limit)}';
}

/// Downloads message files into the server's files cache, one request per
/// file at a time, within the server's file size limit.
class FileDownloads {
  FileDownloads({
    required this._api,
    required this._cache,
    required this._partialDirectory,
    required this.handoffDirectory,
    required this._maxBytes,
  });

  final ServerApi _api;
  final CacheManager _cache;
  final String _partialDirectory;

  /// Where named copies for other apps go; signing out deletes it with the
  /// rest of the server's caches.
  final String handoffDirectory;
  final Future<int?> Function() _maxBytes;

  final _running = <String, Future<File>>{};

  /// Where the file's bytes come from. File ids never change, so this is
  /// also its cache key.
  Uri originalUri(String fileId) =>
      serverUri(_api.baseUrl, 'api/v4/files/$fileId');

  Uri previewUri(String fileId) =>
      serverUri(_api.baseUrl, 'api/v4/files/$fileId/preview');

  /// The file when it was downloaded before.
  Future<File?> cached(String fileId) async =>
      (await _cache.getFileFromCache(originalUri(fileId).toString()))?.file;

  /// The file, from the cache or downloaded now. [onProgress] gets the
  /// share received, null while the size is unknown. A second call for the
  /// same file while one runs joins it.
  Future<File> fetch(
    PostFile file, {
    void Function(double? progress)? onProgress,
    CancelToken? cancel,
  }) async {
    final hit = await cached(file.id);
    if (hit != null) return hit;
    final running = _running[file.id];
    if (running != null) return running;
    final download = _running[file.id] = _download(file, onProgress, cancel);
    try {
      return await download;
    } finally {
      _running.remove(file.id)?.ignore();
    }
  }

  Future<File> _download(
    PostFile file,
    void Function(double? progress)? onProgress,
    CancelToken? cancel,
  ) async {
    final limit = await _maxBytes();
    if (limit != null && file.size > limit) throw FileTooLargeException(limit);
    final url = originalUri(file.id);
    final partial = File(p.join(_partialDirectory, file.id));
    await partial.parent.create(recursive: true);
    final token = cancel ?? CancelToken();
    var tooLarge = false;
    try {
      await _api.call(
        () => _api.dio.downloadUri(
          url,
          partial.path,
          cancelToken: token,
          options: Options(receiveTimeout: const Duration(seconds: 30)),
          onReceiveProgress: (received, total) {
            if (limit != null && received > limit && !tooLarge) {
              tooLarge = true;
              token.cancel();
              return;
            }
            onProgress?.call(total > 0 ? received / total : null);
          },
        ),
        deadline: ServerApi.transferDeadline,
      );
      if (limit != null && await partial.length() > limit) tooLarge = true;
      if (tooLarge) throw FileTooLargeException(limit!);
      final stored = await _cache.putFileStream(
        url.toString(),
        partial.openRead(),
        maxAge: const Duration(days: 365),
        fileExtension: file.extension.isEmpty ? 'bin' : file.extension,
      );
      return File(stored.path);
    } on Cancelled {
      if (tooLarge) throw FileTooLargeException(limit!);
      rethrow;
    } finally {
      if (partial.existsSync()) await partial.delete();
    }
  }
}

/// Pure: the server's upload limit from its client config, which downloads
/// honour too.
int? maxFileSize(Map<String, Object?> clientConfig) {
  final value = int.tryParse('${clientConfig['MaxFileSize'] ?? ''}');
  return value == null || value <= 0 ? null : value;
}
