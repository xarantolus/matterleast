import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/views/conversation_views.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

void main() {
  late FakeServer server;
  late ServerSession session;

  setUp(() async {
    (server, session) = await startServerSession();
  });

  test('people a thread shows but nobody stored are fetched once', () async {
    final at = DateTime.utc(2026, 11, 5).millisecondsSinceEpoch;
    await session.store.applyThreadPage(
      rootId: 'root',
      page: api.PostList.fromJson({
        'order': ['root'],
        'posts': {
          'root': {
            'id': 'root',
            'channel_id': channelId,
            'user_id': 'newcomer',
            'create_at': at,
            'message': 'hello',
          },
        },
      }),
    );
    server.handle = (r) => r.path == '/api/v4/users/ids'
        ? ok([
            {'id': 'newcomer', 'username': 'quinn', 'roles': 'system_user'},
          ])
        : ok(<Object?>[]);
    final views = ConversationViews(
      session.db,
      missingPeople: session.users.fetchMissing,
    );
    final windows = views
        .thread('root', limit: 30, deletedUpTo: DateTime.utc(2026))
        .asBroadcastStream();
    final named = windows.firstWhere((w) => w.root?.authorName == 'quinn');
    expect(await windows.first, isNotNull);
    await named.timeout(const Duration(seconds: 5));
    expect(
      server.seen.where((r) => r.path == '/api/v4/users/ids'),
      hasLength(1),
    );
  });
}
