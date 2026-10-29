import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/desktop/smooth_wheel.dart';

void main() {
  Future<ScrollController> showList(WidgetTester tester) async {
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ListView.builder(
          controller: scroll,
          itemCount: 200,
          itemBuilder: (_, i) => SizedBox(height: 40, child: Text('row $i')),
        ),
      ),
    );
    return scroll;
  }

  PointerScrollEvent tick(Offset at, double dy) => PointerScrollEvent(
    kind: PointerDeviceKind.mouse,
    position: at,
    scrollDelta: Offset(0, dy),
  );

  testWidgets('a wheel tick eases to its distance within about 120 ms', (
    tester,
  ) async {
    final scroll = await showList(tester);
    final wheel = WheelSmoother(tester.binding.handlePointerEvent);
    addTearDown(wheel.dispose);
    final at = tester.getCenter(find.byType(ListView));

    expect(wheel.take(tick(at, 120)), isTrue);
    final offsets = <double>[];
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      offsets.add(scroll.offset);
    }

    // Not there in one jump, moving every frame, slower towards the end.
    expect(offsets[1], greaterThan(0));
    expect(offsets[1], lessThan(120));
    for (var i = 2; i < 6; i++) {
      expect(offsets[i], greaterThan(offsets[i - 1]));
    }
    expect(offsets[2] - offsets[1], greaterThan(offsets[4] - offsets[3]));
    // The first frame only starts the clock; then 8 frames of 16 ms.
    expect(offsets[9], closeTo(120, 0.01));
    expect(offsets.last, closeTo(120, 0.01));
  });

  testWidgets('ticks in a row add up', (tester) async {
    final scroll = await showList(tester);
    final wheel = WheelSmoother(tester.binding.handlePointerEvent);
    addTearDown(wheel.dispose);
    final at = tester.getCenter(find.byType(ListView));

    wheel.take(tick(at, 100));
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 16));
    wheel.take(tick(at, 100));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 16));

    expect(scroll.offset, closeTo(200, 0.01));
  });

  testWidgets('a trackpad and Ctrl+wheel pass through as they are', (
    tester,
  ) async {
    await showList(tester);
    final wheel = WheelSmoother(tester.binding.handlePointerEvent);
    addTearDown(wheel.dispose);
    const trackpad = PointerScrollEvent(
      kind: PointerDeviceKind.trackpad,
      scrollDelta: Offset(0, 10),
    );
    expect(wheel.take(trackpad), isFalse);
    expect(wheel.take(const PointerDownEvent()), isFalse);
  });

  test('each frame covers a share of what is left, the last one the rest', () {
    const left = Offset(0, 100);
    expect(wheelStep(left, Duration.zero), Offset.zero);
    final first = wheelStep(left, const Duration(milliseconds: 16)).dy;
    expect(first, closeTo(51.7, 0.1));
    expect(
      wheelStep(const Offset(0, 0.6), const Duration(milliseconds: 16)),
      const Offset(0, 0.6),
    );
  });
}
