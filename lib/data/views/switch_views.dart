import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:matterleast/data/db/throttled_watch.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/views/channel_input.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/domain/quick_switch.dart';

/// Everything one server can offer the quick switcher from its database:
/// the user's channels and conversations, and the people it knows.
class SwitchViews {
  SwitchViews(this.db, {required this.serverUrl});

  final ServerDatabase db;
  final String serverUrl;

  Stream<List<SwitchItem>> items() => throttledWatch(
    db.tableUpdates(
      TableUpdateQuery.onAllTables([
        db.teams,
        db.channels,
        db.myChannels,
        db.users,
        db.preferences,
        db.syncState,
        db.config,
      ]),
    ),
    _items,
    interval: const Duration(milliseconds: 500),
  ).distinct(listEquals);

  Future<List<SwitchItem>> _items() async {
    final myId = await db.syncText(SyncKeys.currentUserId) ?? '';
    final currentTeam = await db.syncText(SyncKeys.currentTeamId);
    final crt = await db.collapsedThreads();
    final format = await db.nameFormat();
    final teams = {
      for (final t in await db.select(db.teams).get()) t.id: t.displayName,
    };
    final rows = await db.select(db.channels).join([
      innerJoin(
        db.myChannels,
        db.myChannels.channelId.equalsExp(db.channels.id),
      ),
    ]).get();
    final users = await (db.select(
      db.users,
    )..where((u) => u.deleteAt.isNull())).get();
    final people = {
      for (final u in users)
        u.id: (
          username: u.username,
          firstName: u.firstName,
          lastName: u.lastName,
          nickname: u.nickname,
          status: u.status,
        ),
    };
    final userRows = {for (final u in users) u.id: u};
    final items = <SwitchItem>[];
    final withDirect = <String>{};
    for (final row in rows) {
      final c = row.readTable(db.channels);
      final input = channelInputOf(c, row.readTable(db.myChannels));
      final name = conversationName(
        input,
        myId: myId,
        people: people,
        nameFormat: format,
      );
      final partner = name.userId == null ? null : userRows[name.userId];
      if (name.userId case final id?) withDirect.add(id);
      final unreadCount = crt
          ? input.totalMsgCountRoot - input.msgCountRoot
          : input.totalMsgCount - input.msgCount;
      items.add(
        SwitchItem(
          serverUrl: serverUrl,
          kind: switch (c.type) {
            'D' => SwitchKind.direct,
            'G' => SwitchKind.group,
            _ when input.archived => SwitchKind.archived,
            'P' => SwitchKind.privateChannel,
            _ => SwitchKind.channel,
          },
          id: c.id,
          title: name.title,
          subtitle: partner != null ? '@${partner.username}' : teams[c.teamId],
          handle: partner != null ? '@${partner.username}' : c.name,
          keys: [
            if (c.type != 'D' && c.type != 'G') c.name,
            if (partner != null) ...personKeys(partner),
          ],
          teamId: c.teamId.isEmpty ? currentTeam : c.teamId,
          userId: name.userId,
          pictureUpdate: partner?.lastPictureUpdate,
          status: name.status,
          lastViewedAt: input.lastViewedAt,
          unread: unreadCount > 0,
          mentions: crt ? input.mentionCountRoot : input.mentionCount,
          muted: input.muted,
        ),
      );
    }
    for (final u in users) {
      if (u.id == myId || withDirect.contains(u.id) || u.isBot) continue;
      items.add(personItem(u, serverUrl, format, teamId: currentTeam));
    }
    return items;
  }
}

/// Someone the user has no conversation with yet.
SwitchItem personItem(
  UserRow u,
  String serverUrl,
  String? nameFormat, {
  String? teamId,
}) => SwitchItem(
  serverUrl: serverUrl,
  kind: SwitchKind.person,
  id: u.id,
  title: personName((
    username: u.username,
    firstName: u.firstName,
    lastName: u.lastName,
    nickname: u.nickname,
    status: u.status,
  ), nameFormat),
  subtitle: '@${u.username}',
  handle: u.username,
  keys: personKeys(u),
  teamId: teamId,
  userId: u.id,
  pictureUpdate: u.lastPictureUpdate,
  status: u.status,
);

List<String> personKeys(UserRow u) => [
  u.username,
  '${u.firstName} ${u.lastName}'.trim(),
  u.lastName,
  u.nickname,
];

/// The stored direct message channel with [userId] that the user is in.
Future<String?> directChannelWith(ServerDatabase db, String userId) async {
  final myId = await db.syncText(SyncKeys.currentUserId);
  if (myId == null) return null;
  final ids = [myId, userId]..sort();
  final row =
      await (db.select(db.channels)
            ..where((c) => c.type.equals('D') & c.name.equals(ids.join('__'))))
          .getSingleOrNull();
  if (row == null) return null;
  final mine = await (db.select(
    db.myChannels,
  )..where((m) => m.channelId.equals(row.id))).getSingleOrNull();
  return mine == null ? null : row.id;
}
