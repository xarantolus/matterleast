import 'dart:async';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/actions/post_actions.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/store/server_store.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

void main() {
  late FakeServer server;
  late ServerSession session;
  late PostActions actions;

  /// Holds the server's answer until released, to look at the screen's
  /// data in between.
  Completer<Reply>? hold;
  Reply answer = ok({'status': 'OK'});

  setUp(() async {
    hold = null;
    answer = ok({'status': 'OK'});
    server = await FakeServer.start();
    server.handle = (r) => hold?.future ?? answer;
    session = await testSession(server);
    actions = PostActions(session);
  });

  tearDown(() async {
    await closeTestSession(session);
    await server.close();
  });

  Future<PostRow> old1() async => (await session.store.post('old1'))!;

  Future<List<String>> myReactions() async => [
    for (final r in await (session.db.select(
      session.db.reactions,
    )..where((r) => r.postId.equals('old1') & r.userId.equals(meId))).get())
      r.emojiName,
  ];

  test('a reaction shows before the server answers', () async {
    hold = Completer();
    final adding = actions.addReaction('old1', 'tada');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(await myReactions(), ['tada']);
    expect((await old1()).reactionCount, 1);
    hold!.complete(ok({'user_id': meId, 'post_id': 'old1'}));
    await adding;
    final sent = server.seen.single;
    expect(sent.path, '/api/v4/reactions');
    expect(sent.body['emoji_name'], 'tada');
    expect(await session.store.recentEmoji(), ['tada']);
  });

  test('the reaction event arriving too changes nothing', () async {
    await actions.addReaction('old1', 'tada');
    await session.store.applyReaction(
      api.Reaction.fromJson({
        'user_id': meId,
        'post_id': 'old1',
        'emoji_name': 'tada',
      }),
      added: true,
    );
    expect(await myReactions(), ['tada']);
    expect((await old1()).reactionCount, 1);
  });

  test('a refused reaction is taken back and the error passed on', () async {
    answer = error(403, 'api.reaction.save.forbidden');
    await expectLater(
      actions.addReaction('old1', 'tada'),
      throwsA(isA<ServerError>()),
    );
    expect(await myReactions(), isEmpty);
    expect((await old1()).reactionCount, 0);
  });

  test('removing a reaction that the server keeps puts it back', () async {
    await actions.addReaction('old1', 'tada');
    answer = error(500, 'boom');
    await expectLater(
      actions.removeReaction('old1', 'tada'),
      throwsA(isA<ServerError>()),
    );
    expect(await myReactions(), ['tada']);
    answer = ok({'status': 'OK'});
    await actions.removeReaction('old1', 'tada');
    expect(await myReactions(), isEmpty);
    expect(
      server.seen.last.path,
      '/api/v4/users/$meId/posts/old1/reactions/tada',
    );
  });

  test('an edit shows at once and only the text is sent', () async {
    hold = Completer();
    final editing = actions.editPost('old1', 'good morning');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect((await old1()).message, 'good morning');
    expect((await old1()).editAt, isNotNull);
    expect(server.seen.single.body, {'message': 'good morning'});
    hold!.complete(
      ok({
        'id': 'old1',
        'channel_id': channelId,
        'user_id': 'someone',
        'create_at': DateTime.utc(2026, 10, 25, 9).millisecondsSinceEpoch,
        'edit_at': DateTime.utc(2026, 10, 25, 10).millisecondsSinceEpoch,
        'message': 'good morning',
      }),
    );
    await editing;
    expect((await old1()).editAt, DateTime.utc(2026, 10, 25, 10));
  });

  test('a refused edit puts the old text back', () async {
    answer = error(403, 'api.post.update_post.permissions_details.app_error');
    await expectLater(
      actions.editPost('old1', 'nope'),
      throwsA(isA<ServerError>()),
    );
    expect((await old1()).message, 'morning');
    expect((await old1()).editAt, isNull);
  });

  test(
    'a deleted post goes without a placeholder once the server agrees',
    () async {
      answer = error(403, 'nope');
      await expectLater(
        actions.deletePost('old1'),
        throwsA(isA<ServerError>()),
      );
      expect(await session.store.post('old1'), isNotNull);
      answer = ok({'status': 'OK'});
      await actions.deletePost('old1');
      expect(await session.store.post('old1'), isNull);
      await session.store.applyDelete(
        'old1',
        at: DateTime.utc(2026, 10, 25, 11),
      );
      expect(await session.store.post('old1'), isNull);
    },
  );

  test(
    'saving shows in the saved list at once and is undone on failure',
    () async {
      Future<List<String>> saved() async => [
        for (final row in await (session.db.select(
          session.db.postLists,
        )..where((l) => l.list.equals(PostListNames.saved))).get())
          row.postId,
      ];
      await actions.savePost('old1');
      expect(await saved(), ['old1']);
      expect(server.seen.single.path, '/api/v4/users/$meId/preferences');
      expect(server.seen.single.json, [
        {
          'user_id': meId,
          'category': 'flagged_post',
          'name': 'old1',
          'value': 'true',
        },
      ]);
      answer = error(500, 'boom');
      await expectLater(
        actions.unsavePost('old1'),
        throwsA(isA<ServerError>()),
      );
      expect(await saved(), ['old1']);
      answer = ok({'status': 'OK'});
      await actions.unsavePost('old1');
      expect(await saved(), isEmpty);
      expect(server.seen.last.path, '/api/v4/users/$meId/preferences/delete');
    },
  );

  test('pinning shows at once and is undone on failure', () async {
    await actions.pinPost('old1');
    expect((await old1()).isPinned, isTrue);
    expect(server.seen.single.path, '/api/v4/posts/old1/pin');
    answer = error(403, 'nope');
    await expectLater(actions.unpinPost('old1'), throwsA(isA<ServerError>()));
    expect((await old1()).isPinned, isTrue);
  });

  test(
    'marking unread takes the server counts and keeps the channel unread',
    () async {
      server.handle = (r) => switch (r.path) {
        '/api/v4/users/$meId/posts/old1/set_unread' => ok({
          'channel_id': channelId,
          'msg_count': 0,
        }),
        '/api/v4/channels/$channelId' => ok({
          'id': channelId,
          'team_id': teamId,
          'type': 'O',
          'name': 'boats',
          'display_name': 'Boats',
          'total_msg_count': 1,
        }),
        '/api/v4/channels/$channelId/members/me' => ok({
          'channel_id': channelId,
          'user_id': meId,
          'msg_count': 0,
        }),
        _ => error(404, 'not_found'),
      };
      await actions.markUnread('old1');
      expect(server.seen.first.body, {'collapsed_threads_supported': false});
      final mine = await session.db.select(session.db.myChannels).getSingle();
      final channel = await session.db.select(session.db.channels).getSingle();
      expect(channel.totalMsgCount - mine.msgCount, 1);
      expect(mine.manuallyUnread, isTrue);
    },
  );

  test('following a thread shows at once and is undone on failure', () async {
    await session.db
        .into(session.db.threads)
        .insert(ThreadsCompanion.insert(rootId: 'old1', channelId: channelId));
    Future<bool> following() async =>
        (await session.db.select(session.db.threads).getSingle()).isFollowing;
    await actions.followThread(teamId, 'old1');
    expect(await following(), isTrue);
    expect(server.seen.single.method, 'PUT');
    expect(
      server.seen.single.path,
      '/api/v4/users/me/teams/$teamId/threads/old1/following',
    );
    answer = error(500, 'boom');
    await expectLater(
      actions.unfollowThread(teamId, 'old1'),
      throwsA(isA<ServerError>()),
    );
    expect(await following(), isTrue);
  });
}
