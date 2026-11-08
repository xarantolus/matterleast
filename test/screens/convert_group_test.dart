import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/screens/channel_info/convert_group_screen.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';
import '../support/seed.dart';
import '../support/test_session.dart';

void main() {
  late ServerHarness h;

  Future<void> start(WidgetTester tester, {required bool canCreate}) async {
    h = await pumpWithServer(
      tester,
      size: const Size(900, 1200),
      handle: (r) => switch ((r.method, r.path)) {
        ('POST', final p) when p.endsWith('/convert_to_channel') => error(
          400,
          'api.channel.convert_group_message_to_channel.name_exists',
        ),
        _ => emptyAnswer(r),
      },
      seed: (session) async {
        await seedMyPermissions(session, [
          if (canCreate) 'create_private_channel',
        ]);
      },
      home: (url) => ConvertGroupScreen(
        url: url,
        channelId: channelId,
        initialTeamId: teamId,
      ),
    );
  }

  testWidgets('converting sends the name and team, and shows a refusal', (
    tester,
  ) async {
    await start(tester, canCreate: true);
    await tester.enterText(find.byType(TextField), 'Crew Plans');
    await tester.pump();
    await tester.tap(find.text('Convert'));
    await h.settle(tester);
    final sent = h.server.seen.singleWhere(
      (r) => r.path.endsWith('/convert_to_channel'),
    );
    expect(sent.body, {
      'channel_id': channelId,
      'team_id': teamId,
      'display_name': 'Crew Plans',
      'name': 'crew-plans',
    });
    expect(find.textContaining('already exists'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('without a name or a team to move into nothing is sent', (
    tester,
  ) async {
    await start(tester, canCreate: false);
    await tester.enterText(find.byType(TextField), 'Crew Plans');
    await tester.pump();
    await tester.tap(find.text('Convert'));
    await h.settle(tester);
    expect(
      h.server.seen.any((r) => r.path.endsWith('/convert_to_channel')),
      isFalse,
    );
    await h.close(tester);
  });
}
