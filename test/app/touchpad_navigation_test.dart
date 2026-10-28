import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/touchpad_navigation.dart';
import 'package:matterleast/domain/touchpad_swipe.dart';

void main() {
  final steps = <bool>[];
  const at = Offset(300, 300);
  final linuxOnly = TargetPlatformVariant.only(TargetPlatform.linux);

  setUp(steps.clear);

  Future<void> show(WidgetTester tester, Widget content) => tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: TouchpadNavigation(
          onStep: ({required forward}) => steps.add(forward),
          child: content,
        ),
      ),
    ),
  );

  Future<void> swipe(WidgetTester tester, double dx) async {
    final pad = TestPointer(1, PointerDeviceKind.trackpad);
    await tester.sendEventToBinding(pad.panZoomStart(at));
    for (var i = 1; i <= 10; i++) {
      await tester.sendEventToBinding(
        pad.panZoomUpdate(at, pan: Offset(dx * i / 10, 0)),
      );
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.sendEventToBinding(pad.panZoomEnd());
    await tester.pump();
  }

  final plain = ListView(
    children: [for (var i = 0; i < 50; i++) Text('row $i')],
  );

  testWidgets('a swipe right past the distance goes back', (tester) async {
    await show(tester, plain);
    await swipe(tester, swipeDistance + 40);
    expect(steps, [false]);
  }, variant: linuxOnly);

  testWidgets('a swipe left past the distance goes forward', (tester) async {
    await show(tester, plain);
    await swipe(tester, -swipeDistance - 40);
    expect(steps, [true]);
  }, variant: linuxOnly);

  testWidgets('a short swipe does nothing', (tester) async {
    await show(tester, plain);
    await swipe(tester, -swipeDistance / 2);
    expect(steps, isEmpty);
  }, variant: linuxOnly);

  testWidgets('shows an arrow while swiping, gone afterwards', (tester) async {
    await show(tester, plain);
    final pad = TestPointer(1, PointerDeviceKind.trackpad);
    await tester.sendEventToBinding(pad.panZoomStart(at));
    await tester.sendEventToBinding(
      pad.panZoomUpdate(at, pan: const Offset(60, 0)),
    );
    await tester.sendEventToBinding(
      pad.panZoomUpdate(at, pan: const Offset(90, 0)),
    );
    await tester.pump();
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    await tester.sendEventToBinding(pad.panZoomEnd());
    await tester.pump();
    expect(find.byIcon(Icons.arrow_back), findsNothing);
  }, variant: linuxOnly);

  testWidgets('a horizontal scrollable under the pointer keeps the swipe', (
    tester,
  ) async {
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    await show(
      tester,
      SingleChildScrollView(
        controller: scroll,
        scrollDirection: Axis.horizontal,
        child: const SizedBox(width: 3000, height: 600),
      ),
    );
    await swipe(tester, -swipeDistance - 40);
    expect(steps, isEmpty);
    expect(scroll.offset, greaterThan(0));
  }, variant: linuxOnly);
}
