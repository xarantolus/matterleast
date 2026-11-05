import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/app_db/app_database.dart';

import 'memory_database.dart';

/// Pumps [home] in the app's light theme, inside providers with [overrides]
/// and an in-memory app database, or [appDatabase] when given.
Future<void> pumpApp(
  WidgetTester tester,
  Widget home, {
  List<Override> overrides = const [],
  AppDatabase? appDatabase,
}) {
  final db = appDatabase ?? memoryAppDatabase();
  if (appDatabase == null) addTearDown(db.close);
  return tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db), ...overrides],
      child: MaterialApp(theme: MatterleastApp.lightTheme, home: home),
    ),
  );
}

/// Unmounts the app and lets drift close its queries, which it does on a
/// zero timer, before the test's pending-timer check.
Future<void> closeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(Duration.zero);
}
