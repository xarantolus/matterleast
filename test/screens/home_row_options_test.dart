import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/domain/inbox.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/thread_options.dart';
import 'package:matterleast/screens/home/home_pane.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';
import '../support/test_session.dart';

const _dm = 'dm000000000000000000000d01';

void main() {
  test('only unread conversations and saved rows have options', () {
    expect(rowOptions(InboxKind.direct, unread: true), [ThreadOption.markRead]);
    expect(rowOptions(InboxKind.mention, unread: true), [
      ThreadOption.markRead,
    ]);
    expect(rowOptions(InboxKind.direct, unread: false), isEmpty);
    expect(rowOptions(InboxKind.saved, unread: false), [ThreadOption.unsave]);
  });

  testWidgets('marking an unread direct message read removes it from Unread', (
    tester,
  ) async {
    final h = await pumpWithServer(
      tester,
      size: const Size(400, 800),
      handle: (r) => ok(const <String, Object?>{}),
      seed: (session) async {
        final store = session.store;
        await store.applyUsers([
          api.User.fromJson({'id': 'ada', 'username': 'ada'}),
        ]);
        await store.applyChannels(
          channels: [
            api.Channel.fromJson({
              'id': _dm,
              'type': 'D',
              'name': '${meId}__ada',
              'display_name': '',
              'total_msg_count': 2,
            }),
          ],
          members: [
            api.ChannelMember.fromJson({
              'channel_id': _dm,
              'user_id': meId,
              'msg_count': 0,
            }),
          ],
        );
        await store.applyChannelPage(
          channelId: _dm,
          page: api.PostList.fromJson({
            'order': ['dmpost'],
            'posts': {
              'dmpost': {
                'id': 'dmpost',
                'channel_id': _dm,
                'user_id': 'ada',
                'create_at': DateTime.utc(
                  2026,
                  10,
                  25,
                  9,
                ).millisecondsSinceEpoch,
                'message': 'lunch?',
              },
            },
          }),
          kind: PageKind.page,
        );
      },
      home: (url) => Scaffold(
        body: HomePane(
          servers: [
            ServerEntry(
              url: url,
              displayName: 'Chat',
              siteName: null,
              serverVersion: null,
              diagnosticId: null,
              lastActiveAt: null,
              ssoScheme: null,
            ),
          ],
        ),
      ),
    );
    expect(find.textContaining('lunch?'), findsOneWidget);
    await tester.longPress(find.textContaining('lunch?'));
    await h.settle(tester);
    await tester.tap(find.text('Mark as read'));
    await h.settle(tester);
    expect(find.textContaining('lunch?'), findsNothing);
    await h.close(tester);
  });
}
