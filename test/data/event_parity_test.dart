import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/data/server_db/server_config.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/views/root_views.dart';
import 'package:matterleast/domain/channel_list.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';
import '../support/wait.dart';

/// Incoming events that must leave the same state as in the official app.
void main() {
  late FakeServer server;
  late ServerSession session;

  setUp(() async {
    (server, session) = await startServerSession();
    server.handle = (r) => ok({'status': 'OK'});
    await session.store.applyCategoryUpdates([
      api.SidebarCategoryWithChannels.fromJson({
        'id': 'cat1',
        'team_id': teamId,
        'user_id': meId,
        'type': 'channels',
        'display_name': 'Channels',
        'channel_ids': [channelId],
      }),
    ]);
  });

  Future<void> receive(
    String event,
    Map<String, Object?> data, {
    Map<String, Object?>? broadcast,
  }) => session.connection.events.add(
    decodeEvent(
      SocketFrame.fromJson({
        'event': event,
        'data': data,
        'broadcast': broadcast ?? {'channel_id': channelId, 'user_id': meId},
        'seq': 1,
      }),
    ),
  );

  var minute = 0;
  Future<void> posted({
    String from = 'someone',
    String type = '',
    bool mentionsMe = false,
    String? priority,
  }) => receive('posted', {
    'post': jsonEncode({
      'id': 'p${minute++}',
      'channel_id': channelId,
      'user_id': from,
      'type': type,
      'create_at': DateTime.utc(
        2026,
        10,
        25,
        10,
        minute,
      ).millisecondsSinceEpoch,
      'message': mentionsMe ? '@river the boats' : 'about the boats',
      if (priority != null)
        'metadata': {
          'priority': {'priority': priority},
        },
    }),
    if (mentionsMe) 'mentions': jsonEncode([meId]),
  });

  Future<ChannelItem> listed() async {
    final list = await RootViews(session.db).channelList(teamId).first;
    return list.sections
        .expand((s) => s.rows)
        .firstWhere((c) => c.id == channelId);
  }

  Future<MyChannelRow> member() => (session.db.select(
    session.db.myChannels,
  )..where((m) => m.channelId.equals(channelId))).getSingle();

  Future<void> markUnreadHere() => session.store.applyMarkedUnread(
    api.ChannelMember.fromJson({
      'channel_id': channelId,
      'user_id': meId,
      'msg_count': 0,
    }),
  );

  group('a new message', () {
    test(
      'an urgent mention counts as urgent, an ordinary one does not',
      () async {
        await posted(mentionsMe: true);
        expect((await member()).urgentMentionCount, 0);
        await posted(mentionsMe: true, priority: 'urgent');
        expect((await member()).urgentMentionCount, 1);
        expect((await listed()).mentions, 2);
      },
    );

    test('my own message reads the channel', () async {
      await posted();
      expect((await listed()).unread, isTrue);
      await posted(from: meId);
      expect((await listed()).unread, isFalse);
    });

    test('my own message leaves a channel I marked unread unread', () async {
      await markUnreadHere();
      expect((await listed()).unread, isTrue);
      await posted(from: meId);
      expect((await listed()).unread, isTrue);
      expect((await member()).manuallyUnread, isTrue);
    });

    test('someone joining does not make the channel unread', () async {
      await posted(type: 'system_join_channel');
      await posted(type: 'system_add_to_channel');
      expect((await listed()).unread, isFalse);
    });
  });

  test('a message marked unread on another device stays unread here, even '
      'after I post', () async {
    server.handle = (r) => switch (r.path) {
      '/api/v4/channels/$channelId' => ok({
        'id': channelId,
        'team_id': teamId,
        'type': 'O',
        'name': 'boats',
        'display_name': 'Boats',
        'total_msg_count': 3,
      }),
      '/api/v4/channels/$channelId/members/me' => ok({
        'channel_id': channelId,
        'user_id': meId,
        'msg_count': 1,
        'mention_count': 1,
      }),
      _ => ok({'status': 'OK'}),
    };
    await receive(
      'post_unread',
      {'msg_count': 1, 'mention_count': 1, 'last_viewed_at': 1},
      broadcast: {'channel_id': channelId, 'team_id': teamId, 'user_id': meId},
    );
    await eventually(() async => (await member()).manuallyUnread);
    final item = await listed();
    expect((item.unread, item.mentions), (true, 1));

    await posted(from: meId);
    expect((await listed()).unread, isTrue);
  });

  group('events we had ignored', () {
    test('someone who stops typing leaves the typing line', () async {
      await session.store.applyConfig(ConfigKeys.clientConfig, {
        'TimeBetweenUserTypingUpdatesMilliseconds': '60000',
      });
      final typing = session.connection.typing;
      await receive('typing', {'user_id': 'u9', 'parent_id': 'root1'});
      expect(await typing.watch(channelId, rootId: 'root1').first, ['u9']);
      await receive('stop_typing', {'user_id': 'u9', 'parent_id': 'root1'});
      expect(await typing.watch(channelId, rootId: 'root1').first, isEmpty);
    });

    test('a restored team comes back on the rail when I am in it', () async {
      const other = 'tm000000000000000000000t02';
      server.handle = (r) => switch (r.path) {
        '/api/v4/teams/$other/members/me' => ok({
          'team_id': other,
          'user_id': meId,
          'roles': 'team_user',
          'delete_at': 0,
        }),
        '/api/v4/teams/$other' => ok({
          'id': other,
          'name': 'quay',
          'display_name': 'Quay',
        }),
        _ => ok(<Object?>[]),
      };
      await receive('restore_team', {
        'team': jsonEncode({'id': other, 'name': 'quay'}),
      }, broadcast: {});
      await eventually(
        () async => (await RootViews(session.db).railTeams().first).length == 2,
      );
    });

    test('a restored team I am not in stays away', () async {
      const other = 'tm000000000000000000000t03';
      server.handle = (r) => error(404, 'app.team.get_member.missing');
      await receive('restore_team', {
        'team': jsonEncode({'id': other, 'name': 'pier'}),
      }, broadcast: {});
      await eventually(
        () => server.paths.contains('/api/v4/teams/$other/members/me'),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect((await RootViews(session.db).railTeams().first).length, 1);
    });

    test('a changed channel scheme fetches the roles it now gives', () async {
      server.handle = (r) => switch (r.path) {
        '/api/v4/channels/$channelId' => ok({
          'id': channelId,
          'team_id': teamId,
          'type': 'O',
          'name': 'boats',
        }),
        '/api/v4/channels/$channelId/members/me' => ok({
          'channel_id': channelId,
          'user_id': meId,
          'roles': 'scheme1_channel_user',
        }),
        '/api/v4/roles/names' => ok([
          {
            'id': 'r1',
            'name': 'scheme1_channel_user',
            'permissions': ['create_post'],
          },
        ]),
        _ => ok(<Object?>[]),
      };
      await receive('channel_scheme_updated', {});
      await eventually(
        () async =>
            (await session.store.roleNames()).contains('scheme1_channel_user'),
      );
      expect((await member()).roles, 'scheme1_channel_user');
    });

    test('a toast from a plugin and a refused download reach the user, a '
        'refused thumbnail does not', () async {
      final notices = <String>[];
      final sub = session.connection.notices.listen(notices.add);
      await receive('show_toast', {'message': 'Export finished'});
      await receive('file_download_rejected', {
        'file_id': 'f1',
        'download_type': 'file',
        'rejection_reason': 'Files from this channel are blocked',
      });
      await receive('file_download_rejected', {
        'file_id': 'f2',
        'download_type': 'thumbnail',
        'rejection_reason': 'blocked',
      });
      await receive('file_download_rejected', {
        'file_id': 'f3',
        'download_type': 'preview',
      });
      await pumpEventQueue();
      expect(notices, [
        'Export finished',
        'Files from this channel are blocked',
        'A plugin blocked access to this file.',
      ]);
      await sub.cancel();
    });
  });

  group('members of a channel', () {
    var members = 4;
    setUp(() {
      members = 4;
      server.handle = (r) => r.path == '/api/v4/channels/$channelId/stats'
          ? ok({'channel_id': channelId, 'member_count': members})
          : ok(<Object?>[]);
    });

    Future<int?> memberCount() async => (await (session.db.select(
      session.db.channels,
    )..where((c) => c.id.equals(channelId))).getSingle()).memberCount;

    test('someone else added or removed updates the count', () async {
      await receive(
        'user_added',
        {'user_id': 'u9', 'team_id': teamId},
        broadcast: {'channel_id': channelId},
      );
      await eventually(() async => await memberCount() == 4);
      members = 3;
      await receive(
        'user_removed',
        {'user_id': 'u9', 'remover_id': 'u8'},
        broadcast: {'channel_id': channelId},
      );
      await eventually(() async => await memberCount() == 3);
    });
  });
}
