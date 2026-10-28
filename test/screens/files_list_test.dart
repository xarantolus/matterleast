import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/file_providers.dart';
import 'package:matterleast/app/image_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/files/file_downloads.dart';
import 'package:matterleast/data/images/server_image_caches.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/screens/channel/channel_screen.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:matterleast/screens/search/search_results_screen.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

/// Remembers what was picked without touching settings.
class _Rail extends RailSelection {
  @override
  RailTarget? build() => null;

  @override
  void select(RailTarget? target) => state = target;
}

void main() {
  late FakeServer server;
  late ServerSession session;

  Future<void> start(WidgetTester tester) async {
    HttpOverrides.global = null;
    (server, session) = (await tester.runAsync(() async {
      final server = await FakeServer.start();
      server.handle = (_) => ok(const <String, Object?>{});
      final session = await testSession(server);
      await session.store.applyPostList(
        'saved',
        api.PostList.fromJson({
          'order': ['pic1'],
          'posts': {
            'pic1': {
              'id': 'pic1',
              'channel_id': channelId,
              'user_id': meId,
              'create_at': DateTime.utc(
                2026,
                10,
                25,
                10,
              ).millisecondsSinceEpoch,
              'message': '',
              'file_ids': ['f1'],
              'metadata': {
                'files': [
                  {
                    'id': 'f1',
                    'name': 'harbour.txt',
                    'extension': 'txt',
                    'mime_type': 'text/plain',
                    'size': 1200,
                    'width': 40,
                    'height': 30,
                    'post_id': 'pic1',
                    'channel_id': channelId,
                  },
                ],
              },
            },
          },
        }),
        fetchedAt: DateTime.utc(2026, 10, 25, 11),
      );
      return (server, session);
    }))!;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          railSelectionProvider.overrideWith(_Rail.new),
          serverSessionProvider(server.url.toString())
              .overrideWith((ref) async => session),
          serverImageCachesProvider(server.url.toString())
              .overrideWith((ref) => Completer<ServerImageCaches>().future),
          fileDownloadsProvider(server.url.toString())
              .overrideWith((ref) => Completer<FileDownloads>().future),
        ],
        child: MaterialApp(
          theme: MatterleastApp.lightTheme,
          home: SearchResultsScreen(
            url: server.url.toString(),
            teamId: teamId,
            query: 'harbour',
            files: true,
          ),
        ),
      ),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
    await tester.runAsync(() async {
      await closeTestSession(session);
      await server.close();
    });
  }

  testWidgets(
    'tapping a file in the Files list opens the file, not the channel',
    (tester) async {
      await start(tester);
      await settle(tester);
      await tester.tap(find.text('harbour.txt'));
      await settle(tester);
      expect(find.byType(ChannelScreen), findsNothing);
      await finish(tester);
    },
  );

  testWidgets('the one action a file has is a button that opens its '
      'message', (tester) async {
    await start(tester);
    await settle(tester);
    expect(find.byTooltip('More'), findsNothing);
    await tester.tap(find.byTooltip('Jump to message'));
    await settle(tester);
    final screen = tester.widget<ChannelScreen>(find.byType(ChannelScreen));
    expect(screen.highlightPostId, 'pic1');
    Navigator.of(tester.element(find.byType(ChannelScreen))).pop();
    await settle(tester);
    await finish(tester);
  });
}
