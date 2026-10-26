import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/api/websocket/server_socket.dart';
import 'package:matterleast/api/websocket/socket_rules.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/data/sync/entry_sync.dart';
import 'package:matterleast/data/sync/event_applier.dart';
import 'package:matterleast/data/sync/inbox_sync.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/data/users/user_loader.dart';

import '../support/fake_socket_server.dart';

void main() {
  group('rules', () {
    test('retries every 3 s seven times, then backs off to 5 min', () {
      expect(retryDelay(1), const Duration(seconds: 3));
      expect(retryDelay(7), const Duration(seconds: 3));
      expect(retryDelay(8), const Duration(seconds: 24));
      expect(retryDelay(500), const Duration(minutes: 5));
    });

    test('retries are spread by up to 20% either way', () {
      expect(retryDelay(1, jitter: -1), const Duration(milliseconds: 2400));
      expect(retryDelay(1, jitter: 1), const Duration(milliseconds: 3600));
      expect(retryDelay(500, jitter: 1), const Duration(minutes: 6));
      final spread = {for (var i = 0; i < 20; i++) jitteredRetryDelay(1)};
      expect(spread.length, greaterThan(1));
      for (final d in spread) {
        expect(d.inMilliseconds, inInclusiveRange(2400, 3600));
      }
    });

    test('the socket address resumes the connection', () {
      final uri = socketUri(
        Uri.parse('https://chat.example.test/team-chat/'),
        connectionId: 'abc',
        sequence: 7,
      );
      expect(
        uri.toString(),
        'wss://chat.example.test/team-chat/api/v4/websocket'
        '?connection_id=abc&sequence_number=7',
      );
    });

    test('a new connection id asks for a resync, the same one does not', () {
      final first = checkSequence(
        connectionId: '',
        expected: 0,
        seq: 0,
        helloId: 'c1',
      );
      expect(first.resync, isTrue);
      expect(first.expected, 1);
      final resumed = checkSequence(
        connectionId: 'c1',
        expected: 5,
        seq: 5,
        helloId: 'c1',
      );
      expect(resumed.resync, isFalse);
      expect(resumed.connectionId, 'c1');
      final gap = checkSequence(connectionId: 'c1', expected: 5, seq: 7);
      expect(gap.gap, isTrue);
      expect(gap.connectionId, '');
    });
  });

  group('decoding', () {
    SocketFrame frame(String event, Map<String, Object?> data) =>
        SocketFrame.fromJson({
          'event': event,
          'data': data,
          'broadcast': {'channel_id': 'c1', 'team_id': 't1'},
          'seq': 3,
        });

    test('a posted event decodes the post and the mentions twice', () {
      final event = decodeEvent(
        frame('posted', {
          'post': jsonEncode({
            'id': 'p1',
            'channel_id': 'c1',
            'message': 'hi @me',
            'create_at': 1000,
          }),
          'mentions': jsonEncode(['me']),
        }),
      );
      expect(event, isA<PostedEvent>());
      final posted = event as PostedEvent;
      expect(posted.post!.message, 'hi @me');
      expect(posted.mentions, ['me']);
    });

    test('a bad inner payload is skipped, not thrown', () {
      final event = decodeEvent(frame('posted', {'post': '{not json'}));
      expect((event as PostedEvent).post, isNull);
    });

    test('preferences arrive one or many and can be deletions', () {
      final one = decodeEvent(
        frame('preference_changed', {
          'preference': jsonEncode({
            'category': 'favorite_channel',
            'name': 'c1',
            'value': 'true',
          }),
        }),
      );
      expect((one as PreferencesEvent).all.single.name, 'c1');
      final deleted = decodeEvent(
        frame('preferences_deleted', {
          'preferences': jsonEncode([
            {'category': 'favorite_channel', 'name': 'c1'},
            {'category': 'favorite_channel', 'name': 'c2'},
          ]),
        }),
      );
      expect((deleted as PreferencesEvent).deleted, isTrue);
      expect(deleted.all, hasLength(2));
    });

    test('a removal names the user from the broadcast when sent to them', () {
      final event = SocketFrame.fromJson({
        'event': 'user_removed',
        'data': {'channel_id': 'c9', 'remover_id': 'u2'},
        'broadcast': {'user_id': 'me'},
        'seq': 1,
      });
      final removed = decodeEvent(event) as UserRemovedEvent;
      expect(removed.removedUser, 'me');
      expect(removed.channel, 'c9');
    });

    test('unknown events are ignored', () {
      expect(
        decodeEvent(frame('custom_plugin_thing', {})),
        isA<UnknownEvent>(),
      );
    });
  });

  group('connection', () {
    late FakeSocketServer server;
    late ServerSocket socket;
    late List<ServerEvent> events;
    late int resyncs;

    setUp(() async {
      server = await FakeSocketServer.start();
      events = [];
      resyncs = 0;
    });

    tearDown(() async {
      await socket.dispose();
      await server.close();
    });

    void open({Duration ping = const Duration(seconds: 30)}) {
      socket = ServerSocket(
        serverUrl: server.url,
        token: () => 's3cret',
        onEvent: events.add,
        onResync: () => resyncs++,
        pingInterval: ping,
        retryDelayOf: (_) => const Duration(milliseconds: 10),
      );
      socket.start();
    }

    Future<void> until(bool Function() condition) async {
      for (var i = 0; i < 200 && !condition(); i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      expect(condition(), isTrue);
    }

    test('authenticates with the token after opening, then pings', () async {
      final actions = <Map<String, Object?>>[];
      server.actions.listen(actions.add);
      open();
      await until(() => actions.length >= 2);
      expect(actions[0]['action'], 'authentication_challenge');
      expect((actions[0]['data']! as Map)['token'], 's3cret');
      expect(actions[1]['action'], 'ping');
      final request = server.connections.single;
      expect(request.headers.value('origin'), server.url.origin);
      expect(request.uri.queryParameters['connection_id'], '');
      expect(socket.state.value, SocketState.connected);
    });

    test('a missing pong drops the connection and reconnects', () async {
      server.answerPings = false;
      open(ping: const Duration(milliseconds: 50));
      await until(() => server.connections.length >= 2);
    });

    test('a gap in the sequence reconnects fresh and resyncs', () async {
      open();
      await until(() => server.connections.length == 1);
      server.event('hello', 0, {'connection_id': 'first'});
      await until(() => resyncs == 1);
      server.event('status_change', 1, {'user_id': 'u1', 'status': 'away'});
      await until(() => events.length == 2);

      server.event('status_change', 3, {'user_id': 'u1', 'status': 'online'});
      await until(() => server.connections.length == 2);
      expect(server.connections.last.uri.queryParameters['connection_id'], '');
      server.event('hello', 0, {'connection_id': 'second'});
      await until(() => resyncs == 2);
      expect(events.whereType<StatusChangedEvent>(), hasLength(1));
    });

    test('a dropped connection resumes where it left off', () async {
      open();
      await until(() => server.connections.length == 1);
      server.event('hello', 0, {'connection_id': 'kept'});
      server.event('status_change', 1, {'user_id': 'u1', 'status': 'away'});
      await until(() => events.length == 2);

      await server.connections.single.socket.close();
      await until(() => server.connections.length == 2);
      final resumed = server.connections.last.uri.queryParameters;
      expect(resumed['connection_id'], 'kept');
      expect(resumed['sequence_number'], '2');
      server.event('hello', 2, {'connection_id': 'kept'});
      await until(() => events.length == 3);
      expect(resyncs, 1);
    });
  });

  group('events into the database', () {
    late FakeSocketServer server;
    late ServerSocket socket;
    late ServerDatabase db;
    late ServerStore store;
    late SyncRunner runner;
    late ServerApi http;
    late EventApplier applier;

    setUp(() async {
      server = await FakeSocketServer.start();
      db = ServerDatabase(DatabaseConnection(NativeDatabase.memory()));
      store = ServerStore(db);
      runner = SyncRunner();
      http = ServerApi(baseUrl: server.url, token: () => 't');
      final users = UserLoader(server: http, store: store);
      applier = EventApplier(
        server: http,
        store: store,
        runner: runner,
        users: users,
        entry: EntrySync(
          server: http,
          store: store,
          runner: runner,
          users: users,
        ),
        inbox: InboxSync(
          server: http,
          store: store,
          runner: runner,
          users: users,
        ),
      );
      await store.applyMe(api.User.fromJson({'id': 'me', 'username': 'alice'}));
      await store.applyChannels(
        channels: [
          api.Channel.fromJson({
            'id': 'c1',
            'team_id': 't1',
            'type': 'O',
            'name': 'design',
            'total_msg_count': 3,
            'total_msg_count_root': 3,
          }),
        ],
        members: [
          api.ChannelMember.fromJson({
            'channel_id': 'c1',
            'user_id': 'me',
            'msg_count': 3,
            'msg_count_root': 3,
          }),
        ],
      );
    });

    tearDown(() async {
      await socket.dispose();
      runner.close();
      http.close();
      await db.close();
      await server.close();
    });

    Future<({int unread, int mentions})> counts() async {
      final channel = await db.select(db.channels).getSingle();
      final mine = await db.select(db.myChannels).getSingle();
      return (
        unread: channel.totalMsgCount - mine.msgCount,
        mentions: mine.mentionCount,
      );
    }

    test('a new custom emoji is stored as it is announced', () async {
      final applied = StreamController<void>.broadcast();
      socket = ServerSocket(
        serverUrl: server.url,
        token: () => 't',
        onEvent: (e) => applier.add(e).then((_) => applied.add(null)),
        onResync: () {},
      );
      final connected = server.nextConnection();
      socket.start();
      await connected;

      var next = applied.stream.first;
      server.event('hello', 0, {'connection_id': 'x'});
      await next;
      next = applied.stream.first;
      server.event('emoji_added', 1, {
        'emoji': jsonEncode({
          'id': 'e1',
          'creator_id': 'bob',
          'name': 'partyblob',
          'create_at': 5000,
          'update_at': 5000,
          'delete_at': 0,
        }),
      });
      await next;
      final row = await db.select(db.customEmoji).getSingle();
      expect((row.id, row.name), ('e1', 'partyblob'));
      await applied.close();
    });

    test('a post from someone else counts, viewing elsewhere clears', () async {
      final applied = StreamController<void>.broadcast();
      socket = ServerSocket(
        serverUrl: server.url,
        token: () => 't',
        onEvent: (e) => applier.add(e).then((_) => applied.add(null)),
        onResync: () {},
      );
      final connected = server.nextConnection();
      socket.start();
      await connected;

      var next = applied.stream.first;
      server.event('hello', 0, {'connection_id': 'x'});
      await next;
      next = applied.stream.first;
      server.event('posted', 1, {
        'post': jsonEncode({
          'id': 'p9',
          'channel_id': 'c1',
          'user_id': 'bob',
          'message': '@alice look',
          'create_at': 5000,
        }),
        'mentions': jsonEncode(['me']),
      });
      await next;
      expect(await counts(), (unread: 1, mentions: 1));
      expect((await db.select(db.posts).getSingle()).message, '@alice look');
      expect(
        [for (final row in await db.select(db.postLists).get()) row.postId],
        ['p9'],
        reason: 'a live mention goes to the top of the mentions',
      );

      next = applied.stream.first;
      server.event('channel_viewed', 2, {'channel_id': 'c1'});
      await next;
      expect(await counts(), (unread: 0, mentions: 0));
      await applied.close();
    });
  });
}
