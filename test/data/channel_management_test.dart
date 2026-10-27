import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/views/channel_views.dart';
import 'package:matterleast/domain/channel_info.dart';
import 'package:matterleast/domain/permissions.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

Map<String, Object?> _channel({String type = 'O', int deleteAt = 0}) => {
  'id': channelId,
  'team_id': teamId,
  'type': type,
  'name': 'boats',
  'display_name': 'Boats',
  'delete_at': deleteAt,
  'total_msg_count': 1,
};

void main() {
  late FakeServer server;
  late ServerSession session;

  Future<ChannelInfo?> info() => ChannelViews(
    session.db,
    serverUrl: server.url.toString(),
  ).info(channelId).first;

  Future<void> start({required bool teamAdmin, int deleteAt = 0}) async {
    (server, session) = await startServerSession();
    await session.store.applyMyRoles('system_user');
    await session.store.applyTeams(
      [
        api.Team.fromJson({
          'id': teamId,
          'name': 'harbour',
          'display_name': 'Harbour',
        }),
      ],
      [
        api.TeamMember.fromJson({
          'team_id': teamId,
          'roles': teamAdmin ? 'team_user team_admin' : 'team_user',
        }),
      ],
    );
    await session.store.applyRoles([
      api.Role.fromJson({
        'id': '1',
        'name': 'team_admin',
        'permissions': [
          Permission.manageTeam,
          Permission.convertPublicToPrivate,
        ],
      }),
      api.Role.fromJson({'id': '2', 'name': 'team_user', 'permissions': []}),
      api.Role.fromJson({'id': '3', 'name': 'system_user', 'permissions': []}),
    ]);
    await session.store.applyChannel(
      api.Channel.fromJson(_channel(deleteAt: deleteAt)),
    );
  }

  test('an admin can unarchive an archived channel', () async {
    await start(teamAdmin: true, deleteAt: 1760000000000);
    expect((await info())!.canUnarchive, isTrue);
  });

  test('a member cannot unarchive an archived channel', () async {
    await start(teamAdmin: false, deleteAt: 1760000000000);
    expect((await info())!.canUnarchive, isFalse);
  });

  test('unarchiving brings the channel back', () async {
    await start(teamAdmin: true, deleteAt: 1760000000000);
    server.handle = (r) => ok(_channel());
    await session.channels.unarchive(channelId);
    expect(server.seen.single.path, '/api/v4/channels/$channelId/restore');
    final after = (await info())!;
    expect(after.archived, isFalse);
    expect(after.canUnarchive, isFalse);
  });

  test('converting to private turns the channel private', () async {
    await start(teamAdmin: true);
    expect((await info())!.canConvert, isTrue);
    server.handle = (r) => ok(_channel(type: 'P'));
    await session.channels.convertToPrivate(channelId);
    expect(server.seen.single.body['privacy'], 'P');
    final after = (await info())!;
    expect(after.type, 'P');
    expect(after.canConvert, isFalse);
  });

  test('a plain member is not offered the conversion', () async {
    await start(teamAdmin: false);
    expect((await info())!.canConvert, isFalse);
  });

  test('removing a member asks the server to take them out', () async {
    await start(teamAdmin: true);
    server.handle = (r) => ok({'status': 'OK'});
    await session.channels.removeMember(channelId, 'someone');
    expect(server.seen.first.method, 'DELETE');
    expect(
      server.seen.first.path,
      '/api/v4/channels/$channelId/members/someone',
    );
  });
}
