import 'dart:async';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/live/typing.dart';
import 'package:matterleast/data/servers/server_session.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';
import '../support/wait.dart';

/// A server that answers presence with the user online, once [answer]
/// lets it.
void _answerPresence(FakeServer server, {Future<void>? answer}) =>
    server.handle = (r) async {
      if (r.path != '/api/v4/users/status/ids') return error(404, 'not_found');
      await answer;
      return ok([
        {'user_id': meId, 'status': 'online'},
      ]);
    };

void main() {
  // Two servers, each with its own in-memory database.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('typing ends without its stop event', () {
    fakeAsync((async) {
      final typing = TypingTracker();
      final seen = <List<String>>[];
      typing.watch(channelId).listen(seen.add);
      typing.typing(channelId, '', 'u2');
      async.flushMicrotasks();
      expect(seen.last, ['u2']);
      async.elapse(TypingTracker.defaultExpiry);
      expect(seen.last, isEmpty);
      typing.close();
    });
  });

  test('coming back counts as catching up until the socket has caught up '
      'and what it missed is fetched', () async {
    final server = await FakeServer.start();
    server.acceptSockets = true;
    final entry = Completer<void>();
    server.handle = (r) async {
      await entry.future;
      return error(404, 'not_found');
    };
    final session = await testSession(server);
    addTearDown(() async {
      await closeTestSession(session);
      await server.close();
    });
    final catchingUp = session.connection.catchingUp;

    session.connection.foreground();
    await eventually(() => catchingUp.value);
    await eventually(() => session.connection.live.value);
    expect(catchingUp.value, isTrue, reason: 'nothing received yet');

    // A new connection: events may be lost, so the data is fetched again.
    server.sendToSockets({
      'event': 'hello',
      'data': {'connection_id': 'c1'},
      'broadcast': <String, Object?>{},
      'seq': 0,
    });
    await eventually(() => server.paths.contains('/api/v4/users/me'));
    expect(catchingUp.value, isTrue, reason: 'the refresh still runs');
    entry.complete();
    await eventually(() => !catchingUp.value);
  });

  test('a socket that resumes without losing events is caught up with its '
      'first event', () async {
    final server = await FakeServer.start();
    server.acceptSockets = true;
    final session = await testSession(server);
    addTearDown(() async {
      await closeTestSession(session);
      await server.close();
    });
    final catchingUp = session.connection.catchingUp;
    session.connection.foreground();
    await eventually(() => catchingUp.value);
    await eventually(() => session.connection.live.value);
    expect(catchingUp.value, isTrue, reason: 'nothing received yet');
    // The server resumes the connection and replays what was missed.
    server.sendToSockets({
      'event': 'typing',
      'data': {'parent_id': '', 'user_id': 'u2'},
      'broadcast': {'channel_id': channelId},
      'seq': 0,
    });
    await eventually(() => !catchingUp.value);
    expect(server.paths, isNot(contains('/api/v4/users/me')));
  });

  test('a refresh that never answers does not keep the app catching up '
      'forever', () async {
    final server = await FakeServer.start();
    server.acceptSockets = true;
    server.handle = (_) => Completer<Reply?>().future;
    final session = await testSession(
      server,
      catchUpLimit: const Duration(milliseconds: 300),
    );
    addTearDown(() async {
      await closeTestSession(session);
      await server.close();
    });
    final catchingUp = session.connection.catchingUp;
    session.connection.foreground();
    await eventually(() => catchingUp.value);
    await eventually(() => session.connection.live.value);
    // The socket resumes with lost events and the refresh hangs.
    server.sendToSockets({
      'event': 'hello',
      'data': {'connection_id': 'c1'},
      'broadcast': <String, Object?>{},
      'seq': 0,
    });
    await eventually(() => server.paths.contains('/api/v4/users/me'));
    await eventually(() => !catchingUp.value);
  });

  group('two servers, one goes away', () {
    late FakeServer harbour;
    late FakeServer lighthouse;
    late ServerSession first;
    late ServerSession second;

    setUp(() async {
      harbour = await FakeServer.start();
      lighthouse = await FakeServer.start();
      for (final s in [harbour, lighthouse]) {
        s.acceptSockets = true;
        _answerPresence(s);
      }
      first = await testSession(harbour);
      second = await testSession(lighthouse);
      first.connection.foreground();
      second.connection.foreground();
      await eventually(
        () =>
            first.connection.presence.known.value.contains(meId) &&
            second.connection.presence.known.value.contains(meId),
        reason: 'both servers live with fresh presence',
      );
    });

    tearDown(() async {
      await closeTestSession(first);
      await closeTestSession(second);
      await harbour.close();
      await lighthouse.close();
    });

    test('presence and typing clear on the server that stopped being live '
        'only, and presence comes back only from a fresh answer', () async {
      first.connection.typing.typing(channelId, '', 'u2');
      second.connection.typing.typing(channelId, '', 'u2');
      final answer = Completer<void>();
      _answerPresence(lighthouse, answer: answer.future);

      await lighthouse.dropSockets();
      await eventually(() => !second.connection.live.value);
      lighthouse.seen.clear();

      expect(second.connection.presence.known.value, isEmpty);
      expect(await second.connection.typing.watch(channelId).first, isEmpty);
      expect(first.connection.live.value, isTrue);
      expect(first.connection.presence.known.value, contains(meId));
      expect(await first.connection.typing.watch(channelId).first, ['u2']);

      // The socket connects again; the stored status from before isn't
      // shown until the server answers again.
      await eventually(() => second.connection.live.value);
      await eventually(
        () => lighthouse.paths.contains('/api/v4/users/status/ids'),
      );
      expect(second.connection.presence.known.value, isEmpty);
      answer.complete();
      await eventually(
        () => second.connection.presence.known.value.contains(meId),
      );
    });
  });
}
