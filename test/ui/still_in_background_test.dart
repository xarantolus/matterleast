import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/desktop/desktop_shell.dart';
import 'package:matterleast/ui/still_in_background.dart';

import '../support/animated_gif.dart';

/// The number of the frame the picture shows, once it has loaded.
var _frame = -1;

Future<void> pumpGif(WidgetTester tester) async {
  _frame = -1;
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox.square(
          dimension: 50,
          child: StillInBackground(
            child: Image.memory(
              animatedGif,
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
  final desktop = TargetPlatformVariant.only(TargetPlatform.linux);

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
    await pumpGif(tester);
    await wait(tester);

    expect(_frame, greaterThan(0));
  }, variant: desktop);

  testWidgets('it stays still while another window has the focus', (
    tester,
  ) async {
    DesktopShell.windowFocused = false;
    await pumpGif(tester);
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
  }, variant: desktop);

  testWidgets('a phone always plays it', (tester) async {
    DesktopShell.windowFocused = false;
    await pumpGif(tester);
    await wait(tester);

    expect(_frame, greaterThan(0));
  });
}
