import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/network_state.dart';
import 'package:matterleast/api/websocket/server_socket.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/notifications/notification_check.dart';
import 'package:matterleast/notifications/notifier.dart';
import 'package:matterleast/notifications/notify_rules.dart';
import 'package:matterleast/notifications/stay_connected.dart';

import '../support/fake_server.dart';
import '../support/fake_socket_server.dart';
import '../support/test_session.dart';
import '../support/wait.dart';

class _Notices extends Notifier {
  final shownNotices = <ConversationNotice>[];

  @override
  Future<void> show(ConversationNotice notice) async =>
      shownNotices.add(notice);

  @override
  Future<List<ShownConversation>> shown(String serverUrl) async => const [];
}

/// A session whose socket talks to a fake socket server, on a network that
/// reports through [reports] (Wi-Fi first).
Future<
  (FakeSocketServer, ServerSession, StreamController<List<ConnectivityResult>>)
>
_sessionOnNetwork() async {
  final sockets = await FakeSocketServer.start();
  addTearDown(sockets.close);
  final reports = StreamController<List<ConnectivityResult>>();
  final network = NetworkState(reports.stream);
  addTearDown(() async {
    await network.close();
    await reports.close();
  });
  reports.add([ConnectivityResult.wifi]);
  await pumpEventQueue();
  final server = await FakeServer.start();
  addTearDown(server.close);
  final session = await testSession(server, network: network, url: sockets.url);
  addTearDown(() => closeTestSession(session));
  session.connection.socket.start();
  await eventually(() => sockets.connections.length == 1);
  await eventually(
    () => session.connection.socket.state.value == SocketState.connected,
  );
  return (sockets, session, reports);
}

void main() {
  test(
    'a restarted service notifies what arrived while it was down, once',
    () async {
      final (server, session) = await startServerSession();
      final notices = _Notices();
      final seen = DateTime.utc(2026, 10, 25, 10);
      final postAt = seen
          .add(const Duration(minutes: 5))
          .millisecondsSinceEpoch;
      await session.db.setSyncInt(
        NotifyKeys.cursorKey,
        seen.millisecondsSinceEpoch,
      );
      // What the refresh at the start would have learned: the channel has
      // a newer post than the cursor.
      await session.store.applyChannels(
        channels: [
          api.Channel.fromJson({
            'id': channelId,
            'team_id': teamId,
            'type': 'O',
            'name': 'boats',
            'display_name': 'Boats',
            'total_msg_count': 2,
            'last_post_at': postAt,
          }),
        ],
        members: [
          api.ChannelMember.fromJson({
            'channel_id': channelId,
            'user_id': meId,
            'msg_count': 1,
            'mention_count': 1,
            'last_viewed_at': seen.millisecondsSinceEpoch,
          }),
        ],
      );
      server.handle = (r) => r.path.endsWith('/posts')
          ? ok({
              'order': ['p1'],
              'posts': {
                'p1': {
                  'id': 'p1',
                  'channel_id': channelId,
                  'user_id': 'someone',
                  'create_at': postAt,
                  'message': '@river the boats',
                },
              },
            })
          : ok(<Object?>[]);

      final live = watchServer(
        session,
        notices,
        'Harbour',
        shownNow: (_) => false,
      );
      addTearDown(live.stop);
      await eventually(() => notices.shownNotices.isNotEmpty);
      await afterWork();
      expect(notices.shownNotices, hasLength(1));
    },
  );

  test('switching from Wi-Fi to mobile data reconnects the socket', () async {
    final (sockets, _, reports) = await _sessionOnNetwork();
    reports.add([ConnectivityResult.mobile]);
    await eventually(() => sockets.connections.length == 2);
  });

  test('a report that changes nothing keeps the socket', () async {
    final (sockets, _, reports) = await _sessionOnNetwork();
    reports.add([ConnectivityResult.wifi]);
    await afterWork();
    expect(sockets.connections, hasLength(1));
  });
}
