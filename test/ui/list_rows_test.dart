import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/domain/inbox.dart';
import 'package:matterleast/screens/channel_list/channel_tile.dart';
import 'package:matterleast/ui/message_preview_tile.dart';
import 'package:matterleast/ui/presence_dot.dart';

Future<void> _show(WidgetTester tester, Widget child) => tester.pumpWidget(
  ProviderScope(
    child: MaterialApp(
      theme: MatterleastApp.lightTheme,
      home: Scaffold(body: child),
    ),
  ),
);

InboxItem _mention({String? team}) => InboxItem(
  serverUrl: 'https://chat.example.test',
  kind: InboxKind.mention,
  channelId: 'c1',
  teamId: 't1',
  title: '#Town Square',
  avatarName: 'wren',
  author: 'wren',
  preview: 'Lunch at noon?',
  place: null,
  team: team,
  time: DateTime.utc(2026, 3, 1, 9),
  count: 0,
  unread: false,
  postId: 'p1',
);

void main() {
  testWidgets('a presence dot tells a screen reader the status', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _show(tester, const PresenceDot(status: 'away'));
    expect(find.bySemanticsLabel('Away'), findsOneWidget);
    await _show(tester, const PresenceDot(status: null));
    expect(find.bySemanticsLabel('Offline'), findsOneWidget);
    await _show(tester, const PresenceDot(status: 'dnd', announce: false));
    expect(find.bySemanticsLabel('Do not disturb'), findsNothing);
    semantics.dispose();
  });

  testWidgets('a row names the team after the channel, not in the preview', (
    tester,
  ) async {
    await _show(
      tester,
      MessagePreviewTile(
        item: _mention(team: 'Harbour'),
        onTap: () {},
      ),
    );
    expect(find.text('#Town Square · Harbour'), findsOneWidget);
    expect(find.text('wren: Lunch at noon?'), findsOneWidget);
  });

  testWidgets('a channel row reads as one sentence, name first, counts in '
      'words', (tester) async {
    final semantics = tester.ensureSemantics();
    ChannelItem item(ChannelKind kind, {String? status}) => ChannelItem(
      id: 'c',
      title: 'wren',
      kind: kind,
      unread: true,
      mentions: 2,
      muted: true,
      favorite: false,
      hasDraft: true,
      status: status,
    );
    await _show(
      tester,
      ChannelTile(
        serverUrl: 'https://chat.example.test',
        item: item(ChannelKind.direct, status: 'dnd'),
        onTap: () {},
        onLongPress: () {},
      ),
    );
    final node = find.semantics
        .byLabel('wren, do not disturb, draft, muted, 2 mentions')
        .evaluate()
        .single;
    expect(node.hintOverrides?.onLongPressHint, 'channel options');
    expect(find.semantics.byLabel('2'), findsNothing);
    expect(
      channelRowLabel(item(ChannelKind.private)),
      'wren, private channel, draft, muted, 2 mentions',
    );
    expect(
      channelRowLabel(
        item(ChannelKind.public)
            .copyWith(mentions: 0, muted: false, hasDraft: false),
      ),
      'wren, unread',
    );
    semantics.dispose();
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('a direct message preview says the name before the presence', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _show(
      tester,
      MessagePreviewTile(
        item: _mention().copyWith(
          kind: InboxKind.direct,
          title: 'wren',
          author: null,
          status: 'online',
          count: 2,
          unread: true,
        ),
        onTap: () {},
      ),
    );
    expect(
      find.semantics.byLabel(
        RegExp(r'^wren\nonline\n.*\nLunch at noon\?\n2 unread$'),
      ),
      findsOne,
    );
    semantics.dispose();
  });
}
