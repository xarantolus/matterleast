import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/screens/channel_info/members_screen.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';
import '../support/test_session.dart';

Map<String, Object?> _user(String id, String name) => {
  'id': id,
  'username': name,
  'first_name': name,
  'roles': 'system_user',
};

void main() {
  late ServerHarness h;

  Future<void> start(
    WidgetTester tester, {
    required bool canChangeRoles,
    Reply? change,
  }) async {
    h = await pumpWithServer(
      tester,
      handle: (r) => switch ((r.method, r.path)) {
        ('GET', '/api/v4/users') => ok([
          _user(meId, 'river'),
          _user('u2', 'Mira'),
          _user('u3', 'Odin'),
        ]),
        ('GET', final p) when p.endsWith('/members') => ok([
          {'channel_id': channelId, 'user_id': 'u3', 'scheme_admin': true},
          {'channel_id': channelId, 'user_id': 'u2', 'scheme_admin': false},
        ]),
        ('PUT', final p) when p.endsWith('/schemeRoles') =>
          change ?? ok({'status': 'OK'}),
        _ => ok(const <String, Object?>{}),
      },
      home: (url) => MembersScreen(
        url: url,
        channelId: channelId,
        teamId: teamId,
        title: 'Boats',
        canAdd: false,
        canChangeRoles: canChangeRoles,
      ),
    );
  }

  testWidgets('channel admins carry an Admin tag, others do not', (
    tester,
  ) async {
    await start(tester, canChangeRoles: false);
    expect(find.text('Admin'), findsOneWidget);
    expect(find.byTooltip('Roles of Mira'), findsNothing);
    await h.close(tester);
  });

  testWidgets('making a member a channel admin sends the new roles', (
    tester,
  ) async {
    await start(tester, canChangeRoles: true);
    await tester.tap(find.byTooltip('Roles of Mira'));
    await h.settle(tester);
    await tester.tap(find.text('Make channel admin'));
    await h.settle(tester);
    final put = h.server.seen.singleWhere((r) => r.method == 'PUT');
    expect(put.path, endsWith('/members/u2/schemeRoles'));
    expect(put.body['scheme_admin'], isTrue);
    await h.close(tester);
  });

  testWidgets('an admin offers to be made an ordinary member again', (
    tester,
  ) async {
    await start(tester, canChangeRoles: true);
    await tester.tap(find.byTooltip('Roles of Odin'));
    await h.settle(tester);
    expect(find.text('Remove channel admin'), findsOneWidget);
    expect(find.text('Make channel admin'), findsNothing);
    await h.close(tester);
  });

  testWidgets('a refusal says what the server said and hides the menus', (
    tester,
  ) async {
    await start(
      tester,
      canChangeRoles: true,
      change: error(403, 'api.context.permissions.app_error'),
    );
    await tester.tap(find.byTooltip('Roles of Mira'));
    await h.settle(tester);
    await tester.tap(find.text('Make channel admin'));
    await h.settle(tester);
    expect(find.textContaining("Couldn't change Mira"), findsOneWidget);
    expect(find.byTooltip('Roles of Mira'), findsNothing);
    await h.close(tester);
  });
}
