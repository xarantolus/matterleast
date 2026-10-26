import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/server_entry.dart';

ServerEntry _server(String url, String name, {bool signedIn = true}) =>
    ServerEntry(
      url: url,
      displayName: name,
      siteName: 'Mattermost',
      serverVersion: '12.0.1',
      diagnosticId: url,
      lastActiveAt: signedIn ? DateTime.utc(2026) : null,
      ssoScheme: null,
    );

void main() {
  final servers = [
    _server('https://one.example.test', 'Crew'),
    _server('https://two.example.test', 'Lab'),
    _server('https://old.example.test', 'Archive', signedIn: false),
  ];

  String? problem(String name) =>
      renameProblem(name, url: 'https://one.example.test', servers: servers);

  test('a server can take a free name, or keep its own', () {
    expect(problem('Harbour'), isNull);
    expect(problem(' Crew '), isNull);
    expect(problem('Archive'), isNull);
  });

  test('a server cannot be renamed to nothing or to a signed-in name', () {
    expect(problem('   '), 'Enter a name.');
    expect(problem('Lab'), 'Another server already has this name.');
  });
}
