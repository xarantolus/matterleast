import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/actions/conversation_actions.dart';
import 'package:matterleast/data/server_db/server_config.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/views/root_views.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';
import '../support/wait.dart';

void main() {
  late FakeServer server;
  late ServerSession session;

  setUp(() async {
    (server, session) = await startServerSession();
    await session.store.applyConfig(ConfigKeys.clientConfig, {
      'CollapsedThreads': 'always_on',
    });
  });

  Future<void> follow({required int replies, required int mentions}) =>
      session.store.applyThreads(teamId, [
        api.UserThread.fromJson({
          'id': 'old1',
          'reply_count': 1,
          'unread_replies': replies,
          'unread_mentions': mentions,
          'post': {
            'id': 'old1',
            'channel_id': channelId,
            'user_id': 'someone',
            'create_at': 1,
            'message': 'morning',
          },
        }),
      ]);

  Future<int> railMentions() async =>
      (await RootViews(session.db).railTeams().first).single.mentions;

  test('a mention in a thread with unread replies is on the rail', () async {
    await follow(replies: 1, mentions: 1);
    expect(await railMentions(), 1);
  });

  test(
    'a mention in a thread with nothing unread is not on the rail',
    () async {
      await follow(replies: 0, mentions: 1);
      expect(await railMentions(), 0);
    },
  );

  test('reading a thread asks the server to view it just after its newest '
      'message, so a mention in it is read too', () async {
    await follow(replies: 1, mentions: 1);
    server.handle = (_) => ok({'status': 'OK'});
    final newest = (await session.db.newestPostAt(rootId: 'old1'))!
        .millisecondsSinceEpoch;
    await ConversationActions(session).markThreadRead(teamId, 'old1');
    await eventually(
      () => server.paths.any((p) => p.contains('/threads/old1/read/')),
    );
    expect(
      server.paths.singleWhere((p) => p.contains('/threads/old1/read/')),
      endsWith('/read/${newest + 1}'),
    );
  });
}
