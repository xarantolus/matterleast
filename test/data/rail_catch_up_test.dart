import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/server_db/server_config.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/views/root_views.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';
import '../support/wait.dart';

const otherTeam = 'tm000000000000000000000t02';
const otherChannel = 'ch000000000000000000000c02';
const mutedChannel = 'ch000000000000000000000c03';

/// The server's answers for a reconnect of a user in two teams, where the
/// other team has nothing unread any more.
Reply? reconnectServer(
  SeenRequest r, {
  Map<String, Object?> unread = const {},
  Reply? otherChannels,
}) {
  final path = r.path.replaceFirst('/api/v4', '');
  Map<String, Object?> counts(String team) => {
    'team_id': team,
    'msg_count': 0,
    'msg_count_root': 0,
    'mention_count': 0,
    'mention_count_root': 0,
    'thread_count': 0,
    'thread_mention_count': 0,
    ...unread,
  };
  return switch (path) {
    '/config/client' => ok({'CollapsedThreads': 'always_on'}),
    '/users/me' => ok({'id': meId, 'username': 'river'}),
    '/users/me/teams' => ok([
      {'id': teamId, 'name': 'harbour', 'display_name': 'Harbour'},
      {'id': otherTeam, 'name': 'light', 'display_name': 'Light'},
    ]),
    '/users/me/teams/members' => ok([
      {'team_id': teamId, 'user_id': meId},
      {'team_id': otherTeam, 'user_id': meId},
    ]),
    '/users/me/teams/unread' => ok([
      {...counts(teamId), 'team_id': teamId},
      {...counts(otherTeam), 'team_id': otherTeam},
    ]),
    '/users/me/teams/$otherTeam/channels' =>
      otherChannels ??
          ok([
            {
              'id': otherChannel,
              'team_id': otherTeam,
              'type': 'O',
              'name': 'quay',
              'display_name': 'Quay',
              'total_msg_count': 2,
              'total_msg_count_root': 2,
            },
          ]),
    '/users/me/teams/$otherTeam/channels/members' => ok([
      {
        'channel_id': otherChannel,
        'user_id': meId,
        'msg_count': 2,
        'msg_count_root': 2,
      },
    ]),
    '/users/me/teams/$otherTeam/channels/categories' ||
    '/users/me/teams/$teamId/channels/categories' => ok({
      'categories': <Object?>[],
      'order': <Object?>[],
    }),
    '/users/me/teams/$otherTeam/threads' ||
    '/users/me/teams/$teamId/threads' => ok({'threads': <Object?>[]}),
    _ => emptyAnswer(r),
  };
}

void main() {
  late FakeServer server;
  late ServerSession session;

  setUp(() async {
    (server, session) = await startServerSession();
    server.handle = reconnectServer;
    final store = session.store;
    await store.applyConfig(ConfigKeys.clientConfig, {
      'CollapsedThreads': 'always_on',
    });
    await store.applyTeams(
      [
        api.Team.fromJson({
          'id': otherTeam,
          'name': 'light',
          'display_name': 'Light',
        }),
      ],
      [
        api.TeamMember.fromJson({'team_id': otherTeam}),
      ],
    );
    await store.setCurrentTeam(teamId);
    for (final team in [teamId, otherTeam]) {
      await session.db.setSyncInt(SyncKeys.channelsSince(team), 1);
    }
  });

  Future<void> otherTeamHolds({
    required int totalRoot,
    required int readRoot,
    String markUnread = 'all',
    int mentionsRoot = 0,
    String id = otherChannel,
  }) => session.store.applyChannels(
    channels: [
      api.Channel.fromJson({
        'id': id,
        'team_id': otherTeam,
        'type': 'O',
        'name': 'quay',
        'display_name': 'Quay',
        'total_msg_count': totalRoot,
        'total_msg_count_root': totalRoot,
      }),
    ],
    members: [
      api.ChannelMember.fromJson({
        'channel_id': id,
        'user_id': meId,
        'msg_count': readRoot,
        'msg_count_root': readRoot,
        'mention_count': mentionsRoot,
        'mention_count_root': mentionsRoot,
        'notify_props': {'mark_unread': markUnread},
      }),
    ],
  );

  Future<({bool unread, int mentions})> otherTeamBadge() async {
    final team = (await RootViews(
      session.db,
    ).railTeams().first).singleWhere((t) => t.id == otherTeam);
    return (unread: team.unread, mentions: team.mentions);
  }

  Future<void> reconnect() => session.connection.entry.run(light: true);

  Future<bool> fetched(String path) async {
    await afterWork();
    return server.paths.contains('/api/v4$path');
  }

  test('a channel read elsewhere while the app was away stops showing on '
      'the rail after the reconnect, although the team totals look '
      'unchanged', () async {
    await otherTeamHolds(totalRoot: 2, readRoot: 1);
    expect((await otherTeamBadge()).unread, isTrue);

    await reconnect();

    await eventually(() async => !(await otherTeamBadge()).unread);
  });

  test('a failed fetch of the team is tried again at the next '
      'reconnect', () async {
    await otherTeamHolds(totalRoot: 2, readRoot: 1);
    server.handle = (r) =>
        reconnectServer(r, otherChannels: error(500, 'down'));

    await reconnect();
    await afterWork();
    expect((await otherTeamBadge()).unread, isTrue);

    server.handle = reconnectServer;
    await reconnect();

    await eventually(() async => !(await otherTeamBadge()).unread);
  });

  test('a thread read elsewhere stops showing on the rail after the '
      'reconnect', () async {
    await otherTeamHolds(totalRoot: 2, readRoot: 2);
    await session.store.applyThreads(otherTeam, [
      api.UserThread.fromJson({
        'id': 'old1',
        'reply_count': 1,
        'unread_replies': 1,
        'unread_mentions': 0,
        'post': {
          'id': 'old1',
          'channel_id': otherChannel,
          'user_id': 'someone',
          'create_at': 1,
          'message': 'morning',
        },
      }),
    ]);
    expect((await otherTeamBadge()).unread, isTrue);

    await reconnect();

    await eventually(() async => !(await otherTeamBadge()).unread);
  });

  test('nothing is fetched for a team whose counts agree with what is '
      'stored, a mention in a muted channel included', () async {
    await otherTeamHolds(
      totalRoot: 5,
      readRoot: 2,
      markUnread: 'mention',
      mentionsRoot: 1,
    );
    server.handle = (r) =>
        reconnectServer(r, unread: {'mention_count_root': 1});

    await reconnect();

    expect(await fetched('/users/me/teams/$otherTeam/channels'), isFalse);
    expect(await fetched('/users/me/teams/$otherTeam/threads'), isFalse);
  });
}
