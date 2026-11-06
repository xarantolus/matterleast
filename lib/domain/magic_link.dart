import 'package:freezed_annotation/freezed_annotation.dart';

part 'magic_link.freezed.dart';

/// The link the server emails a guest to sign in with:
/// `<server>/login/one_time_link?t=<token>`.
@freezed
abstract class MagicLink with _$MagicLink {
  const factory MagicLink({required Uri server, required String token}) =
      _MagicLink;
}

final _token = RegExp(r'^[a-z0-9]{64}$');

/// Pure: the sign-in link in [uri], or null for anything else. Besides web
/// links, `matterleast://<host>[:port]/<path>` stands for the same path on a
/// server at that host over https, as for other links into a server.
MagicLink? parseMagicLink(Uri uri) {
  final web = uri.scheme == 'https' || uri.scheme == 'http';
  if ((!web && uri.scheme != 'matterleast') || uri.host.isEmpty) return null;
  final path = [
    for (final s in uri.pathSegments)
      if (s.isNotEmpty) s,
  ];
  if (path.length < 2 ||
      path[path.length - 2] != 'login' ||
      path.last != 'one_time_link') {
    return null;
  }
  final token = uri.queryParameters['t'];
  if (token == null || !_token.hasMatch(token)) return null;
  final prefix = path.sublist(0, path.length - 2);
  return MagicLink(
    server: Uri(
      scheme: web ? uri.scheme : 'https',
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
      pathSegments: prefix,
    ),
    token: token,
  );
}
