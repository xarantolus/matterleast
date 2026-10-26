import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/app_db/app_database.dart';
import 'package:matterleast/data/servers/server_probe.dart';
import 'package:matterleast/domain/login_options.dart';
import 'package:matterleast/screens/add_server/add_server_controller.dart';
import 'package:matterleast/screens/login/login_screen.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  const url = 'https://chat.example.test';

  LoginTarget target() => LoginTarget(
    server: ProbedServer(
      url: Uri.parse(url),
      options: const LoginOptions(
        password: true,
        ldap: false,
        ldapFieldLabel: '',
        loginIdLabel: 'Email or username',
        forgotPassword: false,
        forgotPasswordLink: null,
        sso: [],
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

  Future<void> showLogin(WidgetTester tester, {String? lastLoginId}) async {
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
          theme: MatterleastApp.lightTheme,
          home: LoginScreen(target: target()),
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
}
