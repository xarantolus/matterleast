import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/data/views/conversation_views.dart';
import 'package:matterleast/domain/outbox.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/domain/sign_in_problems.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';
import '../support/wait.dart';

/// A channel with nothing fetched yet.
const emptyChannelId = 'ch000000000000000000000c02';

Matcher get serverDownError =>
    isA<Unreachable>().having((e) => e.serverDown, 'serverDown', isTrue);

/// A server that answers the calls a refresh makes, with nothing new.
Reply? answering(SeenRequest r) => switch (r.path) {
  '/api/v4/system/ping' => ok({'status': 'OK'}),
  '/api/v4/users/me' => ok({'id': meId, 'username': 'river'}),
  _ => error(404, 'not_found'),
};

void main() {
  late FakeServer server;
  late ServerSession session;
  late List<SyncStatus> statuses;

  setUp(() async {
    server = await FakeServer.start();
    session = await testSession(server);
    statuses = [];
    session.runner.status.addListener(
      () => statuses.add(session.runner.status.value),
    );
  });

  tearDown(() async {
    await closeTestSession(session);
    await server.close();
  });

  /// The server stops answering, and one request finds out: it waits for
  /// its (here shortened) timeout while the socket isn't connected either.
  Future<void> serverStopsAnswering() async {
    server.handle = (_) => null;
    session.api.dio.options.receiveTimeout = const Duration(milliseconds: 300);
    await expectLater(
      session.api.getJsonObject('/api/v4/users/me'),
      throwsA(isA<RequestTimeout>()),
    );
    expect(session.api.reach.unreachable, isTrue);
    session.api.dio.options.receiveTimeout = const Duration(seconds: 30);
    statuses.clear();
  }

  group('a server that stops answering on a network that says online', () {
    test('a background refresh shows no bar and stops within the short '
        'ping timeout instead of the request timeouts', () async {
      await serverStopsAnswering();
      final clock = Stopwatch()..start();
      await expectLater(
        session.connection.entry.run(quiet: true),
        throwsA(serverDownError),
      );
      expect(clock.elapsed, lessThan(const Duration(seconds: 5)));
      expect(statuses.whereType<SyncRefreshing>(), isEmpty);
      expect(server.paths.last, '/api/v4/system/ping');
    });

    test('a refresh the user asks for says within seconds that the server '
        "can't be reached, not that the device is offline", () async {
      await serverStopsAnswering();
      final clock = Stopwatch()..start();
      await expectLater(session.connection.entry.run(), throwsA(anything));
      expect(clock.elapsed, lessThan(const Duration(seconds: 5)));
      // Only a ping is waited for; the bar would just flash.
      expect(statuses.whereType<SyncRefreshing>(), isEmpty);
      final shown = session.runner.status.value;
      expect(shown, isA<SyncFailed>());
      final cause = (shown as SyncFailed).cause;
      expect(
        connectionProblemText(cause, 'chat.example.test'),
        "Can't reach chat.example.test right now. The app updates when it "
        'answers again.',
      );
      expect(
        staleDataNotice(cause),
        "Can't reach the server · showing saved data",
      );
    });

    test('requests waiting on the server stop as soon as it is known not '
        'to answer', () async {
      server.handle = (_) => null;
      final waiting = session.api.getJsonObject('/api/v4/channels/x');
      await eventually(() => server.seen.isNotEmpty);
      final failed = expectLater(waiting, throwsA(serverDownError));
      final clock = Stopwatch()..start();
      session.api.dio.options.receiveTimeout = const Duration(
        milliseconds: 300,
      );
      await expectLater(
        session.api.getJsonObject('/api/v4/users/me'),
        throwsA(isA<RequestTimeout>()),
      );
      await failed;
      expect(clock.elapsed, lessThan(const Duration(seconds: 2)));
    });

    test('a message waits without using up attempts and goes once the '
        'server answers again', () async {
      await session.outbox.start();
      await serverStopsAnswering();
      await session.composer.send(channelId, message: 'into the fog');
      await session.outbox.kick();
      final waiting = await session.db.select(session.db.outbox).getSingle();
      expect(waiting.attempts, 0);
      expect(waiting.state, OutboxStates.queued);
      expect(server.paths, isNot(contains('/api/v4/posts')));

      server.handle = (r) => r.path == '/api/v4/posts'
          ? ok({
              'id': 'srv1',
              'channel_id': channelId,
              'user_id': meId,
              'create_at': DateTime.now().millisecondsSinceEpoch,
              'message': r.body['message'],
              'pending_post_id': r.body['pending_post_id'],
            })
          : answering(r);
      // The socket's next ping finds the server; a failed ping stands
      // for a few seconds.
      await eventually(
        () => session.api.reach.probe(),
        timeout: const Duration(seconds: 8),
      );
      await eventually(
        () async => (await session.db.select(session.db.outbox).get()).isEmpty,
        timeout: const Duration(seconds: 2),
      );
    });
  });

  test(
    'the first answer clears the state and the data refreshes at once',
    () async {
      await serverStopsAnswering();
      server.handle = answering;
      server.seen.clear();

      // Coming to the foreground, the first request asks with a ping
      // whether the server answers again; it does.
      session.connection.foreground();
      await eventually(
        () => !session.api.reach.unreachable,
        timeout: const Duration(seconds: 1),
      );
      await eventually(
        () => server.paths.contains('/api/v4/users/me'),
        timeout: const Duration(seconds: 1),
        reason: 'the entry sync runs once the server answers',
      );
    },
  );

  test('a slow server that answers after 8 s still succeeds on the first '
      'attempt and is not taken as down', () async {
    server.handle = (r) async {
      await Future<void>.delayed(const Duration(seconds: 8));
      return ok({'id': meId, 'username': 'river'});
    };
    final me = await session.api.getJsonObject('/api/v4/users/me');
    expect(me?['id'], meId);
    expect(session.api.reach.unreachable, isFalse);
    expect(server.seen, hasLength(1));
  }, timeout: const Timeout(Duration(seconds: 20)));

  group('a message queued where nothing was loaded yet', () {
    setUp(() async {
      await session.store.applyChannels(
        channels: [
          api.Channel.fromJson({
            'id': emptyChannelId,
            'team_id': teamId,
            'type': 'O',
            'name': 'lighthouse',
            'display_name': 'Lighthouse',
            'total_msg_count': 3,
          }),
        ],
        members: [
          api.ChannelMember.fromJson({
            'channel_id': emptyChannelId,
            'user_id': meId,
            'msg_count': 3,
          }),
        ],
      );
    });

    Future<ConversationWindow> window() => ConversationViews(session.db)
        .channel(emptyChannelId, limit: 50, openedAt: DateTime.now().toUtc())
        .first;

    test('shows at once, and stays once it is sent', () async {
      final id = await session.composer.send(
        emptyChannelId,
        message: 'first words here',
      );
      final queued = await window();
      expect(queued.loaded, isFalse);
      expect(queued.posts.map((p) => p.message), ['first words here']);
      expect(queued.posts.single.sendState, 'pending');

      await session.store.applySent(
        id,
        api.Post.fromJson({
          'id': 'srv2',
          'channel_id': emptyChannelId,
          'user_id': meId,
          'create_at': DateTime.now().millisecondsSinceEpoch,
          'message': 'first words here',
          'pending_post_id': id,
        }),
      );
      final sent = await window();
      expect(sent.posts.map((p) => p.id), ['srv2']);
    });
  });
}
