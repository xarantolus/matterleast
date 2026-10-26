import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/websocket/dialog.dart';
import 'package:matterleast/data/actions/integration_actions.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/data/views/conversation_views.dart';
import 'package:matterleast/domain/integration_blocks.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';
import '../support/wait.dart';

void main() {
  late FakeServer server;
  late ServerSession session;
  late IntegrationActions actions;
  FutureOr<Reply> Function() reply = () => ok({'status': 'OK'});

  setUp(() async {
    reply = () => ok({'status': 'OK'});
    (server, session) = await startServerSession();
    server.handle = (r) =>
        r.path.startsWith('/api/v4/posts/') ? reply() : error(404, 'not_found');
    actions = IntegrationActions(session);
  });

  PostActionRequest request({
    String actionId = 'approve',
    String? cookie,
    String selected = '',
    Map<String, String>? query,
    IntegrationFormat format = IntegrationFormat.attachment,
  }) => (
    postId: 'post1',
    actionId: actionId,
    cookie: cookie,
    selectedOption: selected,
    query: query,
    format: format,
  );

  test('a button sends its cookie, choice, query and format', () async {
    await actions.run(
      request(
        cookie: 'sealed',
        selected: 'fri',
        query: {'row': '2'},
        format: IntegrationFormat.mmBlock,
      ),
    );
    final seen = server.seen.single;
    expect(seen.method, 'POST');
    expect(seen.path, '/api/v4/posts/post1/actions/approve');
    expect(seen.body, {
      'selected_option': 'fri',
      'cookie': 'sealed',
      'query': {'row': '2'},
      'integration_format': 'mm_block',
    });
  });

  test('without a cookie or query none is sent', () async {
    await actions.run(request());
    expect(server.seen.single.body, {
      'selected_option': '',
      'integration_format': 'attachment',
    });
  });

  test('a second tap while the action runs sends nothing more', () async {
    final answer = Completer<Reply>();
    reply = () => answer.future;
    final first = actions.run(request());
    final second = actions.run(request());
    await eventually(() => server.seen.isNotEmpty);
    answer.complete(ok({'status': 'OK'}));
    await Future.wait([first, second]);
    expect(server.seen, hasLength(1));
    await actions.run(request());
    expect(server.seen, hasLength(2), reason: 'a later tap runs again');
  });

  test('the dialog the integration opens shows', () async {
    reply = () => ok({'status': 'OK', 'trigger_id': 'trig9'});
    final shown = session.connection.dialogs.dialogs.first;
    await actions.run(request());
    session.connection.dialogs
      ..offer(const OpenDialog(triggerId: 'someone-else'))
      ..offer(const OpenDialog(triggerId: 'trig9', url: 'form'));
    expect((await shown).url, 'form');
  });

  test('where the integration sends the user is returned', () async {
    reply = () =>
        ok({'status': 'OK', 'goto_location': 'https://example.test/x'});
    expect(await actions.run(request()), 'https://example.test/x');
    reply = () => ok({'status': 'OK'});
    expect(await actions.run(request()), isNull);
  });

  test('a refused action throws what the server said', () async {
    reply = () => (
      status: 400,
      json: {
        'id': 'api.post.do_action.action_integration.app_error',
        'message': 'Action integration error.',
      },
      headers: const <String, String>{},
    );
    await expectLater(
      actions.run(request()),
      throwsA(
        isA<ServerError>().having(
          (e) => e.message,
          'message',
          'Action integration error.',
        ),
      ),
    );
  });

  test(
    'the ephemeral answer shows in the channel with collapsed threads',
    () async {
      await session.store.applyConfig('client_config', {
        'CollapsedThreads': 'always_on',
      });
      final at = DateTime.utc(2026, 10, 26, 9);
      await session.store.applyEphemeralPost(
        api.Post.fromJson({
          'id': 'eph1',
          'channel_id': channelId,
          'root_id': 'post1',
          'user_id': meId,
          'create_at': at.millisecondsSinceEpoch,
          'type': ephemeralType,
          'message': 'Pong!',
        }),
      );
      final window = await ConversationViews(session.db)
          .channel(channelId, limit: 10, openedAt: at)
          .first;
      expect(window.posts.map((p) => p.message), contains('Pong!'));
    },
  );
}
