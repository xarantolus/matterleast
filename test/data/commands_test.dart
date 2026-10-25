import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/actions/composer_actions.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/data/views/conversation_views.dart';
import 'package:matterleast/domain/commands.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

void main() {
  late FakeServer server;
  late ServerSession session;
  late ComposerActions actions;
  var now = DateTime.utc(2026, 10, 25, 10);
  Reply reply = ok(<String, Object?>{});

  setUp(() async {
    now = DateTime.utc(2026, 10, 25, 10);
    server = await FakeServer.start();
    server.handle = (r) =>
        r.path == '/api/v4/commands/execute' ? reply : error(404, 'not_found');
    session = await testSession(server);
    actions = ComposerActions(session, clock: () => now);
  });

  tearDown(() async {
    await actions.dispose();
    await closeTestSession(session);
    await server.close();
  });

  Future<List<PostRow>> ephemeral() => (session.db.select(
    session.db.posts,
  )..where((p) => p.type.equals(ephemeralType))).get();

  test(
    'the command goes out normalised with its channel, team and thread',
    () async {
      await actions.executeCommand(
        channelId,
        teamId: teamId,
        rootId: 'root1',
        text: '/Shout  hello —loud ',
      );
      final body = server.seen.single.body;
      expect(body['command'], '/shout hello --loud');
      expect(body['channel_id'], channelId);
      expect(body['team_id'], teamId);
      expect(body['root_id'], 'root1');
      expect(body['parent_id'], 'root1');
    },
  );

  test('a reply only for the user shows as an ephemeral message', () async {
    reply = ok({'response_type': 'ephemeral', 'text': 'Only you see this'});
    final outcome = await actions.executeCommand(
      channelId,
      teamId: teamId,
      text: '/lunch',
    );
    expect(outcome, isA<CommandDone>());
    final rows = await ephemeral();
    expect(rows.single.message, 'Only you see this');
    final window = await ConversationViews(session.db)
        .channel(channelId, limit: 10, openedAt: now)
        .first;
    expect(window.posts.first.isEphemeral, isTrue);
    final channel = await (session.db.select(
      session.db.channels,
    )..where((c) => c.id.equals(channelId))).getSingle();
    expect(channel.totalMsgCount, 1, reason: 'not counted as unread');
  });

  test(
    'the same reply over the socket replaces it under the same key',
    () async {
      reply = ok({'response_type': 'ephemeral', 'text': 'Done'});
      await actions.executeCommand(channelId, teamId: teamId, text: '/lunch');
      final local = (await ephemeral()).single;
      await session.store.applyEphemeralPost(
        api.Post.fromJson({
          'id': 'eph1',
          'channel_id': channelId,
          'user_id': meId,
          'create_at': now.millisecondsSinceEpoch + 30,
          'type': ephemeralType,
          'message': 'Done',
        }),
      );
      final rows = await ephemeral();
      expect(rows.single.id, 'eph1');
      expect(rows.single.pendingPostId, local.id);
    },
  );

  test('the socket copy first: the command answer adds nothing', () async {
    await session.store.applyEphemeralPost(
      api.Post.fromJson({
        'id': 'eph1',
        'channel_id': channelId,
        'user_id': meId,
        'create_at': now.millisecondsSinceEpoch,
        'type': ephemeralType,
        'message': 'Done',
      }),
    );
    reply = ok({'response_type': 'ephemeral', 'text': 'Done'});
    await actions.executeCommand(channelId, teamId: teamId, text: '/lunch');
    expect((await ephemeral()).single.id, 'eph1');
  });

  test('a reply for everyone is left to the posted event', () async {
    reply = ok({'response_type': 'in_channel', 'text': 'Lunch!'});
    await actions.executeCommand(channelId, teamId: teamId, text: '/lunch');
    expect(await ephemeral(), isEmpty);
  });

  test('goto_location is handed back to open', () async {
    reply = ok({'goto_location': 'https://example.invalid/docs'});
    final outcome = await actions.executeCommand(
      channelId,
      teamId: teamId,
      text: '/help',
    );
    expect((outcome as CommandGoto).location, 'https://example.invalid/docs');
  });

  test('a dialog trigger is remembered for the dialog that follows', () async {
    reply = ok({'trigger_id': 'trig1'});
    await actions.executeCommand(channelId, teamId: teamId, text: '/form');
    expect(session.dialogTriggerId, 'trig1');
  });

  test('a failing command throws the server message', () async {
    reply = (
      status: 404,
      json: {
        'id': 'api.command.execute_command.not_found.app_error',
        'message': 'Command with a trigger of /nope not found.',
      },
      headers: const <String, String>{},
    );
    await expectLater(
      actions.executeCommand(channelId, teamId: teamId, text: '/nope'),
      throwsA(
        isA<ServerError>().having(
          (e) => e.message,
          'message',
          'Command with a trigger of /nope not found.',
        ),
      ),
    );
  });

  test(
    'ephemeral messages can be dismissed and are gone after a restart',
    () async {
      reply = ok({'response_type': 'ephemeral', 'text': 'one'});
      await actions.executeCommand(channelId, teamId: teamId, text: '/a');
      now = now.add(const Duration(minutes: 5));
      reply = ok({'response_type': 'ephemeral', 'text': 'two'});
      await actions.executeCommand(channelId, teamId: teamId, text: '/b');
      await actions.dismissEphemeral((await ephemeral()).first.id);
      expect((await ephemeral()).single.message, 'two');
      await session.store.removeEphemeralPosts();
      expect(await ephemeral(), isEmpty);
    },
  );

  test('normalising keeps the trailing spaces of /code', () {
    expect(normalizeCommand('/CODE  x  '), '/code   x');
    expect(normalizeCommand('/away'), '/away ');
  });
}
