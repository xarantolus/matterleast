import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart' hide isNotNull, isNull;
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/network_state.dart';
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/data/images/server_image_caches.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/data/sync/sync_runner.dart';

import 'fake_server.dart';

/// Invented ids of the signed-in user, a channel and a team.
const meId = 'me0000000000000000000000me';
const channelId = 'ch000000000000000000000c01';
const teamId = 'tm000000000000000000000t01';

/// A session on an in-memory database talking to [server], with the user,
/// one team and one channel (with one stored post) as an entry sync would
/// leave them. [interceptor] sees every statement the database runs;
/// [network] is wired in as [ServerSession.open] does.
Future<ServerSession> testSession(
  FakeServer server, {
  ServerDatabase? db,
  QueryInterceptor? interceptor,
  NetworkState? network,
}) async {
  var connection = DatabaseConnection(NativeDatabase.memory());
  if (interceptor != null) connection = connection.interceptWith(interceptor);
  final database = db ?? ServerDatabase(connection);
  final http = ServerApi(
    baseUrl: server.url,
    token: () => 'token',
    network: network,
  );
  final session = ServerSession(
    url: server.url,
    api: http,
    db: database,
    network: network,
    runner: SyncRunner(offline: () => network?.offline ?? false),
    dbPath: '',
    images: ServerImageCaches(
      directory: '',
      api: http,
      mediaBudget: () async => 0,
      filesBudget: () async => 0,
    ),
    token: () => 'token',
  );
  if (db != null) return session;
  final store = session.store;
  await store.applyMe(
    api.User.fromJson({'id': meId, 'username': 'river', 'first_name': 'River'}),
  );
  await store.applyTeams(
    [
      api.Team.fromJson({
        'id': teamId,
        'name': 'harbour',
        'display_name': 'Harbour',
      }),
    ],
    [
      api.TeamMember.fromJson({'team_id': teamId}),
    ],
  );
  await store.applyChannels(
    channels: [
      api.Channel.fromJson({
        'id': channelId,
        'team_id': teamId,
        'type': 'O',
        'name': 'boats',
        'display_name': 'Boats',
        'total_msg_count': 1,
      }),
    ],
    members: [
      api.ChannelMember.fromJson({
        'channel_id': channelId,
        'user_id': meId,
        'msg_count': 1,
      }),
    ],
  );
  await store.applyChannelPage(
    channelId: channelId,
    page: api.PostList.fromJson({
      'order': ['old1'],
      'posts': {
        'old1': {
          'id': 'old1',
          'channel_id': channelId,
          'user_id': 'someone',
          'create_at': DateTime.utc(2026, 10, 25, 9).millisecondsSinceEpoch,
          'message': 'morning',
        },
      },
    }),
    kind: PageKind.page,
  );
  return session;
}

/// Closes what [testSession] opened, leaving the image caches untouched.
Future<void> closeTestSession(ServerSession session) async {
  await session.outbox.close();
  await session.connection.close();
  session.users.close();
  session.runner.close();
  session.api.close();
  await session.db.close();
}

/// A fake server and a session on it, both closed when the test ends.
Future<(FakeServer, ServerSession)> startServerSession() async {
  final server = await FakeServer.start();
  final session = await testSession(server);
  addTearDown(() async {
    await closeTestSession(session);
    await server.close();
  });
  return (server, session);
}
