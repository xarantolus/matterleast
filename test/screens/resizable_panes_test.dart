import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/app_db/app_database.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/domain/pane_widths.dart';
import 'package:matterleast/screens/root/resizable_panes.dart';

/// How often each row was built, by name.
final _builds = <String, int>{};

class _Row extends StatelessWidget {
  const _Row(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    _builds.update(name, (n) => n + 1, ifAbsent: () => 1);
    // Rows depend on the window like real ones do.
    MediaQuery.sizeOf(context);
    return SizedBox(height: 40, child: Text(name));
  }
}

class _Pane extends StatelessWidget {
  const _Pane(this.name, {super.key});

  final String name;

  @override
  Widget build(BuildContext context) =>
      ListView(children: [for (var i = 0; i < 12; i++) _Row('$name $i')]);
}

const _rail = 73.0;
const _defaultList = 360.0;

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(DatabaseConnection(NativeDatabase.memory()));
    _builds.clear();
  });

  tearDown(() => db.close());

  final listPane = find.byKey(const ValueKey('list'));
  final threadPane = find.byKey(const ValueKey('thread'));
  Finder divider(String label) => find.byWidgetPredicate(
    (w) => w is Semantics && w.properties.label == label,
  );
  final listDivider = divider('Channel list width');
  final threadDivider = divider('Thread width');

  double listWidth(WidgetTester tester) =>
      tester.getSize(listPane).width - _rail;
  double threadWidth(WidgetTester tester) => tester.getSize(threadPane).width;

  /// The database answers outside the fake clock.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  Future<void> show(
    WidgetTester tester, {
    double width = 1600,
    bool thread = false,
  }) async {
    tester.view
      ..physicalSize = Size(width, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: ResizablePanes(
            defaultListWidth: _defaultList,
            listInset: _rail,
            list: const _Pane('list', key: ValueKey('list')),
            main: const _Pane('main', key: ValueKey('main')),
            side: thread
                ? const _Pane('thread', key: ValueKey('thread'))
                : null,
          ),
        ),
      ),
    );
    await settle(tester);
  }

  Future<void> close(WidgetTester tester) async {
    // Past the double-tap timeout a drag starts.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox());
    // Drift closes its queries on a zero timer.
    await tester.pump(Duration.zero);
  }

  Future<void> drag(WidgetTester tester, Finder divider, double dx) async {
    final gesture = await tester.startGesture(tester.getCenter(divider));
    for (var i = 1; i <= 10; i++) {
      await gesture.moveBy(Offset(dx / 10, 0));
      await tester.pump();
    }
    await gesture.up();
    await tester.pump();
  }

  Future<PaneWidths> stored() async =>
      (await SettingsStore(db).read(Settings.paneWidths));

  testWidgets('dragging a divider resizes its pane within limits', (
    tester,
  ) async {
    await show(tester);
    expect(listWidth(tester), _defaultList);

    await drag(tester, listDivider, 100);
    expect(listWidth(tester), _defaultList + 100);

    await drag(tester, listDivider, 2000);
    expect(listWidth(tester), maxListWidth);

    await drag(tester, listDivider, -2000);
    expect(listWidth(tester), minListWidth);
    await close(tester);
  });

  testWidgets('the thread pane grows when its divider moves left', (
    tester,
  ) async {
    await show(tester, thread: true);
    expect(threadWidth(tester), 400);

    await drag(tester, threadDivider, -80);
    expect(threadWidth(tester), 480);
    await close(tester);
  });

  testWidgets('dragged widths are saved and come back next time', (
    tester,
  ) async {
    await show(tester, thread: true);
    await drag(tester, listDivider, -60);
    await drag(tester, threadDivider, -100);
    await settle(tester);
    expect(
      await tester.runAsync(stored),
      const PaneWidths(listBesideThread: 300, thread: 500),
    );
    await close(tester);

    await show(tester, thread: true);
    expect(listWidth(tester), 300);
    expect(threadWidth(tester), 500);
    await close(tester);

    // Without a thread the list keeps its own width.
    await show(tester);
    expect(listWidth(tester), _defaultList);
    await close(tester);
  });

  testWidgets('a narrower window takes from the thread, then the list, and '
      'gives the stored widths back', (tester) async {
    const saved = PaneWidths(listBesideThread: 400, thread: 500);
    await tester.runAsync(
      () => SettingsStore(db).write(Settings.paneWidths, saved),
    );
    await show(tester, thread: true);
    expect((listWidth(tester), threadWidth(tester)), (400, 500));

    // 1200 - rail - two dividers leaves 1125: 135 too little.
    await show(tester, width: 1200, thread: true);
    expect((listWidth(tester), threadWidth(tester)), (400, 365));

    // 925: the thread is at its minimum, the list gives the rest.
    await show(tester, width: 1000, thread: true);
    expect((listWidth(tester), threadWidth(tester)), (265, minThreadWidth));
    expect(
      tester.getSize(find.byKey(const ValueKey('main'))).width,
      minConversationWidth,
    );

    await show(tester, thread: true);
    expect((listWidth(tester), threadWidth(tester)), (400, 500));
    expect(await tester.runAsync(stored), saved);
    await close(tester);
  });

  testWidgets('double-clicking a divider resets it', (tester) async {
    await show(tester);
    await drag(tester, listDivider, 120);
    expect(listWidth(tester), _defaultList + 120);

    await tester.tap(listDivider);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(listDivider);
    await tester.pumpAndSettle();
    expect(listWidth(tester), _defaultList);
    await settle(tester);
    expect(await tester.runAsync(stored), const PaneWidths());
    await close(tester);
  });

  testWidgets('arrow keys and the slider actions step a divider', (
    tester,
  ) async {
    await show(tester);
    final semantics = tester.ensureSemantics();
    expect(
      tester.getSemantics(listDivider),
      matchesSemantics(
        label: 'Channel list width',
        value: '360',
        increasedValue: '376',
        decreasedValue: '344',
        isSlider: true,
        isFocusable: true,
        hasIncreaseAction: true,
        hasDecreaseAction: true,
        hasFocusAction: true,
      ),
    );

    final handle = find.descendant(
      of: listDivider,
      matching: find.byType(MouseRegion),
    );
    Focus.of(tester.element(handle.first)).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(listWidth(tester), _defaultList + paneWidthStep);

    tester.semantics.decrease(find.semantics.byLabel('Channel list width'));
    tester.semantics.decrease(find.semantics.byLabel('Channel list width'));
    await tester.pump();
    expect(listWidth(tester), _defaultList - paneWidthStep);
    semantics.dispose();
    await close(tester);
  });

  testWidgets('dragging rebuilds no rows in the panes', (tester) async {
    await show(tester, thread: true);
    final before = Map.of(_builds);
    expect(before, isNotEmpty);

    await drag(tester, listDivider, 90);
    await drag(tester, threadDivider, -90);
    expect(listWidth(tester), _defaultList + 90);
    expect(_builds, before);
    await close(tester);
  });
}
