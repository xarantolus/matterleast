import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/permissions.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/screens/channel/message_menu.dart';
import 'package:matterleast/ui/emoji_picker.dart';

const _url = 'https://chat.example.test';

PostItem _post(String userId) => PostItem(
  id: 'post1',
  key: 'post1',
  userId: userId,
  authorName: 'someone',
  createAt: DateTime.utc(2026, 3, 1),
  message: 'Hello',
);

const _all = (
  react: true,
  reply: true,
  pin: true,
  edit: true,
  delete: true,
  markUnread: true,
);
const _readOnly = (
  react: false,
  reply: false,
  pin: false,
  edit: false,
  delete: false,
  markUnread: false,
);

Future<void> _open(
  WidgetTester tester,
  PostItem post, {
  MessageRights rights = _all,
  bool reminders = false,
  ValueChanged<String?>? onQuote,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        postMenuFactsProvider(_url, post, 'team1').overrideWith(
          (ref) async => (
            myId: 'me',
            saved: false,
            following: false,
            teamName: 'crew',
            rights: rights,
            reminders: reminders,
          ),
        ),
        recentEmojiProvider(_url).overrideWith((ref) async => const []),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showMessageMenu(
                context,
                MessageTarget(
                  url: _url,
                  teamId: 'team1',
                  post: post,
                  onEdit: () {},
                  onReply: () {},
                  onQuote: onQuote,
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'quick reactions follow the width the sheet has, not the screen',
    (tester) async {
      tester.view.physicalSize = const Size(1800, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final post = _post('other');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            postMenuFactsProvider(_url, post, 'team1').overrideWith(
              (ref) async => (
                myId: 'me',
                saved: false,
                following: false,
                teamName: 'crew',
                rights: _all,
                reminders: false,
              ),
            ),
            recentEmojiProvider(_url).overrideWith((ref) async => const []),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 240,
                  child: MessageMenu(
                    target: MessageTarget(
                      url: _url,
                      teamId: 'team1',
                      post: post,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byTooltip(RegExp(r'^:[^:]+:$')), findsNWidgets(3));
    },
  );

  test('six quick reactions fit a wide row, three a narrow one', () {
    expect(quickReactionCount(640), 6);
    expect(quickReactionCount(300), 5);
    expect(quickReactionCount(100), 3);
  });

  testWidgets('the menu offers what the rights allow', (tester) async {
    await _open(tester, _post('me'));
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Reply'), findsOneWidget);
    expect(find.text('Pin to channel'), findsOneWidget);
    expect(find.byTooltip('Add reaction'), findsOneWidget);
  });

  testWidgets('where nothing may be written only reading actions remain', (
    tester,
  ) async {
    await _open(tester, _post('other'), rights: _readOnly);
    expect(find.text('Edit'), findsNothing);
    expect(find.text('Delete'), findsNothing);
    expect(find.text('Reply'), findsNothing);
    expect(find.text('Pin to channel'), findsNothing);
    expect(find.text('Mark as unread'), findsNothing);
    expect(find.byTooltip('Add reaction'), findsNothing);
    expect(find.text('Copy text'), findsOneWidget);
  });

  testWidgets('Remind me shows only where the server has reminders', (
    tester,
  ) async {
    await _open(tester, _post('other'));
    expect(find.text('Remind me'), findsNothing);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    await _open(tester, _post('other'), reminders: true);
    expect(find.text('Remind me'), findsOneWidget);
    await tester.tap(find.text('Remind me'));
    await tester.pumpAndSettle();
    expect(find.text('In 30 minutes'), findsOneWidget);
    expect(find.text('Tomorrow'), findsOneWidget);
    expect(find.text('Custom'), findsOneWidget);
  });

  testWidgets('Quote hands the message link to the composer', (tester) async {
    String? quoted;
    await _open(tester, _post('other'), onQuote: (link) => quoted = link);
    await tester.tap(find.text('Quote'));
    await tester.pumpAndSettle();
    expect(quoted, '$_url/crew/pl/post1');
    expect(find.text('Quote'), findsNothing);
  });

  for (final (name, rights) in [('all', _all), ('read-only', _readOnly)]) {
    testWidgets('a right click offers what the sheet offers ($name rights)', (
      tester,
    ) async {
      final post = _post('me');
      final target = MessageTarget(
        url: _url,
        teamId: 'team1',
        post: post,
        onEdit: () {},
        onReply: () {},
        onQuote: (_) {},
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            postMenuFactsProvider(_url, post, 'team1').overrideWith(
              (ref) async => (
                myId: 'me',
                saved: false,
                following: false,
                teamName: 'crew',
                rights: rights,
                reminders: true,
              ),
            ),
            recentEmojiProvider(_url).overrideWith((ref) async => const []),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => Column(
                  children: [
                    TextButton(
                      onPressed: () => showMessageMenu(context, target),
                      child: const Text('sheet'),
                    ),
                    TextButton(
                      onPressed: () => showMessageContextMenu(
                        context,
                        target,
                        const Offset(200, 300),
                      ),
                      child: const Text('popup'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('sheet'));
      await tester.pumpAndSettle();
      final sheet = [
        if (find.byTooltip('Add reaction').evaluate().isNotEmpty)
          'Add reaction',
        for (final tile in tester.widgetList<ListTile>(find.byType(ListTile)))
          (tile.title! as Text).data!,
      ];
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      await tester.tap(find.text('popup'));
      await tester.pumpAndSettle();
      final popup = [
        for (final item in tester.widgetList<PopupMenuItem<Object?>>(
          find.byWidgetPredicate((w) => w is PopupMenuItem),
        ))
          tester
              .widget<Text>(
                find.descendant(
                  of: find.byWidget(item),
                  matching: find.byType(Text),
                ),
              )
              .data!,
      ];

      expect(sheet, contains('Copy text'));
      expect(popup, sheet);
    });
  }
}
