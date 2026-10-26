import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/actions/channel_actions.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

void main() {
  test('opening a channel tells the server, which keeps threads unread '
      'because the app understands collapsed threads', () async {
    final server = await FakeServer.start();
    final session = await testSession(server);
    final viewed = Completer<SeenRequest>();
    server.handle = (r) {
      if (r.path == '/api/v4/channels/members/me/view') viewed.complete(r);
      return ok({'status': 'OK'});
    };

    await ChannelActions(session).view(channelId);
    final request = await viewed.future.timeout(const Duration(seconds: 5));

    expect(request.method, 'POST');
    expect(request.body['channel_id'], channelId);
    expect(request.body['collapsed_threads_supported'], isTrue);
    await closeTestSession(session);
    await server.close();
  });
}
