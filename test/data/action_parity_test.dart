import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/data/actions/channel_actions.dart';
import 'package:matterleast/data/actions/conversation_actions.dart';
import 'package:matterleast/data/actions/post_actions.dart';
import 'package:matterleast/data/actions/team_actions.dart';
import 'package:matterleast/data/server_db/server_config.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/data/views/channel_views.dart';
import 'package:matterleast/data/views/root_views.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

/// Actions that must leave the same state as in the official app.
void main() {
  late FakeServer server;
  late ServerSession session;

  setUp(() async {
    (server, session) = await startServerSession();
    server.handle = (r) => ok({'status': 'OK'});
  });

  Future<void> receive(String event, Map<String, Object?> data) =>
      session.connection.events.add(
        decodeEvent(
          SocketFrame.fromJson({
            'event': event,
            'data': data,
            'broadcast': {'channel_id': channelId, 'user_id': meId},
            'seq': 1,
          }),
        ),
      );

  Map<String, Object?> post(
    String id, {
    String rootId = '',
    int minute = 0,
    bool pinned = false,
  }) => {
    'id': id,
    'channel_id': channelId,
    'root_id': rootId,
    'user_id': 'someone',
    'create_at': DateTime.utc(2026, 10, 25, 10, minute).millisecondsSinceEpoch,
    'message': 'about the boats',
    'is_pinned': pinned,
  };

  Future<void> storeThread({
    required int replies,
    int unreadReplies = 0,
    int unreadMentions = 0,
  }) async {
    await session.store.applyChannelPage(
      channelId: channelId,
      page: api.PostList.fromJson({
        'order': ['root1'],
        'posts': {
          'root1': {...post('root1'), 'reply_count': replies},
          for (var i = 1; i <= replies; i++)
            'reply$i': post('reply$i', rootId: 'root1', minute: i),
        },
      }),
      kind: PageKind.page,
    );
    await session.store.applyThreads(teamId, [
      api.UserThread.fromJson({
        'id': 'root1',
        'reply_count': replies,
        'unread_replies': unreadReplies,
        'unread_mentions': unreadMentions,
        'is_following': true,
        'post': post('root1'),
      }),
    ]);
  }

  Future<int> rootReplies() async =>
      (await session.store.post('root1'))!.replyCount;

  Future<int> threadReplies() async => (await (session.db.select(
    session.db.threads,
  )..where((t) => t.rootId.equals('root1'))).getSingle()).replyCount;

  group('the rail under collapsed threads', () {
    setUp(() async {
      await session.store.applyConfig(ConfigKeys.clientConfig, {
        'CollapsedThreads': 'always_on',
      });
    });

    test('counts a mention in a followed thread on its team', () async {
      await storeThread(replies: 2, unreadReplies: 1, unreadMentions: 1);
      final team = (await RootViews(session.db).railTeams().first).single;
      expect(team.mentions, 1);
      expect(team.unread, isTrue);
    });

    test('drops the thread once it is read', () async {
      await storeThread(replies: 2, unreadReplies: 1, unreadMentions: 1);
      await session.store.applyThreadRead(teamId: teamId, threadId: 'root1');
      final team = (await RootViews(session.db).railTeams().first).single;
      expect(team.mentions, 0);
    });
  });

  group('pinned messages', () {
    Future<List<String>> pinned() => ChannelViews(
      session.db,
      serverUrl: server.url.toString(),
    ).listIds(ChannelActions.pinnedList(channelId)).first;

    test('a message pinned here joins the pinned list at once', () async {
      await PostActions(session).pinPost('old1');
      expect(await pinned(), ['old1']);
      await PostActions(session).unpinPost('old1');
      expect(await pinned(), isEmpty);
    });

    test('a message unpinned elsewhere leaves the pinned list', () async {
      await PostActions(session).pinPost('old1');
      await receive('post_edited', {
        'post':
            '{"id":"old1","channel_id":"$channelId","user_id":"someone",'
            '"create_at":${DateTime.utc(2026, 10, 25, 9).millisecondsSinceEpoch},'
            '"message":"morning","is_pinned":false}',
      });
      expect(await pinned(), isEmpty);
    });
  });

  group('a deleted reply', () {
    test('counts one reply less when deleted elsewhere, once', () async {
      await storeThread(replies: 2);
      final event = {
        'post':
            '{"id":"reply1","channel_id":"$channelId",'
            '"root_id":"root1","user_id":"someone","create_at":1,'
            '"delete_at":2}',
      };
      await receive('post_deleted', event);
      await receive('post_deleted', event);
      expect(await rootReplies(), 1);
      expect(await threadReplies(), 1);
    });

    test('counts one reply less when the user deletes it', () async {
      await storeThread(replies: 2);
      await PostActions(session).deletePost('reply2');
      expect(await rootReplies(), 1);
      expect(await threadReplies(), 1);
    });
  });

  test('mark all threads read reads every thread of the team', () async {
    await storeThread(replies: 2, unreadReplies: 2, unreadMentions: 1);
    await ConversationActions(session).markAllThreadsRead(teamId);
    expect(server.seen.last.method, 'PUT');
    expect(
      server.seen.last.path,
      '/api/v4/users/me/teams/$teamId/threads/read',
    );
    final thread = await (session.db.select(
      session.db.threads,
    )..where((t) => t.rootId.equals('root1'))).getSingle();
    expect(thread.unreadReplies, 0);
    expect(thread.unreadMentions, 0);
  });

  group('+:emoji: in the composer', () {
    test('reacts to the newest message instead of sending', () async {
      final reacted = await PostActions(
        session,
      ).reactToNewest(channelId, rootId: '', emojiName: 'thumbsup', add: true);
      expect(reacted, isTrue);
      final sent = server.seen.single;
      expect(sent.path, '/api/v4/reactions');
      expect(sent.body['post_id'], 'old1');
      expect(sent.body['emoji_name'], '+1');
    });

    test('-:emoji: takes the reaction back', () async {
      final actions = PostActions(session);
      await actions.addReaction('old1', 'tada');
      await actions.reactToNewest(
        channelId,
        rootId: '',
        emojiName: 'tada',
        add: false,
      );
      expect(server.seen.last.method, 'DELETE');
      expect(await (session.db.select(session.db.reactions)).get(), isEmpty);
    });

    test('an unknown emoji is sent as text', () async {
      expect(
        await PostActions(session).reactToNewest(
          channelId,
          rootId: '',
          emojiName: 'no_such_emoji_here',
          add: true,
        ),
        isFalse,
      );
      expect(server.seen, isEmpty);
    });
  });

  test('leaving a team takes it off the rail at once', () async {
    await TeamActions(session).leave(teamId);
    expect(await session.db.select(session.db.myTeams).get(), isEmpty);
  });
}
