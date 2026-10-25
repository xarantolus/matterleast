import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/data/actions/settings_actions.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/domain/notify_props.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

void main() {
  late FakeServer server;
  late ServerSession session;
  late SettingsActions actions;

  const stored = {
    'push': 'mention',
    'push_status': 'away',
    'desktop': 'all',
    'email': 'true',
    'mention_keys': 'river,@river,anchor',
    'channel': 'true',
  };

  setUp(() async {
    server = await FakeServer.start();
    server.handle = (r) => switch (r.path) {
      '/api/v4/users/me' => ok({
        'id': meId,
        'notify_props': {...stored, 'auto_responder_active': false},
      }),
      '/api/v4/users/me/patch' => ok({
        'id': meId,
        'notify_props': r.body['notify_props'],
      }),
      _ => ok({'status': 'OK'}),
    };
    session = await testSession(server);
    actions = SettingsActions(session);
  });

  tearDown(() async {
    await closeTestSession(session);
    await server.close();
  });

  test('a changed notification setting keeps every other one', () async {
    final props = await actions.notifyProps();
    expect(props.push, PushLevel.mention);
    expect(props.mentionKeys('river'), ['anchor']);

    final saved = await actions.saveNotifyProps(
      props
          .withPush(PushLevel.all)
          .withMentionKeys('river', parseMentionKeys('anchor, buoy')),
    );

    final sent = server.seen.last.body['notify_props']! as Map;
    expect(sent['push'], 'all');
    expect(sent['desktop'], 'all');
    expect(sent['email'], 'true');
    expect(sent['push_status'], 'away');
    expect(sent['mention_keys'], 'river,@river,anchor,buoy');
    expect(saved.push, PushLevel.all);
  });

  test('a refused save passes the server error on', () async {
    server.handle = (r) => error(400, 'api.user.patch.invalid');
    await expectLater(
      actions.saveNotifyProps(const NotifyProps({'push': 'all'})),
      throwsA(isA<ServerError>()),
    );
  });

  test('turning collapsed reply threads on drops the stored history', () async {
    await session.store.applyConfig('client_config', {
      'CollapsedThreads': 'default_off',
    });
    expect(await session.db.select(session.db.posts).get(), isNotEmpty);

    await actions.setCollapsedThreads(true);

    expect(server.seen.first.path, '/api/v4/users/$meId/preferences');
    expect(await session.db.collapsedThreads(), isTrue);
    expect(await session.db.select(session.db.posts).get(), isEmpty);
    expect(await session.db.select(session.db.myChannels).get(), isNotEmpty);
  });

  test('saving the same thread setting again keeps the history', () async {
    await session.store.applyConfig('client_config', {
      'CollapsedThreads': 'default_off',
    });
    await actions.setCollapsedThreads(false);
    expect(await session.db.select(session.db.posts).get(), isNotEmpty);
  });
}
