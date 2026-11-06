import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/servers/server_probe.dart';
import 'package:matterleast/data/servers/sign_in.dart';
import 'package:matterleast/domain/login_options.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/domain/sso_callback.dart';

import '../support/fake_server.dart';

const gitlab = SsoButton(provider: SsoProvider.gitlab, label: 'GitLab');

void main() {
  late FakeServer server;
  late ProbedServer probed;

  setUp(() async {
    server = await FakeServer.start();
    server.handle = mattermostProbe;
    probed = await ServerProbe().probe('${server.url}');
    server.seen.clear();
  });
  tearDown(() => server.close());

  Reply me(SeenRequest r) => r.header('authorization') == 'Bearer s3ss10n'
      ? ok(fixtureMap('me'))
      : error(401, 'api.context.session_expired.app_error');

  test('password login reads the session from the Token header', () async {
    server.handle = (r) => switch (r.path) {
      '/api/v4/users/login' => ok(
        fixtureMap('me'),
        headers: {'Token': 's3ss10n'},
      ),
      '/api/v4/users/me' => me(r),
      _ => error(404, 'not_found'),
    };
    final signedIn = await SignIn().withPassword(
      probed,
      loginId: ' Alice ',
      password: 'pw',
    );
    expect(signedIn.token, 's3ss10n');
    expect(signedIn.me.username, fixtureMap('me')['username']);
    final login = server.seen.first;
    expect(login.body, {'login_id': 'alice', 'password': 'pw'});
    expect(login.header('x-requested-with'), 'XMLHttpRequest');
    expect(login.header('authorization'), isNull);
  });

  test('asks for the MFA code, then signs in with it', () async {
    server.handle = (r) => switch (r.path) {
      '/api/v4/users/login' when r.body['token'] == '123456' => ok(
        fixtureMap('me'),
        headers: {'Token': 's3ss10n'},
      ),
      '/api/v4/users/login' when r.body['token'] == null => error(
        401,
        'mfa.validate_token.authenticate.app_error',
      ),
      '/api/v4/users/login' => error(
        401,
        'mfa.validate_token.authenticate.app_error',
      ),
      '/api/v4/users/me' => me(r),
      _ => error(404, 'not_found'),
    };
    final signIn = SignIn();
    await expectLater(
      signIn.withPassword(probed, loginId: 'alice', password: 'pw'),
      throwsA(isA<MfaCodeNeeded>()),
    );
    await expectLater(
      signIn.withPassword(
        probed,
        loginId: 'alice',
        password: 'pw',
        mfaCode: '000000',
      ),
      throwsA(
        isA<LoginRejected>().having((e) => e.mfaCodeWrong, 'code wrong', true),
      ),
    );
    final signedIn = await signIn.withPassword(
      probed,
      loginId: 'alice',
      password: 'pw',
      mfaCode: ' 123456 ',
    );
    expect(signedIn.token, 's3ss10n');
  });

  test('wrong credentials say so in words', () async {
    server.handle = (r) =>
        error(401, 'api.user.login.invalid_credentials_email_username');
    await expectLater(
      SignIn().withPassword(probed, loginId: 'alice', password: 'nope'),
      throwsA(
        isA<LoginRejected>().having(
          (e) => e.message,
          'message',
          wrongCredentialsText,
        ),
      ),
    );
  });

  test('enforced MFA that is not set up is explained', () async {
    server.handle = (r) => switch (r.path) {
      '/api/v4/users/login' => ok(
        fixtureMap('me'),
        headers: {'Token': 's3ss10n'},
      ),
      _ => error(403, 'api.context.mfa_required.app_error'),
    };
    await expectLater(
      SignIn().withPassword(probed, loginId: 'alice', password: 'pw'),
      throwsA(
        isA<LoginRejected>().having(
          (e) => e.message,
          'message',
          mfaSetupNeededText,
        ),
      ),
    );
  });

  test('SSO takes the token from a callback for this server', () async {
    server.handle = me;
    Uri? opened;
    final signIn = SignIn(
      openAuthSession: (url, scheme) async {
        opened = url;
        return Uri.parse(
          '$scheme://callback?MMAUTHTOKEN=s3ss10n&MMCSRF=x'
          '&srv=${Uri.encodeComponent(server.url.toString())}',
        );
      },
    );
    final signedIn = await signIn.withSso(probed, gitlab);
    expect(signedIn!.token, 's3ss10n');
    expect(opened!.path, '/oauth/gitlab/mobile_login');
    expect(opened!.queryParameters['redirect_to'], 'mmauth://callback');
    expect(server.paths, ['/api/v4/users/me']);
  });

  test(
    'SSO sends a challenge and redeems the code the server answers',
    () async {
      server.handle = (r) => switch (r.path) {
        '/api/v4/users/login/sso/code-exchange' => ok({
          'token': 's3ss10n',
          'csrf': 'x',
        }),
        '/api/v4/users/me' => me(r),
        _ => error(404, 'not_found'),
      };
      Uri? opened;
      final signIn = SignIn(
        openAuthSession: (url, scheme) async {
          opened = url;
          return Uri.parse(
            '$scheme://callback?login_code=one-time'
            '&srv=${Uri.encodeComponent(server.url.toString())}',
          );
        },
      );

      final signedIn = await signIn.withSso(probed, gitlab);

      expect(signedIn!.token, 's3ss10n');
      final exchange = server.seen.first;
      expect(exchange.path, '/api/v4/users/login/sso/code-exchange');
      expect(exchange.body['login_code'], 'one-time');
      expect(exchange.body['state'], opened!.queryParameters['state']);
      // The verifier proves the code is ours: it hashes to the challenge sent.
      expect(
        s256Challenge(exchange.body['code_verifier']! as String),
        opened!.queryParameters['code_challenge'],
      );
      expect(exchange.header('authorization'), isNull);
    },
  );

  test('a refused code exchange says what the server said', () async {
    server.handle = (r) => (
      status: 410,
      json: {'id': 'x', 'message': 'The code exchange is switched off.'},
      headers: const <String, String>{},
    );
    final signIn = SignIn(
      openAuthSession: (url, scheme) async => Uri.parse(
        '$scheme://callback?login_code=one-time'
        '&srv=${Uri.encodeComponent(server.url.toString())}',
      ),
    );
    await expectLater(
      signIn.withSso(probed, gitlab),
      throwsA(
        isA<LoginRejected>().having(
          (e) => e.message,
          'message',
          contains('switched off'),
        ),
      ),
    );
  });

  test('SSO refuses a callback naming another server', () async {
    final signIn = SignIn(
      openAuthSession: (url, scheme) async => Uri.parse(
        '$scheme://callback?MMAUTHTOKEN=planted&srv=https://evil.example.test',
      ),
    );
    await expectLater(
      signIn.withSso(probed, gitlab),
      throwsA(isA<LoginRejected>()),
    );
    expect(server.seen, isEmpty);
  });

  test('closing the SSO page is not an error', () async {
    final signIn = SignIn(
      openAuthSession: (url, scheme) async =>
          throw PlatformException(code: 'CANCELED'),
    );
    expect(await signIn.withSso(probed, gitlab), isNull);
  });

  test(
    'a server asking for the full browser gets it, others the tab',
    () async {
      server.handle = me;
      final opened = <String>[];
      Future<Uri> opener(String name, Uri url, String scheme) async {
        opened.add(name);
        return Uri.parse(
          '$scheme://callback?MMAUTHTOKEN=s3ss10n&MMCSRF=x'
          '&srv=${Uri.encodeComponent(server.url.toString())}',
        );
      }

      final signIn = SignIn(
        openAuthSession: (url, scheme) => opener('tab', url, scheme),
        openExternalAuthSession: (url, scheme) =>
            opener('browser', url, scheme),
      );
      final external = ProbedServer(
        url: probed.url,
        options: probed.options.copyWith(externalBrowserForSso: true),
        config: probed.config,
        license: probed.license,
      );
      await signIn.withSso(probed, gitlab);
      await signIn.withSso(external, gitlab);
      expect(opened, ['tab', 'browser']);
    },
  );

  test('the sign-in is saved before the browser opens', () async {
    server.handle = me;
    var savedBeforeOpen = false;
    SsoChallenge? saved;
    final signIn = SignIn(
      openAuthSession: (url, scheme) async {
        savedBeforeOpen = saved?.state == url.queryParameters['state'];
        return Uri.parse(
          '$scheme://callback?MMAUTHTOKEN=s3ss10n&MMCSRF=x'
          '&srv=${Uri.encodeComponent(server.url.toString())}',
        );
      },
    );
    await signIn.withSso(probed, gitlab, onStarted: (c) async => saved = c);
    expect(savedBeforeOpen, isTrue);
  });

  test(
    'a callback after a restart finishes with the saved challenge',
    () async {
      server.handle = (r) => switch (r.path) {
        '/api/v4/users/login/sso/code-exchange' => ok({'token': 's3ss10n'}),
        '/api/v4/users/me' => me(r),
        _ => error(404, 'not_found'),
      };
      final challenge = SsoChallenge.generate();
      final signedIn = await SignIn().finishSso(
        probed,
        'mmauth',
        challenge,
        Uri.parse(
          'mmauth://callback?login_code=one-time'
          '&srv=${Uri.encodeComponent(server.url.toString())}',
        ),
      );
      expect(signedIn.token, 's3ss10n');
      final exchange = server.seen.first;
      expect(exchange.body['code_verifier'], challenge.verifier);
      expect(exchange.body['state'], challenge.state);
    },
  );

  test('a magic link signs in with its token', () async {
    server.handle = (r) => switch (r.path) {
      '/api/v4/users/login' => ok(
        fixtureMap('me'),
        headers: {'Token': 's3ss10n'},
      ),
      '/api/v4/users/me' => me(r),
      _ => error(404, 'not_found'),
    };
    final signedIn = await SignIn().withMagicLink(probed, 'a' * 64);
    expect(signedIn.token, 's3ss10n');
    final login = server.seen.first;
    expect(login.body['magic_link_token'], 'a' * 64);
    expect(login.body['password'], isNull);
  });

  test('the login type names what the server did for that login', () async {
    server.handle = (r) => ok({'auth_service': 'magic_link'});
    expect(
      await SignIn().loginType(probed, ' Guest@Example.test '),
      'magic_link',
    );
    expect(server.seen.single.path, '/api/v4/users/login/type');
    expect(server.seen.single.body['login_id'], 'guest@example.test');
    server.handle = (r) => ok({'auth_service': ''});
    expect(await SignIn().loginType(probed, 'alice'), '');
  });
}
