import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/db/throttled_watch.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/views/channel_input.dart';
import 'package:matterleast/data/views/permission_views.dart';
import 'package:matterleast/data/views/switch_views.dart';
import 'package:matterleast/domain/channel_info.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/domain/permissions.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/domain/teams.dart';

/// Reads for the channel management screens from one server database.
class ChannelViews {
  ChannelViews(this.db, {required this.serverUrl});

  final ServerDatabase db;
  final String serverUrl;

  static const _interval = Duration(milliseconds: 300);

  /// One channel as its info screen shows it; null once it is gone.
  Stream<ChannelInfo?> info(String channelId) => throttledWatch(
    db.tableUpdates(
      TableUpdateQuery.onAllTables([
        db.channels,
        db.myChannels,
        db.teams,
        db.myTeams,
        db.users,
        db.categories,
        db.categoryChannels,
        db.roles,
        db.syncState,
        db.config,
        db.preferences,
      ]),
    ),
    () => _info(channelId),
    interval: _interval,
  ).distinct();

  Future<ChannelInfo?> _info(String channelId) async {
    final channel = await (db.select(
      db.channels,
    )..where((c) => c.id.equals(channelId))).getSingleOrNull();
    if (channel == null) return null;
    final mine = await (db.select(
      db.myChannels,
    )..where((m) => m.channelId.equals(channelId))).getSingleOrNull();
    final myId = await db.syncText(SyncKeys.currentUserId) ?? '';
    final teamId = channel.teamId.isEmpty
        ? await db.syncText(SyncKeys.currentTeamId) ?? ''
        : channel.teamId;
    final team = await (db.select(
      db.teams,
    )..where((t) => t.id.equals(teamId))).getSingleOrNull();
    final myTeam = await (db.select(
      db.myTeams,
    )..where((t) => t.teamId.equals(teamId))).getSingleOrNull();
    final format = await db.nameFormat();
    final partnerId = channel.type == 'D'
        ? directPartnerId(channel.name, myId)
        : null;
    final userIds = {myId, ?partnerId, channel.creatorId};
    final users = {
      for (final u in await (db.select(
        db.users,
      )..where((u) => u.id.isIn(userIds))).get())
        u.id: u,
    };
    PersonInput? person(String? id) => switch (users[id]) {
      null => null,
      final u => (
        username: u.username,
        firstName: u.firstName,
        lastName: u.lastName,
        nickname: u.nickname,
        status: u.status,
      ),
    };
    final title = mine == null
        ? channel.displayName
        : conversationName(
            channelInputOf(channel, mine),
            myId: myId,
            people: {for (final id in userIds) id: ?person(id)},
            nameFormat: format,
          ).title;
    final favorites =
        await (db.select(db.categoryChannels).join([
              innerJoin(
                db.categories,
                db.categories.id.equalsExp(db.categoryChannels.categoryId),
              ),
            ])..where(
              db.categoryChannels.channelId.equals(channelId) &
                  db.categories.type.equals('favorites'),
            ))
            .get();
    final granted = await PermissionViews(db).roleGrants();
    final rights = channelRights(
      channel.type,
      roles: roleNames([
        await db.syncText(SyncKeys.currentUserRoles) ?? '',
        myTeam?.roles ?? '',
        mine?.roles ?? '',
      ]),
      granted: granted,
    );
    final props =
        mine?.notifyProps ?? api.ChannelNotifyProps.fromJson(const {});
    final account = _accountProps(
      await db.syncText(SyncKeys.accountNotifyProps),
    );
    final creator = person(channel.creatorId);
    return ChannelInfo(
      id: channel.id,
      type: channel.type,
      name: channel.name,
      title: title.isEmpty ? channel.name : title,
      teamId: teamId,
      teamName: team?.name ?? '',
      teamDisplayName: team?.displayName ?? '',
      purpose: channel.purpose,
      header: channel.header,
      archived: channel.deleteAt != null,
      joined: mine != null,
      favorite: favorites.isNotEmpty,
      muted: props.markUnread == 'mention',
      memberCount: channel.memberCount,
      partnerId: partnerId,
      creatorName: creator == null ? null : personName(creator, format),
      createAt: channel.createAt,
      notify: ChannelNotify(
        push: props.push ?? 'default',
        desktop: props.desktop ?? 'default',
        ignoreChannelMentions: props.ignoreChannelMentions ?? 'default',
        accountPush: account.push ?? 'mention',
        accountDesktop: account.desktop ?? 'mention',
      ),
      canEdit: rights.edit,
      canArchive: rights.archive,
      canManageMembers: rights.manageMembers,
      canConvert:
          rights.convert &&
          channel.deleteAt == null &&
          channel.name != 'town-square',
      canUnarchive: rights.unarchive && channel.deleteAt != null,
    );
  }

  /// Whether the user may create public and private channels in [teamId]
  /// and join public ones.
  Future<({bool public, bool private, bool join})> teamRights(
    String teamId,
  ) async {
    final myTeam = await (db.select(
      db.myTeams,
    )..where((t) => t.teamId.equals(teamId))).getSingleOrNull();
    final roles = roleNames([
      await db.syncText(SyncKeys.currentUserRoles) ?? '',
      myTeam?.roles ?? '',
    ]);
    final granted = await PermissionViews(db).roleGrants();
    bool can(String p) => hasPermission(p, roles: roles, granted: granted);
    return (
      public: can(Permission.createPublicChannel),
      private: can(Permission.createPrivateChannel),
      join: can(Permission.joinPublicChannels),
    );
  }

  static api.UserNotifyProps _accountProps(String? json) {
    final decoded = json == null ? null : jsonDecode(json);
    return api.UserNotifyProps.fromJson(
      decoded is Map<String, Object?> ? decoded : const {},
    );
  }

  /// The post ids of a stored list, such as `pinned:<channel>`, in order.
  Stream<List<String>> listIds(String list) =>
      (db.select(db.postLists)
            ..where((l) => l.list.equals(list))
            ..orderBy([(l) => OrderingTerm.asc(l.rank)]))
          .watch()
          .map((rows) => [for (final r in rows) r.postId])
          .distinct(listEquals);

  /// Whether [list] was fetched at least once.
  Future<bool> listKnown(String list) async =>
      await db.syncInt(SyncKeys.listFetchedAt(list)) != null;

  /// People by id as rows, in the order of [ids], with live presence.
  Stream<List<SwitchItem>> people(List<String> ids) => throttledWatch(
    db.tableUpdates(
      TableUpdateQuery.onAllTables([db.users, db.config, db.preferences]),
    ),
    () async {
      final format = await db.nameFormat();
      final rows = {
        for (final u in await (db.select(
          db.users,
        )..where((u) => u.id.isIn(ids))).get())
          u.id: u,
      };
      return [
        for (final id in ids)
          if (rows[id] case final u?) personItem(u, serverUrl, format),
      ];
    },
    interval: _interval,
  ).distinct(listEquals);

  /// The channels the user is in, by id, for telling joined ones apart.
  Future<Set<String>> joinedIds() async => {
    for (final m in await db.select(db.myChannels).get()) m.channelId,
  };
}
