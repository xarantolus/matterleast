import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/anchored_list.dart';

typedef Item = ({int id, double height});

void main() {
  final controller = AnchoredListController();

  Widget list(
    List<Item> rows, {
    Widget? olderEdge,
    ValueChanged<AnchoredListView>? onView,
  }) => MaterialApp(
    home: Scaffold(
      body: SizedBox(
        height: 600,
        child: AnchoredList<Item>(
          rows: rows,
          keyOf: (r) => r.id,
          controller: controller,
          olderEdge: olderEdge,
          onViewChanged: onView,
          itemBuilder: (_, r) =>
              SizedBox(height: r.height, child: Text('row ${r.id}')),
        ),
      ),
    ),
  );

  // Newest first, heights varied like real messages.
  List<Item> rowsFrom(int newest, int oldest) => [
    for (var id = newest; id >= oldest; id--)
      (id: id, height: 40.0 + (id * 37) % 90),
  ];

  double topOf(WidgetTester tester, int id) =>
      tester.getTopLeft(find.text('row $id')).dy;

  Future<void> scrollUpAndSettle(WidgetTester tester) async {
    await tester.drag(find.byType(Scrollable), const Offset(0, 400));
    await tester.pumpAndSettle();
  }

  testWidgets('opens at the newest row, at the bottom', (tester) async {
    await tester.pumpWidget(list(rowsFrom(100, 1)));
    await tester.pumpAndSettle();
    expect(tester.getBottomLeft(find.text('row 100')).dy, closeTo(600, 0.5));
  });

  testWidgets('rows added on both sides leave a scrolled-up reader in place', (
    tester,
  ) async {
    await tester.pumpWidget(list(rowsFrom(100, 1)));
    await tester.pumpAndSettle();
    await scrollUpAndSettle(tester);
    final visible = [for (var id = 85; id <= 100; id++) id]
        .where((id) => find.text('row $id').evaluate().isNotEmpty)
        .toList();
    expect(visible, isNotEmpty);
    final before = {for (final id in visible) id: topOf(tester, id)};

    await tester.pumpWidget(list([...rowsFrom(103, 101), ...rowsFrom(100, 1)]));
    await tester.pumpAndSettle();
    await tester.pumpWidget(list(rowsFrom(103, -40)));
    await tester.pumpAndSettle();

    for (final id in visible) {
      expect(topOf(tester, id), closeTo(before[id]!, 0.01), reason: 'row $id');
    }
    expect(find.text('row 103'), findsNothing);
  });

  testWidgets('a row growing off screen moves nothing on screen', (
    tester,
  ) async {
    final rows = rowsFrom(100, 1);
    await tester.pumpWidget(list(rows));
    await tester.pumpAndSettle();
    await scrollUpAndSettle(tester);
    final anchor = controller.position!.key as int;
    final before = topOf(tester, anchor);

    await tester.pumpWidget(
      list([
        for (final r in rows)
          r.id == 100 ? (id: 100, height: r.height + 200) : r,
      ]),
    );
    await tester.pumpAndSettle();
    expect(topOf(tester, anchor), closeTo(before, 0.01));
  });

  testWidgets('a new row enters at the bottom when the reader is there', (
    tester,
  ) async {
    await tester.pumpWidget(list(rowsFrom(100, 1)));
    await tester.pumpAndSettle();
    await tester.pumpWidget(list(rowsFrom(101, 1)));
    await tester.pumpAndSettle();
    expect(tester.getBottomLeft(find.text('row 101')).dy, closeTo(600, 0.5));
  });

  testWidgets('jumping to the bottom shows the newest row', (tester) async {
    await tester.pumpWidget(list(rowsFrom(100, 1)));
    await tester.pumpAndSettle();
    await scrollUpAndSettle(tester);
    await scrollUpAndSettle(tester);
    expect(find.text('row 100'), findsNothing);
    controller.jumpToBottom();
    await tester.pumpAndSettle();
    expect(tester.getBottomLeft(find.text('row 100')).dy, closeTo(600, 0.5));
  });

  testWidgets('a row that comes with a jump down from far up shows', (
    tester,
  ) async {
    await tester.pumpWidget(list(rowsFrom(100, 1)));
    await tester.pumpAndSettle();
    for (var i = 0; i < 6; i++) {
      await scrollUpAndSettle(tester);
    }
    expect(find.text('row 100'), findsNothing);
    // Sending: the conversation asks for the bottom as it hears of the new
    // row, and the list gets that row in the next frame.
    controller.jumpToBottom();
    await tester.pumpWidget(list(rowsFrom(101, 1)));
    await tester.pumpAndSettle();
    expect(tester.getBottomLeft(find.text('row 101')).dy, closeTo(600, 0.5));
    await tester.pumpWidget(list(rowsFrom(102, 1)));
    await tester.pumpAndSettle();
    expect(tester.getBottomLeft(find.text('row 102')).dy, closeTo(600, 0.5));
  });

  int topVisible(WidgetTester tester, List<Item> rows) => rows
      .map((r) => r.id)
      .where((id) => find.text('row $id').evaluate().isNotEmpty)
      .where((id) => topOf(tester, id) >= 0)
      .reduce((a, b) => topOf(tester, a) <= topOf(tester, b) ? a : b);

  testWidgets('a new row in the frame after scrolling up moves nothing', (
    tester,
  ) async {
    final rows = rowsFrom(100, 1);
    await tester.pumpWidget(list(rows));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable), const Offset(0, 300));
    // The scroll ends and the list re-anchors in this frame; the new row
    // lands in the next one.
    await tester.pump();
    final reading = topVisible(tester, rows);
    final before = topOf(tester, reading);
    await tester.pumpWidget(list(rowsFrom(101, 1)));
    await tester.pumpAndSettle();
    expect(topOf(tester, reading), closeTo(before, 0.01));
  });

  testWidgets('a visible row that grows pushes the rows below it down', (
    tester,
  ) async {
    final rows = rowsFrom(100, 1);
    await tester.pumpWidget(list(rows));
    await tester.pumpAndSettle();
    await scrollUpAndSettle(tester);
    final reading = topVisible(tester, rows);
    final grows = reading + 1;
    final before = topOf(tester, reading);
    final belowBefore = topOf(tester, grows + 1);
    await tester.pumpWidget(
      list([
        for (final r in rows)
          r.id == grows ? (id: grows, height: r.height + 100) : r,
      ]),
    );
    await tester.pumpAndSettle();
    expect(topOf(tester, reading), closeTo(before, 0.01));
    expect(topOf(tester, grows + 1), closeTo(belowBefore + 100, 0.01));
  });

  testWidgets('at the bottom, the newest row grows upwards', (tester) async {
    final rows = rowsFrom(100, 1);
    await tester.pumpWidget(list(rows));
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      list([
        for (final r in rows)
          r.id == 100 ? (id: 100, height: r.height + 100) : r,
      ]),
    );
    await tester.pumpAndSettle();
    expect(tester.getBottomLeft(find.text('row 100')).dy, closeTo(600, 0.5));
  });

  testWidgets('scrolling up stops with the oldest row at the top', (
    tester,
  ) async {
    await tester.pumpWidget(list(rowsFrom(30, 1)));
    await tester.pumpAndSettle();
    for (var i = 0; i < 8; i++) {
      await tester.fling(find.byType(Scrollable), const Offset(0, 600), 3000);
      await tester.pumpAndSettle();
    }
    expect(topOf(tester, 1), closeTo(0, 0.5));
  });

  Future<void> toTheTop(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.fling(find.byType(Scrollable), const Offset(0, 600), 3000);
      await tester.pumpAndSettle();
    }
  }

  List<int> onScreen(WidgetTester tester, Iterable<int> ids) => [
    for (final id in ids)
      if (find.text('row $id').evaluate().isNotEmpty &&
          tester.getBottomLeft(find.text('row $id')).dy > 0 &&
          topOf(tester, id) < 600)
        id,
  ];

  testWidgets('older rows arriving at the top leave the reader in place', (
    tester,
  ) async {
    final views = <AnchoredListView>[];
    await tester.pumpWidget(list(rowsFrom(30, 1), onView: views.add));
    await tester.pumpAndSettle();
    await toTheTop(tester);
    expect(topOf(tester, 1), closeTo(0, 0.5));
    final shown = onScreen(tester, [for (var id = 1; id <= 30; id++) id]);
    final before = {for (final id in shown) id: topOf(tester, id)};

    await tester.pumpWidget(list(rowsFrom(30, -30), onView: views.add));
    await tester.pumpAndSettle();

    for (final id in shown) {
      expect(topOf(tester, id), closeTo(before[id]!, 0.01), reason: 'row $id');
    }
    expect(onScreen(tester, [for (var id = -30; id <= 0; id++) id]), isEmpty);
    expect(views.last.nearOlderEnd, isFalse);
  });

  testWidgets('a row that moves above older rows arriving moves nothing', (
    tester,
  ) async {
    // Like a day separator, the oldest row stays the oldest.
    const day = (id: 1000, height: 30.0);
    await tester.pumpWidget(list([...rowsFrom(30, 1), day]));
    await tester.pumpAndSettle();
    await toTheTop(tester);
    final shown = onScreen(tester, [for (var id = 1; id <= 30; id++) id]);
    final before = {for (final id in shown) id: topOf(tester, id)};

    await tester.pumpWidget(list([...rowsFrom(30, -30), day]));
    await tester.pumpAndSettle();

    for (final id in shown) {
      expect(topOf(tester, id), closeTo(before[id]!, 0.01), reason: 'row $id');
    }
  });

  testWidgets('the oldest row losing its header keeps the rows below still', (
    tester,
  ) async {
    final rows = rowsFrom(30, 1);
    await tester.pumpWidget(list(rows));
    await tester.pumpAndSettle();
    await toTheTop(tester);
    final shown = onScreen(tester, [for (var id = 2; id <= 30; id++) id]);
    final before = {for (final id in shown) id: topOf(tester, id)};
    final bottomOfOldest = tester.getBottomLeft(find.text('row 1')).dy;

    await tester.pumpWidget(
      list([
        for (final r in rows) r.id == 1 ? (id: 1, height: r.height - 30) : r,
        ...rowsFrom(0, -30),
      ]),
    );
    await tester.pumpAndSettle();

    for (final id in shown) {
      expect(topOf(tester, id), closeTo(before[id]!, 0.01), reason: 'row $id');
    }
    expect(
      tester.getBottomLeft(find.text('row 1')).dy,
      closeTo(bottomOfOldest, 0.01),
    );
  });

  testWidgets('older rows arriving during a fling leave the fling as it was', (
    tester,
  ) async {
    Future<double> flingDown({required bool olderArrive}) async {
      await tester.pumpWidget(list(rowsFrom(30, 1)));
      await tester.pumpAndSettle();
      await toTheTop(tester);
      await tester.fling(find.byType(Scrollable), const Offset(0, -150), 800);
      await tester.pump(const Duration(milliseconds: 16));
      if (olderArrive) await tester.pumpWidget(list(rowsFrom(30, -30)));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      final top = topOf(tester, 8);
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      return top;
    }

    final undisturbed = await flingDown(olderArrive: false);
    expect(await flingDown(olderArrive: true), closeTo(undisturbed, 1));
  });

  testWidgets('a row at the top edge growing mid-drag moves nothing', (
    tester,
  ) async {
    // A link preview arriving late for a message the reader just scrolled
    // past, while they are still scrolling towards the newest one.
    final rows = rowsFrom(100, 1);
    await tester.pumpWidget(list(rows));
    await tester.pumpAndSettle();
    for (var i = 0; i < 3; i++) {
      await scrollUpAndSettle(tester);
    }
    final drag = await tester.startGesture(const Offset(400, 300));
    for (var i = 0; i < 10; i++) {
      await drag.moveBy(const Offset(0, -40));
      await tester.pump();
    }
    final reading = topVisible(tester, rows);
    // The row the drag is taking off the top of the screen.
    final above = [
      for (var id = reading - 1; id > reading - 5; id--)
        if (find.text('row $id').evaluate().isNotEmpty && topOf(tester, id) < 0)
          id,
    ].firstOrNull;
    expect(above, isNotNull, reason: 'a row cut by the top edge');
    final before = topOf(tester, reading);
    await tester.pumpWidget(
      list([
        for (final r in rows)
          r.id == above ? (id: r.id, height: r.height + 150) : r,
      ]),
    );
    await tester.pump();
    expect(topOf(tester, reading), closeTo(before, 0.01));
    await drag.up();
    await tester.pumpAndSettle();
  });

  testWidgets(
    'a row above the screen growing under a held drag moves nothing',
    (tester) async {
      // The reader drags towards the newest message and holds still; a
      // message they dragged off the top gets its link preview.
      final rows = rowsFrom(100, 1);
      await tester.pumpWidget(list(rows));
      await tester.pumpAndSettle();
      for (var i = 0; i < 4; i++) {
        await scrollUpAndSettle(tester);
      }
      final drag = await tester.startGesture(const Offset(400, 500));
      for (var i = 0; i < 12; i++) {
        await drag.moveBy(const Offset(0, -40));
        await tester.pump();
      }
      final reading = topVisible(tester, rows);
      // Rows in the cache area above the screen count as offstage.
      double? bottomOf(Item r) {
        final text = find.text('row ${r.id}', skipOffstage: false);
        if (text.evaluate().isEmpty) return null;
        return tester.getTopLeft(text).dy + r.height;
      }

      final above = rows
          .where((r) => r.id < reading && (bottomOf(r) ?? 1) < 0)
          .map((r) => r.id)
          .firstOrNull;
      expect(above, isNotNull, reason: 'a built row wholly above the screen');
      final before = topOf(tester, reading);
      await tester.pumpWidget(
        list([
          for (final r in rows)
            r.id == above ? (id: r.id, height: r.height + 280) : r,
        ]),
      );
      await tester.pump();
      expect(topOf(tester, reading), closeTo(before, 0.01));
      await drag.up();
      await tester.pumpAndSettle();
    },
  );

  testWidgets('a row at the top edge growing mid-fling leaves the fling', (
    tester,
  ) async {
    final rows = rowsFrom(100, 1);
    Future<double> fling({required bool grow}) async {
      await tester.pumpWidget(list(rows));
      await tester.pumpAndSettle();
      for (var i = 0; i < 3; i++) {
        await scrollUpAndSettle(tester);
      }
      final reading = topVisible(tester, rows);
      await tester.fling(find.byType(Scrollable), const Offset(0, -150), 800);
      await tester.pump(const Duration(milliseconds: 16));
      if (grow) {
        final cut = [
          for (var id = reading + 5; id > reading - 10; id--)
            if (find.text('row $id').evaluate().isNotEmpty &&
                topOf(tester, id) < 0)
              id,
        ].first;
        await tester.pumpWidget(
          list([
            for (final r in rows)
              r.id == cut ? (id: r.id, height: r.height + 150) : r,
          ]),
        );
      }
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      final top = topOf(tester, reading + 6);
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      return top;
    }

    final undisturbed = await fling(grow: false);
    expect(await fling(grow: true), closeTo(undisturbed, 1));
  });

  testWidgets(
    'a short list stays on screen when pulled past either end',
    (tester) async {
      await tester.pumpWidget(list(rowsFrom(3, 1)));
      await tester.pumpAndSettle();
      final rest = [for (var id = 1; id <= 3; id++) topOf(tester, id)];
      void expectInPlace() =>
          expect([for (var id = 1; id <= 3; id++) topOf(tester, id)], rest);

      for (final dy in [300.0, -300.0, 900.0, -900.0]) {
        final gesture = await tester.startGesture(const Offset(400, 300));
        await gesture.moveBy(Offset(0, dy / 2));
        await tester.pump();
        expectInPlace();
        await gesture.moveBy(Offset(0, dy / 2));
        await tester.pump();
        expectInPlace();
        await gesture.up();
        await tester.pump(const Duration(milliseconds: 100));
        expectInPlace();
        await tester.pumpAndSettle();
        expectInPlace();
        await tester.fling(find.byType(Scrollable), Offset(0, dy), 3000);
        await tester.pump(const Duration(milliseconds: 100));
        expectInPlace();
        await tester.pumpAndSettle();
        expectInPlace();
      }
    },
    variant: TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.linux,
    }),
  );

  testWidgets('a scroll up from the bottom stays where it stopped', (
    tester,
  ) async {
    final rows = rowsFrom(100, 1);
    await tester.pumpWidget(list(rows));
    await tester.pumpAndSettle();
    final drag = await tester.startGesture(const Offset(400, 300));
    for (var i = 0; i < 10; i++) {
      await drag.moveBy(const Offset(0, 40));
      await tester.pump();
    }
    final reading = topVisible(tester, rows);
    final before = topOf(tester, reading);
    await drag.up();
    await tester.pumpAndSettle();
    expect(topOf(tester, reading), closeTo(before, 0.01));
  });

  for (final expanding in [100, 99]) {
    testWidgets('at the bottom, row $expanding opened by the reader keeps '
        'its top and grows downwards', (tester) async {
      final rows = rowsFrom(100, 1);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: AnchoredList<Item>(
                rows: rows,
                keyOf: (r) => r.id,
                controller: controller,
                itemBuilder: (_, r) =>
                    _Opens(label: 'row ${r.id}', height: r.height),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(controller.pinned, isTrue);
      final before = topOf(tester, expanding);

      await tester.tap(find.text('row $expanding'));
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(topOf(tester, expanding), closeTo(before, 0.5));
      }
      await tester.pumpAndSettle();
      expect(topOf(tester, expanding), closeTo(before, 0.5));
    });
  }
}

/// A row that grows by 400 px over 200 ms when tapped, like "Show more".
class _Opens extends StatefulWidget {
  const _Opens({required this.label, required this.height});

  final String label;
  final double height;

  @override
  State<_Opens> createState() => _OpensState();
}

class _OpensState extends State<_Opens> with SingleTickerProviderStateMixin {
  late final _open = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  )..addListener(() => setState(() {}));

  @override
  void dispose() {
    _open.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      AnchoredList.keepTopOf(context);
      _open.forward();
    },
    child: SizedBox(
      height: widget.height + 400 * _open.value,
      child: Align(alignment: Alignment.topLeft, child: Text(widget.label)),
    ),
  );
}
