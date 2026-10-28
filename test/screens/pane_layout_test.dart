import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/app_db/app_database.dart';
import 'package:matterleast/screens/root/pane_layout.dart';

void main() {
  testWidgets('a snack bar shows once in a window of several panes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = AppDatabase(DatabaseConnection(NativeDatabase.memory()));
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: MatterleastApp.lightTheme,
          home: const PaneLayout(
            list: Scaffold(body: Center(child: Text('Channels'))),
          ),
        ),
      ),
    );
    // The database answers outside the fake clock.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
    // The list and the empty conversation pane are both on screen.
    expect(find.text('Channels'), findsOneWidget);
    expect(find.text('No conversation open'), findsOneWidget);
    ScaffoldMessenger.of(tester.element(find.text('Channels')))
        .showSnackBar(const SnackBar(content: Text('Copied')));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Copied'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    // Drift closes its queries on a zero timer.
    await tester.pump(Duration.zero);
  });
}
