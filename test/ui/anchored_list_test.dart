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
}
