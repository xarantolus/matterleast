import 'package:connectivity_plus/connectivity_plus.dart';

/// One file in an image cache, as eviction sees it.
typedef CachedImage = ({int id, int bytes, DateTime lastUsed});

/// Pure: the ids to delete from a cache. Anything not used for [maxIdle]
/// goes; past [budgetBytes], the least recently used go first until the
/// rest fits.
Set<int> imagesToEvict(
  Iterable<CachedImage> images, {
  required DateTime now,
  required Duration maxIdle,
  int? budgetBytes,
}) {
  final newestFirst = images.toList()
    ..sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
  final evict = <int>{};
  var kept = 0;
  for (final image in newestFirst) {
    if (now.difference(image.lastUsed) > maxIdle) {
      evict.add(image.id);
      continue;
    }
    kept += image.bytes;
    if (budgetBytes != null && kept > budgetBytes) evict.add(image.id);
  }
  return evict;
}

/// The segments after `api/v4/` when [url] points at [server]'s API, which
/// may live below a sub-path.
List<String>? apiSegments(Uri url, Uri server) {
  if (url.origin != server.origin) return null;
  final base = server.pathSegments.where((s) => s.isNotEmpty).toList();
  final path = url.pathSegments;
  if (path.length < base.length + 2) return null;
  for (final (i, segment) in base.indexed) {
    if (path[i] != segment) return null;
  }
  final rest = path.sublist(base.length);
  return rest[0] == 'api' && rest[1] == 'v4' ? rest.sublist(2) : null;
}

/// Pure: whether the bytes behind [url] never change. File and emoji ids
/// are immutable; avatars and team icons carry their update time.
bool isImmutableImage(Uri url, Uri server) {
  final api = apiSegments(url, server);
  if (api == null) return false;
  final versioned = url.queryParameters['_']?.isNotEmpty ?? false;
  return switch (api) {
    ['files', _] || ['files', _, 'preview' || 'thumbnail'] => true,
    ['emoji', _, 'image'] => true,
    ['users' || 'teams', _, 'image'] => versioned,
    _ => false,
  };
}

/// Pure: until when a downloaded image counts as fresh. Immutable images
/// stay fresh whatever the server's short `max-age` says; eviction by last
/// use removes them in the end.
DateTime imageValidUntil(
  Uri url,
  Uri server, {
  required DateTime now,
  String? cacheControl,
}) {
  if (isImmutableImage(url, server)) return now.add(const Duration(days: 365));
  var age = const Duration(days: 7);
  for (final part in (cacheControl ?? '').split(',')) {
    final setting = part.trim().toLowerCase();
    if (setting == 'no-cache' || setting == 'no-store') return now;
    if (setting.startsWith('max-age=')) {
      final seconds = int.tryParse(setting.substring(8)) ?? 0;
      if (seconds > 0) age = Duration(seconds: seconds);
    }
  }
  return now.add(age);
}

/// [path] (such as `api/v4/users/x/image`) under [server], which may live
/// below a sub-path.
Uri serverUri(Uri server, String path, [Map<String, String>? query]) {
  final base = server.path.endsWith('/')
      ? server.path.substring(0, server.path.length - 1)
      : server.path;
  return server.replace(
    path: '$base/$path',
    queryParameters: (query == null || query.isEmpty) ? null : query,
  );
}

/// Pure: where to fetch [image] from. Server-relative paths resolve
/// against [server]. Other hosts go through the server's image proxy when
/// it has one, so they don't learn the reader's address.
Uri imageRequestUri(Uri image, Uri server, {required bool proxy}) {
  final resolved = image.hasScheme
      ? image
      : serverUri(
          server,
          image.path.startsWith('/') ? image.path.substring(1) : image.path,
          image.hasQuery ? image.queryParameters : null,
        );
  if (resolved.origin == server.origin || !proxy) return resolved;
  return serverUri(server, 'api/v4/image', {'url': resolved.toString()});
}

/// Pure: whether the client config says the server proxies images.
bool hasImageProxy(Map<String, Object?> clientConfig) {
  final type = clientConfig['ImageProxyType'];
  return clientConfig['HasImageProxy'] == 'true' ||
      (type is String && type.isNotEmpty);
}

/// Pure: whether the connection is likely billed by volume. Mobile data
/// without Wi-Fi or Ethernet counts; Android's Data Saver can't be seen
/// through connectivity_plus.
bool isMetered(List<ConnectivityResult> connection) =>
    connection.contains(ConnectivityResult.mobile) &&
    !connection.contains(ConnectivityResult.wifi) &&
    !connection.contains(ConnectivityResult.ethernet);

/// Pure: whether images load without a tap.
bool loadsImagesAutomatically({
  required bool onMobileData,
  required List<ConnectivityResult> connection,
}) => onMobileData || !isMetered(connection);
