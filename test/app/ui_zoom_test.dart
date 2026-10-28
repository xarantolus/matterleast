import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/keyboard_shortcuts.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/app/ui_zoom.dart';
import 'package:matterleast/data/app_db/app_database.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/domain/ui_zoom.dart';

void main() {
  final desktop = TargetPlatformVariant.only(TargetPlatform.windows);

  late AppDatabase db;
  setUp(() => db = AppDatabase(DatabaseConnection(NativeDatabase.memory())));
  tearDown(() => db.close());

  Size? laidOut;
  double? pixelRatio;

  Future<void> show(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          builder: (_, child) => UiZoom(child: AppShortcuts(child: child!)),
          home: Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                laidOut = constraints.biggest;
                pixelRatio = MediaQuery.devicePixelRatioOf(context);
                return const TextField(autofocus: true);
              },
            ),
          ),
        ),
      ),
    );
    await settle(tester);
  }

  Future<void> press(WidgetTester tester, LogicalKeyboardKey key) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(key);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await settle(tester);
  }

  testWidgets('Ctrl+plus and Ctrl+minus zoom the whole window in steps, '
      'kept for the next start', (tester) async {
    await show(tester);
    expect(laidOut, const Size(1200, 800));

    await press(tester, LogicalKeyboardKey.equal);
    expect(await db.allSettings(), containsPair('uiZoom', '110'));
    expect(laidOut!.width, closeTo(1200 / 1.1, 0.01));
    expect(laidOut!.height, closeTo(800 / 1.1, 0.01));
    expect(pixelRatio, closeTo(1.1, 0.001));
    // Laid out smaller, drawn larger: it still fills the window.
    expect(
      tester.getBottomRight(find.byType(Scaffold)),
      const Offset(1200, 800),
    );

    await press(tester, LogicalKeyboardKey.numpadAdd);
    expect(laidOut!.width, closeTo(1200 / 1.25, 0.01));

    await press(tester, LogicalKeyboardKey.digit0);
    expect(laidOut, const Size(1200, 800));
    for (var i = 0; i < 5; i++) {
      await press(tester, LogicalKeyboardKey.minus);
    }
    expect(laidOut!.width, closeTo(1200 / 0.8, 0.01));

    // A new start opens at the zoom left last.
    await tester.pumpWidget(const SizedBox());
    await show(tester);
    expect(laidOut!.width, closeTo(1200 / 0.8, 0.01));
    await close(tester);
  }, variant: desktop);

  testWidgets('a phone has no zoom', (tester) async {
    await SettingsStore(db).write(Settings.uiZoom, 150);
    await show(tester);
    expect(laidOut, const Size(1200, 800));
    await close(tester);
  });

  test('zoom steps stop at either end and snap to a step', () {
    expect(zoomAfter(ZoomChange.zoomIn, 100), 110);
    expect(zoomAfter(ZoomChange.zoomIn, 200), 200);
    expect(zoomAfter(ZoomChange.zoomOut, 80), 80);
    expect(zoomAfter(ZoomChange.zoomOut, 125), 110);
    expect(zoomAfter(ZoomChange.reset, 175), 100);
  });

  test('the zoom setting only takes a step', () {
    expect(Settings.uiZoom.read({'uiZoom': '125'}), 125);
    expect(Settings.uiZoom.read({'uiZoom': '1000'}), 100);
  });
}

Future<void> close(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await settle(tester);
  await tester.pump(const Duration(seconds: 1));
}

/// Lets the settings database answer outside the fake clock.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
  }
}
