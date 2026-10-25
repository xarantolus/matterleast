import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/servers/server_probe.dart';
import 'package:matterleast/domain/login_options.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/screens/add_server/add_server_controller.dart';

void main() {
  final probed = ProbedServer(
    url: Uri.parse('https://chat.example.test'),
    options: loginOptionsFrom({
      'DiagnosticId': 'd1',
      'SiteName': 'Team Chat',
    }, {}),
    config: const {},
    license: const {},
  );

  ServerEntry entry(
    String url,
    String name,
    String id, {
    bool signedIn = true,
    String? scheme,
  }) => ServerEntry(
    url: url,
    displayName: name,
    siteName: name,
    serverVersion: '12.0.1',
    diagnosticId: id,
    lastActiveAt: signedIn ? DateTime(2026) : null,
    ssoScheme: scheme,
  );

  test('a server already signed in under another address is refused', () {
    final check = checkNewServer(
      server: probed,
      typedName: '',
      existing: [entry('https://old.example.test', 'Work', 'd1')],
    );
    expect(check.target, isNull);
    expect(check.urlError, contains('already signed in'));
  });

  test('a name another signed-in server uses is refused', () {
    final check = checkNewServer(
      server: probed,
      typedName: 'Work ',
      existing: [entry('https://other.example.test', 'Work', 'd2')],
    );
    expect(check.target, isNull);
    expect(check.nameError, isNotNull);
  });

  test('a taken site name falls back to the host; the SSO scheme is kept', () {
    final check = checkNewServer(
      server: probed,
      typedName: '',
      existing: [
        entry(
          'https://chat.example.test',
          'Team Chat',
          'd1',
          signedIn: false,
          scheme: 'matterleast',
        ),
        entry('https://other.example.test', 'Team Chat', 'd2'),
      ],
    );
    expect(check.target!.displayName, 'chat.example.test');
    expect(check.target!.ssoScheme, 'matterleast');
  });
}
