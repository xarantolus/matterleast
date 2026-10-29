import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/image_providers.dart';
import 'package:matterleast/app/keyboard_shortcuts.dart';
import 'package:matterleast/app/live_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/app/restore_conversation.dart';
import 'package:matterleast/data/app_db/app_database.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/data/images/server_image_caches.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/store/server_store.dart' show PageKind;
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/domain/inbox.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/server_features.dart';
import 'package:matterleast/domain/user_profile.dart';
import 'package:matterleast/notifications/notification_launch.dart';
import 'package:matterleast/notifications/notifier.dart';
import 'package:matterleast/screens/channel/channel_screen.dart';
import 'package:matterleast/screens/channel/composer.dart';
import 'package:matterleast/screens/channel/conversation_view.dart';
import 'package:matterleast/screens/channel/link_opener.dart';
import 'package:matterleast/screens/home/home_providers.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/open_page.dart';
import 'package:matterleast/screens/reopen_swipe.dart';
import 'package:matterleast/screens/root/conversation_memory.dart';
import 'package:matterleast/screens/root/gone_channels.dart';
import 'package:matterleast/screens/root/open_history.dart';
import 'package:matterleast/screens/root/open_panes.dart';
import 'package:matterleast/screens/root/pane_layout.dart';
import 'package:matterleast/screens/root/place_reconciler.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:matterleast/screens/root/rail_switch.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/root/root_shortcuts.dart';
import 'package:matterleast/screens/search/search_providers.dart';
import 'package:matterleast/screens/thread/thread_screen.dart';
import 'package:matterleast/screens/threads/team_threads_screen.dart';
import 'package:matterleast/screens/you/profile_providers.dart';
import 'package:matterleast/screens/you/user_profile_sheet.dart';
import 'package:matterleast/ui/conversation_route.dart';
import 'package:matterleast/ui/slide_route.dart';

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
  late WidgetRef widgetRef;
  late AppDatabase db;

  Future<void> start(
    WidgetTester tester, {
    List<Override> Function(String url)? more,
    bool panes = false,
    bool keys = false,
  }) async {
    HttpOverrides.global = null;
    (server, session) = (await tester.runAsync(() async {
      final server = await FakeServer.start();
      server.handle = (_) => ok(const <String, Object?>{});
      return (server, await testSession(server));
    }))!;
    db = AppDatabase(DatabaseConnection(NativeDatabase.memory()));
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          serverSessionProvider(server.url.toString())
              .overrideWith((ref) async => session),
          railSelectionProvider.overrideWith(_Rail.new),
          ...?more?.call(server.url.toString()),
          serverImageCachesProvider(server.url.toString())
              .overrideWith((ref) => Completer<ServerImageCaches>().future),
          userProfileProvider(
            server.url.toString(),
            _pat.id,
          ).overrideWith((ref) => Stream.value(_pat)),
          profileRefreshProvider(
            server.url.toString(),
            _pat.id,
          ).overrideWith((ref) async {}),
        ],
        child: Consumer(
          builder: (context, ref, _) => MaterialApp(
            theme: MatterleastApp.lightTheme,
            navigatorObservers: [ref.watch(conversationRoutesProvider)],
            builder: keys ? (_, child) => AppShortcuts(child: child!) : null,
            home: Consumer(
              builder: (context, ref, _) {
                widgetRef = ref;
                container = ProviderScope.containerOf(context);
                const list = Scaffold(
                  body: ReopenSwipe(child: SizedBox.expand()),
                );
                final layout = panes ? const PaneLayout(list: list) : list;
                return keys
                    ? RootShortcuts(onSwitcher: () {}, child: layout)
                    : layout;
              },
            ),
          ),
        ),
      ),
    );
    container.read(placeReconcilerProvider);
    await tester.runAsync(container.read(conversationMemoryProvider).start);
  }

  /// The server signed in and its channel list, [channelId] in it as
  /// [kind].
  List<Override> Function(String url) known({
    SwitchKind kind = SwitchKind.channel,
    Stream<List<SwitchItem>>? listed,
  }) =>
      (url) => [
        serversProvider.overrideWith((ref) {
          ref.keepAlive();
          return Stream.value([
            ServerEntry(
              url: url,
              displayName: 'Test',
              siteName: null,
              serverVersion: null,
              diagnosticId: null,
              lastActiveAt: DateTime(2026),
              ssoScheme: null,
            ),
          ]);
        }),
        switchItemsProvider(url).overrideWith((ref) {
          ref.keepAlive();
          return listed ??
              Stream.value([
                SwitchItem(
                  serverUrl: url,
                  kind: kind,
                  id: channelId,
                  title: 'Boats',
                  teamId: teamId,
                ),
              ]);
        }),
      ];

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

  NavigatorState navigator(WidgetTester tester) =>
      tester.state<NavigatorState>(find.byType(Navigator).first);

  Future<void> open(
    WidgetTester tester, {
    String channel = channelId,
    String? rootId,
    String? highlight,
  }) async {
    unawaited(
      openConversation(
        navigator(tester),
        url: server.url.toString(),
        channelId: channel,
        title: 'Boats',
        teamId: teamId,
        rootId: rootId,
        highlightPostId: highlight,
      ),
    );
    await settle(tester);
  }

  Future<void> back(WidgetTester tester) async {
    navigator(tester).pop();
    await settle(tester);
  }

  /// A page such as a channel's info or its pinned messages.
  Future<void> page(WidgetTester tester, String title) async {
    unawaited(
      navigator(tester).push(
        SlideRoute<void>(
          builder: (_) => Scaffold(appBar: AppBar(title: Text(title))),
        ),
      ),
    );
    await settle(tester);
  }

  Finder conversations() => find.byWidgetPredicate(
    (w) => w is ChannelScreen || w is ThreadScreen,
    skipOffstage: false,
  );

  /// The user may post, so the composer shows.
  Future<void> mayPost(WidgetTester tester) => tester.runAsync(() async {
    await session.db.setSyncText(SyncKeys.currentUserRoles, 'system_user');
    await session.store.applyRoles([
      api.Role.fromJson({
        'id': 'rl000000000000000000000r01',
        'name': 'system_user',
        'permissions': ['create_post'],
      }),
    ]);
  });

  /// Whether the composer of the [screen] on top has the keyboard.
  bool typingIn(WidgetTester tester, Type screen) {
    final field = find.descendant(
      of: find.byType(screen),
      matching: find.byType(EditableText),
    );
    return tester.widget<EditableText>(field).focusNode.hasFocus &&
        tester.testTextInput.isVisible;
  }

  testWidgets('a message picked under a channel\'s info opens in that '
      'channel, and one Back leads to the list', (tester) async {
    await start(tester);
    await open(tester);
    await page(tester, 'Info');
    await page(tester, 'Pinned');
    await open(tester, highlight: 'old1');
    expect(find.text('Pinned'), findsNothing);
    expect(conversations(), findsOneWidget);
    expect(
      tester.widget<ChannelScreen>(find.byType(ChannelScreen)).highlightPostId,
      'old1',
    );
    await back(tester);
    expect(conversations(), findsNothing);
    expect(find.byType(ReopenSwipe), findsOneWidget);
    await finish(tester);
  });

  testWidgets('a direct message opened at a message names the other person', (
    tester,
  ) async {
    await start(tester);
    await tester.runAsync(() async {
      await session.db.setSyncText(SyncKeys.currentUserId, _me);
      await session.store.applyUsers([
        api.User.fromJson({
          'id': _pat.id,
          'username': 'pat',
          'first_name': 'Pat',
          'last_name': 'Doe',
        }),
      ]);
      await session.store.applyChannel(
        api.Channel.fromJson({
          'id': _directId,
          'type': 'D',
          'name': '${_pat.id}__$_me',
          'display_name': '',
        }),
      );
      await session.store.applyChannelMember(
        api.ChannelMember.fromJson({
          'channel_id': _directId,
          'user_id': _me,
          'roles': '',
        }),
      );
    });
    unawaited(
      openConversation(
        navigator(tester),
        url: server.url.toString(),
        channelId: _directId,
        title: '',
        highlightPostId: 'old1',
      ),
    );
    await settle(tester);
    expect(
      find.descendant(
        of: find.byType(ChannelScreen),
        matching: find.textContaining('pat'),
      ),
      findsWidgets,
    );
    await back(tester);
    await finish(tester);
  });

  testWidgets('another conversation takes the place of the open one', (
    tester,
  ) async {
    await start(tester);
    await open(tester);
    await open(tester, rootId: 'old1');
    await page(tester, 'Profile');
    await open(tester, channel: _directId);
    expect(conversations(), findsOneWidget);
    expect(
      tester.widget<ChannelScreen>(find.byType(ChannelScreen)).channelId,
      _directId,
    );
    await back(tester);
    expect(conversations(), findsNothing);
    await finish(tester);
  });

  group('Esc on a wide window', () {
    final desktop = TargetPlatformVariant.only(TargetPlatform.linux);

    Future<void> focusIn(WidgetTester tester, Type screen) async {
      tester
          .widget<Focus>(
            find
                .descendant(
                  of: find.byType(screen),
                  matching: find.byWidgetPredicate(
                    (w) => w is Focus && w.focusNode?.debugLabel == 'Region',
                  ),
                )
                .first,
          )
          .focusNode!
          .requestFocus();
      await tester.pump();
    }

    Future<void> esc(WidgetTester tester) async {
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);
    }

    testWidgets('closes the thread, then the channel, from the message list', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await start(tester, panes: true, keys: true);
      await open(tester);
      await open(tester, rootId: 'old1');
      expect(find.byType(ThreadScreen), findsOneWidget);
      await focusIn(tester, ThreadScreen);
      await esc(tester);
      expect(find.byType(ThreadScreen), findsNothing);
      expect(find.byType(ChannelScreen), findsOneWidget);
      await focusIn(tester, ChannelScreen);
      await esc(tester);
      expect(find.byType(ChannelScreen), findsNothing);
      await finish(tester);
      await tester.pump(Duration.zero);
    }, variant: desktop);

    testWidgets('from an empty composer the first Esc leaves it, the second '
        'closes the thread', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await start(tester, panes: true, keys: true);
      await mayPost(tester);
      await open(tester);
      await open(tester, rootId: 'old1');
      final field = find.descendant(
        of: find.byType(ThreadScreen),
        matching: find.byType(EditableText),
      );
      tester.widget<EditableText>(field).focusNode.requestFocus();
      await tester.pump();
      await esc(tester);
      expect(tester.widget<EditableText>(field).focusNode.hasFocus, isFalse);
      expect(find.byType(ThreadScreen), findsOneWidget);
      await esc(tester);
      expect(find.byType(ThreadScreen), findsNothing);
      closeConversations(navigator(tester));
      await settle(tester);
      await finish(tester);
      await tester.pump(Duration.zero);
    }, variant: desktop);
  });

  testWidgets('a thread opens over its channel; a right swipe goes back to '
      'the channel, the next to the list', (tester) async {
    await start(tester);
    await open(tester);
    await open(tester, rootId: 'old1');
    expect(find.byType(ThreadScreen), findsOneWidget);
    await tester.fling(find.byType(ThreadScreen), const Offset(300, 0), 1000);
    await settle(tester);
    expect(find.byType(ThreadScreen), findsNothing);
    expect(find.byType(ChannelScreen), findsOneWidget);
    await open(tester, rootId: 'old1');
    await open(tester, rootId: 'old2');
    await back(tester);
    expect(find.byType(ChannelScreen), findsOneWidget);
    expect(find.byType(ThreadScreen), findsNothing);
    await back(tester);
    expect(conversations(), findsNothing);
    await finish(tester);
  });

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

  testWidgets("Message in someone's profile opens the direct message", (
    tester,
  ) async {
    await start(tester);
    server.handle = (request) => request.path == '/api/v4/channels/direct'
        ? ok({
            'id': _directId,
            'type': 'D',
            'name': '${_pat.id}__$meId',
            'display_name': '',
          })
        : ok(const <String, Object?>{});
    unawaited(
      showUserProfile(
        tester.element(find.byType(Scaffold)),
        url: server.url.toString(),
        userId: _pat.id,
      ),
    );
    await settle(tester);
    await tester.tap(find.text('Message'));
    await settle(tester);
    expect(find.byType(UserProfileSheet), findsNothing);
    expect(find.byType(ChannelScreen), findsOneWidget);
    expect(
      tester.widget<ChannelScreen>(find.byType(ChannelScreen)).channelId,
      _directId,
    );
    navigator(tester).pop();
    await settle(tester);
    await finish(tester);
  });

  testWidgets('a left swipe brings back the conversation just closed', (
    tester,
  ) async {
    await start(tester, more: known());
    unawaited(
      openConversation(
        navigator(tester),
        url: server.url.toString(),
        channelId: channelId,
        title: 'Boats',
        teamId: teamId,
        highlightPostId: 'old1',
      ),
    );
    await settle(tester);
    navigator(tester).pop();
    await settle(tester);
    expect(find.byType(ChannelScreen), findsNothing);
    await tester.drag(find.byType(ReopenSwipe), const Offset(-200, 0));
    await settle(tester);
    final screen = tester.widget<ChannelScreen>(find.byType(ChannelScreen));
    expect(screen.channelId, channelId);
    expect(screen.highlightPostId, isNull);
    navigator(tester).pop();
    await settle(tester);
    await finish(tester);
  });

  testWidgets('an agent citation link opens its post highlighted', (
    tester,
  ) async {
    const postId = 'harbourpost0000000000000a1';
    await start(tester, more: known());
    await tester.runAsync(
      () => session.store.applyChannelPage(
        channelId: channelId,
        page: api.PostList.fromJson({
          'order': [postId],
          'posts': {
            postId: {
              'id': postId,
              'channel_id': channelId,
              'user_id': 'someone',
              'create_at': DateTime.utc(
                2026,
                10,
                25,
                10,
              ).millisecondsSinceEpoch,
              'message': 'cited',
            },
          },
        }),
        kind: PageKind.page,
      ),
    );
    // The rail keeps the server list alive in the app.
    final servers = container.listen(serversProvider, (_, _) {});
    addTearDown(servers.close);
    await settle(tester);
    unawaited(
      openLinkFromMessage(
        navigator(tester),
        server.url.replace(
          path: '/_redirect/pl/$postId',
          query: 'view=citation',
        ),
      ),
    );
    await settle(tester);
    expect(
      tester.widget<ChannelScreen>(find.byType(ChannelScreen)).highlightPostId,
      postId,
    );
    navigator(tester).pop();
    await settle(tester);
    await finish(tester);
  });

  testWidgets('a tapped notification opens its conversation', (tester) async {
    await start(tester, more: known());
    final opening = openNotice(
      navigator(tester),
      widgetRef,
      NoticeTarget(
        serverUrl: server.url.toString(),
        channelId: channelId,
        postId: 'old1',
        newestAt: DateTime(2026),
      ),
    );
    await settle(tester);
    expect(
      tester.widget<ChannelScreen>(find.byType(ChannelScreen)).highlightPostId,
      'old1',
    );
    navigator(tester).pop();
    await settle(tester);
    await opening;
    await finish(tester);
  });

  testWidgets("a left swipe doesn't bring back a channel the user left", (
    tester,
  ) async {
    await start(tester, more: known(kind: SwitchKind.joinable));
    await open(tester);
    await back(tester);
    await tester.drag(find.byType(ReopenSwipe), const Offset(-200, 0));
    await settle(tester);
    expect(conversations(), findsNothing);
    await finish(tester);
  });

  testWidgets('leaving a channel closes it and its thread in the panes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await start(tester);
    await open(tester);
    await open(tester, rootId: 'old1');
    expect(container.read(openPanesProvider).isEmpty, isFalse);
    closeChannel(
      navigator(tester),
      url: server.url.toString(),
      channelId: channelId,
    );
    expect(container.read(openPanesProvider).isEmpty, isTrue);
    await finish(tester);
  });

  testWidgets('leaving a channel closes its routes and its threads', (
    tester,
  ) async {
    await start(tester);
    await open(tester);
    await open(tester, rootId: 'old1');
    closeChannel(
      navigator(tester),
      url: server.url.toString(),
      channelId: channelId,
    );
    await settle(tester);
    expect(conversations(), findsNothing);
    await finish(tester);
  });

  testWidgets('a restored channel opens like any other: team picked, '
      'remembered, and a left swipe brings it back', (tester) async {
    await start(
      tester,
      more: (url) => [
        serversProvider.overrideWith((ref) {
          ref.keepAlive();
          return Stream.value([
            ServerEntry(
              url: url,
              displayName: 'Test',
              siteName: null,
              serverVersion: null,
              diagnosticId: null,
              lastActiveAt: DateTime(2026),
              ssoScheme: null,
            ),
          ]);
        }),
        switchItemsProvider(url).overrideWith((ref) {
          ref.keepAlive();
          return Stream.value([
            SwitchItem(
              serverUrl: url,
              kind: SwitchKind.channel,
              id: channelId,
              title: 'Boats',
              teamId: teamId,
            ),
          ]);
        }),
      ],
    );
    final url = server.url.toString();
    await tester.runAsync(() async {
      await db.writeSetting(
        Settings.lastRailTarget.key,
        '{"url":"$url","teamId":"$teamId"}',
      );
      await db.writeSetting(
        Settings.openConversations.key,
        '{"open":{"$url $teamId":{"url":"$url","channelId":"$channelId",'
        '"title":"Old","teamId":"$teamId"}}}',
      );
    });
    container
      ..listen(serversProvider, (_, _) {})
      ..listen(switchItemsProvider(url), (_, _) {});
    await tester.pump();
    final restoring = restoreConversation(
      widgetRef,
      navigator(tester),
      launchedByIntent: Future.value(false),
    );
    await settle(tester);
    await restoring;
    expect(find.byType(ChannelScreen), findsOneWidget);
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
    expect(find.byType(ChannelScreen), findsNothing);
    await tester.drag(find.byType(ReopenSwipe), const Offset(-200, 0));
    await settle(tester);
    expect(find.byType(ChannelScreen), findsOneWidget);
    navigator(tester).pop();
    await settle(tester);
    await finish(tester);
  });

  group('each team keeps its own conversation', () {
    const shipsId = 'ch000000000000000000000c02';
    const otherTeam = 'tm000000000000000000000t02';
    late StreamController<List<SwitchItem>> listed;

    List<SwitchItem> channels(String url, {bool boats = true}) => [
      if (boats)
        SwitchItem(
          serverUrl: url,
          kind: SwitchKind.channel,
          id: channelId,
          title: 'Boats',
          teamId: teamId,
        ),
      SwitchItem(
        serverUrl: url,
        kind: SwitchKind.channel,
        id: shipsId,
        title: 'Ships',
        teamId: otherTeam,
      ),
    ];

    Future<String> begin(WidgetTester tester) async {
      listed = StreamController<List<SwitchItem>>.broadcast();
      addTearDown(listed.close);
      await start(
        tester,
        more: (url) => [
          ...known(listed: listed.stream)(url),
          railTeamsProvider(url).overrideWith(
            (ref) => Stream.value([
              for (final id in [teamId, otherTeam])
                RailTeam(id: id, displayName: id, unread: false, mentions: 0),
            ]),
          ),
        ],
      );
      final url = server.url.toString();
      container.listen(switchItemsProvider(url), (_, _) {});
      listed.add(channels(url));
      return url;
    }

    Future<void> show(WidgetTester tester, String url, String team) async {
      unawaited(
        showPlace(navigator(tester), RailTarget(url: url, teamId: team)),
      );
      await settle(tester);
    }

    String? shownChannel(WidgetTester tester) => tester
        .widgetList<ChannelScreen>(
          find.byType(ChannelScreen, skipOffstage: false),
        )
        .map((w) => w.channelId)
        .firstOrNull;

    Future<void> openShips(WidgetTester tester, String url) async {
      unawaited(
        openConversation(
          navigator(tester),
          url: url,
          channelId: shipsId,
          title: 'Ships',
          teamId: otherTeam,
        ),
      );
      await settle(tester);
    }

    Future<void> step(WidgetTester tester, {required bool forward}) async {
      unawaited(stepHistory(container, forward: forward));
      await settle(tester);
    }

    testWidgets('Back and Forward walk what was opened, across teams', (
      tester,
    ) async {
      final url = await begin(tester);
      await open(tester);
      await openShips(tester, url);
      expect(container.read(railSelectionProvider)?.teamId, otherTeam);
      await step(tester, forward: false);
      expect(shownChannel(tester), channelId);
      expect(container.read(railSelectionProvider)?.teamId, teamId);
      await step(tester, forward: true);
      expect(shownChannel(tester), shipsId);
      expect(container.read(railSelectionProvider)?.teamId, otherTeam);
      await step(tester, forward: false);
      await open(tester, channel: _directId);
      await step(tester, forward: true);
      expect(shownChannel(tester), _directId);
      await finish(tester);
    });

    testWidgets('Back skips a channel that is gone', (tester) async {
      final url = await begin(tester);
      await open(tester);
      await openShips(tester, url);
      listed.add(channels(url, boats: false));
      await settle(tester);
      await step(tester, forward: false);
      expect(shownChannel(tester), isNull, reason: 'Home, not the lost one');
      await step(tester, forward: true);
      expect(shownChannel(tester), shipsId);
      await finish(tester);
    });

    testWidgets('switching team closes the open conversation, and switching '
        'back opens it again', (tester) async {
      final url = await begin(tester);
      await open(tester);
      await show(tester, url, otherTeam);
      expect(conversations(), findsNothing);
      await show(tester, url, teamId);
      expect(shownChannel(tester), channelId);
      await show(tester, url, otherTeam);
      await finish(tester);
    });

    testWidgets("a team shows what was open in it, never another team's", (
      tester,
    ) async {
      final url = await begin(tester);
      await open(tester);
      await show(tester, url, otherTeam);
      unawaited(
        openConversation(
          navigator(tester),
          url: url,
          channelId: shipsId,
          title: 'Ships',
          teamId: otherTeam,
        ),
      );
      await settle(tester);
      expect(shownChannel(tester), shipsId);
      await show(tester, url, teamId);
      expect(shownChannel(tester), channelId);
      await show(tester, url, otherTeam);
      expect(shownChannel(tester), shipsId);
      await finish(tester);
    });

    testWidgets('a channel left since shows the list instead', (tester) async {
      final url = await begin(tester);
      await open(tester);
      await show(tester, url, otherTeam);
      listed.add(channels(url, boats: false));
      await settle(tester);
      await show(tester, url, teamId);
      expect(conversations(), findsNothing);
      await finish(tester);
    });

    testWidgets("the swipe back brings only this team's closed "
        'conversation', (tester) async {
      final url = await begin(tester);
      await open(tester);
      await back(tester);
      await show(tester, url, otherTeam);
      await tester.drag(find.byType(ReopenSwipe), const Offset(-200, 0));
      await settle(tester);
      expect(conversations(), findsNothing);
      await show(tester, url, teamId);
      await tester.drag(find.byType(ReopenSwipe), const Offset(-200, 0));
      await settle(tester);
      expect(shownChannel(tester), channelId);
      // The harness hangs closing a reopened conversation's database.
      await show(tester, url, otherTeam);
      await finish(tester);
    });

    testWidgets('on a wide window the panes follow the team, channel and '
        'thread', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final url = await begin(tester);
      await open(tester);
      await open(tester, rootId: 'old1');
      expect(container.read(openPanesProvider).thread?.rootId, 'old1');
      await show(tester, url, otherTeam);
      expect(container.read(openPanesProvider).isEmpty, isTrue);
      await show(tester, url, teamId);
      final panes = container.read(openPanesProvider);
      expect(panes.channel?.channelId, channelId);
      expect(panes.thread?.rootId, 'old1');
      await finish(tester);
    });
  });

  testWidgets('a channel, a thread and the Threads list have headers of '
      'one height', (tester) async {
    Rect header(Type screen) => tester.getRect(
      find.descendant(of: find.byType(screen), matching: find.byType(AppBar)),
    );
    await start(tester);
    await open(tester);
    final channel = header(ChannelScreen);
    await open(tester, rootId: 'old1');
    expect(header(ThreadScreen).height, channel.height);
    await back(tester);
    unawaited(
      openPage(
        navigator(tester),
        TeamThreadsScreen(
          url: server.url.toString(),
          teamId: teamId,
          teamName: 'Harbor',
        ),
      ),
    );
    await settle(tester);
    expect(header(TeamThreadsScreen).height, channel.height);
    await back(tester);
    await back(tester);
    await finish(tester);
  });

  group('the Threads list', () {
    List<Override> threadsOf(String url) => [
      teamThreadsProvider(url, teamId).overrideWith(
        (ref) => Stream.value([
          InboxItem(
            serverUrl: url,
            kind: InboxKind.thread,
            channelId: channelId,
            teamId: teamId,
            title: 'Slipway repairs',
            avatarName: 'wren',
            author: 'wren',
            preview: 'Needs two more planks',
            place: '#boats',
            time: DateTime.utc(2026, 3, 1, 9),
            count: 0,
            unread: false,
            rootId: 'old1',
          ),
        ]),
      ),
      syncStatusProvider(url)
          .overrideWith((ref) => const Stream<SyncStatus>.empty()),
      knownPresenceProvider(url).overrideWithValue(const {}),
      featuresProvider(url)
          .overrideWith((ref) => Stream.value(const ServerFeatures())),
    ];

    Future<void> openList(WidgetTester tester) async {
      unawaited(
        openPage(
          navigator(tester),
          TeamThreadsScreen(
            url: server.url.toString(),
            teamId: teamId,
            teamName: 'Harbor',
          ),
        ),
      );
      await settle(tester);
    }

    Future<void> pickThread(WidgetTester tester) async {
      await tester.tap(find.textContaining('Slipway repairs'));
      await settle(tester);
    }

    testWidgets('on a large window a picked thread opens beside the list', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await start(tester, panes: true, more: threadsOf);
      await openList(tester);
      await pickThread(tester);
      expect(find.byType(TeamThreadsScreen), findsOneWidget);
      expect(find.byType(ThreadScreen), findsOneWidget);
      expect(
        tester.getRect(find.byType(ThreadScreen)).left,
        greaterThan(tester.getRect(find.byType(TeamThreadsScreen)).left),
        reason: 'in the thread pane',
      );
      closeConversations(navigator(tester));
      await settle(tester);
      await finish(tester);
      await tester.pump(Duration.zero);
    });

    testWidgets('on a phone a picked thread slides in over the list', (
      tester,
    ) async {
      await start(tester, more: threadsOf);
      await openList(tester);
      await pickThread(tester);
      expect(find.byType(ThreadScreen), findsOneWidget);
      await back(tester);
      expect(find.byType(ThreadScreen), findsNothing);
      await finish(tester);
    });

    testWidgets("the channel in a thread's header opens that channel", (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await start(tester, panes: true);
      await open(tester);
      await open(tester, rootId: 'old1');
      expect(find.byType(ThreadScreen), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: find.byType(ThreadScreen),
          matching: find.textContaining('Boats', findRichText: true),
        ),
      );
      // Frame by frame: no step may leave the panes without the channel.
      for (var i = 0; i < 3; i++) {
        await tester.pump();
        final panes = container.read(openPanesProvider);
        expect(panes.channel?.channelId, channelId);
        expect(panes.thread, isNull);
        expect(find.text('No conversation open'), findsNothing);
      }
      await settle(tester);
      expect(find.byType(ThreadScreen), findsNothing);
      expect(find.byType(ChannelScreen), findsOneWidget);
      closeConversations(navigator(tester));
      await settle(tester);
      await finish(tester);
      await tester.pump(Duration.zero);
    });
  });

  testWidgets('on a wide window the channel and thread header strips line '
      'up', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Rect header(Type screen) => tester.getRect(
      find.descendant(
        of: find.byType(screen, skipOffstage: false),
        matching: find.byType(AppBar, skipOffstage: false),
      ),
    );
    await start(tester, panes: true);
    await open(tester);
    await open(tester, rootId: 'old1');
    final channel = header(ChannelScreen);
    final thread = header(ThreadScreen);
    expect(thread.left, greaterThan(channel.left), reason: 'side by side');
    expect(thread.top, channel.top);
    expect(thread.height, channel.height);
    closeConversations(navigator(tester));
    await settle(tester);
    await finish(tester);
    // Drift closes the pane's queries on a zero timer.
    await tester.pump(Duration.zero);
  });

  testWidgets('on a wide window the thread pane closes at the end of its '
      'header', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await start(tester, panes: true);
    await open(tester);
    await open(tester, rootId: 'old1');
    final thread = find.byType(ThreadScreen);
    final close = find.descendant(
      of: thread,
      matching: find.byTooltip('Close the thread'),
    );
    final title = find.descendant(of: thread, matching: find.text('Thread'));
    expect(
      tester.getRect(close).left,
      greaterThan(tester.getRect(title).right),
    );
    expect(
      tester.getRect(close).right,
      closeTo(tester.getRect(thread).right, 24),
      reason: 'at the pane edge',
    );
    closeConversations(navigator(tester));
    await settle(tester);
    await finish(tester);
    await tester.pump(Duration.zero);
  });

  testWidgets('suggestions float above the composer; the list keeps its size', (
    tester,
  ) async {
    await start(tester);
    await tester.runAsync(() async {
      await session.db.setSyncText(SyncKeys.currentUserRoles, 'system_user');
      await session.store.applyRoles([
        api.Role.fromJson({
          'id': 'rl000000000000000000000r01',
          'name': 'system_user',
          'permissions': ['create_post'],
        }),
      ]);
    });
    unawaited(
      openConversation(
        navigator(tester),
        url: server.url.toString(),
        channelId: channelId,
        title: 'Boats',
        teamId: teamId,
      ),
    );
    await settle(tester);
    final list = find.byType(ConversationView);
    final field = find.byType(TextField);
    final before = tester.getRect(list);

    await tester.enterText(field, ':smil');
    await settle(tester);

    final suggestions = find.byType(SuggestionList);
    expect(suggestions, findsOneWidget);
    expect(tester.getRect(list), before);
    expect(
      tester.getBottomLeft(suggestions).dy,
      lessThanOrEqualTo(tester.getTopLeft(field).dy),
    );
    await tester.tap(find.textContaining(':smile:').first);
    await settle(tester);
    expect(suggestions, findsNothing);
    // The pick replaced the typed word.
    expect(tester.widget<TextField>(field).controller!.text, isNot(':smil'));
    navigator(tester).pop();
    await settle(tester);
    await finish(tester);
  });

  testWidgets('Reply in the message menu opens the thread ready to type; '
      'tapping the message opens it with the keyboard down', (tester) async {
    await start(tester);
    await mayPost(tester);
    await open(tester);
    await tester.longPress(find.text('morning'));
    await settle(tester);
    await tester.tap(find.text('Reply'));
    await settle(tester);
    expect(find.byType(ThreadScreen), findsOneWidget);
    expect(typingIn(tester, ThreadScreen), isTrue);
    await back(tester);
    expect(find.byType(ThreadScreen), findsNothing);
    expect(tester.testTextInput.isVisible, isFalse);
    await tester.tap(find.text('morning'));
    await settle(tester);
    expect(find.byType(ThreadScreen), findsOneWidget);
    expect(tester.testTextInput.isVisible, isFalse);
    await back(tester);
    await back(tester);
    await finish(tester);
  });

  testWidgets('closing the message menu gives the keyboard back to the '
      'composer it was in', (tester) async {
    await start(tester);
    await mayPost(tester);
    await open(tester);
    await tester.showKeyboard(find.byType(TextField));
    await settle(tester);
    await tester.longPress(find.text('morning'));
    await settle(tester);
    expect(tester.testTextInput.isVisible, isFalse);
    navigator(tester).pop();
    await settle(tester);
    expect(typingIn(tester, ChannelScreen), isTrue);
    await back(tester);
    await finish(tester);
  });

  testWidgets('a notification for a thread of the open channel opens over '
      'it, and Back leads to the channel', (tester) async {
    await start(tester, more: known());
    await open(tester);
    await page(tester, 'Info');
    unawaited(
      openNotice(
        navigator(tester),
        widgetRef,
        NoticeTarget(
          serverUrl: server.url.toString(),
          channelId: channelId,
          rootId: 'old1',
          postId: 'old1',
          newestAt: DateTime(2026),
        ),
      ),
    );
    await settle(tester);
    expect(find.byType(ThreadScreen), findsOneWidget);
    expect(find.text('Info', skipOffstage: false), findsNothing);
    await back(tester);
    expect(find.byType(ChannelScreen), findsOneWidget);
    await back(tester);
    expect(conversations(), findsNothing);
    await finish(tester);
  });

  testWidgets('a notification for another channel opens over the list, not '
      'over the page that was open', (tester) async {
    await start(tester, more: known());
    await page(tester, 'Settings');
    unawaited(
      openNotice(
        navigator(tester),
        widgetRef,
        NoticeTarget(
          serverUrl: server.url.toString(),
          channelId: channelId,
          postId: 'old1',
          newestAt: DateTime(2026),
        ),
      ),
    );
    await settle(tester);
    expect(find.byType(ChannelScreen), findsOneWidget);
    await back(tester);
    expect(conversations(), findsNothing);
    expect(find.text('Settings'), findsNothing);
    await finish(tester);
  });

  testWidgets('a notification for a channel not stored yet opens it from '
      'the server', (tester) async {
    await start(tester, more: known());
    server.handle = (request) => switch (request.path) {
      '/api/v4/posts/new1/info' => ok({
        'channel_id': _directId,
        'channel_type': 'D',
        'channel_display_name': 'pat',
        'has_joined_channel': true,
        'team_id': '',
      }),
      '/api/v4/posts/new1' => ok({
        'id': 'new1',
        'channel_id': _directId,
        'user_id': _pat.id,
        'message': 'hello there',
        'create_at': DateTime.utc(2026, 10, 26).millisecondsSinceEpoch,
      }),
      _ => ok(const <String, Object?>{}),
    };
    unawaited(
      openNotice(
        navigator(tester),
        widgetRef,
        NoticeTarget(
          serverUrl: server.url.toString(),
          channelId: _directId,
          postId: 'new1',
          newestAt: DateTime(2026),
        ),
      ),
    );
    await settle(tester);
    expect(
      tester.widget<ChannelScreen>(find.byType(ChannelScreen)).channelId,
      _directId,
    );
    await back(tester);
    await finish(tester);
  });

  testWidgets('a message link the server takes a while to find says it is '
      'opening, then opens it', (tester) async {
    await start(tester);
    final found = Completer<void>();
    server.handle = (request) async {
      if (request.path == '/api/v4/posts/far1/info') {
        await found.future;
        return ok({
          'channel_id': channelId,
          'team_id': teamId,
          'has_joined_team': true,
          'has_joined_channel': true,
          'channel_display_name': 'Boats',
        });
      }
      if (request.path == '/api/v4/posts/far1') {
        return ok({
          'id': 'far1',
          'channel_id': channelId,
          'user_id': 'someone',
          'message': 'far back',
          'create_at': DateTime.utc(2026, 1, 2).millisecondsSinceEpoch,
        });
      }
      return ok(const <String, Object?>{});
    };
    unawaited(openPost(navigator(tester), server.url.toString(), 'far1'));
    var said = false;
    for (var i = 0; i < 20 && !said; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      said = find.text('Opening the message…').evaluate().isNotEmpty;
    }
    expect(said, isTrue);
    found.complete();
    await settle(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Opening the message…'), findsNothing);
    expect(
      tester.widget<ChannelScreen>(find.byType(ChannelScreen)).highlightPostId,
      'far1',
    );
    await back(tester);
    await finish(tester);
  });

  testWidgets('going back to a conversation that is open completes once it '
      'closes', (tester) async {
    await start(tester);
    await open(tester);
    var closed = false;
    unawaited(
      openConversation(
        navigator(tester),
        url: server.url.toString(),
        channelId: channelId,
        title: 'Boats',
        teamId: teamId,
      ).then((_) => closed = true),
    );
    await settle(tester);
    expect(find.byType(ChannelScreen), findsOneWidget);
    expect(closed, isFalse);
    await back(tester);
    expect(closed, isTrue);
    await finish(tester);
  });

  group('removed from an open channel', () {
    late StreamController<List<SwitchItem>> listed;

    Future<void> startListing(WidgetTester tester) async {
      listed = StreamController.broadcast();
      addTearDown(listed.close);
      await start(tester, more: known(listed: listed.stream));
      final gone = GoneChannels(widgetRef, navigator(tester))..start();
      addTearDown(gone.dispose);
    }

    SwitchItem boats() => SwitchItem(
      serverUrl: server.url.toString(),
      kind: SwitchKind.channel,
      id: channelId,
      title: 'Boats',
      teamId: teamId,
    );

    testWidgets('the channel, its thread and the pages over them close, and '
        'the user is told', (tester) async {
      await startListing(tester);
      await open(tester);
      await open(tester, rootId: 'old1');
      await page(tester, 'Thread info');
      listed.add([boats()]);
      await settle(tester);
      expect(find.text('Thread info'), findsOneWidget);
      listed.add(const []);
      await settle(tester);
      expect(conversations(), findsNothing);
      expect(find.text('Thread info'), findsNothing);
      expect(find.text('You were removed from Boats.'), findsOneWidget);
      await finish(tester);
    });

    testWidgets('a conversation opened before its channel is listed stays', (
      tester,
    ) async {
      await startListing(tester);
      await open(tester);
      listed.add(const []);
      await settle(tester);
      expect(find.byType(ChannelScreen), findsOneWidget);
      await back(tester);
      await finish(tester);
    });
  });
}

const _me = 'me0000000000000000000000m1';
const _directId = 'dm000000000000000000000d01';

const _pat = UserProfile(
  id: 'pt000000000000000000000p01',
  name: 'Pat Doe',
  username: 'pat',
  nickname: '',
  firstName: 'Pat',
  lastName: 'Doe',
  position: '',
  status: 'online',
  isBot: false,
  isMe: false,
);
