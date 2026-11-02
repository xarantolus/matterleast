import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/servers/server_probe.dart';
import 'package:matterleast/domain/login_options.dart';
import 'package:matterleast/screens/add_server/add_server_controller.dart';
import 'package:matterleast/screens/login/forgot_password_sheet.dart';
import 'package:matterleast/screens/login/login_screen.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';

LoginTarget _target(String url, {required bool forgotPassword}) => LoginTarget(
  server: ProbedServer(
    url: Uri.parse(url),
    options: LoginOptions(
      password: true,
      ldap: false,
      ldapFieldLabel: '',
      loginIdLabel: 'Email or username',
      forgotPassword: forgotPassword,
      forgotPasswordLink: null,
      sso: const [],
      mfaPossible: false,
      mfaEnforced: false,
      siteName: 'Team Chat',
      serverVersion: '12.0.1',
      diagnosticId: 'd1',
      externalBrowserForSso: false,
    ),
    config: const {},
    license: const {},
  ),
  displayName: 'Team Chat',
);

void main() {
  const tall = Size(800, 1400);

  testWidgets('forgot password asks for an email and sends the reset', (
    tester,
  ) async {
    final h = await pumpWithServer(
      tester,
      size: tall,
      handle: (r) => r.path == '/api/v4/users/password/reset/send'
          ? ok({'status': 'OK'})
          : error(404, 'not_found'),
      home: (url) => LoginScreen(target: _target(url, forgotPassword: true)),
    );

    await tester.tap(find.text('Forgot password?'));
    await h.settle(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Email'),
      'sam@example.test',
    );
    await tester.tap(find.text('Send reset link'));
    await h.settle(tester);

    final sent = h.server.seen.singleWhere(
      (r) => r.path == '/api/v4/users/password/reset/send',
    );
    expect(sent.method, 'POST');
    expect(sent.body, {'email': 'sam@example.test'});
    expect(find.text(passwordResetSentText), findsOneWidget);
    await h.close(tester);
  });

  testWidgets("the server's own answer is shown when it refuses", (
    tester,
  ) async {
    final h = await pumpWithServer(
      tester,
      size: tall,
      handle: (r) => (
        status: 501,
        json: {'id': 'x', 'message': 'Email is not set up here.'},
        headers: const <String, String>{},
      ),
      home: (url) => LoginScreen(target: _target(url, forgotPassword: true)),
    );

    await tester.tap(find.text('Forgot password?'));
    await h.settle(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Email'),
      'sam@example.test',
    );
    await tester.tap(find.text('Send reset link'));
    await h.settle(tester);

    expect(find.textContaining('Email is not set up here.'), findsOneWidget);
    expect(find.text(passwordResetSentText), findsNothing);
    await h.close(tester);
  });

  testWidgets('no link when the server turns password reset off', (
    tester,
  ) async {
    final h = await pumpWithServer(
      tester,
      size: tall,
      home: (url) => LoginScreen(target: _target(url, forgotPassword: false)),
    );

    expect(find.text('Forgot password?'), findsNothing);
    await h.close(tester);
  });
}
