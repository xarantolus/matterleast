import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/server_db/server_config.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_manager.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/screens/settings/account_providers.dart';
import 'package:matterleast/screens/settings/sessions_page.dart';
import 'package:matterleast/screens/settings/two_factor_page.dart';
import 'package:matterleast/screens/terms/terms_gate.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';
import '../support/test_session.dart';

class _Manager extends Fake implements ServerManager {
  final signedOut = <String>[];

  @override
  Future<bool> signOut(String url, {bool force = false}) async {
    signedOut.add(url);
    return true;
  }
}

ServerEntry _entry(String url) => ServerEntry(
  url: url,
  displayName: 'Team Chat',
  siteName: null,
  serverVersion: null,
  diagnosticId: null,
  lastActiveAt: DateTime.utc(2026, 11, 2),
  ssoScheme: null,
);

// A one-pixel PNG, as the server sends the QR code, base64 encoded.
const _png =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';

void main() {
  const tall = Size(800, 1400);

  group('active sessions', () {
    Map<String, Object?> session(String id, int lastActive, String browser) => {
      'id': id,
      'create_at': 1,
      'last_activity_at': lastActive,
      'props': {'os': 'Android', 'browser': browser},
    };

    final nowMs = DateTime.utc(2026, 11, 2, 12).millisecondsSinceEpoch;
    final weekMs = DateTime.utc(2026, 10, 20, 9).millisecondsSinceEpoch;
    var revoked = <String>[];

    Reply? handle(SeenRequest r) {
      if (r.path == '/api/v4/users/me/sessions') {
        return ok([
          session('s-this', nowMs, 'Matterleast'),
          if (!revoked.contains('s-old')) session('s-old', weekMs, 'Chrome'),
        ]);
      }
      if (r.path == '/api/v4/users/me/sessions/revoke') {
        revoked.add(r.body['session_id']! as String);
        return ok({'status': 'OK'});
      }
      return error(404, 'not_found');
    }

    setUp(() => revoked = []);

    testWidgets('lists them, marks this device, and ends another', (
      tester,
    ) async {
      final h = await pumpWithServer(
        tester,
        size: tall,
        handle: handle,
        home: (url) => SessionsPage(server: _entry(url)),
      );

      expect(find.text('Matterleast on Android'), findsOneWidget);
      expect(find.text('Chrome on Android'), findsOneWidget);
      expect(find.textContaining('This device'), findsOneWidget);
      expect(find.textContaining('Last active'), findsNWidgets(2));

      await tester.tap(find.text('Sign out').last);
      await h.settle(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Sign out').last);
      await h.settle(tester);

      expect(revoked, ['s-old']);
      expect(find.text('Chrome on Android'), findsNothing);
      expect(find.text('Matterleast on Android'), findsOneWidget);
      await h.close(tester);
    });

    testWidgets('ending this device signs out through the normal path', (
      tester,
    ) async {
      final manager = _Manager();
      final h = await pumpWithServer(
        tester,
        size: tall,
        handle: handle,
        overrides: (_) => [serverManagerProvider.overrideWithValue(manager)],
        home: (url) => SessionsPage(server: _entry(url)),
      );

      await tester.tap(find.text('Sign out').first);
      await h.settle(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Sign out').last);
      await h.settle(tester);

      expect(manager.signedOut, [h.url]);
      expect(revoked, isEmpty);
      await h.close(tester);
    });

    testWidgets('a failed first load says why and offers to try again', (
      tester,
    ) async {
      final h = await pumpWithServer(
        tester,
        size: tall,
        handle: (_) => (
          status: 403,
          json: {'id': 'x', 'message': 'Sessions are hidden.'},
          headers: const <String, String>{},
        ),
        home: (url) => SessionsPage(server: _entry(url)),
      );

      expect(find.textContaining('Sessions are hidden.'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      await h.close(tester);
    });
  });

  group('two-factor authentication', () {
    var active = false;
    var codes = <Map<String, Object?>>[];

    Reply? handle(SeenRequest r) {
      switch ((r.method, r.path)) {
        case ('GET', '/api/v4/users/me'):
          return ok({'id': meId, if (active) 'mfa_active': true});
        case ('POST', '/api/v4/users/me/mfa/generate'):
          return ok({'secret': 'JBSWY3DPEHPK3PXP', 'qr_code': _png});
        case ('PUT', '/api/v4/users/me/mfa'):
          codes.add(r.body);
          if (r.body['activate'] == true && r.body['code'] != '123456') {
            return error(400, 'MFA code is wrong');
          }
          active = r.body['activate'] == true;
          return ok({'status': 'OK'});
      }
      return error(404, 'not_found');
    }

    setUp(() {
      active = false;
      codes = [];
    });

    testWidgets('shows the secret and QR code, then turns on with a code', (
      tester,
    ) async {
      final h = await pumpWithServer(
        tester,
        size: tall,
        handle: handle,
        home: (url) => TwoFactorPage(server: _entry(url)),
      );

      await tester.tap(find.text('Set up'));
      await h.settle(tester);
      expect(find.text('JBSWY3DPEHPK3PXP'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);

      await tester.enterText(find.byType(TextField), '000000');
      await tester.tap(find.text('Turn on'));
      await h.settle(tester);
      expect(find.textContaining('MFA code is wrong'), findsOneWidget);
      expect(active, isFalse);

      await tester.enterText(find.byType(TextField), '123456');
      await tester.tap(find.text('Turn on'));
      await h.settle(tester);
      expect(active, isTrue);
      expect(codes.last, {'activate': true, 'code': '123456'});
      expect(find.text('Turn off'), findsOneWidget);
      await h.close(tester);
    });

    testWidgets('turns off when it is on', (tester) async {
      active = true;
      final h = await pumpWithServer(
        tester,
        size: tall,
        handle: handle,
        home: (url) => TwoFactorPage(server: _entry(url)),
      );

      await tester.tap(find.text('Turn off'));
      await h.settle(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Turn off'));
      await h.settle(tester);

      expect(active, isFalse);
      expect(codes.single['activate'], false);
      expect(find.text('Set up'), findsOneWidget);
      await h.close(tester);
    });

    testWidgets('a server that does not support it says so', (tester) async {
      final h = await pumpWithServer(
        tester,
        size: tall,
        handle: (r) => r.method == 'GET'
            ? ok({'id': meId})
            : (
                status: 501,
                json: {'id': 'x', 'message': 'MFA is not available.'},
                headers: const <String, String>{},
              ),
        home: (url) => TwoFactorPage(server: _entry(url)),
      );

      await tester.tap(find.text('Set up'));
      await h.settle(tester);
      expect(find.textContaining('MFA is not available.'), findsOneWidget);
      expect(find.text('Turn on'), findsNothing);
      await h.close(tester);
    });
  });

  group('the two-factor setting in Settings', () {
    Future<void> check(
      WidgetTester tester, {
      required String mfa,
      required String authService,
      required bool shown,
    }) async {
      final h = await pumpWithServer(
        tester,
        seed: (session) async {
          await session.store.applyConfig(ConfigKeys.clientConfig, {
            'EnableMultifactorAuthentication': mfa,
          });
          await session.db.setSyncText(
            SyncKeys.currentUserAuthService,
            authService,
          );
        },
        home: (url) => Consumer(
          builder: (context, ref, _) => Text(
            (ref.watch(mfaAvailableProvider(url)).value ?? false)
                ? 'offered'
                : 'hidden',
          ),
        ),
      );
      expect(find.text(shown ? 'offered' : 'hidden'), findsOneWidget);
      await h.close(tester);
    }

    testWidgets(
      'offered to a password account on a server that has it',
      (tester) => check(tester, mfa: 'true', authService: '', shown: true),
    );

    testWidgets(
      'hidden for an account that signs in with SSO',
      (tester) =>
          check(tester, mfa: 'true', authService: 'gitlab', shown: false),
    );

    testWidgets(
      'hidden when the server has it off',
      (tester) => check(tester, mfa: 'false', authService: '', shown: false),
    );
  });

  group('terms of service', () {
    var acceptedId = 'old';
    var termsStatus = 200;
    var answers = <Map<String, Object?>>[];

    Reply? handle(SeenRequest r) {
      switch ((r.method, r.path)) {
        case ('GET', '/api/v4/users/me'):
          return ok({'id': meId, 'terms_of_service_id': acceptedId});
        case ('GET', '/api/v4/terms_of_service'):
          return termsStatus == 200
              ? ok({'id': 't2', 'text': '# House rules\n\nBe kind to people.'})
              : error(termsStatus, 'no_terms');
        case ('POST', '/api/v4/users/me/terms_of_service'):
          answers.add(r.body);
          if (r.body['accepted'] == true) acceptedId = 't2';
          return ok({'status': 'OK'});
      }
      return error(404, 'not_found');
    }

    Future<ServerHarness> pump(
      WidgetTester tester, {
      required Map<String, Object?> config,
      bool licensed = true,
      _Manager? manager,
    }) => pumpWithServer(
      tester,
      size: tall,
      handle: handle,
      overrides: (_) => [
        if (manager != null) serverManagerProvider.overrideWithValue(manager),
      ],
      seed: (session) async {
        await session.store.applyConfig(ConfigKeys.clientConfig, config);
        await session.store.applyConfig(ConfigKeys.license, {
          'IsLicensed': '$licensed',
        });
      },
      home: (url) => TermsGate(url: url, child: const Text('Inbox')),
    );

    const on = {
      'EnableCustomTermsOfService': 'true',
      'CustomTermsOfServiceId': 't2',
    };

    setUp(() {
      acceptedId = 'old';
      termsStatus = 200;
      answers = [];
    });

    testWidgets('new terms are shown and accepting lets the user in', (
      tester,
    ) async {
      final h = await pump(tester, config: on);

      expect(find.text('Terms of service'), findsOneWidget);
      expect(find.textContaining('Be kind to people.'), findsOneWidget);

      await tester.tap(find.text('Accept'));
      await h.settle(tester);

      expect(answers.single, {'termsOfServiceId': 't2', 'accepted': true});
      expect(find.text('Terms of service'), findsNothing);
      expect(find.text('Inbox'), findsOneWidget);
      await h.close(tester);
    });

    testWidgets('declining signs the user out of that server', (tester) async {
      final manager = _Manager();
      final h = await pump(tester, config: on, manager: manager);

      await tester.tap(find.text('Decline'));
      await h.settle(tester);
      await tester.tap(find.text('Decline and sign out'));
      await h.settle(tester);

      expect(answers.single['accepted'], false);
      expect(manager.signedOut, [h.url]);
      await h.close(tester);
    });

    testWidgets('terms already accepted are not shown again', (tester) async {
      acceptedId = 't2';
      final h = await pump(tester, config: on);

      expect(find.text('Terms of service'), findsNothing);
      expect(h.server.paths, isNot(contains('/api/v4/terms_of_service')));
      await h.close(tester);
    });

    testWidgets('a server without custom terms is never asked', (tester) async {
      final h = await pump(
        tester,
        config: const {'EnableCustomTermsOfService': 'false'},
      );

      expect(find.text('Terms of service'), findsNothing);
      expect(h.server.paths, isNot(contains('/api/v4/terms_of_service')));
      expect(h.server.paths, isNot(contains('/api/v4/users/me')));
      await h.close(tester);
    });

    for (final status in [404, 501]) {
      testWidgets('an answer of $status from the terms turns it off', (
        tester,
      ) async {
        termsStatus = status;
        final h = await pump(tester, config: on);

        expect(find.text('Terms of service'), findsNothing);
        expect(find.text('Inbox'), findsOneWidget);
        await h.close(tester);
      });
    }

    testWidgets('an unlicensed server is not asked', (tester) async {
      final h = await pump(tester, config: on, licensed: false);

      expect(find.text('Terms of service'), findsNothing);
      expect(jsonEncode(h.server.paths.toList()), isNot(contains('terms')));
      await h.close(tester);
    });
  });
}
