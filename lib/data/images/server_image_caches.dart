import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file/file.dart' as f;
import 'package:file/local.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/data/images/image_rules.dart';
import 'package:path/path.dart' as p;

/// The download caches of one server, each in its own directory under
/// [directory]. Identity images (avatars, team icons, custom emoji) have
/// no size cap and go 60 days after they were last shown; media (message
/// and link-preview images) keep within a byte budget, least recently
/// shown first, and go after 30 days; opened files the same with their own
/// budget and 7 days. Opened lazily, so a session that never shows an
/// image never opens the cache databases.
class ServerImageCaches {
  ServerImageCaches({
    required this.directory,
    required this._api,
    required this._mediaBudget,
    required this._filesBudget,
  });

  final String directory;
  final ServerApi _api;
  final Future<int> Function() _mediaBudget;
  final Future<int> Function() _filesBudget;

  static const identityMaxIdle = Duration(days: 60);
  static const mediaMaxIdle = Duration(days: 30);
  static const filesMaxIdle = Duration(days: 7);

  late final CacheManager identity = _manager(
    'identity',
    maxIdle: identityMaxIdle,
    maxBytes: 5 * 1024 * 1024,
  );

  late final CacheManager media = _manager(
    'media',
    maxIdle: mediaMaxIdle,
    maxBytes: 50 * 1024 * 1024,
    budget: _mediaBudget,
  );

  /// Files are written by [FileDownloads], never fetched by the manager.
  late final CacheManager files = _manager(
    'files',
    maxIdle: filesMaxIdle,
    maxBytes: 0,
    budget: _filesBudget,
  );

  final _opened = <CacheManager>[];

  CacheManager _manager(
    String kind, {
    required Duration maxIdle,
    required int maxBytes,
    Future<int> Function()? budget,
  }) {
    final dir = p.join(directory, kind);
    final manager = CacheManager(
      Config(
        dir,
        stalePeriod: maxIdle,
        repo: LastUseRepository(
          CacheObjectProvider(path: p.join(dir, 'index.db')),
          maxIdle: maxIdle,
          budget: budget,
        ),
        fileSystem: DirectoryFileSystem(p.join(dir, 'files')),
        fileService: ServerFileService(_api, maxBytes: maxBytes),
      ),
    );
    _opened.add(manager);
    return manager;
  }

  Future<void> close() async {
    for (final manager in _opened) {
      await manager.dispose();
    }
    _opened.clear();
  }
}

