import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/desktop/right_drag_scroll.dart';

import '../support/pump_app.dart';

void main() {
  final linux = TargetPlatformVariant.only(TargetPlatform.linux);
  late ScrollController scroll;
  var menus = 0;
  var longPresses = 0;

  setUp(() {
    menus = 0;
    longPresses = 0;
  });

  Future<void> show(WidgetTester tester) async {
    scroll = ScrollController();
    addTearDown(scroll.dispose);
    await pumpApp(
      tester,
      RightDragScroll(
        child: ListView.builder(
          controller: scroll,
          itemCount: 200,
          itemBuilder: (_, i) => GestureDetector(
            onSecondaryTapUp: (_) => menus++,
            onLongPress: () => longPresses++,
            child: SizedBox(height: 40, child: Text('row $i')),
          ),
        ),
      ),
    );
  }

  Future<TestGesture> press(WidgetTester tester) async {
    final mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    await mouse.down(const Offset(200, 300));
    return mouse;
  }

  testWidgets('a right drag scrolls the list along with the pointer', (
    tester,
  ) async {
    await show(tester);
    final mouse = await press(tester);
    await mouse.moveBy(const Offset(0, -100));
    await tester.pump(const Duration(milliseconds: 50));
    final start = scroll.offset;
    await mouse.moveBy(const Offset(0, -50));
    await tester.pump(const Duration(milliseconds: 50));
    expect(scroll.offset - start, 50);
    await mouse.up();
    await tester.pumpAndSettle();
    expect(menus, 0);
  }, variant: linux);

  testWidgets('releasing while moving keeps it scrolling', (tester) async {
    await show(tester);
    final mouse = await press(tester);
    var at = Duration.zero;
    for (var i = 0; i < 8; i++) {
      at += const Duration(milliseconds: 16);
      await mouse.moveBy(const Offset(0, -30), timeStamp: at);
      await tester.pump(const Duration(milliseconds: 16));
    }
    await mouse.up(timeStamp: at);
    final atRelease = scroll.offset;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(scroll.offset, greaterThan(atRelease + 20));
    await tester.pumpAndSettle();
  }, variant: linux);

  testWidgets('a right click without movement opens the menu', (tester) async {
    await show(tester);
    final mouse = await press(tester);
    await mouse.up();
    await tester.pump();
    expect(menus, 1);
    expect(scroll.offset, 0);
  }, variant: linux);

  testWidgets('a small move and a pause starts neither scroll nor long press', (
    tester,
  ) async {
    await show(tester);
    final mouse = await press(tester);
    await mouse.moveBy(const Offset(0, -5));
    await tester.pump(const Duration(seconds: 1));
    expect(longPresses, 0);
    expect(menus, 0);
    expect(scroll.offset, 0);
    await mouse.up();
  }, variant: linux);

  testWidgets('a left drag is not taken', (tester) async {
    await show(tester);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.down(const Offset(200, 300));
    await mouse.moveBy(const Offset(0, -100));
    await tester.pump();
    expect(scroll.offset, 0);
    await mouse.up();
  }, variant: linux);
}
