import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/domain/inbox.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/screens/home/home_pane.dart';
import 'package:matterleast/screens/home/home_providers.dart';
import 'package:matterleast/screens/root/root_providers.dart';

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

InboxItem _item() => InboxItem(
  serverUrl: _url,
  kind: InboxKind.group,
  channelId: 'c',
  teamId: null,
  title: 'Ada',
  avatarName: 'Ada',
  author: null,
  preview: 'Hello there',
  place: null,
  time: DateTime.utc(2026, 1, 1),
  count: 3,
  unread: true,
);

ServerInbox _inbox(List<InboxItem> unread) => ServerInbox(
  unread: unread,
  mentions: const [],
  threads: const [],
  saved: const [],
  known: InboxFilter.values.toSet(),
);

class _Filter extends HomeFilterSelection {
  _Filter(this.initial);
  final InboxFilter initial;

  @override
  InboxFilter build() => initial;
}

Future<void> _show(
  WidgetTester tester, {
  ServerInbox? inbox,
  SyncStatus? status,
  InboxFilter filter = InboxFilter.unread,
}) async {
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        serverSessionProvider(_url)
            .overrideWith((ref) => Completer<ServerSession>().future),
        serverInboxProvider(_url).overrideWith(
          (ref) => inbox == null ? const Stream.empty() : Stream.value(inbox),
        ),
        syncStatusProvider(_url).overrideWith(
          (ref) => status == null ? const Stream.empty() : Stream.value(status),
        ),
        homeFilterSelectionProvider.overrideWith(() => _Filter(filter)),
      ],
      child: MaterialApp(
        theme: MatterleastApp.lightTheme,
        home: const Scaffold(body: HomePane(servers: [_server])),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

double _scrollExtent(WidgetTester tester) => tester
    .state<ScrollableState>(
      find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          )
          .first,
    )
    .position
    .maxScrollExtent;

void main() {
  for (final filter in InboxFilter.values) {
    testWidgets('an empty ${filter.name} list has nothing to scroll to', (
      tester,
    ) async {
      await _show(tester, inbox: _inbox(const []), filter: filter);
      expect(_scrollExtent(tester), 0);
    });
  }

  testWidgets('a failed first load has nothing to scroll to', (tester) async {
    await _show(
      tester,
      status: SyncFailed(cause: const Unreachable(), at: DateTime.utc(2026)),
    );
    expect(find.text('Retry'), findsOneWidget);
    expect(_scrollExtent(tester), 0);
  });

  testWidgets('rows end the same distance from the edge as the channel list', (
    tester,
  ) async {
    await _show(tester, inbox: _inbox([_item()]));
    final tile = tester.getRect(find.byType(ListTile));
    final badge = tester.getRect(find.byType(Badge));
    expect(tile.right - badge.right, 12);
  });
}
