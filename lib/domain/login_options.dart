import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matterleast/api/json/client_config.dart';
import 'package:matterleast/domain/server_features.dart';
import 'package:matterleast/markdown/links.dart';

part 'login_options.freezed.dart';

enum SsoProvider { gitlab, google, office365, openid, saml }

/// Which sign-in methods a server offers, read from the client config
/// (`GET /config/client?format=old`) and client licence.
@freezed
abstract class LoginOptions with _$LoginOptions {
  const factory LoginOptions({
    required bool password,
    required bool ldap,
    required String ldapFieldLabel,

    /// "Email or username", with the LDAP field name when LDAP is on.
    required String loginIdLabel,

    /// Whether to offer a password reset, and the admin's own reset page if
    /// one is configured (else the server's web page).
    required bool forgotPassword,
    required String? forgotPasswordLink,
    required List<SsoButton> sso,
    required bool mfaPossible,
    required bool mfaEnforced,
    required String siteName,
    required String serverVersion,
    required String diagnosticId,
    required bool externalBrowserForSso,
  }) = _LoginOptions;

  const LoginOptions._();

  bool get any => password || ldap || sso.isNotEmpty;

  /// With no form and exactly one provider the app can go straight to it.
  SsoButton? get onlySso =>
      !password && !ldap && sso.length == 1 ? sso.single : null;
}

@freezed
abstract class SsoButton with _$SsoButton {
  const factory SsoButton({
    required SsoProvider provider,
    required String label,
  }) = _SsoButton;

  const SsoButton._();

  /// The server's mobile login entry point for this provider.
  String get path => switch (provider) {
    SsoProvider.saml => '/login/sso/saml',
    SsoProvider.gitlab => '/oauth/gitlab/mobile_login',
    SsoProvider.google => '/oauth/google/mobile_login',
    SsoProvider.office365 => '/oauth/office365/mobile_login',
    SsoProvider.openid => '/oauth/openid/mobile_login',
  };
}

String _text(String? value, String fallback) {
  final text = value?.trim();
  return text == null || text.isEmpty ? fallback : text;
}

LoginOptions loginOptionsFrom(ClientConfig config, ClientLicense license) {
  final licensed = license.isLicensed == true;
  final ldap = config.enableLdap == true && licensed && license.ldap == true;
  final email = config.enableSignInWithEmail == true;
  final username = config.enableSignInWithUsername == true;
  final password = email || username || ldap;
  final ldapFieldLabel = _text(config.ldapLoginFieldName, 'AD/LDAP username');
  final forgotLink = _text(config.forgotPasswordLink, '');
  final sso = <SsoButton>[
    if (config.enableSignUpWithGitLab == true)
      SsoButton(
        provider: SsoProvider.gitlab,
        label: _text(config.gitLabButtonText, 'GitLab'),
      ),
    if (config.enableSignUpWithGoogle == true)
      const SsoButton(provider: SsoProvider.google, label: 'Google'),
    if (config.enableSignUpWithOffice365 == true)
      const SsoButton(provider: SsoProvider.office365, label: 'Entra ID'),
    if (config.enableSignUpWithOpenId == true)
      SsoButton(
        provider: SsoProvider.openid,
        label: _text(config.openIdButtonText, 'OpenID Connect'),
      ),
    if (config.enableSaml == true && licensed && license.saml == true)
      SsoButton(
        provider: SsoProvider.saml,
        label: _text(config.samlLoginButtonText, 'SAML'),
      ),
  ];
  return LoginOptions(
    password: password,
    ldap: ldap,
    ldapFieldLabel: ldapFieldLabel,
    loginIdLabel: _joinWithOr([
      if (email) 'email',
      if (username) 'username',
      if (ldap) ldapFieldLabel,
    ]),
    forgotPassword:
        (email || username) && config.passwordEnableForgotLink != false,
    forgotPasswordLink: forgotLink.isEmpty ? null : forgotLink,
    sso: sso,
    mfaPossible: config.enableMultifactorAuthentication == true,
    mfaEnforced: config.enforceMultifactorAuthentication == true,
    siteName: _text(config.siteName, 'Mattermost'),
    serverVersion: _text(config.version, ''),
    diagnosticId: _text(config.diagnosticId, ''),
    externalBrowserForSso: config.mobileExternalBrowser == true,
  );
}

String _joinWithOr(List<String> parts) {
  if (parts.isEmpty) return 'Username';
  final text = parts.length == 1
      ? parts.single
      : '${parts.sublist(0, parts.length - 1).join(', ')} or ${parts.last}';
  return text[0].toUpperCase() + text.substring(1);
}

/// Pure: where "Forgot password?" goes: the configured link when it is one
/// the app may open, else the server's own reset page.
Uri forgotPasswordUri(String? link, Uri server) {
  if (link != null) {
    if (classifyLink(link, server) case UriLink(:final uri)) return uri;
  }
  final base = server.path.endsWith('/')
      ? server.path.substring(0, server.path.length - 1)
      : server.path;
  return server.replace(path: '$base/reset_password');
}

/// Oldest server we claim to work with; older ones get a warning, not a block.
const minimumServerVersion = (10, 11);

bool isServerVersionSupported(String version) =>
    isVersionAtLeast(version, minimumServerVersion) ?? true;

/// Pure: whether [version] (such as `12.0.1`) is [floor] or newer; null
/// when it can't be read.
bool? isVersionAtLeast(String version, (int, int) floor) {
  final (major, minor) = floor;
  final compared = compareVersions(version, (major, minor, 0));
  return compared == null ? null : compared >= 0;
}
