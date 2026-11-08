import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/store/server_store.dart';

import 'test_session.dart';

/// Gives the signed-in user the `system_user` role holding exactly
/// [permissions].
Future<void> seedMyPermissions(
  ServerSession session, [
  Iterable<String> permissions = const [],
]) async {
  await session.db.setSyncText(SyncKeys.currentUserRoles, 'system_user');
  await session.store.applyRoles([
    api.Role.fromJson({
      'id': 'rl000000000000000000000r01',
      'name': 'system_user',
      'permissions': [...permissions],
    }),
  ]);
}

/// Stores a first page of [count] messages in the test channel, `n0` oldest
/// to `n<count-1>` newest, a minute apart, written by someone else.
Future<void> seedChannel(ServerSession session, {int count = 3}) =>
    session.store.applyChannelPage(
      channelId: channelId,
      page: api.PostList.fromJson({
        'order': [for (var i = count - 1; i >= 0; i--) 'n$i'],
        'posts': {
          for (var i = 0; i < count; i++)
            'n$i': {
              'id': 'n$i',
              'channel_id': channelId,
              'user_id': 'someone',
              'create_at': DateTime.utc(
                2026,
                10,
                26,
                8,
                i,
              ).millisecondsSinceEpoch,
              'message': 'message $i',
            },
        },
      }),
      kind: PageKind.page,
      requested: count,
    );
