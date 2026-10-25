import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:matterleast/data/db/throttled_watch.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/views/channel_input.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/domain/preference_keys.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/domain/teams.dart';

/// The root screen's reads from one server database. Each is one batched
/// query, re-run at most every few hundred milliseconds while writes land,
/// and only passed on when its result changed.
class RootViews {
  RootViews(this.db);

  final ServerDatabase db;

  Stream<List<RailTeam>> railTeams() => throttledWatch(
    db.tableUpdates(
      TableUpdateQuery.onAllTables([
        db.teams,
        db.myTeams,
        db.channels,
        db.myChannels,
        db.preferences,
        db.syncState,
        db.config,
      ]),
    ),
    _railTeams,
    interval: const Duration(milliseconds: 500),
  ).distinct(listEquals);

  Stream<ChannelList> channelList(String teamId) => throttledWatch(
    db.tableUpdates(
      TableUpdateQuery.onAllTables([
        db.teams,
        db.categories,
        db.categoryChannels,
        db.channels,
        db.myChannels,
        db.users,
        db.preferences,
        db.drafts,
        db.threads,
        db.threadTeams,
        db.syncState,
        db.config,
      ]),
    ),
    () => _channelList(teamId),
    interval: const Duration(milliseconds: 300),
  ).distinct();

  Future<List<RailTeam>> _railTeams() async {
    final teams = await db.select(db.teams).join([
      innerJoin(db.myTeams, db.myTeams.teamId.equalsExp(db.teams.id)),
    ]).get();
    final crt = await db.collapsedThreads();
    final channels = await _myChannels((c) => c.teamId.equals('').not());
    final synced = {
      for (final s in await (db.select(
        db.syncState,
      )..where((s) => s.key.like('${SyncKeys.channelsSince('')}%'))).get())
        s.key.substring(SyncKeys.channelsSince('').length),
    };
    final ordered = sortTeams([
      for (final row in teams)
        (
          id: row.readTable(db.teams).id,
          displayName: row.readTable(db.teams).displayName,
        ),
    ], await db.preference(Prefs.teamsOrder.$1, Prefs.teamsOrder.$2));
    final mine = {
      for (final row in teams)
        row.readTable(db.myTeams).teamId: row.readTable(db.myTeams),
    };
    return [
      for (final team in ordered)
        () {
          final own = channels.where(
            (c) => c.teamId == team.id && !c.input.archived,
          );
          final badge = teamBadge(
            channelsSynced: synced.contains(team.id),
            channelMentions: own
                .where((c) => !c.input.muted)
                .fold(
                  0,
                  (sum, c) =>
                      sum +
                      (crt ? c.input.mentionCountRoot : c.input.mentionCount),
                ),
            anyChannelUnread: own.any(
              (c) => !c.input.muted && _unreadCount(c.input, crt) > 0,
            ),
            teamMentions: crt
                ? mine[team.id]!.mentionCountRoot
                : mine[team.id]!.mentionCount,
            teamUnreadMessages: crt
                ? mine[team.id]!.msgCountRoot
                : mine[team.id]!.msgCount,
          );
          return RailTeam(
            id: team.id,
            displayName: team.displayName,
            unread: badge.unread,
            mentions: badge.mentions,
          );
        }(),
    ];
  }

  int _unreadCount(ChannelInput c, bool crt) =>
      crt ? c.totalMsgCountRoot - c.msgCountRoot : c.totalMsgCount - c.msgCount;

  Future<List<({String teamId, ChannelInput input})>> _myChannels(
    Expression<bool> Function($ChannelsTable c) filter,
  ) async {
    final rows = await (db.select(db.channels)..where(filter)).join([
      innerJoin(
        db.myChannels,
        db.myChannels.channelId.equalsExp(db.channels.id),
      ),
    ]).get();
    return [
      for (final row in rows)
        (
          teamId: row.readTable(db.channels).teamId,
          input: channelInputOf(
            row.readTable(db.channels),
            row.readTable(db.myChannels),
          ),
        ),
    ];
  }

