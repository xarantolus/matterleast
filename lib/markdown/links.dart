import 'package:freezed_annotation/freezed_annotation.dart';

part 'links.freezed.dart';

/// Where tapping a link goes.
@freezed
sealed class LinkTarget with _$LinkTarget {
  /// Opens in the browser or the app for the scheme.
  const factory LinkTarget.external(Uri uri) = ExternalLink;

  /// A message on this server: `/<team>/pl/<post id>`.
  const factory LinkTarget.permalink(String team, String postId) =
      PermalinkLink;

  /// A channel on this server: `/<team>/channels/<name>`.
  const factory LinkTarget.channel(String team, String name) = ChannelLink;

  /// Nothing to open (an unknown scheme or a malformed address).
  const factory LinkTarget.none() = NoLink;
}

const _schemes = {'http', 'https', 'mailto', 'tel', 'ftp'};
final _postId = RegExp(r'^[a-z0-9]{26}$');
final _scheme = RegExp(r'^[a-z][a-z0-9+.\-]*:', caseSensitive: false);

/// Pure: what [url] from a message on [server] points at. Relative links
/// resolve against the server; links into the server's own web app stay in
/// the app.
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
  if (uri.host.toLowerCase() == server.host.toLowerCase() &&
      uri.port == server.port &&
      uri.path.startsWith(server.path)) {
    final rest = uri.path.substring(server.path.length);
    final parts = [
      for (final p in rest.split('/'))
        if (p.isNotEmpty) p,
    ];
    if (parts.length == 3 && parts[1] == 'pl' && _postId.hasMatch(parts[2])) {
      return LinkTarget.permalink(parts[0], parts[2]);
    }
    if (parts.length == 3 && parts[1] == 'channels') {
      return LinkTarget.channel(parts[0], parts[2]);
    }
  }
  return LinkTarget.external(uri);
}
