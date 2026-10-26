import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/server_api.dart';

void main() {
  late HttpServer server;
  late List<HttpRequest> seen;
  late Future<void> Function(HttpRequest) respond;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    seen = [];
    respond = (req) async {
      req.response
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'id': 'u1', 'username': 'alice'}));
      await req.response.close();
    };
    server.listen((req) {
      seen.add(req);
      respond(req);
    });
  });

  tearDown(() => server.close(force: true));

  Uri base() => Uri.parse('http://127.0.0.1:${server.port}');

  test('sends the token to its own server only', () async {
    final api = ServerApi(baseUrl: base(), token: () => 'secret');
    final me = await api.call(() => api.client.users.getUser(userId: 'me'));
    expect(me.username, 'alice');
    expect(seen.single.uri.path, '/api/v4/users/me');
    expect(seen.single.headers.value('authorization'), 'Bearer secret');
    expect(seen.single.headers.value('x-requested-with'), 'XMLHttpRequest');

    final other = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final otherRequests = <HttpRequest>[];
    other.listen((req) {
      otherRequests.add(req);
      req.response.close();
    });
    await api.dio.get<void>('http://127.0.0.1:${other.port}/image.png');
    expect(otherRequests.single.headers.value('authorization'), isNull);
    await other.close(force: true);
    api.close();
  });

  test('a server below a sub-path gets the token for its API and plugins '
      'only, not for other apps on the host', () async {
    final api = ServerApi(
      baseUrl: base().replace(path: '/chat'),
      token: () => 'secret',
    );
    for (final path in [
      '/chat/api/v4/users/me',
      '/chat/plugins/playbooks/api/v0/runs',
      '/other-app/pixel.png',
      '/chat/static/logo.png',
      '/api/v4/users/me',
    ]) {
      await api.dio.get<void>(
        base().replace(path: path).toString(),
        options: Options(validateStatus: (_) => true),
      );
    }
    expect(
      {for (final r in seen) r.uri.path: r.headers.value('authorization')},
      {
        '/chat/api/v4/users/me': 'Bearer secret',
        '/chat/plugins/playbooks/api/v0/runs': 'Bearer secret',
        '/other-app/pixel.png': null,
        '/chat/static/logo.png': null,
        '/api/v4/users/me': null,
      },
    );
    api.close();
  });

  test(
    'a 401 outside login ends the session and surfaces as ServerError',
    () async {
      respond = (req) async {
        req.response
          ..statusCode = 401
          ..headers.contentType = ContentType.json
          ..write(
            jsonEncode({
              'id': 'api.context.session_expired.app_error',
              'message': 'Invalid or expired session',
              'status_code': 401,
            }),
          );
        await req.response.close();
      };
      final api = ServerApi(baseUrl: base(), token: () => 'stale');
      final ended = api.sessionEnded.first;
      await expectLater(
        api.call(() => api.client.users.getUser(userId: 'me')),
        throwsA(
          isA<ServerError>()
              .having((e) => e.isUnauthorized, 'unauthorized', isTrue)
              .having(
                (e) => e.id,
                'id',
                'api.context.session_expired.app_error',
              ),
        ),
      );
      await ended.timeout(const Duration(seconds: 1));
      api.close();
    },
  );

  test('a connection refused becomes Unreachable', () async {
    final port = server.port;
    await server.close(force: true);
    final api = ServerApi(
      baseUrl: Uri.parse('http://127.0.0.1:$port'),
      token: () => null,
    );
    await expectLater(
      api.call(() => api.client.users.getUser(userId: 'me')),
      throwsA(isA<Unreachable>()),
    );
    api.close();
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  });

  test('identical in-flight requests share one round trip', () async {
    final gate = Completer<void>();
    respond = (req) async {
      await gate.future;
      req.response
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'id': 'u1', 'username': 'alice'}));
      await req.response.close();
    };
    final api = ServerApi(baseUrl: base(), token: () => 't');
    final a = api.coalesced('me', () => api.client.users.getUser(userId: 'me'));
    final b = api.coalesced('me', () => api.client.users.getUser(userId: 'me'));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    gate.complete();
    final results = await Future.wait([a, b]);
    expect(results.map((u) => u.username), ['alice', 'alice']);
    expect(seen, hasLength(1));
    api.close();
  });
}
