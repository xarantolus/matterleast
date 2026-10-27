import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/agent_providers.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/image_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/images/server_image_caches.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/screens/agents/agents_screen.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:matterleast/screens/thread/thread_screen.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

class _Rail extends RailSelection {
  @override
  RailTarget? build() => null;

  @override
  void select(RailTarget? target) => state = target;
}

const _route = '/plugins/mattermost-ai';
const _botId = 'bt000000000000000000000b01';
const _directId = 'dm000000000000000000000d01';

/// The agents a plugin 2.x server offers: one, with its direct message.
final _bots = {
  'bots': [
    {
      'id': _botId,
      'displayName': 'Lighthouse',
      'username': 'lighthouse',
      'lastIconUpdate': 0,
      'dmChannelID': _directId,
      'isDefault': true,
    },
  ],
  'searchEnabled': false,
};

/// Plugin 2.x history: a channel summary (no channel id, as the plugin
/// writes it), a question in the direct message, and a conversation that
/// never got a thread.
final _threads = [
  {
    'id': 'cv000000000000000000000c01',
    'title': 'Summarize Channel',
    'channel_id': null,
    'bot_id': _botId,
    'root_post_id': 'sm000000000000000000000s01',
    'turn_count': 2,
    'update_at': DateTime.utc(2026, 10, 26, 9).millisecondsSinceEpoch,
  },
  {
    'id': 'cv000000000000000000000c02',
    'title': 'Knots for sailing',
    'channel_id': _directId,
    'bot_id': _botId,
    'root_post_id': 'qs000000000000000000000q01',
    'turn_count': 2,
    'update_at': DateTime.utc(2026, 10, 25, 9).millisecondsSinceEpoch,
  },
  {
    'id': 'cv000000000000000000000c03',
    'title': 'Background request',
    'channel_id': null,
    'bot_id': _botId,
    'root_post_id': null,
    'turn_count': 1,
    'update_at': DateTime.utc(2026, 10, 24, 9).millisecondsSinceEpoch,
  },
];

void main() {
  late FakeServer server;
  late ServerSession session;

  Future<void> start(
    WidgetTester tester,
    FutureOr<Reply?> Function(SeenRequest request) handle,
  ) async {
    HttpOverrides.global = null;
    (server, session) = (await tester.runAsync(() async {
      final server = await FakeServer.start();
      server.handle = handle;
      return (server, await testSession(server));
    }))!;
    final url = server.url.toString();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          serverSessionProvider(url).overrideWith((ref) async => session),
          agentsAvailableProvider(url).overrideWithValue(true),
          railSelectionProvider.overrideWith(_Rail.new),
          serverImageCachesProvider(url)
              .overrideWith((ref) => Completer<ServerImageCaches>().future),
        ],
        child: MaterialApp(
          theme: MatterleastApp.lightTheme,
          home: AgentsScreen(url: url),
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
    await tester.runAsync(() async {
      await closeTestSession(session);
      await server.close();
    });
  }

  testWidgets('a channel summary in the history opens its thread', (
    tester,
  ) async {
    await start(
      tester,
      (request) => switch (request.path) {
        '$_route/ai_bots' => ok(_bots),
        '$_route/ai_threads' => ok(_threads),
        // The summary sits in the agent's direct message, not stored yet.
        '/api/v4/posts/sm000000000000000000000s01/info' => ok({
          'channel_id': _directId,
          'channel_type': 'D',
          'channel_display_name': '',
          'has_joined_channel': true,
          'team_id': '',
          'has_joined_team': false,
        }),
        '/api/v4/posts/sm000000000000000000000s01' => ok({
          'id': 'sm000000000000000000000s01',
          'channel_id': _directId,
          'user_id': _botId,
          'root_id': '',
          'message': 'Here is the summary.',
        }),
        _ => ok(const <String, Object?>{}),
      },
    );
    await settle(tester);
    expect(find.text('Knots for sailing'), findsOneWidget);
    expect(find.text('Background request'), findsNothing);

    await tester.tap(find.text('Summarize Channel'));
    await settle(tester);
    final thread = tester.widget<ThreadScreen>(find.byType(ThreadScreen));
    expect(thread.rootId, 'sm000000000000000000000s01');
    expect(thread.channelId, _directId);
    await finish(tester);
  });

  testWidgets('a plugin that refuses the agents list shows no error', (
    tester,
  ) async {
    await start(
      tester,
      (request) => request.path.startsWith(_route)
          ? error(404, 'not_found')
          : ok(const <String, Object?>{}),
    );
    await settle(tester);
    expect(find.text('No agents for you'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
    await finish(tester);
  });
}
