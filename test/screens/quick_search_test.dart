import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/keyboard_shortcuts.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/screens/root/root_shortcuts.dart';
import 'package:matterleast/screens/search/quick_search.dart';
import 'package:matterleast/screens/search/search_providers.dart';

import '../support/pump_app.dart';
import '../support/servers.dart';

const _url = 'https://chat.example.test';

SwitchItem _channel(String id, String title) => SwitchItem(
  serverUrl: _url,
  kind: SwitchKind.channel,
  id: id,
  title: title,
  teamId: 'team1',
);

void main() {
  final server = testServerEntry(_url, name: 'Test');

  late List<String> opened;

  Future<void> show(WidgetTester tester, List<SwitchItem> items) async {
    opened = [];
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await pumpApp(
      tester,
      QuickSearchView(
        controller: controller,
        servers: [server],
        target: (url: _url, teamId: 'team1'),
        onOpen: (item) => opened.add(item.id),
      ),
      overrides: [
        offlineProvider.overrideWithValue(false),
        switchItemsProvider(_url).overrideWith((ref) => Stream.value(items)),
        switchRemoteProvider.overrideWith((ref, args) async => const []),
      ],
    );
    await tester.pumpAndSettle();
  }

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
  }

  Future<void> pressReturn(WidgetTester tester) async {
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
  }

  testWidgets('Return opens the first matching channel', (tester) async {
    await show(tester, [_channel('c1', 'Boathouse'), _channel('c2', 'Boats')]);
    await type(tester, 'boat');
    await pressReturn(tester);
    expect(opened, ['c1']);
  });

  testWidgets('arrow keys move the highlight Return opens', (tester) async {
    await show(tester, [_channel('c1', 'Boathouse'), _channel('c2', 'Boats')]);
    await type(tester, 'boat');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    final second = tester.widget<ListTile>(
      find.ancestor(of: find.text('Boats'), matching: find.byType(ListTile)),
    );
    expect(second.selected, isTrue);
    await pressReturn(tester);
    expect(opened, ['c2']);
  });

  testWidgets('the switcher has no row for searching messages', (tester) async {
    await show(tester, [_channel('c1', 'Boats')]);
    await type(tester, 'boat');
    expect(find.textContaining('Search messages'), findsNothing);
    await type(tester, 'lunch');
    await pressReturn(tester);
    expect(opened, isEmpty);
    expect(find.textContaining('Search messages'), findsNothing);
  });

  testWidgets('the first match is highlighted as the user types, and again '
      'after typing more', (tester) async {
    bool selected(String title) => tester
        .widget<ListTile>(
          find.ancestor(of: find.text(title), matching: find.byType(ListTile)),
        )
        .selected;
    await show(tester, [
      _channel('c1', 'Boathouse'),
      _channel('c2', 'Boats'),
      _channel('c3', 'Boatswain'),
    ]);
    await type(tester, 'boat');
    expect(selected('Boathouse'), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(selected('Boatswain'), isTrue);
    await type(tester, 'boats');
    expect(selected('Boats'), isTrue);
    expect(selected('Boatswain'), isFalse);
    await pressReturn(tester);
    expect(opened, ['c2']);
  });

  testWidgets(
    'Ctrl+K opens the switcher, which has no row for searching messages',
    (tester) async {
      final opener = QuickSearchOpener();
      addTearDown(opener.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            offlineProvider.overrideWithValue(false),
            switchItemsProvider(_url)
                .overrideWith((ref) => Stream.value([_channel('c1', 'Boats')])),
            switchRemoteProvider.overrideWith((ref, args) async => const []),
          ],
          child: MaterialApp(
            theme: MatterleastApp.lightTheme,
            builder: (_, child) => AppShortcuts(child: child!),
            home: RootShortcuts(
              onSwitcher: opener.open,
              child: Scaffold(
                body: QuickSearchAnchor(
                  opener: opener,
                  servers: [server],
                  target: (url: _url, teamId: 'team1'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      await type(tester, 'boat');
      expect(find.text('Boats'), findsOneWidget);
      expect(find.textContaining('Search messages'), findsNothing);
    },
    variant: const TargetPlatformVariant({TargetPlatform.linux}),
  );
}
