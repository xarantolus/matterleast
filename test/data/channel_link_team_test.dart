import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/actions/message_links.dart';
import 'package:matterleast/data/servers/server_session.dart';

import '../support/test_session.dart';

void main() {
  late ServerSession session;

  setUp(() async {
    (_, session) = await startServerSession();
  });

  test('~name in one team never opens the same name in another', () async {
    await session.store.applyChannels(
      channels: [
        api.Channel.fromJson({
          'id': 'other00000000000000000c002',
          'team_id': 'tm000000000000000000000t02',
          'type': 'O',
          'name': 'deck',
          'display_name': 'Deck',
        }),
      ],
      members: [
        api.ChannelMember.fromJson({
          'channel_id': 'other00000000000000000c002',
          'user_id': meId,
        }),
      ],
    );
    final links = MessageLinks(session);
    expect(await links.channelNamed('deck', teamId: teamId), isNull);
    expect((await links.channelNamed('boats', teamId: teamId))?.id, channelId);
    expect(
      (await links.channelNamed('deck'))?.id,
      'other00000000000000000c002',
    );
  });
}
