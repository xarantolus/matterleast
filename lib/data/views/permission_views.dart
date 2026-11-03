import 'package:drift/drift.dart';
import 'package:matterleast/data/db/throttled_watch.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/domain/emoji_rules.dart';
import 'package:matterleast/domain/permissions.dart';

/// The user's rights from their stored roles, kept fresh by the sync.
class PermissionViews {
  PermissionViews(this.db);

  final ServerDatabase db;

  /// Each stored role's permissions by role name.
  Future<Grants> roleGrants() async => {
    for (final r in await db.select(db.roles).get())
      r.name: r.permissions.toSet(),
  };

  Future<String> systemRoles() async =>
      await db.syncText(SyncKeys.currentUserRoles) ?? '';

  Future<String> _teamRoles(String teamId) async {
    if (teamId.isEmpty) return '';
    final myTeam = await (db.select(
      db.myTeams,
    )..where((t) => t.teamId.equals(teamId))).getSingleOrNull();
    return myTeam?.roles ?? '';
  }

  /// The user's permissions in [teamId]: system roles, then that team's.
  Future<Can> inTeam(String teamId) async => haveITeamPermission(
    systemRoles: await systemRoles(),
    teamRoles: await _teamRoles(teamId),
    granted: await roleGrants(),
  );

  /// The user's permissions in [channelId]: system roles, the channel's
  /// team's, then the channel's; direct and group messages have no team.
  Future<Can> inChannel(String channelId) async {
    final channel = await (db.select(
      db.channels,
    )..where((c) => c.id.equals(channelId))).getSingleOrNull();
    final mine = await (db.select(
      db.myChannels,
    )..where((m) => m.channelId.equals(channelId))).getSingleOrNull();
    return haveIChannelPermission(
      systemRoles: await systemRoles(),
      teamRoles: await _teamRoles(channel?.teamId ?? ''),
      channelRoles: mine?.roles ?? '',
      granted: await roleGrants(),
    );
  }

  /// What the user may do with custom emoji; nothing when the server has
  /// them off.
  Future<EmojiRights> emoji() async => emojiRights(
    enabled: (await db.features()).customEmoji,
    can: haveIAnyTeamPermission(
      systemRoles: await systemRoles(),
      teamRoles: [for (final t in await db.select(db.myTeams).get()) t.roles],
      granted: await roleGrants(),
    ),
  );

  Stream<EmojiRights> watchEmoji() => throttledWatch(
    db.tableUpdates(
      TableUpdateQuery.onAllTables([
        db.roles,
        db.syncState,
        db.config,
        db.myTeams,
      ]),
    ),
    emoji,
    interval: const Duration(milliseconds: 300),
  ).distinct();

  Future<ChannelPermissions> channel(String channelId) async {
    final channel = await (db.select(
      db.channels,
    )..where((c) => c.id.equals(channelId))).getSingleOrNull();
    final features = await db.features();
    return channelPermissions(
      archived: channel?.deleteAt != null,
      readOnly: readOnlyChannel(
        channelName: channel?.name ?? '',
        townSquareReadOnly: features.townSquareReadOnly,
        systemRoles: await systemRoles(),
      ),
      can: await inChannel(channelId),
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
