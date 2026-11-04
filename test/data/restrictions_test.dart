import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/actions/directory.dart';
import 'package:matterleast/data/actions/switch_search.dart';
import 'package:matterleast/data/views/switch_views.dart';
import 'package:matterleast/domain/permissions.dart';
import 'package:matterleast/domain/quick_switch.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

const _botId = 'bt0000000000000000000000b1';
const _privateId = 'pv0000000000000000000000p1';
const _publicId = 'pb0000000000000000000000p2';

Map<String, Object?> _channel(String id, String type, String name) => {
  'id': id,
  'team_id': teamId,
  'type': type,
  'name': name,
  'display_name': name,
  'total_msg_count': 1,
};

void main() {
  test('people search and the switcher list bots and yourself', () async {
    final (server, session) = await startServerSession();
    server.handle = (r) => switch (r.path) {
      '/api/v4/users/search' => ok([
        {'id': _botId, 'username': 'tidebot', 'is_bot': true},
        {'id': meId, 'username': 'river'},
      ]),
      _ => ok(const <Object?>[]),
    };
    final url = server.url.toString();

    final found = await Directory(session, serverUrl: url).searchPeople('t');
    expect(found, [_botId, meId]);

    final remote = await SwitchSearch(session, serverUrl: url).search('t');
    expect(remote.map((i) => i.id), containsAll([_botId, meId]));

    final local = await SwitchViews(session.db, serverUrl: url).items().first;
    expect(
      local.where((i) => i.kind == SwitchKind.person).map((i) => i.id),
      containsAll([_botId, meId]),
    );
  });

  group('browsing channels', () {
    late FakeServer server;
    late Directory directory;

    Future<void> start({required bool admin, int privateStatus = 200}) async {
      final (s, session) = await startServerSession();
      server = s;
      await session.store.applyMyRoles(admin ? 'system_admin' : 'system_user');
      await session.store.applyRoles([
        api.Role.fromJson({
          'id': '1',
          'name': 'system_admin',
          'permissions': [Permission.manageSystem],
        }),
        api.Role.fromJson({
          'id': '2',
          'name': 'system_user',
          'permissions': [],
        }),
      ]);
      server.handle = (r) => switch (r.path) {
        '/api/v4/teams/$teamId/channels' => ok([
          _channel(channelId, 'O', 'boats'),
          _channel(_publicId, 'O', 'quay'),
        ]),
        '/api/v4/teams/$teamId/channels/private' =>
          privateStatus == 200
              ? ok([_channel(_privateId, 'P', 'vault')])
              : error(privateStatus, 'not_allowed'),
        _ => ok(const <Object?>[]),
      };
      directory = Directory(session, serverUrl: server.url.toString());
    }

    test('joined and private channels are listed too', () async {
      await start(admin: true);
      final page = await directory.channels(teamId);
      final kinds = {for (final i in page.items) i.id: i.kind};
      expect(kinds, {
        channelId: SwitchKind.channel,
        _publicId: SwitchKind.joinable,
        _privateId: SwitchKind.joinable,
      });
    });

    test('private channels are not asked for without the permission', () async {
      await start(admin: false);
      final page = await directory.channels(teamId);
      expect(page.items.map((i) => i.id), isNot(contains(_privateId)));
      expect(
        server.paths,
        isNot(contains('/api/v4/teams/$teamId/channels/private')),
      );
    });

    for (final status in [403, 404, 501]) {
      test('a $status for the private list leaves the public ones', () async {
        await start(admin: true, privateStatus: status);
        final page = await directory.channels(teamId);
        expect(page.items.map((i) => i.id), [channelId, _publicId]);
      });
    }
  });
}
