import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/actions/composer_actions.dart';
import 'package:matterleast/data/outbox/outbox_sender.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/data/views/conversation_views.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

void main() {
  late FakeServer server;
  late ServerSession session;
  late ComposerActions actions;
  late OutboxSender sender;
  late DateTime now;
  var created = 0;

  /// What the server does with the next `POST /posts`; null creates it.
  final answers = <Reply?>[];

  Map<String, Object?> createdPost(SeenRequest r) => {
    'id': 'srv${++created}',
    'channel_id': r.body['channel_id'],
    'root_id': r.body['root_id'] ?? '',
    'user_id': meId,
    'create_at': now.millisecondsSinceEpoch + 5,
    'message': r.body['message'],
    'pending_post_id': r.body['pending_post_id'],
    'metadata': <String, Object?>{},
  };

  OutboxSender newSender() =>
      OutboxSender(server: session.api, store: session.store, clock: () => now);

  setUp(() async {
    created = 0;
    answers.clear();
    now = DateTime.utc(2026, 10, 25, 10);
    server = await FakeServer.start();
    server.handle = (r) {
      if (r.method == 'POST' && r.path == '/api/v4/posts') {
        final answer = answers.isEmpty ? null : answers.removeAt(0);
        return answer ?? ok(createdPost(r));
      }
      return error(404, 'not_found');
    };
    session = await testSession(server);
    actions = ComposerActions(session, clock: () => now);
    sender = newSender();
  });

  tearDown(() async {
    await sender.close();
    await closeTestSession(session);
    await server.close();
  });

  ServerDatabase db() => session.db;

  Future<List<PostRow>> posts() => (db().select(
    db().posts,
  )..orderBy([(p) => OrderingTerm.asc(p.createAt)])).get();

  Future<List<String>> shownKeys() async {
    final window = await ConversationViews(db())
        .channel(channelId, limit: 50, openedAt: now)
        .first;
    return [for (final p in window.posts) p.key];
  }

  Iterable<SeenRequest> sends() =>
      server.seen.where((r) => r.path == '/api/v4/posts');

  test('a sent message shows at once, dimmed, and becomes the server post '
      'under the same key', () async {
    final id = await actions.send(channelId, message: 'hello boats');
    expect(id, '$meId:${now.millisecondsSinceEpoch}');
    final pending = (await posts()).last;
    expect(pending.id, id);
    expect(pending.sendState, SendStates.pending);
    expect(await shownKeys(), [id, 'old1']);

    await sender.start();
    expect(sends().single.body['pending_post_id'], id);
    final rows = await posts();
    expect(rows.map((p) => p.id), ['old1', 'srv1']);
    expect(rows.last.sendState, isNull);
    expect(await shownKeys(), [id, 'old1']);
    expect(await db().select(db().outbox).get(), isEmpty);
  });

  test('a later refresh of the sent post keeps its key', () async {
    final id = await actions.send(channelId, message: 'hello');
    await sender.start();
    final refetched = api.Post.fromJson({
      'id': 'srv1',
      'channel_id': channelId,
      'user_id': meId,
      'create_at': now.millisecondsSinceEpoch + 5,
      'edit_at': now.millisecondsSinceEpoch + 50,
      'message': 'hello, edited',
      'pending_post_id': '',
    });
    await session.store.applyEdit(refetched);
    expect((await shownKeys()).first, id);
  });

  test('the posted event arriving before the reply leaves one row', () async {
    final id = await actions.send(channelId, message: 'race');
    await session.store.applyLivePost(
      api.Post.fromJson({
        'id': 'srv1',
        'channel_id': channelId,
        'user_id': meId,
        'create_at': now.millisecondsSinceEpoch + 5,
        'message': 'race',
        'pending_post_id': id,
      }),
      fromSelf: true,
      mentionsMe: false,
    );
    expect((await posts()).map((p) => p.id), ['old1', 'srv1']);
    final channel = await (db().select(
      db().channels,
    )..where((c) => c.id.equals(channelId))).getSingle();
    expect(channel.totalMsgCount, 2);

    await sender.start();
    expect(sends(), isEmpty, reason: 'the event already confirmed it');
    expect((await posts()).map((p) => p.id), ['old1', 'srv1']);
    expect(await shownKeys(), [id, 'old1']);
  });

  test('a reply that comes after the event is not counted twice', () async {
    await actions.send(channelId, message: 'twice');
    await sender.start();
    final created = await (db().select(
      db().posts,
    )..where((p) => p.id.equals('srv1'))).getSingle();
    await session.store.applyLivePost(
      api.Post.fromJson({
        'id': 'srv1',
        'channel_id': channelId,
        'user_id': meId,
        'create_at': created.createAt.millisecondsSinceEpoch,
        'message': 'twice',
        'pending_post_id': created.pendingPostId,
      }),
      fromSelf: true,
      mentionsMe: false,
    );
    final channel = await (db().select(
      db().channels,
    )..where((c) => c.id.equals(channelId))).getSingle();
    expect(channel.totalMsgCount, 2);
    expect((await posts()).length, 2);
  });

  test('posts of a channel go in the order they were written, waiting for '
      'the server to come back', () async {
    answers.addAll([error(503, 'unavailable')]);
    final first = await actions.send(channelId, message: 'one');
    final second = await actions.send(channelId, message: 'two');
    await sender.start();
    expect(sends().map((r) => r.body['message']), ['one']);
    final outbox = await db().select(db().outbox).get();
    final waiting = outbox.firstWhere((o) => o.pendingPostId == first);
    expect(waiting.attempts, 1);
    expect(waiting.nextAttemptAt, now.add(const Duration(seconds: 2)));

    await sender.kick();
    expect(sends().length, 1, reason: 'still backing off');

    now = now.add(const Duration(seconds: 2));
    await sender.kick();
    expect(sends().map((r) => r.body['message']), ['one', 'one', 'two']);
    expect(sends().map((r) => r.body['pending_post_id']).skip(1), [
      first,
      second,
    ]);
    expect(await db().select(db().outbox).get(), isEmpty);
  });

  test(
    'the socket coming back sends waiting posts without the backoff',
    () async {
      answers.add(error(503, 'unavailable'));
      await actions.send(channelId, message: 'one');
      await sender.start();
      await sender.wake();
      expect(sends().length, 2);
      expect(await db().select(db().outbox).get(), isEmpty);
    },
  );

  test('after ten failed attempts the post is marked as not sent', () async {
    final id = await actions.send(channelId, message: 'lost');
    answers.addAll(List.filled(10, error(502, 'bad_gateway')));
    await sender.start();
    for (var i = 0; i < 9; i++) {
      now = now.add(const Duration(minutes: 1));
      await sender.kick();
    }
    expect(sends().length, 10);
    final post = (await posts()).last;
    expect(post.id, id);
    expect(post.sendState, SendStates.failed);
    final row = (await db().select(db().outbox).get()).single;
    expect(row.state, 'failed');

    now = now.add(const Duration(minutes: 1));
    await sender.kick();
    expect(sends().length, 10, reason: 'failed posts wait for a retry');
  });

  test('a refused post fails at once with the server message and can be '
      'retried', () async {
    answers.add((
      status: 400,
      json: {'id': 'api.post.too_long', 'message': 'Message too long'},
      headers: const <String, String>{},
    ));
    final id = await actions.send(channelId, message: 'long');
    final next = await actions.send(channelId, message: 'after');
    await sender.start();
    final query = db().select(db().outbox)
      ..where((o) => o.pendingPostId.equals(id));
    final failed = await query.getSingle();
    expect(failed.state, 'failed');
    expect(failed.lastError, 'Message too long');
    expect(sends().map((r) => r.body['pending_post_id']), [
      id,
      next,
    ], reason: 'a failed post does not block the channel');

    await actions.retry(id);
    await sender.kick();
    expect(sends().length, 3);
    expect((await posts()).every((p) => p.sendState == null), isTrue);
  });

  test('a request for acknowledgement the server lacks fails once with its '
      'message, stops being offered, and the retry goes without it', () async {
    await session.store.applyConfig('client_config', {
      'PostPriority': 'true',
      'PostAcknowledgements': 'true',
    });
    answers.add((
      status: 501,
      json: {
        'id': 'api.post.acknowledgement.license.app_error',
        'message': 'Acknowledgements need a licence.',
      },
      headers: const <String, String>{},
    ));
    final id = await actions.send(
      channelId,
      message: 'read this',
      priority: const api.PostPriority(
        priority: api.PostPriorityPriority.important,
        requestedAck: true,
      ),
    );
    await sender.start();
    final failed = await (db().select(
      db().outbox,
    )..where((o) => o.pendingPostId.equals(id))).getSingle();
    expect(failed.state, 'failed');
    expect(failed.lastError, 'Acknowledgements need a licence.');
    expect(sends(), hasLength(1), reason: 'not retried on its own');
    expect((await db().features()).acknowledgements, isFalse);

    await actions.retry(id);
    await sender.kick();
    final retried = sends().last.body['metadata'] as Map<String, Object?>?;
    final priority = retried?['priority'] as Map<String, Object?>?;
    expect(priority?['priority'], 'important');
    expect(priority?['requested_ack'], isNot(true));
    expect((await posts()).every((p) => p.sendState == null), isTrue);
  });

  test('a post to a deleted thread is removed and reported', () async {
    answers.add(error(400, 'api.post.create_post.root_id.app_error'));
    final reported = sender.rejected.first;
    final id = await actions.send(channelId, rootId: 'gone', message: 'hi');
    await sender.start();
    final rejected = await reported;
    expect(rejected.pendingPostId, id);
    expect(rejected.channelId, channelId);
    expect((await posts()).map((p) => p.id), ['old1']);
    expect(await db().select(db().outbox).get(), isEmpty);
  });

  test('discarding a failed post removes it', () async {
    answers.add(error(403, 'api.context.permissions.app_error'));
    final id = await actions.send(channelId, message: 'nope');
    await sender.start();
    await actions.discard(id);
    expect((await posts()).map((p) => p.id), ['old1']);
    expect(await db().select(db().outbox).get(), isEmpty);
  });

  test('queued and failed posts survive a restart; one cut off while '
      'sending goes again', () async {
    final hanging = await actions.send(channelId, message: 'cut off');
    await session.store.markSending(hanging);
    await sender.close();

    sender = newSender();
    await sender.start();
    expect(sends().single.body['pending_post_id'], hanging);
    expect(await db().select(db().outbox).get(), isEmpty);
  });

  test('sending clears the draft of the conversation', () async {
    await session.store.saveDraft(
      DraftsCompanion.insert(
        channelId: channelId,
        message: const Value('hello'),
        updatedAt: now,
      ),
    );
    await actions.send(channelId, message: 'hello');
    expect(await db().select(db().drafts).get(), isEmpty);
  });

  test(
    'an unsent post shows even before the channel was refreshed since',
    () async {
      final id = await actions.send(channelId, message: 'early');
      final member = await (db().select(
        db().myChannels,
      )..where((m) => m.channelId.equals(channelId))).getSingle();
      expect(
        member.postsFetchedAt,
        DateTime.utc(2026, 10, 25, 9),
        reason: 'the next refresh still asks from the newest server post',
      );
      expect((await shownKeys()).first, id);
    },
  );
}
