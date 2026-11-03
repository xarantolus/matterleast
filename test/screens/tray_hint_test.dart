import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/screens/settings/phone_notifications.dart';

import '../support/memory_database.dart';
import '../support/pump_app.dart';

void main() {
  Future<ValueNotifier<bool>> show(WidgetTester tester, bool hasTray) async {
    final tray = ValueNotifier(hasTray);
    addTearDown(tray.dispose);
    final db = memoryAppDatabase();
    addTearDown(db.close);
    await pumpApp(
      tester,
      Scaffold(body: ComputerNotifications(hasTray: tray)),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        closeToTrayProvider.overrideWith((ref) => Stream.value(true)),
      ],
    );
    await tester.pump();
    return tray;
  }

  const hint = 'No tray on this desktop.';

  testWidgets('without a tray the setting says closing quits', (tester) async {
    await show(tester, false);
    expect(find.textContaining(hint), findsOneWidget);
    expect(find.textContaining('AppIndicator'), findsOneWidget);
  });

  testWidgets('with a tray there is no hint, and it appears when the tray '
      'goes', (tester) async {
    final tray = await show(tester, true);
    expect(find.textContaining(hint), findsNothing);
    tray.value = false;
    await tester.pump();
    expect(find.textContaining(hint), findsOneWidget);
  });
}
