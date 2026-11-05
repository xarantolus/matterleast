import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/actions/conversation_actions.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/store/server_store.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

void main() {
  late FakeServer server;
  late ServerSession session;
  late ConversationActions actions;

  setUp(() async {
    (server, session) = await startServerSession();
    actions = ConversationActions(session);
  });

  final start = DateTime.utc(2026, 10, 26, 10);

  Map<String, Object?> page(int from, int count) {
    final ids = [for (var i = from + count - 1; i >= from; i--) 'n$i'];
    return {
      'order': ids,
      'posts': {
        for (var i = from; i < from + count; i++)
          'n$i': {
            'id': 'n$i',
            'channel_id': channelId,
            'user_id': 'someone',
            'create_at': start.add(Duration(seconds: i)).millisecondsSinceEpoch,
            'message': 'message $i',
          },
      },
    };
  }

  void answer({required int sinceCount}) {
    server.handle = (r) {
      if (r.path != '/api/v4/channels/$channelId/posts') {
        return ok(<Object?>[]);
      }
      final query = r.raw.uri.queryParameters;
      return query.containsKey('since')
          ? ok(page(0, sinceCount))
          : ok(page(sinceCount - ConversationActions.pageSize, 60));
    };
  }

  test('a few new messages join the stored history', () async {
    answer(sinceCount: 3);
    expect(await actions.refreshChannel(channelId), isFalse);
    expect(await session.store.rangesFor('channel', channelId), hasLength(1));
    expect(
      server.seen.where(
        (r) =>
            r.path.endsWith('/posts') &&
            !r.raw.uri.queryParameters.containsKey('since'),
      ),
      isEmpty,
      reason: 'no second request',
    );
  });

  test('more changes than one answer holds open at the newest page, apart '
      'from what was stored', () async {
    answer(sinceCount: sinceCap);
    expect(await actions.refreshChannel(channelId), isTrue);
    final ranges = await session.store.rangesFor('channel', channelId);
    expect(ranges, hasLength(2), reason: 'a gap, not false continuity');
    final newest = await session.store.post('n${sinceCap - 1}');
    expect(newest, isNotNull);
  });

  test('a thread whose first message is gone on the server shows as '
      'deleted, not as an error', () async {
    Map<String, Object?> post(String id, int second, {String root = ''}) => {
      'id': id,
      'channel_id': channelId,
      'user_id': 'someone',
      'root_id': root,
      'create_at': start.add(Duration(seconds: second)).millisecondsSinceEpoch,
      'message': 'message $id',
    };
    await session.store.applyThreadPage(
      rootId: 'root',
      page: api.PostList.fromJson({
        'order': ['reply', 'root'],
        'posts': {
          'root': post('root', 0),
          'reply': post('reply', 1, root: 'root'),
        },
      }),
    );
    server.handle = (r) => r.path == '/api/v4/posts/root/thread'
        ? error(404, 'app.post.get.app_error')
        : ok(<Object?>[]);
    await actions.refreshThread('root');
    for (final id in ['root', 'reply']) {
      expect((await session.store.post(id))?.deleteAt, isNotNull, reason: id);
    }
  });
}
