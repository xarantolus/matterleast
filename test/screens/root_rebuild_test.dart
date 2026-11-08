import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/root/root_screen.dart';

import '../support/pump_with_server.dart';
import '../support/rail.dart';
import '../support/servers.dart';
import '../support/test_session.dart';

const _team = 'team0000000000000000000000';

api.Channel _channel(String id, String name) => api.Channel.fromJson({
  'id': id,
  'team_id': _team,
  'type': 'O',
  'name': id,
  'display_name': name,
  'total_msg_count': 1,
});

Future<void> _channels(ServerSession session, List<api.Channel> channels) =>
    session.store.applyChannels(
      channels: channels,
      members: [
        for (final c in channels)
          api.ChannelMember.fromJson({
            'channel_id': c.id,
            'user_id': meId,
            'msg_count': 1,
          }),
      ],
      categories: api.OrderedSidebarCategories.fromJson({
        'order': ['channels'],
        'categories': [
          {
            'id': 'channels',
            'team_id': _team,
            'user_id': meId,
            'type': 'channels',
            'display_name': 'Channels',
            'channel_ids': [for (final c in channels) c.id],
          },
        ],
      }),
    );

void main() {
  testWidgets('a change in the channel list rebuilds the list, not the '
      'window around it', (tester) async {
    final harbour = _channel('harbour000000000000000000a', 'Harbour');
    final lighthouse = _channel('lighthouse0000000000000000', 'Lighthouse');
    final h = await pumpWithServer(
      tester,
      size: const Size(1400, 900),
      platform: TargetPlatform.linux,
      seed: (s) => _channels(s, [harbour, lighthouse]),
      overrides: (url) => [
        railSelectionProvider.overrideWith(
          () => MemoryRailSelection(RailTarget(url: url, teamId: _team)),
        ),
        railTeamsProvider(url).overrideWith(
          (ref) => Stream.value(const [
            RailTeam(
              id: _team,
              displayName: 'Crew',
              unread: false,
              mentions: 0,
            ),
          ]),
        ),
      ],
      home: (url) => RootScreen(servers: [testServerEntry(url)]),
    );
    await h.settle(tester, until: () => find.text('Lighthouse').tryEvaluate());
    expect(find.text('Lighthouse'), findsOneWidget);

    var rail = 0;
    debugProfileBuildsEnabled = true;
    FlutterTimeline.debugCollectionEnabled = true;
    try {
      FlutterTimeline.debugReset();
      await tester.runAsync(
        () => _channels(h.session, [
          harbour,
          _channel('lighthouse0000000000000000', 'Lighthouse Watch'),
        ]),
      );
      await h.settle(
        tester,
        until: () => find.text('Lighthouse Watch').tryEvaluate(),
      );
      rail = FlutterTimeline.debugCollect().getAggregated('TeamRail').count;
    } finally {
      debugProfileBuildsEnabled = false;
      FlutterTimeline.debugCollectionEnabled = false;
    }

    expect(find.text('Lighthouse Watch'), findsOneWidget);
    expect(rail, 0);
    await h.close(tester);
  });
}
