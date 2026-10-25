import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_link.freezed.dart';

/// A link into the web app of a server the app knows, opened in the app
/// instead of the browser.
@freezed
sealed class ServerLink with _$ServerLink {
  /// `/<team>/pl/<post id>`, or a thread's `/<team>/threads/<post id>`.
  const factory ServerLink.post({
    required Uri server,
    required String team,
    required String postId,
  }) = PostLink;

  /// `/<team>/channels/<name>`, or a group message's
  /// `/<team>/messages/<name>`.
  const factory ServerLink.channel({
    required Uri server,
    required String team,
    required String name,
  }) = ChannelNameLink;

  /// `/<team>/messages/@<username>`.
  const factory ServerLink.directMessage({
    required Uri server,
    required String team,
    required String username,
  }) = DirectMessageLink;

  /// The server itself, or one of its teams.
  const factory ServerLink.home({required Uri server, String? team}) =
      ServerHomeLink;
}

final _postId = RegExp(r'^[a-z0-9]{26}$');

/// Pure: what a link handed to the app from outside opens. Besides web
/// links, `matterleast://<host>[:port]/<path>` stands for the same path on
/// a server at that host, over https or http. Null for anything that is not
/// on one of [knownServers].
ServerLink? parseIncomingLink(Uri uri, Iterable<Uri> knownServers) {
  if (uri.scheme != 'matterleast') return parseServerLink(uri, knownServers);
  if (uri.host.isEmpty || uri.host == 'callback') return null;
  for (final scheme in const ['https', 'http']) {
    final link = parseServerLink(uri.replace(scheme: scheme), knownServers);
    if (link != null) return link;
  }
  return null;
}

/// Pure: what [uri] opens when it points into one of [knownServers]; null
/// for anything else, which belongs in the browser. A server below a
/// sub-path wins over one at the root of the same host.
ServerLink? parseServerLink(Uri uri, Iterable<Uri> knownServers) {
  if (uri.scheme != 'http' && uri.scheme != 'https') return null;
  final path = _segments(uri);
  Uri? server;
  var base = 0;
  for (final candidate in knownServers) {
    if (candidate.host.toLowerCase() != uri.host.toLowerCase() ||
        candidate.port != uri.port) {
      continue;
    }
    final prefix = _segments(candidate);
    if (prefix.length > path.length ||
        (server != null && prefix.length <= base)) {
      continue;
    }
    if (!_startsWith(path, prefix)) continue;
    server = candidate;
    base = prefix.length;
  }
  if (server == null) return null;
  final rest = path.sublist(base);
  return switch (rest) {
    [] => ServerLink.home(server: server),
    [final team] => ServerLink.home(server: server, team: team),
    [final team, 'pl' || 'threads', final id] when _postId.hasMatch(id) =>
      ServerLink.post(server: server, team: team, postId: id),
    [final team, 'channels', final name] => ServerLink.channel(
      server: server,
      team: team,
      name: name.toLowerCase(),
    ),
    [final team, 'messages', final name] when name.startsWith('@') =>
      name.length > 1
          ? ServerLink.directMessage(
              server: server,
              team: team,
              username: name.substring(1).toLowerCase(),
            )
          : null,
    [final team, 'messages', final name] => ServerLink.channel(
      server: server,
      team: team,
      name: name.toLowerCase(),
    ),
    _ => null,
  };
}

List<String> _segments(Uri uri) => [
  for (final s in uri.pathSegments)
    if (s.isNotEmpty) s,
];

bool _startsWith(List<String> path, List<String> prefix) {
  for (var i = 0; i < prefix.length; i++) {
    if (path[i] != prefix[i]) return false;
  }
  return true;
}
