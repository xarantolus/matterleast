import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/screens/channel/channel_screen.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';
import '../support/seed.dart';
import '../support/test_session.dart';

void main() {
  for (final (type, platform, typing) in [
    ('D', TargetPlatform.linux, true),
    ('G', TargetPlatform.windows, true),
    ('O', TargetPlatform.linux, false),
    ('D', TargetPlatform.android, false),
  ]) {
    final what = switch (type) {
      'D' => 'a direct message',
      'G' => 'a group message',
      _ => 'a channel',
    };
    testWidgets('$what opened on ${platform.name} '
        '${typing ? 'puts' : 'leaves'} the cursor in the composer', (
      tester,
    ) async {
      final h = await pumpWithServer(
        tester,
        platform: platform,
        handle: emptyAnswer,
        seed: (session) async {
          await seedMyPermissions(session, ['create_post']);
          await session.store.applyChannels(
            channels: [
              api.Channel.fromJson({
                'id': channelId,
                'team_id': type == 'O' ? teamId : '',
                'type': type,
                'name': 'boats',
                'display_name': 'Boats',
              }),
            ],
            members: [
              api.ChannelMember.fromJson({
                'channel_id': channelId,
                'user_id': meId,
              }),
            ],
          );
        },
        home: (url) =>
            ChannelScreen(url: url, channelId: channelId, title: 'Boats'),
      );

      expect(tester.testTextInput.hasAnyClients, typing);
      await h.close(tester);
    });
  }
}