/// Keeps flutter_cache_manager's own index (which stamps an entry's
/// `touched` time whenever it is read from disk), but decides eviction by
/// last use and bytes with [imagesToEvict] instead of its entry count.
class LastUseRepository implements CacheInfoRepository {
  LastUseRepository(
    this._inner, {
    required this.maxIdle,
    this.budget,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final CacheInfoRepository _inner;
  final Duration maxIdle;
  final Future<int> Function()? budget;
  final DateTime Function() _clock;

  /// The cache manager runs its cleanup as the two queries below, one after
  /// the other; both answer from the same decision.
  @override
  Future<List<CacheObject>> getObjectsOverCapacity(int capacity) =>
      _evictable();

  @override
  Future<List<CacheObject>> getOldObjects(Duration maxAge) => _evictable();

  Future<List<CacheObject>> _evictable() async {
    final all = await _inner.getAllObjects();
    final ids = imagesToEvict(
      [
        for (final o in all)
          if (o.id != null)
            (
              id: o.id!,
              bytes: o.length ?? 0,
              lastUsed: o.touched ?? DateTime.fromMillisecondsSinceEpoch(0),
            ),
      ],
      now: _clock(),
      maxIdle: maxIdle,
      budgetBytes: budget == null ? null : await budget!(),
    );
    return [
      for (final o in all)
        if (ids.contains(o.id)) o,
    ];
  }

  @override
  Future<bool> exists() => _inner.exists();

  @override
  Future<bool> open() => _inner.open();

  @override
  Future<Object?> updateOrInsert(CacheObject cacheObject) =>
      _inner.updateOrInsert(cacheObject);

  @override
  Future<CacheObject> insert(
    CacheObject cacheObject, {
    bool setTouchedToNow = true,
  }) => _inner.insert(cacheObject, setTouchedToNow: setTouchedToNow);

  @override
  Future<CacheObject?> get(String key) => _inner.get(key);

  @override
  Future<int> delete(int id) => _inner.delete(id);

  @override
  Future<int> deleteAll(Iterable<int> ids) => _inner.deleteAll(ids);

  @override
  Future<int> update(CacheObject cacheObject, {bool setTouchedToNow = true}) =>
      _inner.update(cacheObject, setTouchedToNow: setTouchedToNow);

  @override
  Future<List<CacheObject>> getAllObjects() => _inner.getAllObjects();

  @override
  Future<bool> close() => _inner.close();

  @override
  Future<void> deleteDataFile() => _inner.deleteDataFile();
}

/// Cache files in a fixed directory, created on first use.
class DirectoryFileSystem implements FileSystem {
  DirectoryFileSystem(this.path);

  final String path;
  static const _fs = LocalFileSystem();

  @override
  Future<f.File> createFile(String name) async {
    final dir = _fs.directory(path);
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir.childFile(name);
  }
}

class ImageTooLargeException implements Exception {
  const ImageTooLargeException();

  @override
  String toString() => 'Image is larger than the limit';
}

/// Downloads images through the server's own HTTP client, so the token
/// goes only to that server's origin, with its timeouts, and stops at
/// [maxBytes]. Redirects are followed only for other hosts, which never
/// get the token.
class ServerFileService extends FileService {
  ServerFileService(
    this._api, {
    required this.maxBytes,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final ServerApi _api;
  final int maxBytes;
  final DateTime Function() _clock;

  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(url);
    final own = uri.origin == _api.baseUrl.origin;
    final cancel = CancelToken();
    final response = await _api.dio.getUri<ResponseBody>(
      uri,
      cancelToken: cancel,
      options: Options(
        responseType: ResponseType.stream,
        followRedirects: !own,
        validateStatus: (_) => true,
        headers: headers,
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    final body = response.data!;
    final length = int.tryParse(
      response.headers.value(HttpHeaders.contentLengthHeader) ?? '',
    );
    if (length != null && length > maxBytes) {
      cancel.cancel();
      throw const ImageTooLargeException();
    }
    return _Response(
      statusCode: response.statusCode ?? 0,
      contentLength: length,
      content: _limited(body.stream, cancel),
      validTill: imageValidUntil(
        uri,
        _api.baseUrl,
        now: _clock(),
        cacheControl: response.headers.value(HttpHeaders.cacheControlHeader),
      ),
      eTag: response.headers.value(HttpHeaders.etagHeader),
      fileExtension: _extension(
        response.headers.value(HttpHeaders.contentTypeHeader),
      ),
    );
  }

  Stream<List<int>> _limited(
    Stream<Uint8List> bytes,
    CancelToken cancel,
  ) async* {
    var total = 0;
    await for (final chunk in bytes) {
      total += chunk.length;
      if (total > maxBytes) {
        cancel.cancel();
        throw const ImageTooLargeException();
      }
      yield chunk;
    }
  }
}

String _extension(String? contentType) {
  final type = contentType?.split(';').first.trim().toLowerCase();
  return switch (type) {
    'image/jpeg' || 'image/jpg' => '.jpg',
    'image/png' => '.png',
    'image/gif' => '.gif',
    'image/webp' => '.webp',
    'image/bmp' => '.bmp',
    'image/heic' => '.heic',
    'image/svg+xml' => '.svg',
    _ => '',
  };
}

class _Response implements FileServiceResponse {
  _Response({
    required this.statusCode,
    required this.contentLength,
    required this.content,
    required this.validTill,
    required this.eTag,
    required this.fileExtension,
  });

  @override
  final int statusCode;
  @override
  final int? contentLength;
  @override
  final Stream<List<int>> content;
  @override
  final DateTime validTill;
  @override
  final String? eTag;
  @override
  final String fileExtension;
}