  Future<ChannelList> _channelList(String teamId) async {
    final myId = await db.syncText(SyncKeys.currentUserId) ?? '';
    final team = await (db.select(
      db.teams,
    )..where((t) => t.id.equals(teamId))).getSingleOrNull();
    final categories =
        await (db.select(db.categories)
              ..where((c) => c.teamId.equals(teamId))
              ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
            .get();
    final links =
        await (db.select(db.categoryChannels)
              ..where(
                (cc) => cc.categoryId.isIn([for (final c in categories) c.id]),
              )
              ..orderBy([(cc) => OrderingTerm.asc(cc.sortOrder)]))
            .get();
    final channels = {
      for (final c in await _myChannels(
        (c) => c.teamId.equals(teamId) | c.teamId.equals(''),
      ))
        c.input.id: c.input,
    };
    final partnerIds = {
      myId,
      for (final c in channels.values)
        if (c.type == 'D') ?directPartnerId(c.name, myId),
    };
    final people = {
      for (final u in await (db.select(
        db.users,
      )..where((u) => u.id.isIn(partnerIds))).get())
        u.id: (
          username: u.username,
          firstName: u.firstName,
          lastName: u.lastName,
          nickname: u.nickname,
          status: u.status,
        ),
    };
    final hidden =
        await (db.select(db.preferences)..where(
              (p) =>
                  p.category.isIn([
                    Prefs.directChannelShow,
                    Prefs.groupChannelShow,
                  ]) &
                  p.value.equals('false'),
            ))
            .get();
    final drafts =
        await (db.select(db.drafts)..where(
              (d) =>
                  d.channelId.isIn(channels.keys) &
                  (d.message.equals('').not() | d.filesJson.equals('[]').not()),
            ))
            .get();
    final crt = await db.collapsedThreads();
    final unreadThreads = crt ? await _unreadThreads(teamId) : 0;
    final viewTimes = <String, DateTime>{};
    for (final p
        in await (db.select(db.preferences)..where(
              (p) => p.category.isIn([
                Prefs.channelOpenTime,
                Prefs.channelViewTime,
              ]),
            ))
            .get()) {
      final at = int.tryParse(p.value);
      if (at == null) continue;
      final time = DateTime.fromMillisecondsSinceEpoch(at, isUtc: true);
      final known = viewTimes[p.name];
      if (known == null || time.isAfter(known)) viewTimes[p.name] = time;
    }
    return buildChannelList(
      ChannelListSource(
        myId: myId,
        teamName: team?.displayName ?? '',
        categories: [
          for (final c in categories)
            (
              id: c.id,
              type: c.type,
              displayName: c.displayName,
              sorting: c.sorting,
              collapsed: c.collapsed,
            ),
        ],
        channelIdsByCategory: {
          for (final c in categories)
            c.id: [
              for (final link in links)
                if (link.categoryId == c.id) link.channelId,
            ],
        },
        channels: channels,
        people: people,
        hiddenDirect: {
          for (final p in hidden)
            if (p.category == Prefs.directChannelShow) p.name,
        },
        hiddenGroups: {
          for (final p in hidden)
            if (p.category == Prefs.groupChannelShow) p.name,
        },
        draftChannels: {for (final d in drafts) d.channelId},
        collapsedThreads: crt,
        unreadThreads: unreadThreads,
        nameFormat: await db.nameFormat(),
        directLimit:
            int.tryParse(
              await db.preference(Prefs.directLimit.$1, Prefs.directLimit.$2) ??
                  '',
            ) ??
            defaultDirectLimit,
        viewTimes: viewTimes,
        synced: await db.syncInt(SyncKeys.channelsSince(teamId)) != null,
      ),
    );
  }

  Future<int> _unreadThreads(String teamId) async {
    final count = db.threads.rootId.count();
    final query =
        db.selectOnly(db.threads).join([
            innerJoin(
              db.threadTeams,
              db.threadTeams.rootId.equalsExp(db.threads.rootId),
              useColumns: false,
            ),
          ])
          ..addColumns([count])
          ..where(
            db.threadTeams.teamId.isIn([teamId, '']) &
                db.threads.isFollowing.equals(true) &
                db.threads.unreadReplies.isBiggerThanValue(0),
          );
    return (await query.getSingle()).read(count) ?? 0;
  }
}
