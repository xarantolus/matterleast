import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/image_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/images/server_image_caches.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/screens/channel/channel_screen.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:matterleast/screens/thread/thread_screen.dart';
import 'package:matterleast/ui/conversation_route.dart';

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
  late ProviderContainer container;

  Future<void> start(WidgetTester tester) async {
    HttpOverrides.global = null;
    (server, session) = (await tester.runAsync(() async {
      final server = await FakeServer.start();
      server.handle = (_) => ok(const <String, Object?>{});
      return (server, await testSession(server));
    }))!;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          serverSessionProvider(server.url.toString())
              .overrideWith((ref) async => session),
          railSelectionProvider.overrideWith(_Rail.new),
          serverImageCachesProvider(server.url.toString())
              .overrideWith((ref) => Completer<ServerImageCaches>().future),
        ],
        child: MaterialApp(
          theme: MatterleastApp.lightTheme,
          home: Consumer(
            builder: (context, ref, _) {
              container = ProviderScope.containerOf(context);
              return const Scaffold();
            },
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
    await tester.runAsync(() async {
      await closeTestSession(session);
      await server.close();
    });
  }

  NavigatorState navigator(WidgetTester tester) =>
      tester.state<NavigatorState>(find.byType(Navigator).first);

  testWidgets('a channel slides in, its team is picked and it is remembered', (
    tester,
  ) async {
    await start(tester);
    final url = server.url.toString();
    final opening = openConversation(
      navigator(tester),
      url: url,
      channelId: channelId,
      title: 'Boats',
      teamId: teamId,
    );
    await settle(tester);
    expect(find.byType(ChannelScreen), findsOneWidget);
    expect(
      ModalRoute.of(tester.element(find.byType(ChannelScreen))),
      isA<ConversationRoute<void>>(),
    );
    expect(
      container.read(railSelectionProvider),
      RailTarget(url: url, teamId: teamId),
    );
    final last = await tester.runAsync(
      () => session.db.syncText(SyncKeys.lastChannel(teamId)),
    );
    expect(last, channelId);
    navigator(tester).pop();
    await settle(tester);
    await opening;
    await finish(tester);
  });

  testWidgets('a thread slides in the same way and leaves the channel be', (
    tester,
  ) async {
    await start(tester);
    final opening = openConversation(
      navigator(tester),
      url: server.url.toString(),
      channelId: channelId,
      title: 'Boats',
      teamId: teamId,
      rootId: 'old1',
    );
    await settle(tester);
    expect(find.byType(ThreadScreen), findsOneWidget);
    expect(
      ModalRoute.of(tester.element(find.byType(ThreadScreen))),
      isA<ConversationRoute<void>>(),
    );
    final last = await tester.runAsync(
      () => session.db.syncText(SyncKeys.lastChannel(teamId)),
    );
    expect(last, isNull);
    navigator(tester).pop();
    await settle(tester);
    await opening;
    await finish(tester);
  });
}
