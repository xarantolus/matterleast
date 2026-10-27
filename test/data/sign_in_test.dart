import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/servers/server_probe.dart';
import 'package:matterleast/data/servers/sign_in.dart';
import 'package:matterleast/domain/login_options.dart';
import 'package:matterleast/domain/sign_in_problems.dart';

import '../support/fake_server.dart';

const gitlab = SsoButton(provider: SsoProvider.gitlab, label: 'GitLab');

void main() {
  late FakeServer server;
  late ProbedServer probed;

  setUp(() async {
    server = await FakeServer.start();
    server.handle = mattermostProbe;
    probed = await ServerProbe(allowHttp: true).probe('${server.url}');
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
      openAuthSession: (url, scheme, _) async {
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

  test('SSO refuses a callback naming another server', () async {
    final signIn = SignIn(
      openAuthSession: (url, scheme, _) async => Uri.parse(
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
      openAuthSession: (url, scheme, _) async =>
          throw PlatformException(code: 'CANCELED'),
    );
    expect(await signIn.withSso(probed, gitlab), isNull);
  });
}
