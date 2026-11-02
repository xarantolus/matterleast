import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/server_db/server_config.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/screens/root/team_screens.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';
import '../support/test_session.dart';

void main() {
  late ServerHarness h;

  Future<void> start(
    WidgetTester tester, {
    bool admin = true,
    bool emailInvitations = true,
    bool unread = false,
    Reply? invite,
  }) async {
    h = await pumpWithServer(
      tester,
      size: const Size(900, 1200),
      handle: (r) => switch ((r.method, r.path)) {
        ('POST', final p) when p.endsWith('/invite/email') =>
          invite ?? ok({'status': 'OK'}),
        ('POST', '/api/v4/channels/members/me/view') => ok({
          'status': 'OK',
          'last_viewed_at_times': {channelId: 1},
        }),
        _ => ok(const <String, Object?>{}),
      },
      seed: (ServerSession session) async {
        await session.db.setSyncText(SyncKeys.currentUserRoles, 'system_user');
        await session.store.applyConfig(ConfigKeys.clientConfig, {
          'EnableEmailInvitations': emailInvitations ? 'true' : 'false',
        });
        await session.store.applyRoles([
          api.Role.fromJson({
            'id': 'rl000000000000000000000r01',
            'name': 'system_user',
            'permissions': [
              if (admin) ...['invite_user', 'add_user_to_team'],
            ],
          }),
        ]);
        if (unread) {
          await session.store.applyCategoryUpdates([
            api.SidebarCategoryWithChannels.fromJson({
              'id': 'cat1',
              'user_id': meId,
              'team_id': teamId,
              'display_name': 'Channels',
              'type': 'channels',
              'sorting': 'alpha',
              'channel_ids': [channelId],
            }),
          ]);
          await session.store.applyChannels(
            channels: [
              api.Channel.fromJson({
                'id': channelId,
                'team_id': teamId,
                'type': 'O',
                'name': 'boats',
                'display_name': 'Boats',
                'total_msg_count': 5,
              }),
            ],
            members: [
              api.ChannelMember.fromJson({
                'channel_id': channelId,
                'user_id': meId,
                'msg_count': 1,
              }),
            ],
          );
        }
      },
      home: (url) => Scaffold(
        appBar: AppBar(
          actions: [TeamMenu(url: url, teamId: teamId, teamName: 'Harbour')],
        ),
      ),
    );
    await tester.tap(find.byTooltip('Team'));
    await h.settle(tester, rounds: 5);
  }

  testWidgets('people who may invite get the email form and send it', (
    tester,
  ) async {
    await start(tester);
    await tester.tap(find.text('Invite people'));
    await h.settle(tester, rounds: 5);
    await tester.enterText(
      find.byType(TextField),
      'kit@example.test, rowan@example.test',
    );
    await tester.tap(find.text('Send invitations'));
    await h.settle(tester, rounds: 20);
    final sent = h.server.seen.singleWhere(
      (r) => r.path.endsWith('/invite/email'),
    );
    expect(sent.json, ['kit@example.test', 'rowan@example.test']);
    expect(find.text('2 invitations sent'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('a wrong address is named and nothing is sent', (tester) async {
    await start(tester);
    await tester.tap(find.text('Invite people'));
    await h.settle(tester, rounds: 5);
    await tester.enterText(find.byType(TextField), 'kit@example.test nope');
    await tester.tap(find.text('Send invitations'));
    await h.settle(tester, rounds: 5);
    expect(find.text('nope is not an email address.'), findsOneWidget);
    expect(h.server.seen.any((r) => r.path.endsWith('/invite/email')), isFalse);
    await h.close(tester);
  });

  testWidgets('the server refusing says why and keeps the addresses', (
    tester,
  ) async {
    await start(tester, invite: error(501, 'api.team.invite_members.disabled'));
    await tester.tap(find.text('Invite people'));
    await h.settle(tester, rounds: 5);
    await tester.enterText(find.byType(TextField), 'kit@example.test');
    await tester.tap(find.text('Send invitations'));
    await h.settle(tester, rounds: 20);
    expect(
      find.textContaining('api.team.invite_members.disabled'),
      findsOneWidget,
    );
    expect(find.text('kit@example.test'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('without the permission there is no way to invite', (
    tester,
  ) async {
    await start(tester, admin: false);
    expect(find.text('Invite people'), findsNothing);
    expect(find.text('Copy invite link'), findsNothing);
    expect(find.text('Leave Harbour'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('with email invitations off only the link is offered', (
    tester,
  ) async {
    await start(tester, emailInvitations: false);
    expect(find.text('Invite people'), findsNothing);
    expect(find.text('Copy invite link'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('a team with unread channels can be marked read', (tester) async {
    await start(tester, unread: true);
    await tester.tap(find.text('Mark all as read'));
    await h.settle(tester, rounds: 20);
    expect(
      h.server.seen.any((r) => r.path == '/api/v4/channels/members/me/view'),
      isTrue,
    );
    await h.close(tester);
  });

  testWidgets('a team with nothing unread offers no marking', (tester) async {
    await start(tester);
    expect(find.text('Mark all as read'), findsNothing);
    await h.close(tester);
  });
}
