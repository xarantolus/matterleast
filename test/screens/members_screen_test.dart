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

  Future<void> start(WidgetTester tester, {required bool canRemove}) async {
    h = await pumpWithServer(
      tester,
      handle: (r) => switch ((r.method, r.path)) {
        ('GET', '/api/v4/users') => ok([
          _user(meId, 'river'),
          _user('u2', 'Mira'),
        ]),
        ('DELETE', _) => ok({'status': 'OK'}),
        _ => ok(const <String, Object?>{}),
      },
      home: (url) => MembersScreen(
        url: url,
        channelId: channelId,
        teamId: teamId,
        title: 'Boats',
        canAdd: false,
        canRemove: canRemove,
      ),
    );
  }

  testWidgets('removing a member after confirming drops them from the list', (
    tester,
  ) async {
    await start(tester, canRemove: true);
    expect(find.text('Mira'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove Mira from channel'));
    await h.settle(tester, rounds: 20);
    expect(find.text('Remove from Channel'), findsOneWidget);
    await tester.tap(find.text('Remove'));
    await h.settle(tester, rounds: 20);
    expect(find.text('Mira'), findsNothing);
    expect(
      h.server.seen.any(
        (r) => r.method == 'DELETE' && r.path.endsWith('/members/u2'),
      ),
      isTrue,
    );
    await h.close(tester);
  });

  testWidgets('cancelling the confirm keeps the member', (tester) async {
    await start(tester, canRemove: true);
    await tester.tap(find.byTooltip('Remove Mira from channel'));
    await h.settle(tester, rounds: 20);
    await tester.tap(find.text('Cancel'));
    await h.settle(tester, rounds: 20);
    expect(find.text('Mira'), findsOneWidget);
    expect(h.server.seen.any((r) => r.method == 'DELETE'), isFalse);
    await h.close(tester);
  });

  testWidgets('without the right there are no remove buttons', (tester) async {
    await start(tester, canRemove: false);
    expect(find.byTooltip('Remove Mira from channel'), findsNothing);
    await h.close(tester);
  });

  testWidgets('you get no remove button for yourself', (tester) async {
    await start(tester, canRemove: true);
    expect(find.byTooltip('Remove Mira from channel'), findsOneWidget);
    expect(find.byTooltip('Remove river from channel'), findsNothing);
    await h.close(tester);
  });
}
