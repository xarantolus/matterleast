import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/app_sheet.dart';

import '../support/pump_app.dart';

void main() {
  final desktopAndPhone = TargetPlatformVariant({
    TargetPlatform.linux,
    TargetPlatform.android,
  });
  bool desktop() => defaultTargetPlatform == TargetPlatform.linux;

  Future<Future<String?>> open(WidgetTester tester, {Rect? anchor}) async {
    await pumpApp(tester, Scaffold(body: SizedBox.expand()));
    final context = tester.element(find.byType(SizedBox));
    final picked = showAppSheet<String>(
      context: context,
      anchor: anchor,
      builder: (sheet) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Mute'),
            onTap: () => Navigator.pop(sheet, 'mute'),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    return picked;
  }

  testWidgets('a sheet on a phone and a dialog on desktop, with the pick', (
    tester,
  ) async {
    final picked = await open(tester);
    expect(find.byType(Dialog), desktop() ? findsOneWidget : findsNothing);
    expect(find.byType(BottomSheet), desktop() ? findsNothing : findsOneWidget);
    await tester.tap(find.text('Mute'));
    await tester.pumpAndSettle();
    expect(await picked, 'mute');
  }, variant: desktopAndPhone);

  testWidgets('on desktop it opens next to the button that opened it', (
    tester,
  ) async {
    final picked = await open(
      tester,
      anchor: const Rect.fromLTWH(200, 300, 40, 40),
    );
    expect(find.byType(BottomSheet), findsNothing);
    final tile = tester.getRect(find.byType(ListTile));
    expect(tile.left, closeTo(200, 1));
    expect(tile.top, greaterThanOrEqualTo(340));
    expect(tile.top, lessThan(400));
    await tester.tap(find.text('Mute'));
    await tester.pumpAndSettle();
    expect(await picked, 'mute');
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('on desktop Esc closes it without a pick', (tester) async {
    final picked = await open(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Mute'), findsNothing);
    expect(await picked, isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('on desktop a sheet without an anchor opens next to its opener', (
    tester,
  ) async {
    late Future<String?> picked;
    await pumpApp(
      tester,
      Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 200, top: 100),
            child: Builder(
              builder: (button) => TextButton(
                onPressed: () => picked = showAppSheet<String>(
                  context: button,
                  builder: (sheet) => ListTile(
                    title: const Text('Mute'),
                    onTap: () => Navigator.pop(sheet, 'mute'),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    final tile = tester.getRect(find.byType(ListTile));
    expect(tile.left, closeTo(200, 1));
    expect(
      tile.top,
      greaterThanOrEqualTo(tester.getRect(find.byType(TextButton)).bottom),
    );
    await tester.tap(find.text('Mute'));
    await tester.pumpAndSettle();
    expect(await picked, 'mute');
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  test('an opener that is a good part of the window gives no anchor', () {
    const window = Size(1000, 800);
    expect(openerAnchor(null, window), isNull);
    expect(openerAnchor(const Rect.fromLTWH(0, 0, 1000, 800), window), isNull);
    const button = Rect.fromLTWH(10, 10, 40, 40);
    expect(openerAnchor(button, window), button);
  });

  test('a popup with no room below opens above, inside the window', () {
    const layout = AnchoredLayout(Rect.fromLTWH(1500, 900, 40, 40));
    final at = layout.getPositionForChild(
      const Size(1600, 1000),
      const Size(360, 420),
    );
    expect(at, const Offset(1600 - 360 - 8, 900 - 420));
  });
}
