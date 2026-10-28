import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart' hide isNotNull, isNull;
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/domain/thread_options.dart';
import 'package:matterleast/screens/threads/team_threads_screen.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';
import '../support/test_session.dart';

void main() {
  late ServerHarness h;

  Future<void> start(WidgetTester tester) async {
    h = await pumpWithServer(
      tester,
      handle: (r) => switch (r.path) {
        '/api/v4/users/me/teams/$teamId/threads/old1/set_unread/old1' => ok({
          'id': 'old1',
          'unread_replies': 2,
          'unread_mentions': 0,
        }),
        '/api/v4/users/me/teams/$teamId/threads/old1/following' => ok({
          'status': 'OK',
        }),
        '/api/v4/users/me/teams/$teamId/threads' => ok({
          'threads': <Object?>[],
          'total': 0,
          'total_unread_threads': 0,
          'total_unread_mentions': 0,
        }),
        _ => ok(const <String, Object?>{}),
      },
      seed: (session) async {
        await session.db
            .into(session.db.threads)
            .insert(
              ThreadsCompanion.insert(
                rootId: 'old1',
                channelId: channelId,
                isFollowing: const Value(true),
                lastReplyAt: Value(DateTime.utc(2026, 10, 25, 10)),
              ),
            );
        await session.db
            .into(session.db.threadTeams)
            .insert(
              ThreadTeamsCompanion.insert(teamId: teamId, rootId: 'old1'),
            );
      },
      home: (url) =>
          TeamThreadsScreen(url: url, teamId: teamId, teamName: 'Harbour'),
    );
  }

  Future<void> openSheet(WidgetTester tester) async {
    await tester.longPress(find.text('morning'));
    await h.settle(tester);
  }

  testWidgets('long-pressing a thread shows its options, in the usual order', (
    tester,
  ) async {
    await start(tester);
    await openSheet(tester);
    final labels = [
      'Reply',
      'Unfollow thread',
      'Open in channel',
      'Mark as unread',
      'Save',
      'Copy link',
    ];
    final tops = [
      for (final label in labels) tester.getTopLeft(find.text(label)).dy,
    ];
    expect(tops, [...tops]..sort());
    await h.close(tester);
  });

  testWidgets('the thread options are also a screen reader action', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await start(tester);
    final node = tester.getSemantics(find.text('morning'));
    expect(node.getSemanticsData().customSemanticsActionIds, isNotEmpty);
    semantics.dispose();
    await h.close(tester);
  });

  testWidgets('marking a thread unread turns its row unread', (tester) async {
    await start(tester);
    expect(find.text('2'), findsNothing);
    await openSheet(tester);
    await tester.tap(find.text('Mark as unread'));
    await h.settle(tester);
    expect(find.text('2'), findsOneWidget);
    await openSheet(tester);
    expect(find.text('Mark as read'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('unfollowing a thread removes it from the list', (tester) async {
    await start(tester);
    await openSheet(tester);
    await tester.tap(find.text('Unfollow thread'));
    await h.settle(tester);
    expect(find.text('morning'), findsNothing);
    expect(
      h.server.paths,
      contains('/api/v4/users/me/teams/$teamId/threads/old1/following'),
    );
    await h.close(tester);
  });

  test('a followed, unread, saved thread offers the reverse actions', () {
    expect(
      threadOptions(
        following: false,
        unread: true,
        saved: true,
        canLink: false,
      ),
      [
        ThreadOption.reply,
        ThreadOption.follow,
        ThreadOption.openInChannel,
        ThreadOption.markRead,
        ThreadOption.unsave,
      ],
    );
  });
}
