import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/screens/search/quick_search.dart';
import 'package:matterleast/screens/search/search_providers.dart';

const _url = 'https://chat.example.test';

SwitchItem _channel(String id, String title) => SwitchItem(
  serverUrl: _url,
  kind: SwitchKind.channel,
  id: id,
  title: title,
  teamId: 'team1',
);

void main() {
  final server = ServerEntry(
    url: _url,
    displayName: 'Test',
    siteName: null,
    serverVersion: null,
    diagnosticId: null,
    lastActiveAt: DateTime(2026),
    ssoScheme: null,
  );

  late List<String> opened;
  late List<String> searched;

  Future<void> show(WidgetTester tester, List<SwitchItem> items) async {
    opened = [];
    searched = [];
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          offlineProvider.overrideWithValue(false),
          switchItemsProvider(_url).overrideWith((ref) => Stream.value(items)),
          switchRemoteProvider.overrideWith((ref, args) async => const []),
        ],
        child: MaterialApp(
          theme: MatterleastApp.lightTheme,
          home: QuickSearchView(
            controller: controller,
            servers: [server],
            target: (url: _url, teamId: 'team1'),
            onOpen: (item) => opened.add(item.id),
            onSearch: searched.add,
          ),
        ),
      ),
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
    expect(searched, isEmpty);
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

  testWidgets('Return on the message search row searches messages', (
    tester,
  ) async {
    await show(tester, [_channel('c1', 'Boats')]);
    await type(tester, 'boat');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await pressReturn(tester);
    expect(opened, isEmpty);
    expect(searched, ['boat']);
  });

  testWidgets('with no matches Return searches messages', (tester) async {
    await show(tester, [_channel('c1', 'Boats')]);
    await type(tester, 'lunch');
    await pressReturn(tester);
    expect(opened, isEmpty);
    expect(searched, ['lunch']);
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
}
