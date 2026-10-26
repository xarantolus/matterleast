import 'package:matterleast/domain/server_features.dart';

/// Which profile fields the user can't change here, because the service
/// they sign in with keeps them; [source] names that service for the hint.
typedef ProfileLocks = ({
  bool firstName,
  bool lastName,
  bool nickname,
  bool position,
  bool username,
  bool picture,

  /// The password belongs to the sign-in service, not to this server.
  bool password,
  String source,
});

/// Single sign-on services that keep the user's names.
const _namesFromSso = {'gitlab', 'google', 'office365'};

/// Pure: the locks for a user who signs in with [authService] (empty for a
/// password), given the fields the server fills in from LDAP and SAML.
ProfileLocks profileLocks(
  String authService, {
  required Set<ProfileField> ldap,
  required Set<ProfileField> saml,
}) {
  final directory = switch (authService) {
    'ldap' => ldap,
    'saml' => saml,
    _ => const <ProfileField>{},
  };
  final sso = _namesFromSso.contains(authService);
  return (
    firstName: sso || directory.contains(ProfileField.firstName),
    lastName: sso || directory.contains(ProfileField.lastName),
    nickname: directory.contains(ProfileField.nickname),
    position: directory.contains(ProfileField.position),
    username: authService.isNotEmpty,
    picture: authService == 'ldap' && ldap.contains(ProfileField.picture),
    password: authService.isNotEmpty,
    source: switch (authService) {
      'ldap' => 'LDAP',
      'saml' => 'SAML',
      'gitlab' => 'GitLab',
      'google' => 'Google',
      'office365' => 'Microsoft',
      'openid' => 'OpenID Connect',
      final other => other,
    },
  );
}
