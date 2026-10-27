import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/app_sheet.dart';

void main() {
  final desktopAndPhone = TargetPlatformVariant({
    TargetPlatform.linux,
    TargetPlatform.android,
  });
  bool desktop() => defaultTargetPlatform == TargetPlatform.linux;

  Future<Future<String?>> open(WidgetTester tester, {Rect? anchor}) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox.expand())),
    );
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

  test('a popup with no room below opens above, inside the window', () {
    const layout = AnchoredLayout(Rect.fromLTWH(1500, 900, 40, 40));
    final at = layout.getPositionForChild(
      const Size(1600, 1000),
      const Size(360, 420),
    );
    expect(at, const Offset(1600 - 360 - 8, 900 - 420));
  });
}
