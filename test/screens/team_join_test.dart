import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/screens/root/team_screens.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';

void main() {
  late ServerHarness h;

  Future<void> open(WidgetTester tester, Reply team) async {
    h = await pumpWithServer(
      tester,
      handle: (r) => switch ((r.method, r.path)) {
        ('GET', '/api/v4/teams/invite/inv1') => team,
        ('POST', '/api/v4/teams/members/invite') => ok({
          'team_id': 'tm00000000000000000000t02',
          'user_id': 'me',
        }),
        _ => ok(const <String, Object?>{}),
      },
      home: (url) => Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => joinFromInvite(Navigator.of(context), url, 'inv1'),
            child: const Text('Open link'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open link'));
    await h.settle(tester);
  }

  testWidgets('an invite link shows the team and joins it on confirm', (
    tester,
  ) async {
    await open(
      tester,
      ok({
        'id': 'tm00000000000000000000t02',
        'name': 'dock',
        'display_name': 'Dockside',
        'description': 'Ships in and out',
      }),
    );
    expect(find.text('Join Dockside?'), findsOneWidget);
    expect(find.text('Ships in and out'), findsOneWidget);
    await tester.tap(find.text('Join'));
    await h.settle(tester);
    final join = h.server.seen.singleWhere(
      (r) => r.path == '/api/v4/teams/members/invite',
    );
    expect(join.raw.uri.queryParameters['invite_id'], 'inv1');
    await h.close(tester);
  });

  testWidgets('declining joins nothing', (tester) async {
    await open(tester, ok({'id': 'tm00000000000000000000t02', 'name': 'dock'}));
    await tester.tap(find.text('Cancel'));
    await h.settle(tester);
    expect(
      h.server.seen.any((r) => r.path == '/api/v4/teams/members/invite'),
      isFalse,
    );
    await h.close(tester);
  });

  testWidgets('a link that is no longer valid says so', (tester) async {
    await open(tester, error(404, 'app.team.get_by_invite_id.finding'));
    expect(find.text('This invite link is no longer valid.'), findsOneWidget);
    await h.close(tester);
  });
}
