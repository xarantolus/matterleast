import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
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

Future<void> _open(WidgetTester tester, PostItem post) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        postMenuFactsProvider(_url, post, 'team1').overrideWith(
          (ref) async =>
              (myId: 'me', saved: false, following: false, teamName: 'crew'),
        ),
        recentEmojiProvider(_url).overrideWith((ref) async => const []),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showMessageMenu(
                context,
                url: _url,
                teamId: 'team1',
                post: post,
                onEdit: () {},
                onReply: () {},
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
  testWidgets('the menu offers Edit and Delete on the user own message', (
    tester,
  ) async {
    await _open(tester, _post('me'));
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Mark as unread'), findsNothing);
  });

  testWidgets("the menu offers no Edit or Delete on someone else's message", (
    tester,
  ) async {
    await _open(tester, _post('other'));
    expect(find.text('Edit'), findsNothing);
    expect(find.text('Delete'), findsNothing);
    expect(find.text('Mark as unread'), findsOneWidget);
    expect(find.text('Reply'), findsOneWidget);
  });
}
