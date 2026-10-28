import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/live_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/domain/inbox.dart';
import 'package:matterleast/domain/server_features.dart';
import 'package:matterleast/screens/home/home_providers.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/threads/team_threads_screen.dart';
import 'package:matterleast/ui/slide_route.dart';

const _url = 'https://chat.example.test';

Finder row(String title) => find.textContaining(title, findRichText: true);

InboxItem _thread(String root, {required bool unread}) => InboxItem(
  serverUrl: _url,
  kind: InboxKind.thread,
  channelId: 'c1',
  teamId: 't1',
  title: root,
  avatarName: 'wren',
  author: 'wren',
  preview: 'See you at the slipway',
  place: '#town-square',
  time: DateTime.utc(2026, 3, 1, 9),
  count: unread ? 2 : 0,
  unread: unread,
  rootId: root,
);

Future<void> _open(WidgetTester tester, List<InboxItem> threads) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        serverSessionProvider(_url)
            .overrideWith((ref) => Completer<ServerSession>().future),
        teamThreadsProvider(
          _url,
          't1',
        ).overrideWith((ref) => Stream.value(threads)),
        syncStatusProvider(_url)
            .overrideWith((ref) => const Stream<SyncStatus>.empty()),
        knownPresenceProvider(_url).overrideWithValue(const {}),
        featuresProvider(_url)
            .overrideWith((ref) => Stream.value(const ServerFeatures())),
      ],
      child: MaterialApp(
        theme: MatterleastApp.lightTheme,
        home: const Scaffold(body: Text('Channels')),
      ),
    ),
  );
  unawaited(
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .push(
          SlideRoute<void>(
            builder: (_) => const TeamThreadsScreen(
              url: _url,
              teamId: 't1',
              teamName: 'Harbour',
            ),
          ),
        ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a swipe left shows the unread threads; a swipe right on All '
      'goes back', (tester) async {
    await _open(tester, [
      _thread('Kayak rack', unread: false),
      _thread('Tide tables', unread: true),
    ]);
    expect(row('Kayak rack'), findsOneWidget);
    expect(row('Tide tables'), findsOneWidget);

    await tester.fling(row('Kayak rack'), const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    expect(row('Kayak rack'), findsNothing);
    expect(row('Tide tables'), findsOneWidget);

    await tester.fling(row('Tide tables'), const Offset(300, 0), 1000);
    await tester.pumpAndSettle();
    expect(row('Kayak rack'), findsOneWidget);
    expect(find.text('Threads · Harbour'), findsOneWidget);

    await tester.fling(row('Kayak rack'), const Offset(300, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Threads · Harbour'), findsNothing);
    expect(find.text('Channels'), findsOneWidget);
  });

  testWidgets('each tab keeps where it was scrolled to', (tester) async {
    await _open(tester, [
      for (var i = 0; i < 40; i++) _thread('Buoy $i.', unread: i.isOdd),
    ]);
    await tester.drag(row('Buoy 3.'), const Offset(0, -1500));
    await tester.pumpAndSettle();
    final first = row('Buoy 0.');
    expect(first, findsNothing);
    final shown = tester.getTopLeft(row('Buoy 20.')).dy;

    await tester.tap(find.text('Unread'));
    await tester.pumpAndSettle();
    expect(row('Buoy 1.'), findsOneWidget);
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(first, findsNothing);
    expect(tester.getTopLeft(row('Buoy 20.')).dy, shown);
  });
}
