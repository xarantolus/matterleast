import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/servers/server_probe.dart';
import 'package:matterleast/domain/sign_in_problems.dart';

import '../support/fake_server.dart';

void main() {
  late FakeServer server;

  setUp(() async => server = await FakeServer.start());
  tearDown(() => server.close());

  ServerProbe probe({Duration timeout = const Duration(seconds: 5)}) =>
      ServerProbe(allowHttp: true, timeout: timeout);

  Future<String> failureOf(Future<Object?> probing) async {
    try {
      await probing;
    } on ProbeFailure catch (e) {
      return e.message;
    }
    fail('the probe succeeded');
  }

  test('finds a Mattermost server and what it offers for login', () async {
    server.handle = mattermostProbe;
    final found = await probe().probe('${server.url}/');
    expect(found.url, server.url);
    expect(found.options.diagnosticId, isNotEmpty);
    expect(found.options.password, isTrue);
    expect(found.options.serverVersion, '12.0.1');
    expect(found.versionSupported, isTrue);
    expect(found.config['SiteName'], 'Mattermost');
    expect(server.paths, [
      '/api/v4/system/ping',
      '/api/v4/config/client',
      '/api/v4/license/client',
    ]);
  });

  test('a page that answers with something else is not a server', () async {
    server.handle = (r) => ok('<html>Welcome to my blog</html>');
    expect(await failureOf(probe().probe('${server.url}')), notMattermostText);
  });

  test('a 404 for the ping is not a server', () async {
    expect(await failureOf(probe().probe('${server.url}')), notMattermostText);
  });

  test('a config without a DiagnosticId is not a server', () async {
    server.handle = (r) => r.path == '/api/v4/config/client'
        ? ok({'SiteName': 'Something'})
        : mattermostProbe(r);
    expect(await failureOf(probe().probe('${server.url}')), notMattermostText);
  });

  test('a server that never answers times out with a message', () async {
    server.handle = (_) => null;
    final message = await failureOf(
      probe(timeout: const Duration(milliseconds: 300)).probe('${server.url}'),
    );
    expect(message, contains("didn't answer in time"));
  });

  test('an address nobody listens on is unreachable', () async {
    final url = server.url;
    await server.close();
    expect(
      await failureOf(probe().probe('$url')),
      startsWith("Couldn't reach"),
    );
  });

  test('follows a redirect to the sub-path the server lives on', () async {
    server.handle = (r) => r.path.startsWith('/chat/')
        ? mattermostProbe(r, prefix: '/chat')
        : (status: 302, json: null, headers: {'location': '/chat${r.path}'});
    final found = await probe().probe('${server.url}');
    expect(found.url, server.url.replace(path: '/chat'));
    expect(server.paths.last, '/chat/api/v4/license/client');
  });

  test('refuses plain http unless it is allowed', () async {
    server.handle = mattermostProbe;
    expect(
      await failureOf(ServerProbe(allowHttp: false).probe('${server.url}')),
      httpNotAllowedText,
    );
    expect(server.seen, isEmpty);
  });

  test('rejects text that is not an address', () async {
    expect(await failureOf(probe().probe('   ')), invalidAddressText);
  });

  test('names a mistyped scheme instead of asking for an address', () async {
    final message = await failureOf(probe().probe('ttp://chat.example.test'));
    expect(message, contains('“ttp://”'));
    expect(message, isNot(invalidAddressText));
    expect(server.seen, isEmpty);
  });

  test('the base URL comes from the ping URL that answered', () {
    expect(
      baseUrlFromPing(
        Uri.parse('https://example.test/chat/api/v4/system/ping'),
      ),
      Uri.parse('https://example.test/chat'),
    );
    expect(baseUrlFromPing(Uri.parse('https://example.test/login')), isNull);
  });
}
