import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/domain/inbox.dart';
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
      MessagePreviewTile(item: _mention(team: 'Harbour'), onTap: () {}),
    );
    expect(find.text('#Town Square · Harbour'), findsOneWidget);
    expect(find.text('wren: Lunch at noon?'), findsOneWidget);
  });
}
