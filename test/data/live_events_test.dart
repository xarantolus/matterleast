import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/websocket/dialog.dart';
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/api/websocket/server_socket.dart';
import 'package:matterleast/data/actions/composer_actions.dart';
import 'package:matterleast/data/live/typing.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/domain/dialog_rules.dart';
import 'package:matterleast/domain/typing.dart';

import '../support/fake_server.dart';
import '../support/fake_socket_server.dart';
import '../support/test_session.dart';

void main() {
  late FakeServer server;
  late ServerSession session;

  setUp(() async {
    server = await FakeServer.start();
    server.handle = (r) => r.path == '/api/v4/users/ids'
        ? ok([
            {'id': 'u9', 'username': 'nadia', 'first_name': 'Nadia'},
          ])
        : error(404, 'not_found');
    session = await testSession(server);
  });

  tearDown(() async {
    await closeTestSession(session);
    await server.close();
  });

  Future<void> receive(String event, Map<String, Object?> data) =>
      session.connection.events.add(
        decodeEvent(
          SocketFrame.fromJson({
            'event': event,
            'data': data,
            'broadcast': {'channel_id': channelId, 'user_id': meId},
            'seq': 1,
          }),
        ),
      );

  const dialogJson = {
    'trigger_id': 'trig1',
    'url': 'https://integration.invalid/submit',
    'dialog': {
      'callback_id': 'cb',
      'title': 'Order lunch',
      'introduction_text': 'Pick **one**',
      'submit_label': 'Order',
      'notify_on_cancel': true,
      'state': 's1',
      'elements': [
        {
          'display_name': 'Dish',
          'name': 'dish',
          'type': 'select',
          'options': [
            {'text': 'Soup', 'value': 'soup'},
            {'text': 'Salad', 'value': 'salad'},
          ],
        },
        {
          'display_name': 'Portions',
          'name': 'portions',
          'type': 'text',
          'subtype': 'number',
          'optional': true,
        },
        {
          'display_name': 'Note',
          'name': 'note',
          'type': 'textarea',
          'max_length': 5,
          'optional': true,
        },
        {
          'display_name': 'Spicy',
          'name': 'spicy',
          'type': 'bool',
          'optional': true,
        },
        {
          'display_name': 'Pick',
          'name': 'pick',
          'type': 'datetime',
          'optional': true,
        },
      ],
    },
  };

  test('an ephemeral message from the server shows in its channel', () async {
    await receive('ephemeral_message', {
      'post': jsonEncode({
        'id': 'eph1',
        'channel_id': channelId,
        'user_id': meId,
        'create_at': DateTime.utc(2026, 10, 25, 10).millisecondsSinceEpoch,
        'type': 'system_ephemeral',
        'message': 'Only you can see this',
      }),
    });
    final row = await (session.db.select(
      session.db.posts,
    )..where((p) => p.id.equals('eph1'))).getSingle();
    expect(row.type, ephemeralType);
  });

  test('a dialog decodes with its fields and is offered for the trigger '
      'of this device', () async {
    session.connection.dialogs.expect('trig1');
    final shown = session.connection.dialogs.dialogs.first;
    await receive('open_dialog', {'dialog': jsonEncode(dialogJson)});
    final dialog = await shown;
    expect(dialog.dialog.title, 'Order lunch');
    expect(dialog.dialog.notifyOnCancel, isTrue);
    final elements = dialog.dialog.elements;
    expect(
      [for (final e in elements) e.type],
      [
        DialogElementType.select,
        DialogElementType.text,
        DialogElementType.textarea,
        DialogElementType.bool,
        DialogElementType.unknown,
      ],
    );
    expect(elements.first.options.last.value, 'salad');
  });

  test('a dialog for a command run elsewhere is not shown', () async {
    final shown = <OpenDialog>[];
    final sub = session.connection.dialogs.dialogs.listen(shown.add);
    await receive('open_dialog', {'dialog': jsonEncode(dialogJson)});
    await Future<void>.delayed(Duration.zero);
    expect(shown, isEmpty);
    await sub.cancel();
  });

  group('submitting a dialog', () {
    late ComposerActions actions;
    final dialog = OpenDialog.fromJson(dialogJson);

    setUp(() => actions = ComposerActions(session));
    tearDown(() => actions.dispose());

    test('fields are checked before anything is sent', () async {
      final outcome = await actions.submitDialog(
        dialog,
        channelId: channelId,
        values: {'portions': 'two', 'note': 'too long'},
      );
      expect((outcome as DialogRejected).fieldErrors, {
        'dish': 'This field is required.',
        'portions': 'Must be a number.',
        'note': 'Must be at most 5 characters.',
      });
      expect(server.seen, isEmpty);
    });

    test('answers go to the integration, numbers as numbers', () async {
      server.handle = (r) => ok(<String, Object?>{});
      final outcome = await actions.submitDialog(
        dialog,
        channelId: channelId,
        teamId: teamId,
        values: {'dish': 'soup', 'portions': '2', 'spicy': true},
      );
      expect(outcome, isA<DialogSubmitted>());
      final body = server.seen.single.body;
      expect(body['url'], 'https://integration.invalid/submit');
      expect(body['callback_id'], 'cb');
      expect(body['state'], 's1');
      expect(body['submission'], {
        'dish': 'soup',
        'portions': 2,
        'spicy': true,
      });
    });

    test('the integration can reject fields', () async {
      server.handle = (r) => ok({
        'error': 'Kitchen closed',
        'errors': {'dish': 'Sold out'},
      });
      final outcome = await actions.submitDialog(
        dialog,
        channelId: channelId,
        values: {'dish': 'soup'},
      ) as DialogRejected;
      expect(outcome.error, 'Kitchen closed');
      expect(outcome.fieldErrors, {'dish': 'Sold out'});
    });

    test('cancelling tells the integration only when it asked', () async {
      server.handle = (r) => ok(<String, Object?>{});
      await actions.submitDialog(dialog, channelId: channelId, cancelled: true);
      expect(server.seen.single.body['cancelled'], isTrue);
    });
  });

  test('dialog rules: a select must be one of its options, urls are web '
      'links', () {
    final form = DialogForm.fromJson({
      'elements': [
        {
          'name': 'a',
          'type': 'radio',
          'options': [
            {'text': 'X', 'value': 'x'},
          ],
        },
        {'name': 'b', 'type': 'text', 'subtype': 'url'},
        {'name': 'c', 'type': 'text', 'min_length': 3},
      ],
    });
    expect(dialogErrors(form, {'a': 'y', 'b': 'ftp://x', 'c': 'ab'}), {
      'a': 'Pick one of the options.',
      'b': 'Must be a valid URL.',
      'c': 'Must be at least 3 characters.',
    });
    expect(
      dialogErrors(form, {'a': 'x', 'b': 'https://x.invalid', 'c': 'abc'}),
      isEmpty,
    );
  });

  group('typing', () {
    test('someone typing shows by name until they stop or post', () async {
      await session.store.applyConfig('client_config', {
        'TimeBetweenUserTypingUpdatesMilliseconds': '300',
      });
      final seen = <List<String>>[];
      final sub = session.connection.typing.watch(channelId).listen(seen.add);
      await receive('typing', {'user_id': 'u9', 'parent_id': ''});
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(seen.last, ['u9']);
      await session.users.ensure(['u9']);
      final user = await (session.db.select(
        session.db.users,
      )..where((u) => u.id.equals('u9'))).getSingleOrNull();
      expect(user?.username, 'nadia', reason: 'unknown typers are fetched');

      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(seen.last, isEmpty, reason: 'expired');

      await receive('typing', {'user_id': 'u9', 'parent_id': ''});
      await receive('posted', {
        'post': jsonEncode({
          'id': 'p9',
          'channel_id': channelId,
          'user_id': 'u9',
          'create_at': DateTime.utc(2026, 10, 25, 11).millisecondsSinceEpoch,
          'message': 'done',
        }),
      });
      expect(seen.last, isEmpty, reason: 'their post ends it');
      await sub.cancel();
    });

    test('typing in a thread stays in the thread; the user is not shown '
        'typing to themselves', () async {
      await receive('typing', {'user_id': 'u9', 'parent_id': 'root1'});
      await receive('typing', {'user_id': meId, 'parent_id': ''});
      expect(await session.connection.typing.watch(channelId).first, isEmpty);
      expect(
        await session.connection.typing.watch(channelId, rootId: 'root1').first,
        ['u9'],
      );
    });

    test('the tracker expires on its own', () async {
      final tracker = TypingTracker(expiry: const Duration(milliseconds: 20))
        ..typing('c', '', 'u');
      expect(await tracker.watch('c').first, ['u']);
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(await tracker.watch('c').first, isEmpty);
      tracker.close();
    });

    test('sending is throttled by the server interval and turned off for '
        'huge channels', () {
      final t = DateTime.utc(2026, 10, 25, 10);
      bool send({DateTime? last, int? members, bool enabled = true}) =>
          shouldSendTyping(
            now: t,
            lastSent: last,
            interval: const Duration(seconds: 5),
            enabled: enabled,
            memberCount: members,
            maxNotificationsPerChannel: 1000,
          );
      expect(send(), isTrue);
      expect(send(last: t.subtract(const Duration(seconds: 2))), isFalse);
      expect(send(last: t.subtract(const Duration(seconds: 5))), isTrue);
      expect(send(members: 1000), isFalse);
      expect(send(enabled: false), isFalse);
    });

    test(
      'user_typing goes over the socket with the channel and thread',
      () async {
        final sockets = await FakeSocketServer.start();
        final socket = ServerSocket(
          serverUrl: sockets.url,
          token: () => 't',
          onEvent: (_) {},
          onResync: () {},
        );
        final typing = sockets.actions.firstWhere(
          (a) => a['action'] == 'user_typing',
        );
        expect(socket.sendTyping(channelId, ''), isFalse);
        socket.start();
        await sockets.nextConnection();
        while (socket.state.value != SocketState.connected) {
          await Future<void>.delayed(const Duration(milliseconds: 5));
        }
        expect(socket.sendTyping(channelId, 'root1'), isTrue);
        expect((await typing)['data'], {
          'channel_id': channelId,
          'parent_id': 'root1',
        });
        await socket.dispose();
        await sockets.close();
      },
    );
  });
}
