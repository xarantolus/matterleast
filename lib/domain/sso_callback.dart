import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matterleast/domain/login_options.dart';

part 'sso_callback.freezed.dart';

/// Default redirect scheme accepted by every stock server
/// (`NativeAppSettings.AppCustomURLSchemes`).
const defaultSsoScheme = 'mmauth';

Uri ssoStartUrl({
  required Uri server,
  required String path,
  required String scheme,
}) {
  final isSaml = path.startsWith('/login/sso/saml');
  return server.replace(
    path: '${server.path}$path',
    queryParameters: {
      if (isSaml) 'action': 'mobile',
      'redirect_to': '$scheme://callback',
    },
  );
}

/// Whether [uri] is meant as an SSO redirect (`<scheme>://callback`), which
/// only ever finishes a sign-in in progress and never opens anything.
bool isSsoCallbackLink(Uri uri) =>
    uri.host == 'callback' && uri.scheme != 'https' && uri.scheme != 'http';

/// Whether [uri] is exactly `<scheme>://callback?…`, the only shape a server
/// redirects to, with nothing that a hand-made link could add.
bool isSsoCallbackFor(Uri uri, String scheme) =>
    uri.scheme == scheme.toLowerCase() &&
    uri.host == 'callback' &&
    uri.userInfo.isEmpty &&
    !uri.hasPort &&
    uri.path.isEmpty &&
    uri.query.isNotEmpty &&
    !uri.hasFragment;

@freezed
sealed class SsoResult with _$SsoResult {
  const factory SsoResult.token(String token) = SsoToken;

  /// The redirect named another server, or carried no token.
  const factory SsoResult.rejected(String reason) = SsoRejected;
}

/// Reads the session token out of `<scheme>://callback?MMAUTHTOKEN=…&srv=…`.
/// Servers from 12.0 name themselves in `srv` (their configured site URL), so
/// a redirect planted by another site or app cannot hand us its token; only
/// servers known to be older may leave it out, as the official app accepts.
/// The site URL may differ from the address the user entered (another host
/// name for the same server), so either counts when the server reported it.
/// The scheme is ignored because the site URL may be configured as http
/// behind a proxy.
SsoResult parseSsoCallback(
  Uri callback, {
  required String scheme,
  required Uri server,
  required Uri? siteUrl,
  required String serverVersion,
}) {
  if (!isSsoCallbackFor(callback, scheme)) {
    return const SsoResult.rejected(
      "The sign-in came back in a form the app doesn't expect.",
    );
  }
  final srv = callback.queryParameters['srv'];
  if (srv != null && srv.isNotEmpty) {
    final claimed = Uri.tryParse(srv);
    if (claimed == null || claimed.host.isEmpty) {
      return const SsoResult.rejected(
        'The sign-in came back without a server address the app can read.',
      );
    }
    if (!_sameServer(claimed, server) &&
        (siteUrl == null || !_sameServer(claimed, siteUrl))) {
      return SsoResult.rejected(
        'The sign-in came back from ${_hostOf(claimed)}, but this server is '
        '${_hostOf(server)}.',
      );
    }
  } else if (isVersionAtLeast(serverVersion, (12, 0)) != false) {
    return const SsoResult.rejected(
      "The redirect didn't say which server it came from.",
    );
  }
  final token = callback.queryParameters['MMAUTHTOKEN'];
  if (token == null || token.isEmpty) {
    return const SsoResult.rejected('The server sent no session.');
  }
  return SsoResult.token(token);
}

String _hostOf(Uri u) {
  final host = u.host.toLowerCase();
  return u.hasPort ? '$host:${u.port}' : host;
}

bool _sameServer(Uri a, Uri b) =>
    a.host.toLowerCase() == b.host.toLowerCase() &&
    _port(a) == _port(b) &&
    _trimSlash(a.path) == _trimSlash(b.path);

// http and https count alike, so a missing port means the https default.
int _port(Uri u) => u.hasPort ? u.port : 443;

String _trimSlash(String path) =>
    path.endsWith('/') ? path.substring(0, path.length - 1) : path;
