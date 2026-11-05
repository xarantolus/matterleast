import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/agent_providers.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/screens/channel_list/channel_list_pane.dart';
import 'package:matterleast/screens/channel_list/channel_list_state.dart';
import 'package:matterleast/screens/drafts/drafts_providers.dart';

import '../../support/pump_app.dart';

const _url = 'https://chat.example.test';

ChannelItem _row(String id, {bool unread = false}) => ChannelItem(
  id: id,
  title: id,
  kind: ChannelKind.public,
  unread: unread,
  mentions: 0,
  muted: false,
  favorite: false,
  hasDraft: false,
);

CategorySection _section(String id, List<ChannelItem> rows) => CategorySection(
  id: id,
  title: id,
  kind: CategoryKind.custom,
  collapsed: false,
  rows: rows,
);

void main() {
  testWidgets('an unread channel scrolled far above stays above', (
    tester,
  ) async {
    await pumpApp(
      tester,
      Scaffold(
        body: ChannelListPane(
          url: _url,
          teamId: 't1',
          serverLabel: 'Example',
          state: ChannelListReady(
            ChannelList(
              teamName: 'Harbour',
              sections: [
                _section('Favourites', [_row('f1'), _row('f2')]),
                _section('Projects', [
                  _row('p1'),
                  _row('p2', unread: true),
                  for (var i = 3; i < 10; i++) _row('p$i'),
                ]),
                _section('Channels', [
                  for (var i = 0; i < 60; i++) _row('c$i'),
                ]),
              ],
              unreadThreads: 0,
              drafts: 0,
              synced: true,
            ),
            refreshing: false,
          ),
        ),
      ),
      overrides: [
        teamScheduledProvider(
          _url,
          't1',
        ).overrideWith((ref) => Stream.value([])),
        agentsAvailableProvider(_url).overrideWithValue(true),
      ],
    );
    await tester.pump();
    final list = find.byType(CustomScrollView);
    for (var step = 0; step < 12; step++) {
      await tester.drag(list, const Offset(0, -300));
      await tester.pump();
      await tester.pump();
      if (find.text('p2').evaluate().isNotEmpty) continue;
      expect(find.byIcon(Icons.arrow_downward), findsNothing, reason: '$step');
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget, reason: '$step');
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
