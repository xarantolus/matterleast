import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/desktop/autoscroll.dart';

void main() {
  group('autoscrollVelocity', () {
    test('stays still inside the dead zone', () {
      expect(autoscrollVelocity(Offset.zero), Offset.zero);
      expect(
        autoscrollVelocity(const Offset(8, -autoscrollDeadZone)),
        Offset.zero,
      );
    });

    test('grows with the distance and follows its direction', () {
      final near = autoscrollVelocity(const Offset(0, 40)).dy;
      final far = autoscrollVelocity(const Offset(0, 120)).dy;
      expect(near, greaterThan(0));
      expect(far, greaterThan(near));
      expect(autoscrollVelocity(const Offset(0, -40)).dy, -near);
    });

    test('has a top speed', () {
      expect(
        autoscrollVelocity(const Offset(0, 5000)),
        autoscrollVelocity(const Offset(0, 9000)),
      );
    });
  });

  group('MiddleAutoscroll', () {
    late ScrollController scroll;
    const anchor = ValueKey('autoscroll-anchor');

    Future<void> show(WidgetTester tester) async {
      scroll = ScrollController();
      addTearDown(scroll.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: MiddleAutoscroll(
            child: ListView.builder(
              controller: scroll,
              itemCount: 200,
              itemBuilder: (_, i) =>
                  SizedBox(height: 40, child: Text('row $i')),
            ),
          ),
        ),
      );
    }

    Future<TestGesture> pressMiddle(WidgetTester tester, Offset at) async {
      final mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
        buttons: kMiddleMouseButton,
      );
      await mouse.down(at);
      return mouse;
    }

    testWidgets('holding the middle button below the press scrolls down, '
        'releasing stops', (tester) async {
      await show(tester);
      final at = tester.getCenter(find.byType(ListView));
      final mouse = await pressMiddle(tester, at);
      await mouse.moveTo(at + const Offset(0, 100));
      await tester.pump();
      expect(find.byKey(anchor), findsOneWidget);
      final offsets = <double>[];
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        offsets.add(scroll.offset);
      }
      expect(offsets.first, greaterThan(0));
      expect(offsets.last, greaterThan(offsets.first));

      await mouse.up();
      await tester.pump();
      final stopped = scroll.offset;
      await tester.pump(const Duration(milliseconds: 200));
      expect(scroll.offset, stopped);
      expect(find.byKey(anchor), findsNothing);
    });

    testWidgets('a click keeps it going until Esc', (tester) async {
      await show(tester);
      final at = tester.getCenter(find.byType(ListView));
      final mouse = await pressMiddle(tester, at);
      await mouse.up();
      await tester.pump();
      expect(find.byKey(anchor), findsOneWidget);

      await mouse.moveTo(at + const Offset(0, 100));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final moving = scroll.offset;
      expect(moving, greaterThan(0));
      await tester.pump(const Duration(milliseconds: 100));
      expect(scroll.offset, greaterThan(moving));

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      final stopped = scroll.offset;
      await tester.pump(const Duration(milliseconds: 200));
      expect(scroll.offset, stopped);
      expect(find.byKey(anchor), findsNothing);
    });

    testWidgets('a click anywhere stops it', (tester) async {
      await show(tester);
      final at = tester.getCenter(find.byType(ListView));
      final mouse = await pressMiddle(tester, at);
      await mouse.up();
      await tester.pump();
      await tester.tapAt(at + const Offset(10, 10));
      await tester.pump();
      expect(find.byKey(anchor), findsNothing);
    });

    testWidgets('a middle click on a link opens it and does not start', (
      tester,
    ) async {
      var opened = 0;
      scroll = ScrollController();
      addTearDown(scroll.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: MiddleAutoscroll(
            child: Center(
              child: Text.rich(
                TextSpan(
                  text: 'a link',
                  recognizer: TapGestureRecognizer()
                    ..onTertiaryTapUp = (_) => opened++,
                ),
              ),
            ),
          ),
        ),
      );
      final mouse = await pressMiddle(
        tester,
        tester.getCenter(find.text('a link')),
      );
      await mouse.up();
      await tester.pump();
      expect(opened, 1);
      expect(find.byKey(anchor), findsNothing);
    });
  });
}
