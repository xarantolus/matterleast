import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/app/update_providers.dart';
import 'package:matterleast/data/app_db/app_database.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/ui/update_indicator.dart';

import '../support/fake_releases.dart';

void main() {
  late AppDatabase db;
  late FakeReleases github;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase(DatabaseConnection(NativeDatabase.memory()));
    github = FakeReleases();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        updateHttpProvider.overrideWithValue(github.dio),
        runningVersionProvider.overrideWith((ref) async => '0.11.1'),
      ],
    );
  });

  tearDown(() => db.close());

  Future<void> showApp(WidgetTester tester, TargetPlatform platform) async {
    debugDefaultTargetPlatformOverride = platform;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: WindowCorner(
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Town Square'),
                actions: const [UpdateIndicator()],
              ),
            ),
          ),
        ),
      ),
    );
    // The check and the settings database run outside the fake clock.
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  Future<void> closeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    // Drift closes its queries on a zero timer.
    await tester.pump(Duration.zero);
    debugDefaultTargetPlatformOverride = null;
  }

  final indicator = find.byTooltip('Matterleast 0.12.0 is available');

  testWidgets('a desktop shows a newer release and can hide it', (
    tester,
  ) async {
    await showApp(tester, TargetPlatform.linux);

    expect(github.requests, hasLength(1));
    expect(indicator, findsOneWidget);

    await tester.tap(indicator);
    await tester.pumpAndSettle();
    expect(find.text('Open release page'), findsOneWidget);

    await tester.tap(find.text('Hide until the next version'));
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pumpAndSettle();
    }
    expect(indicator, findsNothing);
    expect(
      await tester.runAsync(
        () => SettingsStore(db).read(Settings.dismissedRelease),
      ),
      'v0.12.0',
    );

    await closeApp(tester);
  });

  testWidgets('a desktop shows nothing when the app is current', (
    tester,
  ) async {
    github.tag = 'v0.11.1';
    await showApp(tester, TargetPlatform.windows);

    expect(github.requests, hasLength(1));
    expect(find.byType(IconButton), findsNothing);

    await closeApp(tester);
  });

  testWidgets('a phone never asks and shows nothing', (tester) async {
    await showApp(tester, TargetPlatform.android);

    expect(github.requests, isEmpty);
    expect(find.byType(IconButton), findsNothing);

    await closeApp(tester);
  });
}
