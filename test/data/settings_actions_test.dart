import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/actions/settings_actions.dart';
import 'package:matterleast/data/server_db/server_database.dart';
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
        'username': 'river',
        'notify_props': stored,
      }),
      '/api/v4/users/me/patch' => ok({
        'id': meId,
        'username': 'river',
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

  Future<NotifyProps> storedProps() async => NotifyProps.fromJsonText(
    await session.db.syncText(SyncKeys.accountNotifyProps),
  );

  test('a changed notification setting keeps every other one', () async {
    await actions.refreshNotifyProps();
    final props = await storedProps();
    expect(props.push, PushLevel.mention);
    expect(props.pushTrigger, PushTrigger.away);
    expect(props.mentionKeys('river'), ['anchor']);

    await actions.saveNotifyProps(
      props,
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
    expect((await storedProps()).push, PushLevel.all);
  });

  test('email off and an automatic reply with its message reach the '
      'server, keeping the other settings', () async {
    await actions.refreshNotifyProps();
    final props = await storedProps();
    expect(props.email, isTrue);
    expect(props.autoReply, isFalse);
    expect(props.autoReplyMessage, NotifyProps.defaultAutoReply);

    await actions.saveNotifyProps(props, props.withEmail(false));
    expect((server.seen.last.body['notify_props']! as Map)['email'], 'false');
    final emailOff = await storedProps();
    expect(emailOff.email, isFalse);
    await actions.saveNotifyProps(
      emailOff,
      emailOff.withAutoReply(true, '  Back on Monday.  '),
    );

    final sent = server.seen.last.body['notify_props']! as Map;
    expect(sent['auto_responder_active'], 'true');
    expect(sent['auto_responder_message'], 'Back on Monday.');
    expect(sent['push'], 'mention');
    final after = await storedProps();
    expect(after.autoReply, isTrue);
    expect(
      after.withAutoReply(true, '   ').autoReplyMessage,
      NotifyProps.defaultAutoReply,
    );
  });

  test('saved mention words reach the Mentions search at once', () async {
    await actions.refreshNotifyProps();
    expect(
      await session.db.syncText(SyncKeys.mentionTerms),
      isNot(contains('buoy')),
    );
    final props = await storedProps();
    await actions.saveNotifyProps(
      props,
      props.withMentionKeys('river', ['anchor', 'buoy']),
    );
    expect(
      (await session.db.syncText(SyncKeys.mentionTerms))!.split(' '),
      containsAll(['anchor', 'buoy', '@river']),
    );
  });

  test('a sign-in refresh keeps the keys only the full map has', () async {
    await actions.refreshNotifyProps();
    await session.store.applyMe(
      api.User.fromJson({
        'id': meId,
        'username': 'river',
        'notify_props': {'push': 'none'},
      }),
    );
    final props = await storedProps();
    expect(props.push, PushLevel.none);
    expect(props.pushTrigger, PushTrigger.away);
  });

  test('a refused save passes the server error on', () async {
    server.handle = (r) => error(400, 'api.user.patch.invalid');
    await expectLater(
      actions.saveNotifyProps(
        const NotifyProps({}),
        const NotifyProps({'push': 'all'}),
      ),
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
