import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/play_on_hover.dart';

/// Two frames of one pixel, 100 ms each, looping forever.
final _gif = Uint8List.fromList([
  71, 73, 70, 56, 57, 97, 1, 0, 1, 0, 128, 0, 0, 255, 0, 0, 0, 0, 255, //
  33, 255, 11, 78, 69, 84, 83, 67, 65, 80, 69, 50, 46, 48, 3, 1, 0, 0, 0, //
  33, 249, 4, 0, 10, 0, 0, 0, 44, 0, 0, 0, 0, 1, 0, 1, 0, 0, 2, 2, 68, 1, 0, //
  33, 249, 4, 0, 10, 0, 0, 0, 44, 0, 0, 0, 0, 1, 0, 1, 0, 0, 2, 2, 68, 1, 0, //
  59,
]);

/// The number of the frame the picture shows, once it has loaded.
var _frame = -1;

Future<void> pumpGif(WidgetTester tester, {required bool hoverOnly}) async {
  _frame = -1;
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox.square(
          dimension: 50,
          child: PlayOnHover(
            hoverOnly: hoverOnly,
            child: Image.memory(
              _gif,
              width: 50,
              height: 50,
              frameBuilder: (context, child, frame, synchronous) {
                _frame = frame ?? -1;
                return child;
              },
            ),
          ),
        ),
      ),
    ),
  );
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 200)),
  );
  await tester.pump();
}

Future<void> wait(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('a picture at rest shows its first frame and stays', (
    tester,
  ) async {
    await pumpGif(tester, hoverOnly: true);
    await wait(tester);

    expect(_frame, 0);
  });

  testWidgets('the picture plays while the pointer is over it', (tester) async {
    await pumpGif(tester, hoverOnly: true);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(25, 25));
    await wait(tester);

    expect(_frame, greaterThan(0));

    await mouse.moveTo(const Offset(300, 300));
    await tester.pump();
    final stopped = _frame;
    await wait(tester);

    expect(_frame, stopped);
  });

  testWidgets('without hover-only the picture always plays', (tester) async {
    await pumpGif(tester, hoverOnly: false);
    await wait(tester);

    expect(_frame, greaterThan(0));
  });
}
