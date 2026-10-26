import 'package:drift/drift.dart';
import 'package:matterleast/data/db/throttled_watch.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/domain/permissions.dart';

/// The user's rights from their stored roles, kept fresh by the sync.
class PermissionViews {
  PermissionViews(this.db);

  final ServerDatabase db;

  /// Each stored role's permissions by role name.
  Future<Map<String, Set<String>>> roleGrants() async => {
    for (final r in await db.select(db.roles).get())
      r.name: r.permissions.toSet(),
  };

  /// The user's system, team and channel role names in [channelId]; for
  /// direct and group messages, which belong to no team, without team
  /// roles.
  Future<Set<String>> rolesIn(String channelId) async {
    final channel = await (db.select(
      db.channels,
    )..where((c) => c.id.equals(channelId))).getSingleOrNull();
    final mine = await (db.select(
      db.myChannels,
    )..where((m) => m.channelId.equals(channelId))).getSingleOrNull();
    final teamId = channel?.teamId ?? '';
    final myTeam = teamId.isEmpty
        ? null
        : await (db.select(
            db.myTeams,
          )..where((t) => t.teamId.equals(teamId))).getSingleOrNull();
    return roleNames([
      await db.syncText(SyncKeys.currentUserRoles) ?? '',
      myTeam?.roles ?? '',
      mine?.roles ?? '',
    ]);
  }

  Future<ChannelPermissions> channel(String channelId) async {
    final channel = await (db.select(
      db.channels,
    )..where((c) => c.id.equals(channelId))).getSingleOrNull();
    final roles = await rolesIn(channelId);
    final features = await db.features();
    return channelPermissions(
      archived: channel?.deleteAt != null,
      readOnly: readOnlyChannel(
        channelName: channel?.name ?? '',
        townSquareReadOnly: features.townSquareReadOnly,
        roles: roles,
      ),
      granted: grantedBy(roles, await roleGrants()),
    );
  }

  Stream<ChannelPermissions> watchChannel(String channelId) => throttledWatch(
    db.tableUpdates(
      TableUpdateQuery.onAllTables([
        db.channels,
        db.myChannels,
        db.myTeams,
        db.roles,
        db.syncState,
        db.config,
      ]),
    ),
    () => channel(channelId),
    interval: const Duration(milliseconds: 300),
  ).distinct();
}
