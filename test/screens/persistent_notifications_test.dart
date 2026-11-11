import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/permission_providers.dart';
import 'package:matterleast/data/server_db/server_config.dart';
import 'package:matterleast/screens/channel/channel_screen.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';
import '../support/test_session.dart';

const _note =
    'Recipients are notified every 10 minutes until they acknowledge or '
    'reply.';

Future<ServerHarness> _open(
  WidgetTester tester, {
  bool allowed = true,
  bool guest = false,
  bool guestsAllowed = false,
  Reply? Function(SeenRequest r)? posts,
}) => pumpWithServer(
  tester,
  size: const Size(800, 1600),
  handle: (r) {
    if (r.method == 'POST' && r.path == '/api/v4/posts') {
      return posts?.call(r) ??
          ok({
            'id': 'new1',
            'channel_id': channelId,
            'user_id': meId,
            'create_at': DateTime.now().millisecondsSinceEpoch,
            'message': r.body['message'],
            'pending_post_id': r.body['pending_post_id'],
          });
    }
    return emptyAnswer(r);
  },
  seed: (session) async {
    await session.store.applyConfig(ConfigKeys.clientConfig, {
      'PostPriority': 'true',
      'AllowPersistentNotifications': allowed ? 'true' : 'false',
      'PersistentNotificationIntervalMinutes': '10',
      'AllowPersistentNotificationsForGuests': guestsAllowed ? 'true' : 'false',
    });
    await session.store.applyConfig(ConfigKeys.license, {'IsLicensed': 'true'});
    if (guest) {
      await session.db.setSyncText('current_user_roles', 'system_guest');
    }
    await session.outbox.start();
  },
  overrides: (url) => [
    channelRightsProvider(url, channelId).overrideWith(
      (ref) => Stream.value((
        block: null,
        react: true,
        editOwn: true,
        editOthers: false,
        deleteOwn: true,
        deleteOthers: false,
        channelMentions: true,
        groupMentions: true,
      )),
    ),
  ],
  home: (url) => ChannelScreen(url: url, channelId: channelId, title: 'Boats'),
);

Future<void> _openPicker(WidgetTester tester, ServerHarness h) async {
  await tester.tap(find.byTooltip('Attach'));
  await h.settle(
    tester,
    until: () => find.text('Message priority').tryEvaluate(),
  );
  await tester.tap(find.text('Message priority'));
  await h.settle(tester, until: () => find.text('Urgent').tryEvaluate());
}

Future<void> _chooseUrgentRepeating(
  WidgetTester tester,
  ServerHarness h,
) async {
  await _openPicker(tester, h);
  await tester.tap(find.text('Urgent'));
  await tester.pump();
  await tester.tap(find.text('Send persistent notifications'));
  await tester.pump();
  await tester.tap(find.text('Apply'));
  await h.settle(tester);
}

void main() {
  testWidgets('the switch shows only while the level is Urgent', (
    tester,
  ) async {
    final h = await _open(tester);
    await _openPicker(tester, h);

    expect(find.text('Send persistent notifications'), findsNothing);
    await tester.tap(find.text('Important'));
    await tester.pump();
    expect(find.text('Send persistent notifications'), findsNothing);
    await tester.tap(find.text('Urgent'));
    await tester.pump();
    expect(find.text('Send persistent notifications'), findsOneWidget);
    expect(find.text(_note), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('moving away from Urgent clears the switch', (tester) async {
    final h = await _open(tester);
    await _openPicker(tester, h);
    await tester.tap(find.text('Urgent'));
    await tester.pump();
    await tester.tap(find.text('Send persistent notifications'));
    await tester.pump();
    await tester.tap(find.text('Important'));
    await tester.pump();
    await tester.tap(find.text('Urgent'));
    await tester.pump();

    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );
    await h.close(tester);
  });

  testWidgets('a server that does not allow it shows no switch', (
    tester,
  ) async {
    final h = await _open(tester, allowed: false);
    await _openPicker(tester, h);
    await tester.tap(find.text('Urgent'));
    await tester.pump();

    expect(find.text('Send persistent notifications'), findsNothing);
    await h.close(tester);
  });

  testWidgets('a guest sees no switch unless the server allows guests', (
    tester,
  ) async {
    final h = await _open(tester, guest: true);
    await _openPicker(tester, h);
    await tester.tap(find.text('Urgent'));
    await tester.pump();

    expect(find.text('Send persistent notifications'), findsNothing);
    await h.close(tester);
  });

  testWidgets('a guest sees the switch where the server allows guests', (
    tester,
  ) async {
    final h = await _open(tester, guest: true, guestsAllowed: true);
    await _openPicker(tester, h);
    await tester.tap(find.text('Urgent'));
    await tester.pump();

    expect(find.text('Send persistent notifications'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('it is confirmed before sending, then goes with the message', (
    tester,
  ) async {
    final h = await _open(tester);
    await _chooseUrgentRepeating(tester, h);
    expect(find.textContaining('persistent notifications'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Boat adrift');
    await tester.pump();
    await tester.tap(find.byTooltip('Send'));
    await h.settle(
      tester,
      until: () => find.text('$_note Send?').tryEvaluate(),
    );
    expect(
      h.server.seen.where(
        (r) => r.method == 'POST' && r.path == '/api/v4/posts',
      ),
      isEmpty,
    );

    await tester.tap(find.text('Send'));
    await h.settle(tester);
    final sent = h.server.seen.singleWhere(
      (r) => r.method == 'POST' && r.path == '/api/v4/posts',
    );
    expect(
      sent.body['metadata'],
      containsPair(
        'priority',
        allOf(
          containsPair('priority', 'urgent'),
          containsPair('persistent_notifications', true),
        ),
      ),
    );
    await h.close(tester);
  });

  testWidgets('cancelling the confirmation sends nothing and keeps the '
      'message', (tester) async {
    final h = await _open(tester);
    await _chooseUrgentRepeating(tester, h);
    await tester.enterText(find.byType(TextField), 'Boat adrift');
    await tester.pump();
    await tester.tap(find.byTooltip('Send'));
    await h.settle(tester, until: () => find.text('Cancel').tryEvaluate());

    await tester.tap(find.text('Cancel'));
    await h.settle(tester);

    expect(
      h.server.seen.where(
        (r) => r.method == 'POST' && r.path == '/api/v4/posts',
      ),
      isEmpty,
    );
    expect(find.text('Boat adrift'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('a server that refuses leaves the post to retry, with its '
      'message', (tester) async {
    final h = await _open(
      tester,
      posts: (r) =>
          error(400, 'Too many recipients for persistent notifications'),
    );
    await _chooseUrgentRepeating(tester, h);
    await tester.enterText(find.byType(TextField), 'Boat adrift');
    await tester.pump();
    await tester.tap(find.byTooltip('Send'));
    await h.settle(tester, until: () => find.text('Send').tryEvaluate());
    await tester.tap(find.text('Send'));
    await h.settle(
      tester,
      until: () => find.textContaining('Not sent').tryEvaluate(),
    );

    await tester.tap(find.textContaining('Not sent'));
    await h.settle(tester, until: () => find.text('Try again').tryEvaluate());

    expect(
      find.text('Too many recipients for persistent notifications'),
      findsOneWidget,
    );
    await h.close(tester);
  });
}
