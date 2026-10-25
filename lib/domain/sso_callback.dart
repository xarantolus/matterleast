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
/// The `srv` parameter must name the server the login started for, so a
/// redirect planted by another site cannot hand us its token.
SsoResult parseSsoCallback(Uri callback, {required Uri server}) {
  final srv = callback.queryParameters['srv'];
  if (srv == null || srv.isEmpty) {
    return const SsoResult.rejected('The server did not say who it is.');
  }
  final claimed = Uri.tryParse(srv);
  if (claimed == null || !_sameServer(claimed, server)) {
    return const SsoResult.rejected('The redirect came from another server.');
  }
  final token = callback.queryParameters['MMAUTHTOKEN'];
  if (token == null || token.isEmpty) {
    return const SsoResult.rejected('The server sent no session.');
  }
  return SsoResult.token(token);
}

bool _sameServer(Uri a, Uri b) =>
    a.scheme.toLowerCase() == b.scheme.toLowerCase() &&
    a.host.toLowerCase() == b.host.toLowerCase() &&
    a.port == b.port &&
    _trimSlash(a.path) == _trimSlash(b.path);

String _trimSlash(String path) =>
    path.endsWith('/') ? path.substring(0, path.length - 1) : path;
