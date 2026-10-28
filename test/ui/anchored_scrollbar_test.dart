import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/anchored_list.dart';
import 'package:matterleast/ui/anchored_scrollbar.dart';

void main() {
  group('thumb geometry', () {
    const track = 500.0;

    test('size follows the share of rows shown', () {
      const span = RowSpan(start: 0, extent: 10, total: 50);
      final thumb = thumbGeometry(span, track, minThumb: 36);
      expect(thumb.height, 100);
      expect(thumb.top, 0);
    });

    test('a huge list keeps the thumb at its minimum size', () {
      const span = RowSpan(start: 0, extent: 10, total: 10000);
      expect(thumbGeometry(span, track, minThumb: 36).height, 36);
    });

    test('the thumb reaches both ends of the track with the span', () {
      const end = RowSpan(start: 40, extent: 10, total: 50);
      final thumb = thumbGeometry(end, track, minThumb: 36);
      expect(thumb.top + thumb.height, closeTo(track, 0.001));
      const middle = RowSpan(start: 20, extent: 10, total: 50);
      expect(
        thumbGeometry(middle, track, minThumb: 36).top,
        closeTo(200, 0.01),
      );
    });

    test('a part of a row moves the thumb a part of a row', () {
      const a = RowSpan(start: 20, extent: 10, total: 50);
      const b = RowSpan(start: 20.5, extent: 10, total: 50);
      final delta =
          thumbGeometry(b, track, minThumb: 36).top -
          thumbGeometry(a, track, minThumb: 36).top;
      expect(delta, closeTo(5, 0.001));
    });

    test('everything on screen means nothing to draw', () {
      expect(const RowSpan(start: 0, extent: 5, total: 5).fits, isTrue);
      expect(const RowSpan(start: 0, extent: 4.5, total: 5).fits, isFalse);
    });

    test('a held thumb maps back to the row it shows', () {
      const span = RowSpan(start: 0, extent: 10, total: 50);
      int row(double top) => rowAtThumbTop(span, track, top, minThumb: 36);
      expect(row(0), 0);
      expect(row(200), 20);
      expect(row(400), 40);
      expect(row(900), 40);
      expect(row(-30), 0);
    });
  });

  group('on desktop', () {
    final controller = AnchoredListController();

    Widget list(List<int> rows, {double Function(int row)? heightOf}) =>
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: AnchoredList<int>(
                rows: rows,
                keyOf: (r) => r,
                controller: controller,
                itemBuilder: (_, r) => SizedBox(
                  height: heightOf?.call(r) ?? 60,
                  child: Text('row $r'),
                ),
              ),
            ),
          ),
        );

    // Newest first.
    List<int> rowsFrom(int count) => [for (var i = count; i >= 1; i--) i];

    Finder thumb() => find.descendant(
      of: find.byType(AnchoredScrollbar),
      matching: find.byType(DecoratedBox),
    );

    final desktop = TargetPlatformVariant.only(TargetPlatform.linux);

    testWidgets('dragging the thumb to the middle shows the middle rows', (
      tester,
    ) async {
      await tester.pumpWidget(list(rowsFrom(100)));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Scrollable), const Offset(0, 100));
      await tester.pump();

      final track = tester.getRect(find.byType(AnchoredScrollbar));
      final grab = tester.getRect(thumb()).center;
      final gesture = await tester.startGesture(grab);
      await gesture.moveTo(Offset(grab.dx, track.center.dy));
      await tester.pump();
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      final shown = [
        for (var i = 1; i <= 100; i++)
          if (find.text('row $i').evaluate().isNotEmpty &&
              tester.getTopLeft(find.text('row $i')).dy >= 0 &&
              tester.getBottomLeft(find.text('row $i')).dy <= 600)
            i,
      ];
      expect(shown, isNotEmpty);
      expect(shown.first, inInclusiveRange(35, 65));
    }, variant: desktop);

    testWidgets('rows measuring taller leave the thumb near where it was', (
      tester,
    ) async {
      await tester.pumpWidget(list(rowsFrom(100)));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Scrollable), const Offset(0, 100));
      await tester.pump();
      final before = tester.getRect(thumb());

      await tester.pumpWidget(
        list(rowsFrom(100), heightOf: (r) => r.isEven ? 140 : 60),
      );
      await tester.pump();
      await tester.pump();
      final after = tester.getRect(thumb());
      // Fewer rows fit now, so the thumb is no taller; it stays near.
      expect(after.height, lessThanOrEqualTo(before.height));
      expect((after.top - before.top).abs(), lessThan(16));
    }, variant: desktop);
  });
}
