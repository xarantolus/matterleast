import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/keyboard_shortcuts.dart';
import 'package:matterleast/data/actions/channel_actions.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/domain/panes.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/screens/root/open_panes.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/root/root_shortcuts.dart';
import 'package:matterleast/screens/settings/settings_page.dart';

import '../support/rail.dart';

const _url = 'https://chat.example.test';
const _team = 'team1';

ChannelItem _channel(String id, {bool unread = false}) => ChannelItem(
  id: id,
  title: 'Channel $id',
  kind: ChannelKind.public,
  unread: unread,
  mentions: 0,
  muted: false,
  favorite: false,
  hasDraft: false,
);

final _list = ChannelList(
  teamName: 'boats',
  sections: [
    CategorySection(
      id: 'channels',
      title: 'Channels',
      kind: CategoryKind.channels,
      collapsed: false,
      rows: [_channel('a'), _channel('b'), _channel('c'), _channel('d')],
    ),
    CategorySection(
      id: 'dms',
      title: 'Direct messages',
      kind: CategoryKind.directMessages,
      collapsed: false,
      rows: [_channel('e', unread: true)],
    ),
  ],
  unreadThreads: null,
  drafts: 0,
  synced: true,
);

ConversationTarget _target(String id) => ConversationTarget.channel(
  url: _url,
  channelId: id,
  title: 'Channel $id',
  teamId: _team,
);

const _teams = [
  RailTeam(id: _team, displayName: 'Boats', unread: false, mentions: 0),
  RailTeam(id: 'team2', displayName: 'Docks', unread: false, mentions: 0),
];

