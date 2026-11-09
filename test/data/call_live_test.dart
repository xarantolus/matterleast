import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/data/servers/server_session.dart';

import '../support/calls.dart';
import '../support/fake_server.dart';
import '../support/test_session.dart';
import '../support/wait.dart';

void main() {
  late FakeServer server;
  late ServerSession session;
  var channels = <Object?>[];
  Reply? Function(SeenRequest)? failWith;
  var config = callsConfigJson();

  setUp(() async {
    (server, session) = await startServerSession();
    channels = [
      callsChannelJson(channelId, call: callJson(people: ['ann'])),
    ];
    failWith = null;
    config = callsConfigJson(ringing: true);
    server.handle = (r) {
      final failure = failWith?.call(r);
      if (failure != null) return failure;
      return switch (r.path) {
        '$callsRoute/config' => ok(config),
        '$callsRoute/channels' => ok(channels),
        _ => emptyAnswer(r),
      };
    };
  });

  int asked() => server.paths.where((p) => p == '$callsRoute/channels').length;

  test('a server with the plugin shows its calls and settings', () async {
    final live = session.connection.calls;
    expect(live.state.value.calls, isEmpty);
    await installCallsPlugin(session);
    await eventually(() => live.state.value.calls.containsKey(channelId));
    expect(live.state.value.calls[channelId]!.participantUserIds, ['ann']);
    expect(live.config.value?.defaultEnabled, isTrue);
  });

  test('a server without the plugin is never asked', () async {
    session.connection.calls.reconnected();
    await afterWork();
    expect(server.paths.where((p) => p.startsWith(callsRoute)), isEmpty);
  });

  test('events change the call and its end clears it', () async {
    final live = session.connection.calls;
    await installCallsPlugin(session);
    await eventually(() => live.state.value.calls.containsKey(channelId));

    session.connection.receive(
      const CallJoinedEvent(channelId, sessionId: 's-bob', userId: 'bob'),
    );
    expect(live.state.value.calls[channelId]!.participantUserIds, [
      'ann',
      'bob',
    ]);

    session.connection.receive(const CallEndedEvent(channelId));
    expect(live.state.value.calls, isEmpty);
  });

  test('after a reconnect the server\'s account replaces ours', () async {
    final live = session.connection.calls;
    await installCallsPlugin(session);
    await eventually(() => live.state.value.calls.containsKey(channelId));

    channels = [callsChannelJson(channelId, enabled: false)];
    live.reconnected();
    await eventually(() => live.state.value.calls.isEmpty);
    expect(live.state.value.enabled, {channelId: false});
  });

  test('a person joining a call we missed fetches that call', () async {
    final live = session.connection.calls;
    channels = [];
    await installCallsPlugin(session);
    await eventually(() => asked() == 1);
    await afterWork();
    expect(live.state.value.calls, isEmpty);

    server.handle = (r) => r.path == '$callsRoute/$channelId'
        ? ok(callsChannelJson(channelId, call: callJson(people: ['ann'])))
        : emptyAnswer(r);
    session.connection.receive(
      const CallJoinedEvent(channelId, sessionId: 's-ann', userId: 'ann'),
    );
    await eventually(() => live.state.value.calls.containsKey(channelId));
  });

  for (final status in [404, 403, 501]) {
    test('an answer of $status turns calls off', () async {
      failWith = (r) =>
          r.path.startsWith(callsRoute) ? error(status, 'unavailable') : null;
      await installCallsPlugin(session);
      await eventually(() async => !(await session.db.features()).calls);
      expect(session.connection.calls.state.value.calls, isEmpty);
      expect(session.connection.calls.config.value, isNull);
    });
  }

  test('a failed refresh keeps what is shown', () async {
    final live = session.connection.calls;
    await installCallsPlugin(session);
    await eventually(() => live.state.value.calls.containsKey(channelId));
    final before = asked();

    failWith = (r) => r.path.startsWith(callsRoute) ? error(500, 'boom') : null;
    live.reconnected();
    await eventually(() => asked() > before);
    await afterWork();
    expect(live.state.value.calls.containsKey(channelId), isTrue);
    expect((await session.db.features()).calls, isTrue);
  });

  group('ringing', () {
    const dm = 'dm0000000000000000000000d1';

    Future<void> ready({String type = 'D'}) async {
      await session.store.applyChannels(
        channels: [
          api.Channel.fromJson({'id': dm, 'type': type, 'name': 'a__b'}),
        ],
        members: const [],
      );
      await installCallsPlugin(session);
      await eventually(() => session.connection.calls.config.value != null);
    }

    void started({String owner = 'ann'}) => session.connection.receive(
      CallStartedEvent(dm, id: 'c1', ownerId: owner, hostId: owner),
    );

    test(
      'a direct message call that starts live rings until it ends',
      () async {
        await ready();
        final live = session.connection.calls;
        started();
        await eventually(() => live.incoming.value.containsKey(dm));

        session.connection.receive(const CallEndedEvent(dm));
        expect(live.incoming.value, isEmpty);
      },
    );

    test('joining it or ignoring it stops the ring', () async {
      await ready();
      final live = session.connection.calls;
      started();
      await eventually(() => live.incoming.value.containsKey(dm));
      session.connection.receive(
        const CallJoinedEvent(dm, sessionId: 's-me', userId: meId),
      );
      await eventually(() => live.incoming.value.isEmpty);

      started();
      await eventually(() => live.incoming.value.containsKey(dm));
      live.dismiss(dm);
      expect(live.incoming.value, isEmpty);
    });

    test('a call the user started does not ring', () async {
      await ready();
      final live = session.connection.calls;
      started(owner: meId);
      await afterWork();
      expect(live.incoming.value, isEmpty);
    });

    test('where ringing is off nothing rings', () async {
      config = callsConfigJson(ringing: false);
      await ready();
      started();
      await afterWork();
      expect(session.connection.calls.incoming.value, isEmpty);
    });

    test('a call found by a refresh does not ring', () async {
      channels = [
        callsChannelJson(dm, call: callJson(people: ['ann'])),
      ];
      await ready();
      await eventually(
        () => session.connection.calls.state.value.calls.containsKey(dm),
      );
      expect(session.connection.calls.incoming.value, isEmpty);
    });
  });

  test('a reaction shows on its person', () async {
    final live = session.connection.calls;
    await installCallsPlugin(session);
    await eventually(() => live.state.value.calls.containsKey(channelId));

    session.connection.receive(
      const CallReactionEvent(channelId, sessionId: 's-ann', emoji: 'tada'),
    );
    expect(live.reactions.value, {'s-ann': 'tada'});
  });
}
