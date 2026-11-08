import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:matterleast/api/server_paths.dart';

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

/// Pure: whether [url] is an address an image can be fetched from: http,
/// https or relative to the server. Messages may hold anything.
bool canLoadImage(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  if (!uri.hasScheme) return true;
  return (uri.isScheme('http') || uri.isScheme('https')) && uri.host.isNotEmpty;
}

/// Pure: where to fetch [url] from, or null when it is no image address.
/// Server-relative paths resolve against [server]. Other hosts go through
/// the server's image proxy when it has one, so they don't learn the
/// reader's address.
Uri? imageRequestUri(String url, Uri server, {required bool proxy}) {
  if (!canLoadImage(url)) return null;
  final image = Uri.parse(url);
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

/// What a message can pull over the network that a reader may hold back
/// on mobile data.
enum DataKind { image, gif, linkPicture }

/// Pure: whether [kind] loads without a tap. The phone's [dataSaver] holds
/// everything back: on mobile data, and also on Wi-Fi where it
/// [dataSaverCoversWifi] (iOS Low Data Mode is set per network). Otherwise
/// Wi-Fi and Ethernet always load, and on mobile data the setting for the
/// kind decides.
bool loadsAutomatically(
  DataKind kind, {
  required List<ConnectivityResult> connection,
  required bool dataSaver,
  required bool images,
  required bool gifs,
  required bool linkPictures,
  bool dataSaverCoversWifi = false,
}) {
  final metered = isMetered(connection);
  if (dataSaver && (metered || dataSaverCoversWifi)) return false;
  if (!metered) return true;
  return switch (kind) {
    DataKind.image => images,
    DataKind.gif => gifs,
    DataKind.linkPicture => linkPictures,
  };
}

/// Pure: whether the connection is likely billed by volume. Mobile data
/// without Wi-Fi or Ethernet counts.
bool isMetered(List<ConnectivityResult> connection) =>
    connection.contains(ConnectivityResult.mobile) &&
    !connection.contains(ConnectivityResult.wifi) &&
    !connection.contains(ConnectivityResult.ethernet);