/// The root's shortcuts over an empty page, on a wide window, with the rail
/// on the first team; the container shows what the keys did.
Future<ProviderContainer> _pumpRoot(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1600, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  late ProviderContainer container;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        railSelectionProvider.overrideWith(
          () => MemoryRailSelection(const RailTarget(url: _url, teamId: _team)),
        ),
        railTeamsProvider(_url).overrideWith((ref) => Stream.value(_teams)),
        channelListProvider(
          _url,
          _team,
        ).overrideWith((ref) => Stream.value(_list)),
        // Marking the channel viewed is not what this checks.
        channelActionsProvider(_url)
            .overrideWith((ref) => Completer<ChannelActions>().future),
      ],
      child: MaterialApp(
        theme: MatterleastApp.lightTheme,
        builder: (_, child) => AppShortcuts(child: child!),
        home: Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            // Kept listened, as the root screen does.
            ref
              ..watch(railTeamsProvider(_url))
              ..watch(channelListProvider(_url, _team));
            return RootShortcuts(
              onSwitcher: () {},
              child: const Scaffold(body: SizedBox.expand()),
            );
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Future<void> _press(
  WidgetTester tester,
  LogicalKeyboardKey key, {
  bool control = false,
  bool shift = false,
}) async {
  if (control) await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyEvent(key);
  if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  if (control) await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pumpAndSettle();
}

void main() {
  final desktop = TargetPlatformVariant.only(TargetPlatform.linux);

  testWidgets('the shortcut list shows every shortcut with its keys', (
    tester,
  ) async {
    // Tall, so that the list builds every row.
    tester.view.physicalSize = const Size(1200, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        builder: (_, child) => AppShortcuts(child: child!),
        home: const Scaffold(body: TextField(autofocus: true)),
      ),
    );
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.slash);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(find.text('Keyboard shortcuts'), findsWidgets);
    for (final shortcut in appShortcuts.where((s) => s.listed)) {
      final row = find.ancestor(
        of: find.text(shortcut.description),
        matching: find.byType(Row),
      );
      expect(
        find.descendant(
          of: row,
          matching: find.text(shortcut.listedKeys ?? keysLabel(shortcut.keys)),
        ),
        findsOneWidget,
        reason: shortcut.description,
      );
    }
    expect(keysLabel(appShortcuts.first.keys), 'Ctrl+K');
    expect(find.text('Search this conversation'), findsOneWidget);
    expect(find.text('Ctrl+F'), findsOneWidget);
    expect(find.text('Reply to the newest message'), findsOneWidget);
    expect(find.text('Shift+Up'), findsOneWidget);
  }, variant: desktop);

  testWidgets(
    'Ctrl+K opens the switcher while nothing has the focus',
    (tester) async {
      var opened = 0;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            builder: (_, child) => AppShortcuts(child: child!),
            home: RootShortcuts(
              onSwitcher: () => opened++,
              child: const Scaffold(body: SizedBox.expand()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      expect(opened, 1);
    },
    variant: const TargetPlatformVariant({
      TargetPlatform.linux,
      TargetPlatform.windows,
    }),
  );

  testWidgets('Alt+Down opens the next channel, Alt+Shift+Down the next '
      'unread one', (tester) async {
    final container = await _pumpRoot(tester);
    container.read(openPanesProvider.notifier).open(_target('b'));
    String? open() => container.read(openPanesProvider).channel?.channelId;

    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();
    expect(open(), 'c');

    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();
    expect(open(), 'b');

    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();
    expect(open(), 'e');
  }, variant: desktop);

  testWidgets('Ctrl+Tab and Ctrl+Shift+Tab step through the channels', (
    tester,
  ) async {
    final container = await _pumpRoot(tester);
    container.read(openPanesProvider.notifier).open(_target('b'));
    String? open() => container.read(openPanesProvider).channel?.channelId;

    await _press(tester, LogicalKeyboardKey.tab, control: true);
    expect(open(), 'c');
    await _press(tester, LogicalKeyboardKey.tab, control: true, shift: true);
    expect(open(), 'b');
  }, variant: desktop);

  testWidgets('Ctrl+2 shows the second team of the server', (tester) async {
    final container = await _pumpRoot(tester);
    RailTarget? shown() => container.read(railSelectionProvider);
    expect(shown()?.teamId, _team);

    await _press(tester, LogicalKeyboardKey.digit2, control: true);
    expect(shown()?.teamId, 'team2');

    await _press(tester, LogicalKeyboardKey.digit1, control: true);
    expect(shown()?.teamId, _team);

    // There is no third team.
    await _press(tester, LogicalKeyboardKey.digit3, control: true);
    expect(shown()?.teamId, _team);
  }, variant: desktop);

  testWidgets('Ctrl+, opens the settings', (tester) async {
    await _pumpRoot(tester);
    expect(find.byType(SettingsPage), findsNothing);

    await _press(tester, LogicalKeyboardKey.comma, control: true);
    expect(find.byType(SettingsPage), findsOneWidget);
  }, variant: desktop);

  testWidgets('Esc closes the thread beside a channel, not the channel', (
    tester,
  ) async {
    final container = await _pumpRoot(tester);
    container
        .read(openPanesProvider.notifier)
        .open(
          const ConversationTarget.thread(
            url: _url,
            channelId: 'b',
            rootId: 'root1',
            channelName: 'Channel b',
            teamId: _team,
          ),
        );
    Panes panes() => container.read(openPanesProvider);
    expect(panes().thread, isNotNull);

    await _press(tester, LogicalKeyboardKey.escape);
    expect(panes().thread, isNull);
    expect(panes().channel?.channelId, 'b');

    await _press(tester, LogicalKeyboardKey.escape);
    expect(panes().channel?.channelId, 'b');
  }, variant: desktop);

  test('stepping wraps round and skips read channels for unread', () {
    expect(channelStep(_list, 'e', forward: true)?.id, 'a');
    expect(channelStep(_list, 'a', forward: false)?.id, 'e');
    expect(channelStep(_list, null, forward: true)?.id, 'a');
    expect(channelStep(_list, 'e', forward: true, unreadOnly: true), isNull);
  });
}
