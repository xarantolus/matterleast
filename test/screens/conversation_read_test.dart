import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/server_db/server_config.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/screens/channel/conversation_controller.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';
import '../support/wait.dart';

Map<String, Object?> postJson(String id, int minute, {String rootId = ''}) => {
  'id': id,
  'channel_id': channelId,
  'root_id': rootId,
  'user_id': 'someone',
  'create_at': DateTime.utc(2026, 10, 25, 10, minute).millisecondsSinceEpoch,
  'message': 'message $id',
};

/// When an open conversation counts as read, as in the official app.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  // The binding answers every HTTP request with 400; this talks to the fake
  // server for real.
  HttpOverrides.global = null;

  late FakeServer server;
  late ServerSession session;
  late ProviderContainer container;

  setUp(() async {
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    (server, session) = await startServerSession();
    server.handle = (r) {
      if (r.path == '/api/v4/posts/root1/thread') {
        return ok({
          'order': ['reply1', 'root1'],
          'posts': {
            'root1': postJson('root1', 0),
            'reply1': postJson('reply1', 1, rootId: 'root1'),
          },
        });
      }
      if (r.path.endsWith('/channels/$channelId/posts')) {
        return ok({'order': <String>[], 'posts': <String, Object?>{}});
      }
      if (r.path.endsWith('/users/ids')) return ok(<Object?>[]);
      return ok({'status': 'OK'});
    };
    container = ProviderContainer(
      overrides: [
        serverSessionProvider(server.url.toString())
            .overrideWith((ref) async => session),
      ],
    );
    addTearDown(container.dispose);
  });

  int requests(String path) => server.paths.where((p) => p == path).length;

  Future<void> open({String? rootId}) async {
    final provider = conversationProvider(
      server.url.toString(),
      channelId,
      rootId: rootId,
    );
    container.listen(provider, (_, _) {});
    await eventually(() {
      final s = container.read(provider);
      return s.window != null && !s.refreshing;
    });
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  group('a thread under collapsed threads', () {
    const read = '/api/v4/users/me/teams/$teamId/threads/root1/read';
    bool readAsked() => server.paths.any((p) => p.startsWith('$read/'));

    setUp(() async {
      await session.store.applyConfig(ConfigKeys.clientConfig, {
        'CollapsedThreads': 'always_on',
      });
    });

    test('one I don\'t follow is not marked read', () async {
      await open(rootId: 'root1');
      expect(readAsked(), isFalse);
    });

    test('one I follow is marked read on opening', () async {
      await session.store.applyThreads(teamId, [
        api.UserThread.fromJson({
          'id': 'root1',
          'reply_count': 1,
          'unread_replies': 1,
          'is_following': true,
          'post': postJson('root1', 0),
        }),
      ]);
      await open(rootId: 'root1');
      expect(readAsked(), isTrue);
    });
  });

  group('an open channel', () {
    const view = '/api/v4/channels/members/me/view';
    var minute = 10;

    Future<void> postFromSomeone() async {
      await session.connection.events.add(
        decodeEvent(
          SocketFrame.fromJson({
            'event': 'posted',
            'data': {'post': jsonEncode(postJson('p${minute++}', minute))},
            'broadcast': {'channel_id': channelId},
            'seq': 1,
          }),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }

    test('is read again when a new message arrives', () async {
      await open();
      expect(requests(view), 1);
      await postFromSomeone();
      await eventually(() => requests(view) == 2);
    });

    test('marked unread stays unread when a new message arrives', () async {
      await open();
      await session.store.applyMarkedUnread(
        api.ChannelMember.fromJson({
          'channel_id': channelId,
          'user_id': meId,
          'msg_count': 0,
        }),
      );
      await postFromSomeone();
      expect(requests(view), 1);
    });
  });
}
