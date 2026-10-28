import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/network_state.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/domain/outbox.dart';
import 'package:matterleast/domain/sign_in_problems.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';
import '../support/wait.dart';

const none = [ConnectivityResult.none];
const wifi = [ConnectivityResult.wifi];

Matcher get noNetworkError =>
    isA<Unreachable>().having((e) => e.noNetwork, 'noNetwork', isTrue);

void main() {
  late FakeServer server;
  late ServerSession session;
  late StreamController<List<ConnectivityResult>> reports;
  late NetworkState network;
  late List<SyncStatus> statuses;

  Future<void> report(List<ConnectivityResult> report) async {
    reports.add(report);
    await pumpEventQueue();
  }

  setUp(() async {
    server = await FakeServer.start();
    reports = StreamController();
    network = NetworkState(reports.stream);
    session = await testSession(server, network: network);
    statuses = [];
    session.runner.status.addListener(
      () => statuses.add(session.runner.status.value),
    );
  });

  tearDown(() async {
    await closeTestSession(session);
    await network.close();
    await reports.close();
    await server.close();
  });

  group('without a network', () {
    test('a refresh fails at once as offline and never shows as refreshing; '
        'nothing is sent', () async {
      await report(none);
      final clock = Stopwatch()..start();
      await expectLater(
        session.connection.entry.run(),
        throwsA(noNetworkError),
      );
      expect(clock.elapsedMilliseconds, lessThan(100));
      expect(statuses.whereType<SyncRefreshing>(), isEmpty);
      final shown = session.runner.status.value;
      expect(
        shown,
        isA<SyncFailed>().having((s) => s.offline, 'offline', true),
      );
      expect(
        connectionProblemText((shown as SyncFailed).cause, 'chat.example.test'),
        startsWith("You're offline."),
      );
      expect(server.seen, isEmpty);
    });

    test('a request on its own is refused at once as offline', () async {
      await report(none);
      final clock = Stopwatch()..start();
      await expectLater(
        session.api.getJsonObject('/api/v4/users/me'),
        throwsA(noNetworkError),
      );
      expect(clock.elapsedMilliseconds, lessThan(100));
      expect(server.seen, isEmpty);
    });

    test('a request in flight when the network goes away stops at once, '
        'not after its timeout', () async {
      server.handle = (_) => null;
      final request = session.api.getJsonObject('/api/v4/users/me');
      final failed = expectLater(request, throwsA(noNetworkError));
      await eventually(() => server.seen.isNotEmpty);
      final clock = Stopwatch()..start();
      await report(none);
      await failed;
      expect(clock.elapsedMilliseconds, lessThan(1000));
    });

    test('a message waits for the network without using up attempts and goes '
        'as soon as it is back', () async {
      server.handle = (r) => r.path == '/api/v4/posts'
          ? ok({
              'id': 'srv1',
              'channel_id': channelId,
              'user_id': meId,
              'create_at': 1,
              'message': r.body['message'],
              'pending_post_id': r.body['pending_post_id'],
            })
          : error(404, 'not_found');
      await report(none);
      await session.outbox.start();
      await session.composer.send(channelId, message: 'from the tunnel');
      await session.outbox.kick();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      final waiting = await session.db.select(session.db.outbox).getSingle();
      expect(waiting.attempts, 0);
      expect(waiting.state, OutboxStates.queued);
      expect(server.paths, isNot(contains('/api/v4/posts')));

      await report(wifi);
      await eventually(
        () async => (await session.db.select(session.db.outbox).get()).isEmpty,
      );
      expect(server.paths.where((p) => p == '/api/v4/posts'), hasLength(1));
    });
  });

  test('when the network comes back the socket connects and the data '
      'refreshes at once, not after the backoff', () async {
    await report(none);
    session.connection.foreground();
    await eventually(() => server.paths.contains('/api/v4/websocket'));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    server.seen.clear();

    await report(wifi);
    await eventually(
      () =>
          server.paths.contains('/api/v4/users/me') &&
          server.paths.contains('/api/v4/websocket'),
    );
  });

  test('a retry nobody asked for reports its failure without showing as '
      'refreshing', () async {
    server.handle = (_) => error(500, 'broken');
    await expectLater(
      session.connection.entry.run(quiet: true),
      throwsA(isA<ServerError>()),
    );
    expect(statuses.whereType<SyncRefreshing>(), isEmpty);
    expect(session.runner.status.value, isA<SyncFailed>());
  });

  test('a refresh the user asks for while a quiet one runs shows', () async {
    final answer = Completer<void>();
    server.handle = (_) async {
      await answer.future;
      return error(500, 'broken');
    };
    final quiet = session.connection.entry.run(quiet: true);
    await eventually(() => server.seen.isNotEmpty);
    expect(statuses.whereType<SyncRefreshing>(), isEmpty);
    final asked = session.connection.entry.run();
    expect(session.runner.status.value, isA<SyncRefreshing>());
    answer.complete();
    await expectLater(quiet, throwsA(isA<ServerError>()));
    await expectLater(asked, throwsA(isA<ServerError>()));
  });

  test('only a report of no network at all counts as offline', () {
    expect(hasNetwork(none), isFalse);
    expect(hasNetwork(wifi), isTrue);
    expect(hasNetwork([ConnectivityResult.vpn]), isTrue);
    expect(hasNetwork(const []), isTrue);
  });
}
