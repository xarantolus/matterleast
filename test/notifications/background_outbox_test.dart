import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/notifications/background.dart';
import 'package:matterleast/notifications/notifier.dart';
import 'package:matterleast/notifications/notify_rules.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

class _Quiet extends Notifier {
  @override
  Future<List<ShownConversation>> shown(String serverUrl) async => const [];
}

void main() {
  test('the background check sends a post waiting out its backoff', () async {
    final (server, session) = await startServerSession();
    var posts = 0;
    server.handle = (r) {
      if (r.method == 'POST' && r.path == '/api/v4/posts') {
        posts++;
        return posts == 1
            ? error(500, 'server.broke')
            : ok({
                'id': 'srv1',
                'channel_id': channelId,
                'user_id': meId,
                'create_at': DateTime.now().millisecondsSinceEpoch,
                'message': r.body['message'],
                'pending_post_id': r.body['pending_post_id'],
                'metadata': <String, Object?>{},
              });
      }
      return emptyAnswer(r);
    };
    await session.outbox.start();
    await session.composer.send(channelId, message: 'hello');
    await session.outbox.kick();
    expect(posts, 1);
    expect(await session.store.outboxRows(), hasLength(1));

    await BackgroundApp.checkSession(session, _Quiet(), null, refresh: false);

    expect(posts, 2);
    expect(await session.store.outboxRows(), isEmpty);
    await session.outbox.close();
  });
}
