import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/actions/profile_actions.dart';
import 'package:matterleast/data/actions/settings_actions.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/domain/clock_preference.dart';
import 'package:matterleast/domain/notify_props.dart';
import 'package:matterleast/domain/preference_keys.dart';

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
    (server, session) = await startServerSession();
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
      _ => emptyAnswer(r),
    };
    actions = SettingsActions(session);
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

  test('a time zone picked by hand keeps the one the devices reported, '
      'and switching back to automatic keeps the picked one', () async {
    Map<String, Object?>? zone;
    server.handle = (r) => switch (r.path) {
      '/api/v4/users/me/patch' => ok({
        'id': meId,
        'username': 'river',
        'timezone': zone = r.body['timezone']! as Map<String, Object?>,
      }),
      _ => ok({
        'id': meId,
        'username': 'river',
        'timezone': {
          'useAutomaticTimezone': 'true',
          'automaticTimezone': 'Europe/Berlin',
          'manualTimezone': '',
        },
      }),
    };
    await session.store.applyMe(
      api.User.fromJson({
        'id': meId,
        'username': 'river',
        'timezone': {
          'useAutomaticTimezone': 'true',
          'automaticTimezone': 'Europe/Berlin',
          'manualTimezone': '',
        },
      }),
    );
    final profile = ProfileActions(session);

    await profile.setTimeZone(automatic: false, manual: 'Asia/Tokyo');
    expect(zone, {
      'useAutomaticTimezone': 'false',
      'automaticTimezone': 'Europe/Berlin',
      'manualTimezone': 'Asia/Tokyo',
    });

    await profile.setTimeZone(automatic: true);
    expect(zone, {
      'useAutomaticTimezone': 'true',
      'automaticTimezone': 'Europe/Berlin',
      'manualTimezone': 'Asia/Tokyo',
    });
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

  test(
    'picking the 24-hour clock saves the shared server preference',
    () async {
      expect(clockFrom(await _clock(session)), isNull);

      await actions.setMilitaryTime(true);

      final sent = server.seen.firstWhere((r) => r.method == 'PUT').json;
      expect(sent, [
        {
          'user_id': meId,
          'category': 'display_settings',
          'name': 'use_military_time',
          'value': 'true',
        },
      ]);
      expect(clockFrom(await _clock(session)), isTrue);

      await actions.setMilitaryTime(false);
      expect(clockFrom(await _clock(session)), isFalse);
    },
  );

  test('only true and false in the preference pick a clock', () {
    expect(clockFrom('true'), isTrue);
    expect(clockFrom('false'), isFalse);
    expect(clockFrom(null), isNull);
    expect(clockFrom('maybe'), isNull);
  });
}

Future<String?> _clock(ServerSession session) async =>
    session.db.preference(Prefs.militaryTime.$1, Prefs.militaryTime.$2);
