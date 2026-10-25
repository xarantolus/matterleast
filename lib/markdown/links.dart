import 'package:freezed_annotation/freezed_annotation.dart';

part 'links.freezed.dart';

/// Where tapping a link goes.
@freezed
sealed class LinkTarget with _$LinkTarget {
  /// Opens in the app when it points into a known server, else in the
  /// browser or the app for the scheme.
  const factory LinkTarget.uri(Uri uri) = UriLink;

  /// Nothing to open (an unknown scheme or a malformed address).
  const factory LinkTarget.none() = NoLink;
}

const _schemes = {'http', 'https', 'mailto', 'tel', 'ftp'};
final _scheme = RegExp(r'^[a-z][a-z0-9+.\-]*:', caseSensitive: false);

/// Pure: what [url] from a message on [server] points at. Relative links
/// resolve against the server. Whether a link opens in the app is decided
/// by `parseServerLink` when it is tapped.
LinkTarget classifyLink(String url, Uri server) {
  final trimmed = url.trim();
  Uri? uri;
  if (trimmed.startsWith('/')) {
    uri = Uri.tryParse(server.resolve(trimmed).toString());
  } else if (_scheme.hasMatch(trimmed)) {
    uri = Uri.tryParse(trimmed);
  } else {
    uri = Uri.tryParse('http://$trimmed');
  }
  if (uri == null || !_schemes.contains(uri.scheme.toLowerCase())) {
    return const LinkTarget.none();
  }
  return LinkTarget.uri(uri);
}
