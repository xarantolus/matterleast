import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/app/theme.dart';
import 'package:matterleast/data/app_db/app_database.dart';
import 'package:matterleast/data/servers/server_probe.dart';
import 'package:matterleast/domain/login_options.dart';
import 'package:matterleast/screens/add_server/add_server_controller.dart';
import 'package:matterleast/screens/login/login_screen.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  const url = 'https://chat.example.test';

  LoginTarget target({bool forgotPassword = false}) => LoginTarget(
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

  Future<void> showLogin(
    WidgetTester tester, {
    String? lastLoginId,
    bool forgotPassword = false,
    ThemeData? theme,
  }) async {
    final db = AppDatabase(DatabaseConnection(NativeDatabase.memory()));
    addTearDown(() => tester.runAsync(db.close));
    await tester.runAsync(
      () => db.upsertServer(
        ServersCompanion.insert(
          url: url,
          displayName: 'Team Chat',
          dbFile: 'server-1.sqlite',
          addedAt: DateTime.utc(2026, 10, 1),
          lastLoginId: Value(lastLoginId),
        ),
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: theme ?? MatterleastApp.lightTheme,
          home: LoginScreen(target: target(forgotPassword: forgotPassword)),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
  }

  String field(WidgetTester tester, String label) => tester
      .widget<TextField>(
        find.ancestor(of: find.text(label), matching: find.byType(TextField)),
      )
      .controller!
      .text;

  testWidgets('signing in again offers the username used last, never the '
      'password', (tester) async {
    await showLogin(tester, lastLoginId: 'river');
    expect(field(tester, 'Email or username'), 'river');
    expect(field(tester, 'Password'), isEmpty);
  });

  testWidgets('a server never signed in to starts empty', (tester) async {
    await showLogin(tester);
    expect(field(tester, 'Email or username'), isEmpty);
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.linux]) {
    testWidgets('on ${platform.name} the pressed shape of "Forgot password?" '
        'holds its whole label', (tester) async {
      debugDefaultTargetPlatformOverride = platform;
      try {
        await showLogin(
          tester,
          forgotPassword: true,
          theme: themeForPlatform(MatterleastApp.lightTheme),
        );
        final label = tester.getRect(find.text('Forgot password?'));
        final ink = tester.getRect(
          find.ancestor(
            of: find.text('Forgot password?'),
            matching: find.byType(InkWell),
          ),
        );
        // The ink is a stadium: a corner of the label outside the circle
        // at either end is drawn outside the highlight.
        final radius = ink.height / 2;
        bool inside(Offset p) {
          final x = p.dx.clamp(ink.left + radius, ink.right - radius);
          return (p - Offset(x, ink.center.dy)).distance <= radius;
        }

        for (final corner in [
          label.topLeft,
          label.topRight,
          label.bottomLeft,
          label.bottomRight,
        ]) {
          expect(inside(corner), isTrue, reason: '$corner in $ink');
        }
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }
}
