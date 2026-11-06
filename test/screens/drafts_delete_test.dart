import 'package:drift/drift.dart' show Value;
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/screens/drafts/drafts_screen.dart';

import '../support/pump_with_server.dart';
import '../support/test_session.dart';

Future<ServerHarness> _pump(WidgetTester tester, TargetPlatform platform) =>
    pumpWithServer(
      tester,
      platform: platform,
      size: const Size(900, 700),
      seed: (session) => session.store.saveDraft(
        DraftsCompanion.insert(
          channelId: channelId,
          message: const Value('half a thought'),
          updatedAt: DateTime.utc(2026, 11),
        ),
      ),
      home: (url) =>
          DraftsScreen(url: url, teamId: teamId, teamName: 'Harbour'),
    );

void main() {
  testWidgets('with a mouse a draft is deleted from its row', (tester) async {
    final h = await _pump(tester, TargetPlatform.linux);
    expect(find.text('half a thought'), findsOneWidget);
    expect(find.byType(Dismissible), findsNothing);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.text('half a thought')));
    await tester.pump();
    await tester.tap(find.byTooltip('Delete draft'));
    await h.settle(tester);

    expect(find.text('Draft deleted'), findsOneWidget);
    expect(find.text('half a thought'), findsNothing);
    await h.close(tester);
  });

  testWidgets('on a phone a draft is swiped away and has no button', (
    tester,
  ) async {
    final h = await _pump(tester, TargetPlatform.android);
    expect(find.byType(Dismissible), findsOneWidget);
    expect(find.byTooltip('Delete draft'), findsNothing);
    await h.close(tester);
  });
}
