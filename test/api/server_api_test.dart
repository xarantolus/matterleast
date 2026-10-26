import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/server_api.dart';

import '../support/wait.dart';

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

  group('a video streamed by a player', () {
    test('gets the token when the server answers itself', () async {
      respond = (req) async {
        req.response
          ..statusCode = 206
          ..write('v');
        await req.response.close();
      };
      final api = ServerApi(baseUrl: base(), token: () => 'secret');
      final file = base().replace(path: '/api/v4/files/f1');
      final source = await api.streamSource(file);
      expect(source.uri, file);
      expect(source.headers, {'Authorization': 'Bearer secret'});
      api.close();
    });

    test('goes to a redirect target without the token', () async {
      respond = (req) async {
        req.response
          ..statusCode = 302
          ..headers.set('location', 'http://files.example.test/f1?sig=x');
        await req.response.close();
      };
      final api = ServerApi(baseUrl: base(), token: () => 'secret');
      final source = await api.streamSource(
        base().replace(path: '/api/v4/files/f1'),
      );
      expect(source.uri, Uri.parse('http://files.example.test/f1?sig=x'));
      expect(source.headers, isEmpty);
      api.close();
    });
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

  test('identical GETs in flight share one round trip', () async {
    final gate = Completer<void>();
    respond = (req) async {
      await gate.future;
      req.response
        ..headers.contentType = ContentType.json
        ..write(
          jsonEncode({'id': req.uri.pathSegments.last, 'username': 'alice'}),
        );
      await req.response.close();
    };
    final api = ServerApi(baseUrl: base(), token: () => 't');
    final a = api.call(() => api.client.users.getUser(userId: 'me'));
    final b = api.call(() => api.client.users.getUser(userId: 'me'));
    final other = api.call(() => api.client.users.getUser(userId: 'u2'));
    await eventually(() => seen.length == 2);
    gate.complete();
    final results = await Future.wait([a, b, other]);
    expect(results.map((u) => u.id), ['me', 'me', 'u2']);
    expect(seen.map((r) => r.uri.path), [
      '/api/v4/users/me',
      '/api/v4/users/u2',
    ]);
    api.close();
  });

  test('a GET that joined another still gets its answer when the first '
      'caller gives up', () async {
    var answered = 0;
    respond = (req) async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      req.response
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'id': 'me', 'username': 'alice'}));
      await req.response.close();
      answered++;
    };
    final api = ServerApi(baseUrl: base(), token: () => 't');
    final first = api.call(
      () => api.client.users.getUser(userId: 'me'),
      deadline: const Duration(milliseconds: 100),
    );
    final second = api.call(() => api.client.users.getUser(userId: 'me'));
    await expectLater(first, throwsA(isA<RequestTimeout>()));
    expect((await second).username, 'alice');
    expect(answered, greaterThanOrEqualTo(1));
    api.close();
  });

  test('a server that never answers fails as a timeout at the deadline, '
      'and a cancelled scope stops its requests', () async {
    respond = (_) => Completer<void>().future;
    final api = ServerApi(baseUrl: base(), token: () => 't');
    final watch = Stopwatch()..start();
    await expectLater(
      api.call(
        () => api.client.users.getUser(userId: 'me'),
        deadline: const Duration(milliseconds: 200),
      ),
      throwsA(isA<RequestTimeout>()),
    );
    expect(watch.elapsed, lessThan(const Duration(seconds: 5)));

    final scope = CancelToken();
    final stopped = cancellable(
      scope,
      () => api.call(() => api.client.users.getUser(userId: 'me')),
    );
    await eventually(() => seen.length == 2);
    scope.cancel();
    await expectLater(stopped, throwsA(isA<Cancelled>()));
    api.close();
  });
}
