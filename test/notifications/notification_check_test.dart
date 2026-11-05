import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/notifications/notification_check.dart';
import 'package:matterleast/notifications/notifier.dart';
import 'package:matterleast/notifications/notify_rules.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

class _Notices extends Notifier {
  final shownNotices = <ConversationNotice>[];

  @override
  Future<void> show(ConversationNotice notice) async =>
      shownNotices.add(notice);

  @override
  Future<List<ShownConversation>> shown(String serverUrl) async => const [];
}

void main() {
  late FakeServer server;
  late ServerSession session;
  late _Notices notices;
  late NotificationCheck check;

  final seen = DateTime.utc(2026, 10, 25, 10);
  final postAt = seen.add(const Duration(minutes: 5)).millisecondsSinceEpoch;

  setUp(() async {
    (server, session) = await startServerSession();
    notices = _Notices();
    check = NotificationCheck(session, notices, shownNow: (_) => false);
    await session.db.setSyncInt(
      NotifyKeys.cursorKey,
      seen.millisecondsSinceEpoch,
    );
    server.handle = (r) => r.path.endsWith('/posts')
        ? ok({
            'order': ['p1'],
            'posts': {
              'p1': {
                'id': 'p1',
                'channel_id': channelId,
                'user_id': 'someone',
                'create_at': postAt,
                'message': '@river the boats',
              },
            },
          })
        : ok(<Object?>[]);
    server.seen.clear();
  });

  Future<void> storeLivePost() => session.store.applyLivePost(
    api.Post.fromJson({
      'id': 'p1',
      'channel_id': channelId,
      'user_id': 'someone',
      'create_at': postAt,
      'message': '@river the boats',
    }),
    fromSelf: false,
    mentionsMe: true,
  );

  test('a mention the socket stored notifies without fetching posts', () async {
    await storeLivePost();
    await check.run(refresh: false, fetch: false);
    expect(notices.shownNotices, hasLength(1));
    expect(server.paths.where((p) => p.endsWith('/posts')), isEmpty);
  });

  test('after a gap the posts come from the server', () async {
    await storeLivePost();
    await check.run(refresh: false);
    expect(notices.shownNotices, hasLength(1));
    expect(server.paths.where((p) => p.endsWith('/posts')), hasLength(1));
  });
}
