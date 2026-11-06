import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/secure/token_store.dart';
import 'package:matterleast/data/servers/browser_auth_session.dart';
import 'package:matterleast/data/servers/pending_sso_store.dart';
import 'package:matterleast/data/servers/server_probe.dart';
import 'package:matterleast/domain/login_options.dart';
import 'package:matterleast/screens/add_server/add_server_controller.dart';
import 'package:matterleast/screens/login/login_screen.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';

LoginTarget _target(
  String url, {
  bool magicLink = false,
  List<SsoButton> sso = const [],
}) => LoginTarget(
  server: ProbedServer(
    url: Uri.parse(url),
    options: LoginOptions(
      password: true,
      ldap: false,
      ldapFieldLabel: '',
      loginIdLabel: 'Email or username',
      forgotPassword: false,
      forgotPasswordLink: null,
      sso: sso,
      mfaPossible: false,
      mfaEnforced: false,
      siteName: 'Team Chat',
      serverVersion: '12.0.1',
      diagnosticId: 'd1',
      externalBrowserForSso: false,
      magicLink: magicLink,
    ),
    config: const {},
    license: const {},
  ),
  displayName: 'Team Chat',
);

void main() {
  const tall = Size(800, 1400);

  group('SSO in the browser on Android', () {
    testWidgets('waits with Cancel, and Cancel brings the form back', (
      tester,
    ) async {
      FlutterSecureStorage.setMockInitialValues({});
      final pending = PendingSsoStore(TokenStore());
      final launched = <Uri>[];
      final h = await pumpWithServer(
        tester,
        size: tall,
        platform: TargetPlatform.android,
        home: (url) => LoginScreen(
          target: _target(
            url,
            sso: const [
              SsoButton(provider: SsoProvider.gitlab, label: 'GitLab'),
            ],
          ),
        ),
        overrides: (_) => [
          pendingSsoStoreProvider.overrideWithValue(pending),
          browserAuthSessionProvider.overrideWithValue(
            BrowserAuthSession(
              launch: (url) async {
                launched.add(url);
                return true;
              },
            ),
          ),
        ],
      );

      await tester.tap(find.text('Continue with GitLab'));
      await h.settle(tester);

      expect(launched.single.path, '/oauth/gitlab/mobile_login');
      expect(find.textContaining('Finish signing in'), findsOneWidget);
      final waiting = await tester.runAsync(pending.load);
      expect(waiting!.serverUrl, h.url);
      expect(waiting.state, launched.single.queryParameters['state']);

      await tester.tap(find.text('Cancel'));
      await h.settle(tester);

      expect(find.textContaining('Finish signing in'), findsNothing);
      expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
      expect(await tester.runAsync(pending.load), isNull);
      await h.close(tester);
    });
  });

  group('guest magic link', () {
    Reply? answer(SeenRequest r, String authService) =>
        r.path == '/api/v4/users/login/type'
        ? ok({'auth_service': authService})
        : error(404, 'not_found');

    testWidgets('asks for the login id first, then says the link was sent', (
      tester,
    ) async {
      final h = await pumpWithServer(
        tester,
        size: tall,
        handle: (r) => answer(r, 'magic_link'),
        home: (url) => LoginScreen(target: _target(url, magicLink: true)),
      );

      expect(find.widgetWithText(TextField, 'Password'), findsNothing);
      await tester.enterText(
        find.widgetWithText(TextField, 'Email or username'),
        'guest@example.test',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await h.settle(tester);

      expect(h.server.seen.single.body['login_id'], 'guest@example.test');
      expect(find.text('We sent you a link to login'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Password'), findsNothing);

      await tester.tap(find.text('Use another login'));
      await h.settle(tester);
      expect(find.widgetWithText(FilledButton, 'Continue'), findsOneWidget);
      await h.close(tester);
    });

    testWidgets('an account that uses a password gets the password field', (
      tester,
    ) async {
      final h = await pumpWithServer(
        tester,
        size: tall,
        handle: (r) => answer(r, ''),
        home: (url) => LoginScreen(target: _target(url, magicLink: true)),
      );

      await tester.enterText(
        find.widgetWithText(TextField, 'Email or username'),
        'alice',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await h.settle(tester);

      expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
      expect(find.text('We sent you a link to login'), findsNothing);
      await h.close(tester);
    });

    testWidgets('a server without magic links shows the usual form', (
      tester,
    ) async {
      final h = await pumpWithServer(
        tester,
        size: tall,
        home: (url) => LoginScreen(target: _target(url)),
      );

      expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Continue'), findsNothing);
      await h.close(tester);
    });

    testWidgets('a pasted link for another server is refused', (tester) async {
      final h = await pumpWithServer(
        tester,
        size: tall,
        handle: (r) => answer(r, 'magic_link'),
        home: (url) => LoginScreen(target: _target(url, magicLink: true)),
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Email or username'),
        'guest@example.test',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await h.settle(tester);

      await tester.enterText(
        find.widgetWithText(TextField, 'Link from the email'),
        'https://other.example.test/login/one_time_link?t=${'a' * 64}',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await h.settle(tester);

      expect(find.text('That link is for another server.'), findsOneWidget);
      expect(h.server.paths, ['/api/v4/users/login/type']);
      await h.close(tester);
    });
  });
}
