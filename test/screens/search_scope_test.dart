import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/message_search.dart';
import 'package:matterleast/domain/inbox.dart';
import 'package:matterleast/domain/message_search.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/server_features.dart';
import 'package:matterleast/screens/search/search_providers.dart';
import 'package:matterleast/screens/search/search_results_screen.dart';

import '../support/pump_app.dart';

const _a = 'https://a.example.test';
const _b = 'https://b.example.test';

ServerEntry _server(String url, String name) => ServerEntry(
  url: url,
  displayName: name,
  siteName: null,
  serverVersion: null,
  diagnosticId: null,
  lastActiveAt: DateTime.utc(2026),
  ssoScheme: null,
);

InboxItem _hit(String url, String id, String text, int minute) => InboxItem(
  serverUrl: url,
  kind: InboxKind.saved,
  channelId: 'c$id',
  teamId: 't',
  title: 'town',
  avatarName: 'town',
  author: 'wren',
  preview: text,
  place: null,
  time: DateTime.utc(2026, 1, 1, 0, minute),
  count: 0,
  unread: false,
  postId: id,
);

void main() {
  late List<String> asked;

  Future<void> show(
    WidgetTester tester, {
    required String? url,
    Set<String> failing = const {},
    Widget? home,
  }) async {
    asked = [];
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final hits = {
      _a: _hit(_a, 'a1', 'Boats from the first', 5),
      _b: _hit(_b, 'b1', 'Boats from the second', 9),
    };
    await pumpApp(
      tester,
      home ??
          SearchResultsScreen(
            url: url,
            teamId: url == null ? '' : 't',
            query: 'boat',
          ),
      overrides: [
        serversProvider.overrideWith(
          (ref) => Stream.value([_server(_a, 'First'), _server(_b, 'Second')]),
        ),
        for (final u in [_a, _b]) ...[
          featuresProvider(u).overrideWith(
            (ref) => Stream.value(const ServerFeatures(crossTeamSearch: true)),
          ),
          currentTeamProvider(u).overrideWith((ref) async => 't'),
          messageSearchProvider(u)
              .overrideWith((ref) => Completer<MessageSearch>().future),
        ],
        localPostResultsProvider.overrideWith((ref, args) async => const []),
        serverPostResultsProvider.overrideWith((ref, args) async {
          asked.add(args.$1);
          if (failing.contains(args.$1)) throw const Unreachable();
          return [hits[args.$1]!.postId!];
        }),
        searchPostItemsProvider.overrideWith(
          (ref, args) => Stream.value([
            for (final h in hits.values)
              if (h.serverUrl == args.$1 && h.postId == args.$2) h,
          ]),
        ),
      ],
    );
    await tester.pumpAndSettle();
  }

  testWidgets('from Home both servers are searched, newest first, labelled', (
    tester,
  ) async {
    await show(tester, url: null);
    expect(asked, unorderedEquals([_a, _b]));
    final newer = tester.getTopLeft(find.textContaining('second'));
    final older = tester.getTopLeft(find.textContaining('first'));
    expect(newer.dy, lessThan(older.dy));
    expect(find.textContaining('Second'), findsWidgets);
    expect(find.textContaining('First'), findsWidgets);
    await closeApp(tester);
  });

  testWidgets('inside one server only that server is searched', (tester) async {
    await show(tester, url: _a);
    expect(asked, [_a]);
    expect(find.textContaining('first'), findsOneWidget);
    expect(find.textContaining('second'), findsNothing);
    await closeApp(tester);
  });

  testWidgets('a failing server is named and the others still show', (
    tester,
  ) async {
    await show(tester, url: null, failing: {_b});
    expect(find.textContaining('first'), findsOneWidget);
    expect(find.textContaining("Couldn't search Second"), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.textContaining('No results'), findsNothing);
    await closeApp(tester);
  });

  testWidgets('the search button opens message search with the field focused', (
    tester,
  ) async {
    await show(
      tester,
      url: _a,
      home: Scaffold(
        appBar: AppBar(
          actions: const [MessageSearchButton(url: _a, teamId: 't')],
        ),
      ),
    );
    await tester.tap(find.byTooltip('Search messages'));
    await tester.pumpAndSettle();
    final field = tester.widget<EditableText>(find.byType(EditableText));
    expect(field.focusNode.hasFocus, isTrue);
    expect(find.text('Messages'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('a server answering late adds its files below the ones shown', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    FileHit file(String id, String name, int minute) => FileHit(
      id: id,
      name: name,
      extension: 'txt',
      mimeType: 'text/plain',
      size: 10,
      postId: 'p$id',
      channelId: 'c',
      place: '#town',
      createAt: DateTime.utc(2026, 1, 1, 0, minute),
    );
    final late = Completer<List<FileHit>>();
    await pumpApp(
      tester,
      const SearchResultsScreen(
        url: null,
        teamId: '',
        query: 'boat',
        files: true,
      ),
      overrides: [
        serversProvider.overrideWith(
          (ref) => Stream.value([_server(_a, 'First'), _server(_b, 'Second')]),
        ),
        for (final u in [_a, _b]) ...[
          featuresProvider(u).overrideWith(
            (ref) => Stream.value(const ServerFeatures(crossTeamSearch: true)),
          ),
          currentTeamProvider(u).overrideWith((ref) async => 't'),
          messageSearchProvider(u)
              .overrideWith((ref) => Completer<MessageSearch>().future),
        ],
        localFileResultsProvider.overrideWith((ref, args) async => const []),
        serverFileResultsProvider.overrideWith(
          (ref, args) => args.$1 == _a
              ? Future.value([file('a1', 'first.txt', 5)])
              : late.future,
        ),
      ],
    );
    // B is still loading, so its progress bar keeps animating.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('first.txt'), findsOneWidget);
    final before = tester.getTopLeft(find.text('first.txt'));

    late.complete([file('b1', 'second.txt', 9)]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.getTopLeft(find.text('first.txt')), before);
    expect(
      tester.getTopLeft(find.text('second.txt')).dy,
      greaterThan(before.dy),
    );
    expect(find.text('MORE FROM SECOND'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('submitting an empty message search asks the server', (
    tester,
  ) async {
    await show(
      tester,
      url: _a,
      home: const SearchResultsScreen(url: _a, teamId: 't', query: ''),
    );
    expect(asked, isEmpty);
    expect(find.text('Search messages and files'), findsOneWidget);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(asked, [_a]);
    expect(find.textContaining('first'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('a person filter alone searches without words', (tester) async {
    await show(
      tester,
      url: _a,
      home: const SearchResultsScreen(
        url: _a,
        teamId: 't',
        query: '',
        scope: SearchScope(teamId: 't', username: 'wren'),
      ),
    );
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(asked, [_a]);
    expect(find.textContaining('first'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('opening Files with no words lists the server files', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpApp(
      tester,
      const SearchResultsScreen(url: _a, teamId: 't', query: '', files: true),
      overrides: [
        serversProvider.overrideWith((ref) => Stream.value([_server(_a, 'A')])),
        featuresProvider(_a).overrideWith(
          (ref) => Stream.value(const ServerFeatures(crossTeamSearch: true)),
        ),
        currentTeamProvider(_a).overrideWith((ref) async => 't'),
        messageSearchProvider(_a)
            .overrideWith((ref) => Completer<MessageSearch>().future),
        localFileResultsProvider.overrideWith((ref, args) async => const []),
        serverFileResultsProvider.overrideWith(
          (ref, args) async => [
            FileHit(
              id: 'f1',
              name: 'plan.txt',
              extension: 'txt',
              mimeType: 'text/plain',
              size: 10,
              postId: 'p1',
              channelId: 'c',
              place: '#town',
              createAt: DateTime.utc(2026, 1, 1),
            ),
          ],
        ),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.text('plan.txt'), findsOneWidget);
    await closeApp(tester);
  });
}
