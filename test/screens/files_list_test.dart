import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/domain/message_search.dart';
import 'package:matterleast/screens/channel/channel_screen.dart';
import 'package:matterleast/screens/gallery/gallery_screen.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:matterleast/screens/search/search_results_screen.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';
import '../support/rail.dart';
import '../support/servers.dart';
import '../support/test_session.dart';

const _bobId = 'us0000000000000000000000bob';

Map<String, Object?> _file(
  String id,
  String name,
  String ext,
  String mime, {
  int size = 1200,
  bool picture = false,
  String user = meId,
  required DateTime at,
}) => {
  'id': id,
  'user_id': user,
  'post_id': 'pic1',
  'channel_id': channelId,
  'create_at': at.millisecondsSinceEpoch,
  'name': name,
  'extension': ext,
  'mime_type': mime,
  'size': size,
  if (picture) ...{'width': 40, 'height': 30, 'has_preview_image': true},
};

void main() {
  late ServerHarness h;

  final files = [
    _file(
      'f1',
      'harbour.png',
      'png',
      'image/png',
      picture: true,
      user: _bobId,
      at: DateTime.utc(2025, 10, 25, 10),
    ),
    _file(
      'f2',
      'dunes.png',
      'png',
      'image/png',
      picture: true,
      user: _bobId,
      at: DateTime.utc(2025, 10, 24, 10),
    ),
    _file(
      'f3',
      'report.pdf',
      'pdf',
      'application/pdf',
      size: 52000,
      at: DateTime.utc(2025, 10, 23, 10),
    ),
  ];

  Future<void> start(
    WidgetTester tester, {
    List<Map<String, Object?>>? found,
    Reply? answer,
    FutureOr<Reply?> Function(SeenRequest request)? serve,
  }) async {
    h = await pumpWithServer(
      tester,
      handle:
          serve ??
          (r) => r.path.endsWith('/files/search')
              ? answer ??
                    ok({
                      'order': [for (final f in found ?? files) f['id']],
                      'file_infos': {
                        for (final f in found ?? files) f['id']: f,
                      },
                    })
              : emptyAnswer(r),
      seed: (session) async {
        await session.store.applyUsers([
          api.User.fromJson({'id': _bobId, 'username': 'bobby'}),
        ]);
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
                  2025,
                  10,
                  25,
                  10,
                ).millisecondsSinceEpoch,
                'message': '',
              },
            },
          }),
          fetchedAt: DateTime.utc(2025, 10, 25, 11),
        );
      },
      overrides: (url) => [
        railSelectionProvider.overrideWith(MemoryRailSelection.new),
        serversOverride([testServerEntry(url, name: 'Test')]),
      ],
      home: (url) => SearchResultsScreen(
        url: url,
        teamId: teamId,
        query: '',
        files: true,
        scope: const SearchScope(
          teamId: teamId,
          channelId: channelId,
          channelName: 'town',
          channelLabel: '#Town',
        ),
      ),
    );
    await h.settle(tester);
  }

  testWidgets('pictures show as tiles and documents as rows with their type, '
      'size and sender', (tester) async {
    await start(tester);
    expect(find.byTooltip('harbour.png'), findsOneWidget);
    expect(find.byTooltip('dunes.png'), findsOneWidget);
    expect(find.text('report.pdf'), findsOneWidget);
    expect(find.text('PDF'), findsOneWidget);
    expect(find.textContaining('51 KB', findRichText: true), findsOneWidget);
    expect(find.textContaining('river', findRichText: true), findsOneWidget);
    expect(find.text('OCTOBER 2025'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('a file type chip asks the server for those files', (
    tester,
  ) async {
    await start(tester);
    await tester.tap(find.text('Documents'));
    await h.settle(tester);
    final terms = h.server.seen
        .where((r) => r.path.endsWith('/files/search'))
        .last
        .body['terms'];
    expect(terms, allOf(contains('in:town'), contains('ext:pdf')));
    await h.close(tester);
  });

  testWidgets('a tapped picture opens the gallery, which swipes to the next '
      'picture of the channel', (tester) async {
    await start(tester);
    await tester.tap(find.byTooltip('harbour.png'));
    await h.settle(tester);
    expect(find.byType(GalleryScreen), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);
    // The bar names who sent this file, who has no row in the list.
    expect(find.text('bobby'), findsOneWidget);
    await tester.fling(find.byType(GalleryScreen), const Offset(-600, 0), 1500);
    await h.settle(tester);
    expect(find.text('2 / 2'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('the file menu opens the file in its channel', (tester) async {
    await start(tester);
    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    expect(find.text('Copy link'), findsOneWidget);
    await tester.tap(find.text('Open in channel'));
    await h.settle(tester);
    final screen = tester.widget<ChannelScreen>(find.byType(ChannelScreen));
    expect(screen.highlightPostId, 'pic1');
    Navigator.of(tester.element(find.byType(ChannelScreen))).pop();
    await h.settle(tester);
    await h.close(tester);
  });

  testWidgets('a picture in the gallery opens in its channel', (tester) async {
    await start(tester);
    await tester.tap(find.byTooltip('harbour.png'));
    await h.settle(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(GalleryScreen),
        matching: find.byTooltip('More'),
      ),
    );
    await h.settle(tester);
    await tester.tap(find.text('Open in channel'));
    await h.settle(tester);
    expect(find.byType(GalleryScreen), findsNothing);
    final screen = tester.widget<ChannelScreen>(find.byType(ChannelScreen));
    expect(screen.highlightPostId, 'pic1');
    Navigator.of(tester.element(find.byType(ChannelScreen))).pop();
    await h.settle(tester);
    await h.close(tester);
  });

  testWidgets('a channel without files says how they get there', (
    tester,
  ) async {
    await start(tester, found: const []);
    expect(find.text('No files yet'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('a failed first load shows the server message and Retry', (
    tester,
  ) async {
    await start(tester, answer: error(500, 'files_are_down'));
    expect(find.textContaining('files_are_down'), findsWidgets);
    expect(find.text('Retry'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('the next page loads at the end and appears below without '
      'moving what is shown', (tester) async {
    DateTime at(int i) =>
        DateTime.utc(2025, 10, 25, 10).subtract(Duration(minutes: i));
    String name(int i) => 'doc-${i.toString().padLeft(2, '0')}.pdf';
    Map<String, Object?> doc(int i) =>
        _file('d$i', name(i), 'pdf', 'application/pdf', at: at(i));
    final pages = <int>[];
    final second = Completer<void>();
    await start(
      tester,
      serve: (r) async {
        if (!r.path.endsWith('/files/search')) {
          return emptyAnswer(r);
        }
        final page = r.body['page']! as int;
        pages.add(page);
        if (page == 1) await second.future;
        final batch = page == 0
            ? [for (var i = 0; i < filePageSize; i++) doc(i)]
            : [for (var i = filePageSize; i < filePageSize + 3; i++) doc(i)];
        return ok({
          'order': [for (final f in batch) f['id']],
          'file_infos': {for (final f in batch) f['id']: f},
        });
      },
    );
    expect(pages, [0]);
    final list = find.byType(CustomScrollView);
    await tester.drag(list, const Offset(0, -20000));
    await h.settle(tester, until: () => pages.length > 1);
    expect(pages, [0, 1]);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    final last = find.text(name(filePageSize - 1));
    final before = tester.getTopLeft(last);
    second.complete();
    await h.settle(tester);
    expect(tester.getTopLeft(last), before);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    await tester.drag(list, const Offset(0, -20000));
    await h.settle(tester);
    expect(find.text(name(filePageSize + 2)), findsOneWidget);
    // The short page was the last.
    expect(pages, [0, 1]);
    await h.close(tester);
  });
}
