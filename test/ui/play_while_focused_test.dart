import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/desktop/desktop_shell.dart';
import 'package:matterleast/ui/play_while_focused.dart';

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

Future<void> pumpGif(WidgetTester tester, {required bool desktop}) async {
  _frame = -1;
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox.square(
          dimension: 50,
          child: PlayWhileFocused(
            desktop: desktop,
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
    // Decoding the next frame takes real time.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  tearDown(() {
    DesktopShell.windowFocused = true;
    // Each test decodes the picture afresh, not as the last one left it.
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
  });

  testWidgets('on desktop the picture plays while the window has the focus', (
    tester,
  ) async {
    await pumpGif(tester, desktop: true);
    await wait(tester);

    expect(_frame, greaterThan(0));
  });

  testWidgets('it stays still while another window has the focus', (
    tester,
  ) async {
    DesktopShell.windowFocused = false;
    await pumpGif(tester, desktop: true);
    await wait(tester);
    expect(_frame, 0);

    DesktopShell.windowFocused = true;
    await wait(tester);
    expect(_frame, greaterThan(0));

    DesktopShell.windowFocused = false;
    await tester.pump();
    final stopped = _frame;
    await wait(tester);
    expect(_frame, stopped);
  });

  testWidgets('a phone always plays it', (tester) async {
    DesktopShell.windowFocused = false;
    await pumpGif(tester, desktop: false);
    await wait(tester);

    expect(_frame, greaterThan(0));
  });
}
