import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/data/actions/conversation_actions.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';
import '../support/wait.dart';

/// A server answer that was computed before something else happened and
/// arrives after it must not undo it. Each test holds the answer on a
/// Completer, applies the later fact, then lets the old answer in.
void main() {
  late FakeServer server;
  late ServerSession session;

  setUp(() async {
    (server, session) = await startServerSession();
    server.handle = emptyAnswer;
  });

  int ms(int minute) =>
      DateTime.utc(2026, 10, 25, 9, minute).millisecondsSinceEpoch;
  DateTime at(int minute) =>
      DateTime.fromMillisecondsSinceEpoch(ms(minute), isUtc: true);

  Map<String, Object?> post(
    String id,
    int minute, {
    String message = 'text',
    int? updateAt,
    Map<String, Object?>? metadata,
  }) => {
    'id': id,
    'channel_id': channelId,
    'user_id': 'someone',
    'create_at': ms(minute),
    'update_at': updateAt ?? ms(minute),
    'message': message,
    'metadata': ?metadata,
  };

  api.Post asPost(Map<String, Object?> json) => api.Post.fromJson(json);

  Map<String, Object?> pageOf(List<Map<String, Object?>> posts) => {
    'order': [for (final p in posts.reversed) p['id']],
    'posts': {for (final p in posts) p['id']! as String: p},
  };

  group('a posts answer that predates a live change', () {
    // The seeded post `old1` ("morning") sits at minute 0. The channel is
    // refreshed; its answer, made before the change below, is held.
    late Completer<void> held;
    late Future<bool> refresh;

    Future<void> staleAnswer(Map<String, Object?> old) async {
      held = Completer();
      server.handle = (r) async {
        if (r.path != '/api/v4/channels/$channelId/posts') {
          return emptyAnswer(r);
        }
        await held.future;
        return ok(pageOf([old]));
      };
      refresh = ConversationActions(session).refreshChannel(channelId);
      await eventually(
        () => server.paths.contains('/api/v4/channels/$channelId/posts'),
      );
    }

    Future<void> letItIn() async {
      held.complete();
      await refresh;
    }

    test('does not bring back the text an edit replaced', () async {
      await staleAnswer(post('old1', 0, message: 'morning', metadata: {}));
      await session.store.applyEdit(
        asPost(post('old1', 0, message: 'good morning', updateAt: ms(5))),
      );
      await letItIn();
      expect((await session.store.post('old1'))!.message, 'good morning');
    }, skip: 'fix not built yet: posts are stored without a server-time guard');

    test('does not bring back a deleted message', () async {
      await staleAnswer(post('old1', 0, message: 'morning', metadata: {}));
      await session.store.applyDelete('old1', at: at(5));
      await letItIn();
      final row = (await session.store.post('old1'))!;
      expect(row.deleteAt, isNotNull);
      expect(row.message, isEmpty);
    }, skip: 'fix not built yet: posts are stored without a server-time guard');

    test(
      'does not drop a reaction that was added after it was made',
      () async {
        await staleAnswer(
          post('old1', 0, metadata: {'reactions': <Object?>[]}),
        );
        await session.store.applyReaction(
          api.Reaction.fromJson({
            'user_id': 'someone',
            'post_id': 'old1',
            'emoji_name': 'tada',
            'create_at': ms(5),
          }),
          added: true,
        );
        await letItIn();
        final reactions = await session.db.select(session.db.reactions).get();
        expect(reactions.map((r) => r.emojiName), ['tada']);
      },
      skip: 'fix not built yet: a page replaces the reactions unconditionally',
    );

    test(
      'still brings in an edit made by someone while we were away',
      () async {
        await staleAnswer(
          post('old1', 0, message: 'edited elsewhere', updateAt: ms(7)),
        );
        await letItIn();
        expect((await session.store.post('old1'))!.message, 'edited elsewhere');
      },
    );
  });

  group('history after a gap in the socket', () {
    test(
      'posts missed while disconnected appear when the channel opens, '
      'although a live post arrived after them',
      () async {
        // `old1` (minute 0) is the newest stored post. Posts m1..m3 were
        // sent while the socket was down; m4 arrived live after it came back.
        final missed = [for (var i = 1; i <= 3; i++) post('m$i', i * 10)];
        await session.store.applyLivePost(
          asPost(post('m4', 40)),
          fromSelf: false,
          mentionsMe: false,
        );
        server.handle = (r) {
          if (r.path != '/api/v4/channels/$channelId/posts') {
            return emptyAnswer(r);
          }
          final since = int.parse(r.raw.uri.queryParameters['since'] ?? '0');
          return ok(
            pageOf([
              for (final p in [...missed, post('m4', 40)])
                if ((p['update_at']! as int) > since) p,
            ]),
          );
        };
        await ConversationActions(session).refreshChannel(channelId);
        for (final id in ['m1', 'm2', 'm3']) {
          expect(await session.store.post(id), isNotNull, reason: id);
        }
      },
      skip:
          'fix not built yet: the since-fetch starts at the newest stored post',
    );
  });

  group('a team answer that predates a change', () {
    final channel = {
      'id': channelId,
      'team_id': teamId,
      'type': 'O',
      'name': 'boats',
      'display_name': 'Boats',
      'total_msg_count': 1,
      'last_post_at': ms(0),
    };
    final member = {
      'channel_id': channelId,
      'user_id': meId,
      'msg_count': 1,
      'last_viewed_at': ms(0),
    };
    late Completer<void> held;
    late Future<void> refresh;

    Future<void> staleTeam() async {
      held = Completer();
      server.handle = (r) async => switch (r.path) {
        '/api/v4/users/me/teams/$teamId/channels' => await held.future.then(
          (_) => ok([channel]),
        ),
        '/api/v4/users/me/teams/$teamId/channels/members' => ok([member]),
        _ => emptyAnswer(r),
      };
      refresh = session.connection.entry.refreshTeam(teamId);
      await eventually(
        () => server.paths.contains(
          '/api/v4/users/me/teams/$teamId/channels/members',
        ),
      );
    }

    Future<void> letItIn() async {
      held.complete();
      await refresh;
    }

    Future<ChannelRow> channelRow() => (session.db.select(
      session.db.channels,
    )..where((c) => c.id.equals(channelId))).getSingle();

    test('keeps the newer last-post time and count of my own post', () async {
      await staleTeam();
      await session.store.applySent(
        'pending1',
        asPost(post('mine', 30)..['user_id'] = meId),
      );
      await letItIn();
      final row = await channelRow();
      expect(row.lastPostAt, at(30));
      expect(row.totalMsgCount, 2);
    }, skip: 'fix not built yet: channel rows are overwritten verbatim');

    test(
      'does not bring the unread badge back after I read the channel',
      () async {
        await session.store.applyLivePost(
          asPost(post('m1', 10)),
          fromSelf: false,
          mentionsMe: true,
        );
        await staleTeam();
        await session.store.markViewed(channelId, at: at(10));
        await letItIn();
        final mine = await (session.db.select(
          session.db.myChannels,
        )..where((m) => m.channelId.equals(channelId))).getSingle();
        expect(mine.lastViewedAt, at(10));
        expect(mine.mentionCount, 0);
      },
      skip: 'fix not built yet: memberships are overwritten verbatim',
    );

    test(
      'does not bring back a channel I was removed from meanwhile',
      () async {
        await staleTeam();
        await session.connection.events.add(
          decodeEvent(
            SocketFrame.fromJson({
              'event': 'user_removed',
              'data': {'channel_id': channelId, 'remover_id': 'someone'},
              'broadcast': {'channel_id': channelId, 'user_id': meId},
              'seq': 1,
            }),
          ),
        );
        await eventually(
          () async =>
              (await session.db.select(session.db.channels).get()).isEmpty,
        );
        await letItIn();
        expect(await session.db.select(session.db.channels).get(), isEmpty);
        expect(await session.db.select(session.db.myChannels).get(), isEmpty);
      },
      skip: 'fix not built yet: only a later store counts, not a removal',
    );
  });
}
