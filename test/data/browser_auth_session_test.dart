import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/servers/browser_auth_session.dart';
import 'package:matterleast/data/servers/server_probe.dart';
import 'package:matterleast/data/servers/sign_in.dart';
import 'package:matterleast/domain/login_options.dart';
import 'package:matterleast/domain/sign_in_problems.dart';

import '../support/fake_server.dart';

const gitlab = SsoButton(provider: SsoProvider.gitlab, label: 'GitLab');

void main() {
  late FakeServer server;
  late ProbedServer probed;
  late List<Uri> launched;
  late BrowserAuthSession browser;
  late SignIn signIn;

  BrowserAuthSession session({
    Duration timeout = browserSignInTimeout,
    bool launches = true,
  }) => BrowserAuthSession(
    launch: (url) async {
      launched.add(url);
      return launches;
    },
    timeout: timeout,
  );

  setUp(() async {
    server = await FakeServer.start();
    server.handle = mattermostProbe;
    probed = await ServerProbe(allowHttp: true).probe('${server.url}');
    server.seen.clear();
    server.handle = (r) => r.header('authorization') == 'Bearer s3ss10n'
        ? ok(fixtureMap('me'))
        : error(401, 'api.context.session_expired.app_error');
    launched = [];
    browser = session();
    signIn = SignIn(openAuthSession: browser.open);
  });
  tearDown(() => server.close());

  Uri callback({String token = 's3ss10n', String? srv}) => Uri.parse(
    'mmauth://callback?MMAUTHTOKEN=$token&MMCSRF=x'
    '&srv=${Uri.encodeComponent(srv ?? server.url.toString())}',
  );

  // Lets the sign-in reach the point where it waits for the browser.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('a matching callback finishes the sign-in it was started for', () async {
    final result = signIn.withSso(probed, gitlab);
    await settle();
    expect(launched.single.path, '/oauth/gitlab/mobile_login');
    browser.deliver(callback());
    final signedIn = await result;
    expect(signedIn!.token, 's3ss10n');
    expect(server.paths, ['/api/v4/users/me']);
  });

  test('a callback while no sign-in waits is dropped, not kept', () async {
    browser.deliver(callback());
    final result = signIn.withSso(probed, gitlab);
    await settle();
    expect(server.seen, isEmpty);
    browser.cancel();
    expect(await result, isNull);
  });

  test('callbacks for another server or malformed ones are ignored while the '
      'sign-in keeps waiting', () async {
    final result = signIn.withSso(probed, gitlab);
    await settle();
    final planted = callback(token: 'planted').toString();
    Uri reshaped(String prefix) =>
        Uri.parse(planted.replaceFirst('mmauth://callback?', prefix));
    browser
      ..deliver(callback(token: 'planted', srv: 'https://evil.example.test'))
      ..deliver(Uri.parse('mmauth://callback?MMAUTHTOKEN=planted'))
      ..deliver(reshaped('mmauth://callback/x?'))
      ..deliver(reshaped('mmauth://evil@callback?'))
      ..deliver(reshaped('other://callback?'));
    await settle();
    expect(server.seen, isEmpty);
    browser.deliver(callback());
    expect((await result)!.token, 's3ss10n');
    expect(server.paths, ['/api/v4/users/me']);
  });

  test('a callback counts once: a replay does not finish the next sign-in', () {
    fakeAsync((async) {
      final waiting = session(timeout: const Duration(minutes: 10));
      Uri? first;
      unawaited(
        waiting
            .open(Uri.parse('https://a.test'), 'mmauth', (_) => true)
            .then((uri) => first = uri),
      );
      async.flushMicrotasks();
      waiting
        ..deliver(callback())
        ..deliver(callback());
      async.flushMicrotasks();
      expect(first, callback());

      Uri? second;
      unawaited(
        waiting
            .open(Uri.parse('https://a.test'), 'mmauth', (_) => true)
            .then((uri) => second = uri, onError: (_) {}),
      );
      async.elapse(const Duration(minutes: 5));
      expect(second, isNull);
      waiting.cancel();
      async.flushMicrotasks();
    });
  });

  test('Cancel ends the sign-in without an error', () async {
    final result = signIn.withSso(probed, gitlab);
    await settle();
    browser.cancel();
    expect(await result, isNull);
    browser.deliver(callback());
    await settle();
    expect(server.seen, isEmpty);
  });

  test('the wait ends after the timeout with a message saying so', () {
    fakeAsync((async) {
      final waiting = session();
      Object? failure;
      unawaited(
        waiting
            .open(Uri.parse('https://a.test'), 'mmauth', (_) => true)
            .then<void>((_) {}, onError: (Object e) => failure = e),
      );
      async.elapse(browserSignInTimeout - const Duration(seconds: 1));
      expect(failure, isNull);
      async.elapse(const Duration(seconds: 2));
      expect(
        failure,
        isA<LoginRejected>().having(
          (e) => e.message,
          'message',
          browserSignInTimedOutText,
        ),
      );
      waiting.deliver(callback());
    });
  });

  test('a browser that does not open is reported', () async {
    final none = session(launches: false);
    await expectLater(
      SignIn(openAuthSession: none.open).withSso(probed, gitlab),
      throwsA(isA<LoginRejected>()),
    );
  });
}
