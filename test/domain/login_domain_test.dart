import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/login_options.dart';
import 'package:matterleast/domain/server_url.dart';
import 'package:matterleast/domain/sso_callback.dart';

Map<String, Object?> fixtureMap(String name) =>
    jsonDecode(File('test/fixtures/api/$name.json').readAsStringSync())!
        as Map<String, Object?>;

void main() {
  group('server URL', () {
    test('adds https, lowercases the host and strips slashes', () {
      expect(
        normalizeServerUrl('  Chat.Example.Test/ ').toString(),
        'https://chat.example.test',
      );
    });

    test('keeps an explicit http and a port', () {
      expect(
        normalizeServerUrl('http://10.0.2.2:8065').toString(),
        'http://10.0.2.2:8065',
      );
    });

    test('keeps a sub-path deployment', () {
      expect(
        normalizeServerUrl('https://example.test/mattermost/').toString(),
        'https://example.test/mattermost',
      );
    });

    test('cuts a pasted channel or post link back to the server', () {
      expect(
        normalizeServerUrl('https://example.test/crew/channels/town-square')
            .toString(),
        'https://example.test',
      );
      expect(
        normalizeServerUrl('https://example.test/mm/crew/pl/abc').toString(),
        'https://example.test/mm',
      );
      expect(
        normalizeServerUrl('https://example.test/login').toString(),
        'https://example.test',
      );
    });

    test('rejects nonsense', () {
      expect(normalizeServerUrl(''), isNull);
      expect(normalizeServerUrl('ftp://x.test'), isNull);
      expect(normalizeServerUrl('https://'), isNull);
    });

    test('database file names are stable and distinct per server', () {
      final a = serverDbFileName(Uri.parse('https://a.example.test'));
      expect(a, serverDbFileName(Uri.parse('https://a.example.test')));
      expect(a, isNot(serverDbFileName(Uri.parse('https://b.example.test'))));
      expect(a, matches(RegExp(r'^server-[0-9a-f]{8}-[a-z0-9_]+\.sqlite$')));
    });
  });

  group('login options', () {
    test('the recorded test server offers a password form and MFA', () {
      final options = loginOptionsFrom(
        fixtureMap('client_config'),
        fixtureMap('client_license'),
      );
      expect(options.password, isTrue);
      expect(options.ldap, isFalse);
      expect(options.mfaPossible, isTrue);
      expect(options.serverVersion, isNotEmpty);
      expect(options.diagnosticId, isNotEmpty);
      expect(options.onlySso, isNull);
      expect(options.loginIdLabel, 'Email or username');
      expect(options.forgotPassword, isTrue);
      expect(options.forgotPasswordLink, isNull);
    });

    test('the login field names LDAP and the reset link follows config', () {
      final options = loginOptionsFrom(
        {
          'EnableSignInWithEmail': 'true',
          'EnableLdap': 'true',
          'LdapLoginFieldName': 'Staff ID',
          'ForgotPasswordLink': 'https://help.example.test/reset',
        },
        {'IsLicensed': 'true', 'LDAP': 'true'},
      );
      expect(options.loginIdLabel, 'Email or Staff ID');
      expect(options.forgotPasswordLink, 'https://help.example.test/reset');
      final ldapOnly = loginOptionsFrom(
        {'EnableLdap': 'true', 'PasswordEnableForgotLink': 'true'},
        {'IsLicensed': 'true', 'LDAP': 'true'},
      );
      expect(ldapOnly.loginIdLabel, 'AD/LDAP username');
      expect(ldapOnly.forgotPassword, isFalse);
    });

    test('licensed providers need the licence, GitLab does not', () {
      final config = {
        'EnableSignInWithEmail': 'false',
        'EnableSignInWithUsername': 'false',
        'EnableSaml': 'true',
        'EnableSignUpWithGitLab': 'true',
        'EnableLdap': 'true',
      };
      final unlicensed = loginOptionsFrom(config, {'IsLicensed': 'false'});
      expect(unlicensed.sso.map((s) => s.provider), [SsoProvider.gitlab]);
      expect(unlicensed.onlySso?.provider, SsoProvider.gitlab);
      expect(unlicensed.ldap, isFalse);
      final licensed = loginOptionsFrom(config, {
        'IsLicensed': 'true',
        'SAML': 'true',
        'LDAP': 'true',
      });
      expect(
        licensed.sso.map((s) => s.provider),
        containsAll([SsoProvider.gitlab, SsoProvider.saml]),
      );
      expect(licensed.ldap, isTrue);
      expect(licensed.password, isTrue);
    });

    test('button labels fall back when the server leaves them empty', () {
      final options = loginOptionsFrom({
        'EnableSignUpWithOpenId': 'true',
        'OpenIdButtonText': '',
      }, {});
      expect(options.sso.single.label, 'OpenID Connect');
      expect(options.sso.single.path, '/oauth/openid/mobile_login');
    });

    test('old servers are flagged', () {
      expect(isServerVersionSupported('12.0.1'), isTrue);
      expect(isServerVersionSupported('10.11.25'), isTrue);
      expect(isServerVersionSupported('9.11.0'), isFalse);
      expect(isServerVersionSupported('garbage'), isTrue);
    });
  });

  group('SSO callback', () {
    final server = Uri.parse('http://10.0.2.2:8065');

    test('builds the start URL with the redirect scheme', () {
      final url = ssoStartUrl(
        server: server,
        path: '/oauth/gitlab/mobile_login',
        scheme: 'mmauth',
      );
      expect(url.path, '/oauth/gitlab/mobile_login');
      expect(url.queryParameters['redirect_to'], 'mmauth://callback');
      final saml = ssoStartUrl(
        server: Uri.parse('https://example.test/mm'),
        path: '/login/sso/saml',
        scheme: 'mmauth',
      );
      expect(saml.path, '/mm/login/sso/saml');
      expect(saml.queryParameters['action'], 'mobile');
    });

    test('accepts the server\'s own callback', () {
      final result = parseSsoCallback(
        Uri.parse(
          'mmauth://callback?MMAUTHTOKEN=abc&MMCSRF=x&srv=http%3A%2F%2F10.0.2.2%3A8065',
        ),
        server: server,
      );
      expect(result, const SsoResult.token('abc'));
    });

    test('accepts a missing srv (older servers) and an http site URL', () {
      expect(
        parseSsoCallback(
          Uri.parse('mmauth://callback?MMAUTHTOKEN=abc'),
          server: server,
        ),
        const SsoResult.token('abc'),
      );
      expect(
        parseSsoCallback(
          Uri.parse('mmauth://callback?MMAUTHTOKEN=abc&srv='),
          server: server,
        ),
        const SsoResult.token('abc'),
      );
      expect(
        parseSsoCallback(
          Uri.parse(
            'mmauth://callback?MMAUTHTOKEN=abc&srv=http%3A%2F%2Fchat.example.test%2F',
          ),
          server: Uri.parse('https://chat.example.test'),
        ),
        const SsoResult.token('abc'),
      );
    });

    test('rejects another server and a missing token', () {
      expect(
        parseSsoCallback(
          Uri.parse('mmauth://callback?MMAUTHTOKEN=abc&srv=https://evil.test'),
          server: server,
        ),
        isA<SsoRejected>(),
      );
      expect(
        parseSsoCallback(
          Uri.parse(
            'mmauth://callback?MMAUTHTOKEN=abc&srv=http://10.0.2.2:8066',
          ),
          server: server,
        ),
        isA<SsoRejected>(),
      );
      expect(
        parseSsoCallback(
          Uri.parse('mmauth://callback?srv=http://10.0.2.2:8065'),
          server: server,
        ),
        isA<SsoRejected>(),
      );
    });
  });
}
