import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/data/actions/composer_actions.dart';
import 'package:matterleast/data/outbox/outbox_sender.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/views/conversation_views.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';
import '../support/wait.dart';

const _botId = 'bot0000000000000000000bot1';
const _rootId = 'root00000000000000000root1';
const _answerId = 'ans00000000000000000000an1';
const _errorText =
    'Sorry! An error occurred while accessing the LLM. See server logs for '
    'details.';

void main() {
  late FakeServer server;
  late ServerSession session;
  late DateTime now;
  var seq = 0;

  setUp(() async {
    seq = 0;
    now = DateTime.utc(2026, 10, 25, 10);
    server = await FakeServer.start();
    server.handle = (r) {
      if (r.method == 'POST' && r.path == '/api/v4/posts') {
        return ok({
          'id': 'srv1',
          'channel_id': r.body['channel_id'],
          'root_id': r.body['root_id'] ?? '',
          'user_id': meId,
          'create_at': now.millisecondsSinceEpoch + 25,
          'message': r.body['message'],
          'pending_post_id': r.body['pending_post_id'],
        });
      }
      return error(404, 'not_found');
    };
    session = await testSession(server);
  });

  tearDown(() async {
    await closeTestSession(session);
    await server.close();
  });

  Map<String, Object?> post(
    String id, {
    required String userId,
    required int at,
    String rootId = '',
    String message = '',
    String type = '',
    int editAt = 0,
    String pendingPostId = '',
  }) => {
    'id': id,
    'channel_id': channelId,
    'root_id': rootId,
    'user_id': userId,
    'create_at': now.millisecondsSinceEpoch + at,
    'edit_at': editAt == 0 ? 0 : now.millisecondsSinceEpoch + editAt,
    'message': message,
    'type': type,
    'pending_post_id': pendingPostId,
    'props': {
      if (type.isNotEmpty) ...{
        'from_bot': 'true',
        'llm_requester_user_id': meId,
      },
    },
  };

  Map<String, Object?> answer({String message = '', int editAt = 0}) => post(
    _answerId,
    userId: _botId,
    at: 20,
    rootId: _rootId,
    message: message,
    type: 'custom_llmbot',
    editAt: editAt,
  );

  /// One frame as the socket hands it on, in the order it arrived.
  void receive(String event, Map<String, Object?> data) =>
      session.connection.receive(
        decodeEvent(
          SocketFrame.fromJson({
            'event': event,
            'data': data,
            'broadcast': {'channel_id': channelId},
            'seq': ++seq,
          }),
        ),
      );

  void postEvent(String event, Map<String, Object?> post) =>
      receive(event, {'post': jsonEncode(post)});

  void agent(Map<String, Object?> data) => receive(
    'custom_mattermost-ai_postupdate',
    {'post_id': _answerId, ...data},
  );

  /// The question and the agent's empty placeholder, as the thread view
  /// leaves them after opening the thread.
  Future<void> openThread() async {
    await session.store.applyThreadPage(
      rootId: _rootId,
      page: api.PostList.fromJson({
        'order': [_answerId, _rootId],
        'posts': {
          _rootId: post(
            _rootId,
            userId: meId,
            at: 10,
            message: 'Tell me about the harbour',
          ),
          _answerId: answer(),
        },
      }),
      reachesStart: true,
    );
  }

  bool generating() =>
      session.connection.agents.stream(_answerId)?.busy ?? false;

  Future<void> applied() =>
      session.connection.events.add(const UnknownEvent('test'));

  test('an answer that fails before it streams shows the error, not a '
      'running answer', () async {
    await openThread();
    for (final phase in ['checking_mcp', 'loading_conversation']) {
      agent({'control': 'progress', 'progress_phase': phase});
    }
    expect(generating(), isTrue);

    // The plugin writes its error into the post and sends nothing else.
    postEvent('post_edited', answer(message: _errorText, editAt: 30));
    await eventually(() => !generating(), reason: 'still shows Stop');
    expect(session.connection.agents.stream(_answerId), isNull);
    expect((await session.store.post(_answerId))!.message, _errorText);
  });

  test('storing the conversation in the empty placeholder keeps it '
      'generating', () async {
    await openThread();
    agent({'control': 'progress', 'progress_phase': 'loading_conversation'});
    postEvent('post_edited', answer());
    await applied();
    expect(generating(), isTrue);
  });

  test('an answer whose end was missed stops showing as running once the '
      'connection is back, and keeps its text', () async {
    await openThread();
    agent({'control': 'start'});
    agent({'next': 'The harbour has'});
    expect(generating(), isTrue);

    session.connection.agents.reconnected();
    expect(generating(), isFalse);
    expect(
      session.connection.agents.stream(_answerId)?.live?.text,
      'The harbour has',
    );

    // Still running after all: its next text shows it generating again.
    agent({'next': 'The harbour has two piers'});
    expect(generating(), isTrue);
  });

  test('a reply sent while the agent is answering stays in the thread and '
      'is stored once', () async {
    await openThread();
    final sender = OutboxSender(
      server: session.api,
      store: session.store,
      clock: () => now,
    );
    addTearDown(sender.close);
    final composer = ComposerActions(
      session,
      clock: () => now.add(const Duration(milliseconds: 22)),
    );
    agent({'control': 'progress', 'progress_phase': 'checking_mcp'});
    postEvent('post_edited', answer());
    agent({'control': 'start'});
    agent({'next': 'The harbour'});

    Future<List<String>> shown() async {
      final window = await ConversationViews(session.db)
          .thread(_rootId, limit: 50, openedAt: now)
          .first;
      return [for (final p in window.posts) p.key];
    }

    final pendingId = await composer.send(
      channelId,
      rootId: _rootId,
      message: 'And the lighthouse?',
    );
    agent({'next': 'The harbour has two'});
    expect(await shown(), [pendingId, _answerId]);

    await sender.start();
    postEvent(
      'posted',
      post(
        'srv1',
        userId: meId,
        at: 25,
        rootId: _rootId,
        message: 'And the lighthouse?',
        pendingPostId: pendingId,
      ),
    );
    agent({'next': 'The harbour has two piers'});
    agent({'control': 'end'});
    postEvent(
      'post_edited',
      answer(message: 'The harbour has two piers', editAt: 40),
    );
    await applied();

    expect(await shown(), contains(pendingId));
    final replies = [
      for (final p in await session.db.select(session.db.posts).get())
        if (p.message == 'And the lighthouse?') p.id,
    ];
    expect(replies, ['srv1']);
  });
}
