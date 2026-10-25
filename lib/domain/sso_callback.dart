import 'package:freezed_annotation/freezed_annotation.dart';

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

@freezed
sealed class SsoResult with _$SsoResult {
  const factory SsoResult.token(String token) = SsoToken;

  /// The redirect named another server, or carried no token.
  const factory SsoResult.rejected(String reason) = SsoRejected;
}

/// Reads the session token out of `<scheme>://callback?MMAUTHTOKEN=…&srv=…`.
/// Servers from 12.0 name themselves in `srv` (their configured site URL), so
/// a redirect planted by another site cannot hand us its token; older servers
/// send nothing and are accepted like the official app does. The scheme is
/// ignored because the site URL may be configured as http behind a proxy.
SsoResult parseSsoCallback(Uri callback, {required Uri server}) {
  final srv = callback.queryParameters['srv'];
  if (srv != null && srv.isNotEmpty) {
    final claimed = Uri.tryParse(srv);
    if (claimed == null || !_sameServer(claimed, server)) {
      return const SsoResult.rejected('The redirect came from another server.');
    }
  }
  final token = callback.queryParameters['MMAUTHTOKEN'];
  if (token == null || token.isEmpty) {
    return const SsoResult.rejected('The server sent no session.');
  }
  return SsoResult.token(token);
}

bool _sameServer(Uri a, Uri b) =>
    a.host.toLowerCase() == b.host.toLowerCase() &&
    _port(a) == _port(b) &&
    _trimSlash(a.path) == _trimSlash(b.path);

int _port(Uri u) => u.hasPort ? u.port : 443;

String _trimSlash(String path) =>
    path.endsWith('/') ? path.substring(0, path.length - 1) : path;
