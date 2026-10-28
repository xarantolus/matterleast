import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/keyboard_shortcuts.dart';
import 'package:matterleast/data/actions/channel_actions.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/domain/panes.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/screens/root/open_panes.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/root/root_shortcuts.dart';

const _url = 'https://chat.example.test';
const _team = 'team1';

class _Rail extends RailSelection {
  @override
  RailTarget? build() => const RailTarget(url: _url, teamId: _team);

  @override
  void select(RailTarget? target) => state = target;
}

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

void main() {
  final desktop = TargetPlatformVariant.only(TargetPlatform.linux);

  testWidgets('the shortcut list shows every shortcut with its keys', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
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
    for (final shortcut in appShortcuts) {
      final row = find.ancestor(
        of: find.text(shortcut.description),
        matching: find.byType(Row),
      );
      expect(
        find.descendant(of: row, matching: find.text(keysLabel(shortcut.keys))),
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

  testWidgets('Alt+Down opens the next channel, Alt+Shift+Down the next '
      'unread one', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          railSelectionProvider.overrideWith(_Rail.new),
          railTeamsProvider(_url).overrideWith(
            (ref) => Stream.value(const [
              RailTeam(
                id: _team,
                displayName: 'Boats',
                unread: false,
                mentions: 0,
              ),
            ]),
          ),
          channelListProvider(
            _url,
            _team,
          ).overrideWith((ref) => Stream.value(_list)),
          // Marking the channel viewed is not what this checks.
          channelActionsProvider(_url)
              .overrideWith((ref) => Completer<ChannelActions>().future),
        ],
        child: MaterialApp(
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
                child: const Scaffold(body: TextField(autofocus: true)),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    container
        .read(openPanesProvider.notifier)
        .open(
          const ConversationTarget.channel(
            url: _url,
            channelId: 'b',
            title: 'Channel b',
            teamId: _team,
          ),
        );
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

  test('stepping wraps round and skips read channels for unread', () {
    expect(channelStep(_list, 'e', forward: true)?.id, 'a');
    expect(channelStep(_list, 'a', forward: false)?.id, 'e');
    expect(channelStep(_list, null, forward: true)?.id, 'a');
    expect(channelStep(_list, 'e', forward: true, unreadOnly: true), isNull);
  });
}
