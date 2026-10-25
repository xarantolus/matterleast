import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:matterleast/data/images/server_image_caches.dart';
import 'package:path/path.dart' as p;

/// The kinds of downloads kept on the device, each with its own cache.
enum CacheKind {
  identity('Profile pictures and emoji'),
  media('Images in messages'),
  files('Opened files');

  const CacheKind(this.label);
  final String label;

  CacheManager of(ServerImageCaches caches) => switch (this) {
    identity => caches.identity,
    media => caches.media,
    files => caches.files,
  };
}

/// Bytes on disk for one kind of cache of one server.
Future<int> cacheBytes(ServerImageCaches caches, CacheKind kind) async {
  final dir = Directory(p.join(caches.directory, kind.name, 'files'));
  if (!dir.existsSync()) return 0;
  var total = 0;
  await for (final entry in dir.list(recursive: true, followLinks: false)) {
    if (entry is File) total += await entry.length();
  }
  return total;
}
