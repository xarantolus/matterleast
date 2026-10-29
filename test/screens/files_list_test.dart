import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/screens/channel/channel_screen.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:matterleast/screens/search/search_results_screen.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';
import '../support/test_session.dart';

/// Remembers what was picked without touching settings.
class _Rail extends RailSelection {
  @override
  RailTarget? build() => null;

  @override
  void select(RailTarget? target) => state = target;
}

void main() {
  late ServerHarness h;

  Future<void> start(WidgetTester tester) async {
    h = await pumpWithServer(
      tester,
      handle: (_) => ok(const <String, Object?>{}),
      seed: (session) async {
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
      },
      overrides: (url) => [railSelectionProvider.overrideWith(_Rail.new)],
      home: (url) => SearchResultsScreen(
        url: url,
        teamId: teamId,
        query: 'harbour',
        files: true,
      ),
    );
  }

  testWidgets(
    'tapping a file in the Files list opens the file, not the channel',
    (tester) async {
      await start(tester);
      await tester.tap(find.text('harbour.txt'));
      await h.settle(tester, rounds: 20);
      expect(find.byType(ChannelScreen), findsNothing);
      await h.close(tester);
    },
  );

  testWidgets('the one action a file has is a button that opens its '
      'message', (tester) async {
    await start(tester);
    expect(find.byTooltip('More'), findsNothing);
    await tester.tap(find.byTooltip('Jump to message'));
    await h.settle(tester, rounds: 20);
    final screen = tester.widget<ChannelScreen>(find.byType(ChannelScreen));
    expect(screen.highlightPostId, 'pic1');
    Navigator.of(tester.element(find.byType(ChannelScreen))).pop();
    await h.settle(tester, rounds: 20);
    await h.close(tester);
  });
}
