import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/actions/message_search.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/views/search_views.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

void main() {
  late FakeServer server;
  late ServerSession session;
  late MessageSearch search;

  const otherChannel = 'ch000000000000000000000c09';
  const postId = 'po000000000000000000000p01';
  const fileId = 'fi000000000000000000000f01';

  final postList = {
    'order': [postId],
    'posts': {
      postId: {
        'id': postId,
        'channel_id': otherChannel,
        'user_id': meId,
        'message': 'harbour lights tonight',
        'create_at': 1700000000000,
        'update_at': 1700000000000,
      },
    },
  };

  setUp(() async {
    server = await FakeServer.start();
    session = await testSession(server);
    search = MessageSearch(
      session,
      SearchViews(session.db, serverUrl: server.url.toString()),
    );
    server.handle = (r) => switch (r.path) {
      '/api/v4/posts/search' ||
      '/api/v4/teams/$teamId/posts/search' => ok(postList),
      '/api/v4/files/search' => ok({
        'order': [fileId],
        'file_infos': {
          fileId: {
            'id': fileId,
            'name': 'harbour.pdf',
            'extension': 'pdf',
            'channel_id': otherChannel,
            'post_id': postId,
          },
        },
      }),
      '/api/v4/users/ids' => ok(<Object>[]),
      _ => error(404, 'not_found'),
    };
  });

  tearDown(() async {
    await closeTestSession(session);
    await server.close();
  });

  test('searching all teams finds messages outside the current team', () async {
    expect(await search.posts(null, 'harbour'), [postId]);
    final asked = server.seen.where((r) => r.path == '/api/v4/posts/search');
    expect(asked.single.body, containsPair('terms', 'harbour'));
  });

  test('searching all teams finds files outside the current team', () async {
    final hits = await search.files(null, 'harbour');
    expect(hits.map((h) => h.name), ['harbour.pdf']);
  });

  test('a team search stays in the team', () async {
    await search.posts(teamId, 'harbour');
    expect(server.paths, isNot(contains('/api/v4/posts/search')));
    expect(server.paths, contains('/api/v4/teams/$teamId/posts/search'));
  });
}
