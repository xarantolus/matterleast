import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/views/conversation_views.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

void main() {
  late ServerSession session;

  setUp(() async {
    (_, session) = await startServerSession();
  });

  test('a direct message acts in the current team', () async {
    const dm = 'dm00000000000000000000d001';
    await session.store.applyChannels(
      channels: [
        api.Channel.fromJson({
          'id': dm,
          'team_id': '',
          'type': 'D',
          'name': '${meId}__someone',
        }),
      ],
      members: [
        api.ChannelMember.fromJson({'channel_id': dm, 'user_id': meId}),
      ],
    );
    await session.db.setSyncText(SyncKeys.currentTeamId, teamId);
    final views = ConversationViews(session.db);
    final window = await views
        .channel(dm, limit: 30, deletedUpTo: DateTime.utc(2026))
        .first;
    expect(window.teamId, teamId);
    final inTeam = await views
        .channel(channelId, limit: 30, deletedUpTo: DateTime.utc(2026))
        .first;
    expect(inTeam.teamId, teamId);
  });
}
