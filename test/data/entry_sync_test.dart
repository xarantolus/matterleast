import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/data/sync/entry_sync.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/data/users/user_loader.dart';

import '../support/fake_server.dart';
import '../support/memory_database.dart';

const lighthouse = '4aw9gh6hbfy5byx4e66ejs3oyy';
const harbor = 'uzwiwgr4b7np7qcs1knx7nkxbo';
const me = 'mhkm3wzstby7ixmftzjn8pscha';

/// Answers an entry sync like the local test server does for alice, whose
/// recorded channels are all in lighthouse.
Reply? recordedServer(SeenRequest r) {
  final path = r.path.replaceFirst('/api/v4', '');
  return switch (path) {
    '/config/client' => ok(fixtureMap('client_config')),
    '/license/client' => ok(fixtureMap('client_license')),
    '/users/me' => ok(fixtureMap('me')),
    '/users/me/preferences' => ok(fixture('preferences')),
    '/users/me/teams' => ok(fixture('my_teams')),
    '/users/me/teams/members' => ok(fixture('my_team_members')),
    '/users/me/teams/unread' => ok(fixture('team_unreads')),
    '/users/me/teams/$lighthouse/channels' => ok(fixture('channels')),
    '/users/me/teams/$lighthouse/channels/members' => ok(
      fixture('channel_members'),
    ),
    '/users/me/teams/$lighthouse/channels/categories' => ok(
      fixture('categories'),
    ),
    '/users/me/teams/$lighthouse/threads' => ok(fixture('threads')),
    '/users/me/teams/$harbor/channels' ||
    '/users/me/teams/$harbor/channels/members' => ok(<Object?>[]),
    '/users/me/teams/$harbor/channels/categories' => ok({
      'categories': <Object?>[],
      'order': <Object?>[],
    }),
    '/users/me/teams/$harbor/threads' => ok({'threads': <Object?>[]}),
    '/users/ids' => ok(fixture('users_by_ids')),
    '/roles/names' => ok(fixture('roles')),
    _ => error(404, 'not_found'),
  };
}

void main() {
  late FakeServer server;
  late ServerDatabase db;
  late ServerStore store;
  late SyncRunner runner;
  late ServerApi api;
  late EntrySync sync;

  setUp(() async {
    server = await FakeServer.start();
    server.handle = recordedServer;
    db = memoryDatabase();
    store = ServerStore(db);
    runner = SyncRunner();
    api = ServerApi(baseUrl: server.url, token: () => 'token');
    sync = EntrySync(
      server: api,
      store: store,
      runner: runner,
      users: UserLoader(server: api, store: store),
    );
  });

  tearDown(() async {
    runner.close();
    api.close();
    await db.close();
    await server.close();
  });

  Future<void> settled() async {
    while (runner.isBusy) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }

  Future<List<String>> channelNames() async => [
    for (final c in await db.select(db.channels).get()) c.name,
  ];

  test('teams, channels, members, categories and unreads land', () async {
    await store.setCurrentTeam(lighthouse);
    await sync.run();

    expect(await db.syncText(SyncKeys.currentUserId), me);
    expect(await db.syncText(SyncKeys.currentTeamId), lighthouse);
    expect([
      for (final t in await db.select(db.teams).get()) t.name,
    ], unorderedEquals(['lighthouse', 'harbor']));
    expect(await channelNames(), containsAll(['engineering', 'off-topic']));
    final members = await db.select(db.myChannels).get();
    expect(
      members,
      hasLength(await db.select(db.channels).get().then((c) => c.length)),
    );
    final categories = await db.select(db.categories).get();
    expect(
      categories.map((c) => c.displayName),
      containsAll(['Favorites', 'Projects', 'Channels', 'Direct Messages']),
    );
    expect(await db.syncInt(SyncKeys.channelsSince(lighthouse)), isNotNull);
    expect(await db.syncInt(SyncKeys.lastFullSync), isNotNull);

    await settled();
    final unread = await (db.select(
      db.myTeams,
    )..where((t) => t.teamId.equals(lighthouse))).getSingle();
    expect(unread.mentionCount, 8);
    expect(await db.syncInt(SyncKeys.channelsSince(harbor)), isNotNull);
    final partners = server.seen.where((r) => r.path.endsWith('/users/ids'));
    expect(partners, isNotEmpty);
    expect(await db.select(db.roles).get(), isNotEmpty);
  });

  test(
    'the second sync asks only for channels archived since the first',
    () async {
      await store.setCurrentTeam(lighthouse);
      await sync.run();
      await settled();
      await sync.run();
      final channelCalls = server.seen
          .where((r) => r.path.endsWith('/teams/$lighthouse/channels'))
          .map((r) => r.raw.uri.queryParameters)
          .toList();
      expect(channelCalls.first['last_delete_at'], '0');
      expect(channelCalls.first['include_deleted'], 'true');
      expect(int.parse(channelCalls.last['last_delete_at']!), greaterThan(0));
    },
  );

  test('without a remembered team the first by name is synced first', () async {
    await sync.run();
    expect(await db.syncText(SyncKeys.currentTeamId), harbor);
  });

  test('a failing request keeps what was stored', () async {
    await store.setCurrentTeam(lighthouse);
    await sync.run();
    await settled();
    final before = await channelNames();

    server.handle = (r) => r.path.endsWith('/channels/categories')
        ? error(500, 'boom')
        : recordedServer(r);
    await expectLater(sync.run(), throwsA(isA<ServerError>()));
    expect(await channelNames(), before);
    expect(runner.status.value, isA<SyncFailed>());
  });

  test('a channel left elsewhere disappears on the next sync', () async {
    await store.setCurrentTeam(lighthouse);
    await sync.run();
    await settled();
    expect(await channelNames(), contains('design'));

    server.handle = (r) {
      final reply = recordedServer(r);
      if (!r.path.endsWith('/teams/$lighthouse/channels')) return reply;
      final channels = (reply!.json! as List<Object?>)
          .cast<Map<String, Object?>>()
          .where((c) => c['name'] != 'design')
          .toList();
      return ok(channels);
    };
    await sync.run();
    expect(await channelNames(), isNot(contains('design')));
  });
}
