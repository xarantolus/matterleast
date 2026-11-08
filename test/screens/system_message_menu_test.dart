import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/domain/permissions.dart';
import 'package:matterleast/screens/channel/conversation_controller.dart';
import 'package:matterleast/screens/channel/conversation_view.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';
import '../support/test_session.dart';

Future<void> _seed(
  ServerSession session, {
  required bool admin,
  bool twice = false,
}) async {
  final store = session.store;
  await store.applyMyRoles('system_user');
  await store.applyChannelMember(
    api.ChannelMember.fromJson({
      'channel_id': channelId,
      'user_id': meId,
      'roles': 'channel_user',
    }),
  );
  api.Role role(String name, List<String> permissions) =>
      api.Role.fromJson({'id': name, 'name': name, 'permissions': permissions});
  await store.applyRoles([
    role('channel_user', [Permission.createPost, Permission.deletePost]),
    role('system_user', [if (admin) Permission.deleteOthersPosts]),
  ]);
  await store.applyChannelPage(
    channelId: channelId,
    page: api.PostList.fromJson({
      'order': [if (twice) 'sys2', 'sys1'],
      'posts': {
        if (twice)
          'sys2': {
            'id': 'sys2',
            'channel_id': channelId,
            'user_id': 'someone',
            'type': 'system_add_to_channel',
            'props': {'username': 'wren', 'addedUsername': 'carol'},
            'create_at': DateTime.utc(
              2026,
              10,
              26,
              9,
              1,
            ).millisecondsSinceEpoch,
            'message': '@wren added @carol to the channel.',
          },
        'sys1': {
          'id': 'sys1',
          'channel_id': channelId,
          'user_id': 'someone',
          'type': 'system_add_to_channel',
          'props': {'username': 'wren', 'addedUsername': 'bob'},
          'create_at': DateTime.utc(2026, 10, 26, 9).millisecondsSinceEpoch,
          'message': '@wren added @bob to the channel.',
        },
      },
    }),
    kind: PageKind.page,
  );
}

void main() {
  Future<ServerHarness> open(
    WidgetTester tester, {
    required bool admin,
    bool twice = false,
  }) => pumpWithServer(
    tester,
    size: const Size(400, 800),
    handle: emptyAnswer,
    seed: (session) => _seed(session, admin: admin, twice: twice),
    home: (url) => Scaffold(
      body: ConversationView(
        url: url,
        conversation: conversationProvider(url, channelId),
        startText: 'This is the start of Boats.',
        onOpenThread: (post, {reply = false}) {},
      ),
    ),
  );

  testWidgets('an admin long-pressing a system message can delete it', (
    tester,
  ) async {
    final h = await open(tester, admin: true);
    await tester.longPress(find.textContaining('added', findRichText: true));
    await h.settle(tester);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Copy text'), findsNothing);
    await h.close(tester);
  });

  testWidgets('a member long-pressing a system message gets no menu', (
    tester,
  ) async {
    final h = await open(tester, admin: false);
    await tester.longPress(find.textContaining('added', findRichText: true));
    await h.settle(tester);
    expect(find.text('Delete'), findsNothing);
    expect(find.text('Copy text'), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
    await h.close(tester);
  });

  testWidgets('a line telling several system messages has no menu', (
    tester,
  ) async {
    final h = await open(tester, admin: true, twice: true);
    await tester.longPress(find.textContaining('added', findRichText: true));
    await h.settle(tester);
    expect(find.text('Delete'), findsNothing);
    await h.close(tester);
  });
}
