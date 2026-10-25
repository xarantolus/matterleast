import 'package:freezed_annotation/freezed_annotation.dart';

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

bool _flag(Map<String, Object?> config, String key) =>
    config[key]?.toString() == 'true';

String _text(Map<String, Object?> config, String key, String fallback) {
  final value = config[key]?.toString().trim();
  return value == null || value.isEmpty ? fallback : value;
}

LoginOptions loginOptionsFrom(
  Map<String, Object?> config,
  Map<String, Object?> license,
) {
  final licensed = _flag(license, 'IsLicensed');
  final ldap =
      _flag(config, 'EnableLdap') && licensed && _flag(license, 'LDAP');
  final password =
      _flag(config, 'EnableSignInWithEmail') ||
      _flag(config, 'EnableSignInWithUsername') ||
      ldap;
  final sso = <SsoButton>[
    if (_flag(config, 'EnableSignUpWithGitLab'))
      SsoButton(
        provider: SsoProvider.gitlab,
        label: _text(config, 'GitLabButtonText', 'GitLab'),
      ),
    if (_flag(config, 'EnableSignUpWithGoogle'))
      const SsoButton(provider: SsoProvider.google, label: 'Google'),
    if (_flag(config, 'EnableSignUpWithOffice365'))
      const SsoButton(provider: SsoProvider.office365, label: 'Entra ID'),
    if (_flag(config, 'EnableSignUpWithOpenId'))
      SsoButton(
        provider: SsoProvider.openid,
        label: _text(config, 'OpenIdButtonText', 'OpenID Connect'),
      ),
    if (_flag(config, 'EnableSaml') && licensed && _flag(license, 'SAML'))
      SsoButton(
        provider: SsoProvider.saml,
        label: _text(config, 'SamlLoginButtonText', 'SAML'),
      ),
  ];
  return LoginOptions(
    password: password,
    ldap: ldap,
    ldapFieldLabel: _text(config, 'LdapLoginFieldName', 'AD/LDAP username'),
    sso: sso,
    mfaPossible: _flag(config, 'EnableMultifactorAuthentication'),
    mfaEnforced: _flag(config, 'EnforceMultifactorAuthentication'),
    siteName: _text(config, 'SiteName', 'Mattermost'),
    serverVersion: _text(config, 'Version', ''),
    diagnosticId: _text(config, 'DiagnosticId', ''),
    externalBrowserForSso: _flag(config, 'MobileExternalBrowser'),
  );
}

/// Oldest server we claim to work with; older ones get a warning, not a block.
const minimumServerVersion = (10, 11);

bool isServerVersionSupported(String version) {
  final parts = version.split('.').map(int.tryParse).toList();
  if (parts.length < 2 || parts[0] == null || parts[1] == null) return true;
  final (major, minor) = minimumServerVersion;
  return parts[0]! > major || (parts[0] == major && parts[1]! >= minor);
}
