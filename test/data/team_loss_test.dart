import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/data/actions/team_actions.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/store/server_store.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';
import '../support/wait.dart';

const _dmId = 'ch000000000000000000000d01';
const _otherTeam = 'tm000000000000000000000t02';

void main() {
  late FakeServer server;
  late ServerSession session;

  setUp(() async {
    server = await FakeServer.start();
    server.handle = (_) => ok({'status': 'OK'});
    session = await testSession(server);
    await session.store.applyChannels(
      channels: [
        api.Channel.fromJson({
          'id': _dmId,
          'team_id': '',
          'type': 'D',
          'name': '${meId}__someone',
          'display_name': '',
        }),
      ],
      members: [
        api.ChannelMember.fromJson({'channel_id': _dmId, 'user_id': meId}),
      ],
    );
    for (final id in [channelId, _dmId]) {
      await session.store.saveDraft(
        DraftsCompanion.insert(
          channelId: id,
          message: const Value('half a thought'),
          updatedAt: DateTime.utc(2026, 11),
        ),
      );
    }
  });

  tearDown(() async {
    await closeTestSession(session);
    await server.close();
  });

  Future<List<String>> teams() async => [
    for (final t in await session.db.select(session.db.myTeams).get()) t.teamId,
  ];

  Future<List<String>> channels() async => [
    for (final c in await session.db.select(session.db.channels).get()) c.id,
  ];

  Future<List<String>> drafts() async => [
    for (final d in await session.db.select(session.db.drafts).get())
      d.channelId,
  ];

  /// What a lost team has to leave behind: no team, none of its channels or
  /// drafts, the direct message and its draft untouched.
  Future<void> expectGone() async {
    expect(await teams(), isEmpty);
    expect(await channels(), [_dmId]);
    expect(await drafts(), [_dmId]);
  }

  test('leaving a team removes it, its channels and their drafts', () async {
    await TeamActions(session).leave(teamId);
    await expectGone();
  });

  test('being removed by someone else is the same', () async {
    await session.connection.events.add(
      decodeEvent(
        SocketFrame.fromJson({
          'event': 'leave_team',
          'data': {'team_id': teamId, 'user_id': meId},
          'broadcast': {'team_id': teamId},
          'seq': 1,
        }),
      ),
    );
    await eventually(() async => (await teams()).isEmpty);
    await expectGone();
  });

  test('a team that is deleted or archived is the same', () async {
    await session.connection.events.add(
      decodeEvent(
        SocketFrame.fromJson({
          'event': 'delete_team',
          'data': {'team_id': teamId},
          'broadcast': {'team_id': teamId},
          'seq': 1,
        }),
      ),
    );
    await eventually(() async => (await teams()).isEmpty);
    await expectGone();
  });

  test("another member leaving a team doesn't touch ours", () async {
    await session.connection.events.add(
      decodeEvent(
        SocketFrame.fromJson({
          'event': 'leave_team',
          'data': {'team_id': teamId, 'user_id': 'someone'},
          'broadcast': {'team_id': teamId},
          'seq': 1,
        }),
      ),
    );
    await session.connection.events.add(
      decodeEvent(
        SocketFrame.fromJson({
          'event': 'update_team',
          'data': {'team': '{"id":"$teamId","display_name":"Harbour 2"}'},
          'broadcast': {'team_id': teamId},
          'seq': 2,
        }),
      ),
    );
    await eventually(() async {
      final rows = await session.db.select(session.db.teams).get();
      return rows.any((t) => t.displayName == 'Harbour 2');
    });
    expect(await teams(), [teamId]);
  });

  test('a team lost while the app was closed goes at the next entry sync, '
      'and a team that stays is kept', () async {
    await session.store.applyTeams(
      [
        api.Team.fromJson({
          'id': _otherTeam,
          'name': 'bay',
          'display_name': 'Bay',
        }),
      ],
      [
        api.TeamMember.fromJson({'team_id': _otherTeam}),
      ],
    );
    await session.store.applyEntry(
      config: null,
      license: null,
      preferences: const [],
      me: api.User.fromJson({'id': meId, 'username': 'river'}),
      teams: [
        api.Team.fromJson({
          'id': _otherTeam,
          'name': 'bay',
          'display_name': 'Bay',
        }),
      ],
      members: [
        api.TeamMember.fromJson({'team_id': _otherTeam}),
      ],
    );
    expect(await teams(), [_otherTeam]);
    expect(await channels(), [_dmId]);
    expect(await drafts(), [_dmId]);
  });

  test("a lost team's channels clear their notifications, threads included, "
      'and the direct message keeps its own', () async {
    final marks = <ReadMark>[];
    final sub = session.store.read.listen(marks.add);
    await session.store.removeTeam(teamId);
    await sub.cancel();
    expect(marks, [(channelId: channelId, rootId: '')]);
  });
}
