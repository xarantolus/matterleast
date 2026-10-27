import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart' hide isNotNull, isNull;
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/image_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/images/server_image_caches.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/domain/thread_options.dart';
import 'package:matterleast/screens/threads/team_threads_screen.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

void main() {
  late FakeServer server;
  late ServerSession session;

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 15; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> start(WidgetTester tester) async {
    HttpOverrides.global = null;
    (server, session) = (await tester.runAsync(() async {
      final server = await FakeServer.start();
      server.handle = (r) => switch (r.path) {
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
      };
      final session = await testSession(server);
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
          .insert(ThreadTeamsCompanion.insert(teamId: teamId, rootId: 'old1'));
      return (server, session);
    }))!;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          serverSessionProvider(server.url.toString())
              .overrideWith((ref) async => session),
          serverImageCachesProvider(server.url.toString())
              .overrideWith((ref) => Completer<ServerImageCaches>().future),
        ],
        child: MaterialApp(
          theme: MatterleastApp.lightTheme,
          home: TeamThreadsScreen(
            url: server.url.toString(),
            teamId: teamId,
            teamName: 'Harbour',
          ),
        ),
      ),
    );
    await settle(tester);
  }

  Future<void> openSheet(WidgetTester tester) async {
    await tester.longPress(find.text('morning'));
    await settle(tester);
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
    await tester.runAsync(() async {
      await closeTestSession(session);
      await server.close();
    });
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
    await finish(tester);
  });

  testWidgets('the thread options are also a screen reader action', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await start(tester);
    final node = tester.getSemantics(find.text('morning'));
    expect(node.getSemanticsData().customSemanticsActionIds, isNotEmpty);
    semantics.dispose();
    await finish(tester);
  });

  testWidgets('marking a thread unread turns its row unread', (tester) async {
    await start(tester);
    expect(find.text('2'), findsNothing);
    await openSheet(tester);
    await tester.tap(find.text('Mark as unread'));
    await settle(tester);
    expect(find.text('2'), findsOneWidget);
    await openSheet(tester);
    expect(find.text('Mark as read'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('unfollowing a thread removes it from the list', (tester) async {
    await start(tester);
    await openSheet(tester);
    await tester.tap(find.text('Unfollow thread'));
    await settle(tester);
    expect(find.text('morning'), findsNothing);
    expect(
      server.paths,
      contains('/api/v4/users/me/teams/$teamId/threads/old1/following'),
    );
    await finish(tester);
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
