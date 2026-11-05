import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/live_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/message_search.dart';
import 'package:matterleast/data/app_db/app_database.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/domain/inbox.dart';
import 'package:matterleast/domain/message_search.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/server_features.dart';
import 'package:matterleast/screens/home/home_pane.dart';
import 'package:matterleast/screens/home/home_providers.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/search/search_providers.dart';
import 'package:matterleast/screens/search/search_results_screen.dart';
import 'package:matterleast/screens/threads/team_threads_screen.dart';

import '../support/memory_database.dart';

const _url = 'https://chat.example.test';
const _server = ServerEntry(
  url: _url,
  displayName: 'Chat',
  siteName: null,
  serverVersion: null,
  diagnosticId: null,
  lastActiveAt: null,
  ssoScheme: null,
);

InboxItem _item(String title, {InboxKind kind = InboxKind.group}) => InboxItem(
  serverUrl: _url,
  kind: kind,
  channelId: 'c$title',
  teamId: 't1',
  title: title,
  avatarName: title,
  author: 'wren',
  preview: 'Hello there',
  place: null,
  time: DateTime.utc(2026, 1, 1),
  count: 1,
  unread: true,
  rootId: kind == InboxKind.thread ? title : null,
);

void main() {
  late AppDatabase db;
  ProviderContainer? current;

  setUp(() => db = memoryAppDatabase());
  tearDown(() => db.close());

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  /// Drift closes its queries on a zero timer.
  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    current?.dispose();
    current = null;
    await tester.pump(Duration.zero);
  }

  /// A fresh app run over the same database, like a restart.
  Future<void> launch(
    WidgetTester tester,
    Widget home,
    List<Override> overrides,
  ) async {
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await unmount(tester);
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db), ...overrides],
    );
    current = container;
    // The launch gate waits for these before the first frame.
    final warm = [
      container.listen(homeFilterSettingProvider, (_, _) {}),
      container.listen(searchTabProvider, (_, _) {}),
      container.listen(threadsTabProvider, (_, _) {}),
    ];
    await settle(tester);
    expect(warm.every((w) => w.read().hasValue), isTrue);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: MatterleastApp.lightTheme, home: home),
      ),
    );
    // Only the first frame: a saved choice must already show.
    await tester.pump();
  }

  final sessionPending = serverSessionProvider(_url)
      .overrideWith((ref) => Completer<ServerSession>().future);

  group('Home', () {
    Future<void> openHome(WidgetTester tester) =>
        launch(tester, const Scaffold(body: HomePane(servers: [_server])), [
          sessionPending,
          serverInboxProvider(_url).overrideWith(
            (ref) => Stream.value(
              ServerInbox(
                unread: [_item('Ada')],
                mentions: [_item('Mentioned in Dock')],
                threads: const [],
                saved: const [],
                known: InboxFilter.values.toSet(),
              ),
            ),
          ),
          syncStatusProvider(_url)
              .overrideWith((ref) => const Stream<SyncStatus>.empty()),
        ]);

    ChoiceChip chip(WidgetTester tester, String label) =>
        tester.widget(find.widgetWithText(ChoiceChip, label));

    testWidgets('the picked chip is still picked after a restart', (
      tester,
    ) async {
      await openHome(tester);
      expect(chip(tester, 'Unread').selected, isTrue);

      await tester.tap(find.text('Mentions'));
      await settle(tester);
      expect(find.text('Mentioned in Dock'), findsOneWidget);

      await openHome(tester);
      expect(chip(tester, 'Mentions').selected, isTrue);
      expect(find.text('Mentioned in Dock'), findsOneWidget);
      await unmount(tester);
    });
  });

  group('threads', () {
    Future<void> openThreads(WidgetTester tester) => launch(
      tester,
      const TeamThreadsScreen(url: _url, teamId: 't1', teamName: 'Harbour'),
      [
        sessionPending,
        teamThreadsProvider(_url, 't1').overrideWith(
          (ref) => Stream.value([
            _item('Kayak rack', kind: InboxKind.thread).copyWith(unread: false),
            _item('Tide tables', kind: InboxKind.thread),
          ]),
        ),
        syncStatusProvider(_url)
            .overrideWith((ref) => const Stream<SyncStatus>.empty()),
        knownPresenceProvider(_url).overrideWithValue(const {}),
        featuresProvider(_url)
            .overrideWith((ref) => Stream.value(const ServerFeatures())),
      ],
    );

    Finder row(String title) => find.textContaining(title, findRichText: true);

    testWidgets('the Unread tab is still shown after a restart', (
      tester,
    ) async {
      await openThreads(tester);
      expect(row('Kayak rack'), findsOneWidget);

      await tester.tap(find.text('Unread'));
      await tester.pumpAndSettle();
      await settle(tester);
      expect(row('Kayak rack'), findsNothing);

      await openThreads(tester);
      await tester.pumpAndSettle();
      expect(row('Kayak rack'), findsNothing);
      expect(row('Tide tables'), findsOneWidget);

      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      await settle(tester);
      await openThreads(tester);
      await tester.pumpAndSettle();
      expect(row('Kayak rack'), findsOneWidget);
      await unmount(tester);
    });
  });

  group('search', () {
    Future<void> openSearch(WidgetTester tester) => launch(
      tester,
      const SearchResultsScreen(url: _url, teamId: 't1', query: ''),
      [
        serversProvider.overrideWith((ref) => Stream.value([_server])),
        featuresProvider(_url).overrideWith(
          (ref) => Stream.value(const ServerFeatures(crossTeamSearch: true)),
        ),
        currentTeamProvider(_url).overrideWith((ref) async => 't1'),
        messageSearchProvider(_url)
            .overrideWith((ref) => Completer<MessageSearch>().future),
      ],
    );

    bool filesSelected(WidgetTester tester) => tester
        .widget<SegmentedButton<SearchTab>>(
          find.byType(SegmentedButton<SearchTab>),
        )
        .selected
        .contains(SearchTab.files);

    testWidgets('the Files tab is still picked after a restart', (
      tester,
    ) async {
      await openSearch(tester);
      expect(filesSelected(tester), isFalse);

      await tester.tap(find.text('Files'));
      await settle(tester);
      expect(filesSelected(tester), isTrue);

      await openSearch(tester);
      expect(filesSelected(tester), isTrue);
      expect(find.text('Search files'), findsWidgets);

      await tester.tap(find.text('Messages'));
      await settle(tester);
      await openSearch(tester);
      expect(filesSelected(tester), isFalse);
      await unmount(tester);
    });
  });

  test(
    'stored choices decode strictly and fall back to today\'s behaviour',
    () {
      expect(Settings.homeFilter.read(const {}), InboxFilter.unread);
      expect(Settings.searchTab.read(const {}), SearchTab.messages);
      expect(Settings.threadsTab.read(const {}), ThreadsTab.all);
      expect(
        Settings.homeFilter.read({
          Settings.homeFilter.key: Settings.homeFilter.encode(
            InboxFilter.saved,
          ),
        }),
        InboxFilter.saved,
      );
      expect(
        Settings.searchTab.read({Settings.searchTab.key: 'videos'}),
        SearchTab.messages,
      );
    },
  );
}
