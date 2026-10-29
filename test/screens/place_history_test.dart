import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/image_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/app_db/app_database.dart';
import 'package:matterleast/data/images/server_image_caches.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/store/server_store.dart' show PageKind;
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/screens/channel/channel_screen.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/root/conversation_memory.dart';
import 'package:matterleast/screens/root/open_history.dart';
import 'package:matterleast/screens/root/open_panes.dart';
import 'package:matterleast/screens/root/pane_layout.dart';
import 'package:matterleast/screens/root/place_reconciler.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:matterleast/screens/root/rail_switch.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/search/search_providers.dart';
import 'package:matterleast/screens/thread/thread_screen.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

/// Remembers what was picked without touching settings.
class _Rail extends RailSelection {
  @override
  RailTarget? build() => null;

  @override
  void select(RailTarget? target) => state = target;
}

const _xId = 'ch000000000000000000000c10';
const _yId = 'ch000000000000000000000c11';
const _zId = 'ch000000000000000000000c12';
const _otherTeam = 'tm000000000000000000000t02';

/// A message of channel [channel] that reads as its number.
String _text(String channel, int i) => '$channel message $i';

void main() {
  late FakeServer serverA;
  late FakeServer serverB;
  late ServerSession sessionA;
  late ServerSession sessionB;
  late ProviderContainer container;
  late AppDatabase db;
  late StreamController<List<ServerEntry>> servers;
  late Map<String, StreamController<List<SwitchItem>>> items;
  late Map<String, StreamController<List<RailTeam>>> railTeams;

  String urlA() => serverA.url.toString();
  String urlB() => serverB.url.toString();

  ServerEntry entry(String url) => ServerEntry(
    url: url,
    displayName: url,
    siteName: null,
    serverVersion: null,
    diagnosticId: null,
    lastActiveAt: DateTime(2026),
    ssoScheme: null,
  );

  List<SwitchItem> channelsOf(String url, {Set<String> without = const {}}) => [
    for (final (id, name) in [(_xId, 'x'), (_yId, 'y'), (_zId, 'z')])
      if (!without.contains(id))
        SwitchItem(
          serverUrl: url,
          kind: SwitchKind.channel,
          id: id,
          title: name,
          teamId: teamId,
        ),
  ];

  Future<void> seed(ServerSession session) async {
    final store = session.store;
    final channels = [
      for (final (id, name) in [(_xId, 'x'), (_yId, 'y'), (_zId, 'z')])
        api.Channel.fromJson({
          'id': id,
          'team_id': teamId,
          'type': 'O',
          'name': name,
          'display_name': name,
          'total_msg_count': 40,
        }),
    ];
    await store.applyChannels(
      channels: channels,
      members: [
        for (final c in channels)
          api.ChannelMember.fromJson({
            'channel_id': c.id,
            'user_id': meId,
            'msg_count': 40,
          }),
      ],
    );
    final start = DateTime.utc(2026, 10, 26, 8);
    for (final (id, name) in [(_xId, 'x'), (_yId, 'y'), (_zId, 'z')]) {
      Map<String, Object?> post(int i) => {
        'id': '$name$i',
        'channel_id': id,
        'user_id': 'someone',
        'create_at': start.add(Duration(minutes: i)).millisecondsSinceEpoch,
        'message': _text(name, i),
      };
      await store.applyChannelPage(
        channelId: id,
        page: api.PostList.fromJson({
          'order': [for (var i = 40; i >= 1; i--) '$name$i'],
          'posts': {for (var i = 1; i <= 40; i++) '$name$i': post(i)},
        }),
        kind: PageKind.page,
      );
    }
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> start(WidgetTester tester, {bool panes = false}) async {
    HttpOverrides.global = null;
    (serverA, serverB, sessionA, sessionB) = (await tester.runAsync(() async {
      final a = await FakeServer.start();
      final b = await FakeServer.start();
      for (final s in [a, b]) {
        s.handle = (_) => ok(const <String, Object?>{});
      }
      final sa = await testSession(a);
      final sb = await testSession(b);
      await seed(sa);
      await seed(sb);
      return (a, b, sa, sb);
    }))!;
    db = AppDatabase(DatabaseConnection(NativeDatabase.memory()));
    addTearDown(db.close);
    servers = StreamController<List<ServerEntry>>.broadcast();
    addTearDown(servers.close);
    items = {
      for (final u in [urlA(), urlB()])
        u: StreamController<List<SwitchItem>>.broadcast(),
    };
    railTeams = {
      for (final u in [urlA(), urlB()])
        u: StreamController<List<RailTeam>>.broadcast(),
    };
    addTearDown(() {
      for (final c in [...items.values, ...railTeams.values]) {
        unawaited(c.close());
      }
    });
    const team = RailTeam(
      id: teamId,
      displayName: 'Harbour',
      unread: false,
      mentions: 0,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          railSelectionProvider.overrideWith(_Rail.new),
          serversProvider.overrideWith((ref) {
            ref.keepAlive();
            return servers.stream;
          }),
          for (final (url, session) in [
            (urlA(), sessionA),
            (urlB(), sessionB),
          ]) ...[
            serverSessionProvider(url).overrideWith((ref) async => session),
            serverImageCachesProvider(url)
                .overrideWith((ref) => Completer<ServerImageCaches>().future),
            switchItemsProvider(url).overrideWith((ref) {
              ref.keepAlive();
              return items[url]!.stream;
            }),
            railTeamsProvider(url).overrideWith((ref) {
              ref.keepAlive();
              return railTeams[url]!.stream;
            }),
          ],
        ],
        child: Consumer(
          builder: (context, ref, _) => MaterialApp(
            theme: MatterleastApp.lightTheme,
            navigatorObservers: [ref.watch(conversationRoutesProvider)],
            home: Consumer(
              builder: (context, ref, _) {
                container = ProviderScope.containerOf(context);
                const list = Scaffold(body: SizedBox.expand());
                return panes ? const PaneLayout(list: list) : list;
              },
            ),
          ),
        ),
      ),
    );
    container
      ..listen(serversProvider, (_, _) {})
      ..read(placeReconcilerProvider);
    for (final u in [urlA(), urlB()]) {
      container
        ..listen(switchItemsProvider(u), (_, _) {})
        ..listen(railTeamsProvider(u), (_, _) {});
    }
    servers.add([entry(urlA()), entry(urlB())]);
    for (final u in [urlA(), urlB()]) {
      items[u]!.add(channelsOf(u));
      railTeams[u]!.add(const [team]);
    }
    await tester.runAsync(container.read(conversationMemoryProvider).start);
    await settle(tester);
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
    await tester.runAsync(() async {
      for (final (session, server) in [
        (sessionA, serverA),
        (sessionB, serverB),
      ]) {
        await closeTestSession(session);
        await server.close();
      }
    });
  }

  NavigatorState navigator(WidgetTester tester) =>
      tester.state<NavigatorState>(find.byType(Navigator).first);

  Future<void> open(
    WidgetTester tester,
    String url,
    String channel, {
    String? rootId,
    String? highlight,
  }) async {
    unawaited(
      openConversation(
        navigator(tester),
        url: url,
        channelId: channel,
        title: channel,
        teamId: teamId,
        rootId: rootId,
        highlightPostId: highlight,
      ),
    );
    await settle(tester);
  }

  Future<void> step(WidgetTester tester, {required bool forward}) async {
    unawaited(stepHistory(container, forward: forward));
    await settle(tester);
  }

  /// The channels and threads that show, as `url channel` and
  /// `url channel root`.
  List<String> shown(WidgetTester tester) => [
    for (final w in tester.widgetList(
      find.byWidgetPredicate(
        (w) => w is ChannelScreen || w is ThreadScreen,
        skipOffstage: false,
      ),
    ))
      switch (w) {
        ChannelScreen() => '${w.url} ${w.channelId}',
        ThreadScreen() => '${w.url} ${w.channelId} ${w.rootId}',
        _ => '',
      },
  ];

  /// Where each message of [channel] on screen is, by its number.
  Map<int, double> onScreen(WidgetTester tester, String channel) {
    final name = channel == _xId ? 'x' : (channel == _yId ? 'y' : 'z');
    final found = <int, double>{};
    for (var i = 1; i <= 40; i++) {
      final f = find.text(_text(name, i));
      if (f.evaluate().isEmpty) continue;
      final top = tester.getTopLeft(f.first).dy;
      if (top > 80 && top < 560) found[i] = top;
    }
    return found;
  }

  Future<void> scrollUp(WidgetTester tester, [double by = 500]) async {
    await tester.drag(find.byType(ChannelScreen).last, Offset(0, by));
    await settle(tester);
  }

  void expectSameSpot(Map<int, double> before, Map<int, double> after) {
    final common = before.keys.where(after.containsKey);
    expect(
      common,
      isNotEmpty,
      reason: 'the same messages show: $before vs $after',
    );
    for (final i in common) {
      expect(after[i], closeTo(before[i]!, 3), reason: 'message $i');
    }
  }

  RailTarget? place() => container.read(railSelectionProvider);

  group('history of places', () {
    testWidgets('Back and Forward walk servers, channels and a thread', (
      tester,
    ) async {
      await start(tester);
      await open(tester, urlA(), _xId);
      await scrollUp(tester);
      final atX = onScreen(tester, _xId);
      await open(tester, urlB(), _yId);
      await open(tester, urlB(), _yId, rootId: 'y5');
      expect(shown(tester), contains('${urlB()} $_yId y5'));

      await step(tester, forward: false);
      expect(shown(tester), ['${urlB()} $_yId']);
      expect(place()?.url, urlB());

      await step(tester, forward: false);
      expect(shown(tester), ['${urlA()} $_xId']);
      expect(place()?.url, urlA());
      expectSameSpot(atX, onScreen(tester, _xId));

      await step(tester, forward: true);
      expect(shown(tester), ['${urlB()} $_yId']);
      expect(place()?.url, urlB());

      await step(tester, forward: true);
      expect(shown(tester), contains('${urlB()} $_yId y5'));
      await finish(tester);
    });

    testWidgets('Back after a link returns to the message that held it', (
      tester,
    ) async {
      await start(tester);
      await open(tester, urlA(), _xId);
      await scrollUp(tester);
      final before = onScreen(tester, _xId);

      await open(tester, urlA(), _zId, highlight: 'z10');
      expect(shown(tester), ['${urlA()} $_zId']);
      expect(find.text(_text('z', 10)), findsOneWidget);

      await step(tester, forward: false);
      expect(shown(tester), ['${urlA()} $_xId']);
      expectSameSpot(before, onScreen(tester, _xId));

      await step(tester, forward: true);
      expect(shown(tester), ['${urlA()} $_zId']);
      expect(
        tester
            .widget<ChannelScreen>(find.byType(ChannelScreen))
            .highlightPostId,
        'z10',
      );
      expect(find.text(_text('z', 10)), findsOneWidget);
      await finish(tester);
    });

    testWidgets('a permalink to an older message in the same channel can be '
        'left with Back', (tester) async {
      await start(tester);
      await open(tester, urlA(), _xId);
      await scrollUp(tester, 300);
      final before = onScreen(tester, _xId);

      await open(tester, urlA(), _xId, highlight: 'x3');
      expect(find.text(_text('x', 3)), findsOneWidget);
      expect(onScreen(tester, _xId).keys, isNot(containsAll(before.keys)));

      await step(tester, forward: false);
      expect(shown(tester), ['${urlA()} $_xId']);
      expectSameSpot(before, onScreen(tester, _xId));
      await finish(tester);
    });

    testWidgets('a link in a thread reply: Back reopens the thread', (
      tester,
    ) async {
      await start(tester);
      await open(tester, urlA(), _xId);
      await open(tester, urlA(), _xId, rootId: 'x5');
      await open(tester, urlA(), _zId, highlight: 'z10');
      expect(shown(tester), ['${urlA()} $_zId']);

      await step(tester, forward: false);
      expect(shown(tester), contains('${urlA()} $_xId x5'));
      await finish(tester);
    });

    testWidgets('Back at the start and Forward at the end do nothing', (
      tester,
    ) async {
      await start(tester);
      await open(tester, urlA(), _xId);
      await step(tester, forward: true);
      expect(shown(tester), ['${urlA()} $_xId']);
      await step(tester, forward: false);
      expect(shown(tester), isEmpty, reason: 'Home before the first channel');
      await step(tester, forward: false);
      expect(shown(tester), isEmpty);
      expect(place(), isNull);
      expect(tester.takeException(), isNull);
      await finish(tester);
    });

    testWidgets('going somewhere new after Back drops what was ahead', (
      tester,
    ) async {
      await start(tester);
      await open(tester, urlA(), _xId);
      await open(tester, urlB(), _yId);
      await step(tester, forward: false);
      await open(tester, urlA(), _zId);
      await step(tester, forward: true);
      expect(shown(tester), ['${urlA()} $_zId']);
      await step(tester, forward: false);
      expect(shown(tester), ['${urlA()} $_xId']);
      await finish(tester);
    });

    testWidgets('a signed-out server and a channel that was left are '
        'skipped silently', (tester) async {
      await start(tester);
      await open(tester, urlA(), _xId);
      await open(tester, urlB(), _yId);
      await open(tester, urlA(), _zId);
      servers.add([entry(urlA())]);
      items[urlA()]!.add(channelsOf(urlA(), without: {_zId}));
      await settle(tester);
      await open(tester, urlA(), _xId, highlight: 'x30');
      await step(tester, forward: false);
      expect(shown(tester), [
        '${urlA()} $_xId',
      ], reason: 'not the left channel, not the signed-out server');
      expect(tester.takeException(), isNull);
      await finish(tester);
    });

    testWidgets('opening the same place twice in a row is one entry', (
      tester,
    ) async {
      await start(tester);
      await open(tester, urlA(), _xId);
      await open(tester, urlA(), _zId);
      await open(tester, urlA(), _zId);
      await step(tester, forward: false);
      expect(shown(tester), ['${urlA()} $_xId']);
      await finish(tester);
    });

    testWidgets('a message opened from Home: Back returns to Home', (
      tester,
    ) async {
      await start(tester);
      expect(place(), isNull);
      await open(tester, urlA(), _xId, highlight: 'x12');
      expect(shown(tester), ['${urlA()} $_xId']);
      await step(tester, forward: false);
      expect(shown(tester), isEmpty);
      expect(place(), isNull);
      await step(tester, forward: true);
      expect(shown(tester), ['${urlA()} $_xId']);
      await finish(tester);
    });

    testWidgets('on a phone the system Back still pops the thread, then the '
        'conversation', (tester) async {
      await start(tester);
      await open(tester, urlA(), _xId);
      await open(tester, urlA(), _xId, rootId: 'x5');
      expect(shown(tester), contains('${urlA()} $_xId x5'));
      await tester.binding.handlePopRoute();
      await settle(tester);
      expect(shown(tester), ['${urlA()} $_xId']);
      await tester.binding.handlePopRoute();
      await settle(tester);
      expect(shown(tester), isEmpty);
      await finish(tester);
    });
  });

  group('panes follow the place', () {
    final desktop = TargetPlatformVariant.only(TargetPlatform.linux);

    Future<void> wide(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await start(tester, panes: true);
    }

    testWidgets('signing in to a new server leaves no thread of the old one', (
      tester,
    ) async {
      await wide(tester);
      await open(tester, urlA(), _xId);
      await open(tester, urlA(), _xId, rootId: 'x5');
      expect(shown(tester), hasLength(2));
      container
          .read(railSelectionProvider.notifier)
          .select(RailTarget(url: urlB()));
      await settle(tester);
      expect(shown(tester), isEmpty);
      expect(container.read(openPanesProvider).isEmpty, isTrue);
      await finish(tester);
      await tester.pump(Duration.zero);
    }, variant: desktop);

    testWidgets('signing out of the shown server closes its conversation', (
      tester,
    ) async {
      await wide(tester);
      await open(tester, urlA(), _xId);
      servers.add([entry(urlB())]);
      await settle(tester);
      expect(shown(tester), isEmpty);
      await finish(tester);
      await tester.pump(Duration.zero);
    }, variant: desktop);

    testWidgets('leaving the shown team closes its conversation', (
      tester,
    ) async {
      await wide(tester);
      await open(tester, urlA(), _xId);
      expect(shown(tester), isNotEmpty);
      railTeams[urlA()]!.add(const [
        RailTeam(
          id: _otherTeam,
          displayName: 'Other',
          unread: false,
          mentions: 0,
        ),
      ]);
      await settle(tester);
      expect(shown(tester), isEmpty);
      await finish(tester);
      await tester.pump(Duration.zero);
    }, variant: desktop);

    testWidgets('opening from a notification, link or share into another '
        'place shows only that', (tester) async {
      await wide(tester);
      await open(tester, urlA(), _xId);
      await open(tester, urlA(), _xId, rootId: 'x5');
      await open(tester, urlB(), _yId);
      expect(shown(tester), ['${urlB()} $_yId']);
      await finish(tester);
      await tester.pump(Duration.zero);
    }, variant: desktop);

    testWidgets('Home and back: nothing of another place shows, and the '
        'place gets its own conversation back', (tester) async {
      await wide(tester);
      final a = RailTarget(url: urlA(), teamId: teamId);
      await open(tester, urlA(), _xId);
      unawaited(showPlace(navigator(tester), null));
      await settle(tester);
      expect(shown(tester), isEmpty);
      unawaited(showPlace(navigator(tester), a));
      await settle(tester);
      expect(shown(tester), ['${urlA()} $_xId']);
      await finish(tester);
      await tester.pump(Duration.zero);
    }, variant: desktop);

    testWidgets('history on a wide window: Back closes the thread and moves '
        'the rail', (tester) async {
      await wide(tester);
      await open(tester, urlA(), _xId);
      await open(tester, urlB(), _yId);
      await open(tester, urlB(), _yId, rootId: 'y5');
      expect(shown(tester), hasLength(2));
      await step(tester, forward: false);
      expect(shown(tester), ['${urlB()} $_yId']);
      await step(tester, forward: false);
      expect(shown(tester), ['${urlA()} $_xId']);
      expect(place()?.url, urlA());
      await step(tester, forward: true);
      await step(tester, forward: true);
      expect(shown(tester), hasLength(2));
      expect(shown(tester).last, '${urlB()} $_yId y5');
      await finish(tester);
      await tester.pump(Duration.zero);
    }, variant: desktop);
  });
}
