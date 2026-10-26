import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:matterleast/data/db/throttled_watch.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/data/sync/inbox_sync.dart';
import 'package:matterleast/data/views/channel_input.dart';
import 'package:matterleast/domain/inbox.dart';

/// Home's reads from one server database: one batched query, re-run at most
/// twice a second while writes land, passed on only when it changed.
class InboxViews {
  InboxViews(this.db, {required this.serverUrl});

  final ServerDatabase db;
  final String serverUrl;

  static const _interval = Duration(milliseconds: 500);

  Stream<Object?> get _changes => db.tableUpdates(
    TableUpdateQuery.onAllTables([
      db.teams,
      db.channels,
      db.myChannels,
      db.users,
      db.posts,
      db.postLists,
      db.threads,
      db.threadTeams,
      db.preferences,
      db.syncState,
      db.config,
    ]),
  );

  Stream<ServerInbox> inbox() => throttledWatch(
    _changes,
    () async => buildServerInbox(await _source()),
    interval: _interval,
  ).distinct();

  /// Followed threads of one team, newest first.
  Stream<List<InboxItem>> teamThreads(String teamId) => throttledWatch(
    _changes,
    () async => buildServerInbox(await _source(teamId: teamId)).threads,
    interval: _interval,
  ).distinct(listEquals);

  Future<InboxSource> _source({String? teamId}) async {
    final myId = await db.syncText(SyncKeys.currentUserId) ?? '';
    final crt = await db.collapsedThreads();
    final channelRows = await db.select(db.channels).join([
      innerJoin(
        db.myChannels,
        db.myChannels.channelId.equalsExp(db.channels.id),
      ),
    ]).get();
    final channels = <String, InboxChannel>{
      for (final row in channelRows)
        row.readTable(db.channels).id: _channel(
          row.readTable(db.channels),
          row.readTable(db.myChannels),
        ),
    };

    final lists = await (db.select(
      db.postLists,
    )..orderBy([(l) => OrderingTerm.asc(l.rank)])).get();
    List<String> idsOf(String list) => [
      for (final l in lists)
        if (l.list == list) l.postId,
    ];
    final mentionIds = teamId == null
        ? idsOf(PostListNames.mentions)
        : const <String>[];
    final savedIds = teamId == null
        ? idsOf(PostListNames.saved)
        : const <String>[];

    final threadQuery = db.select(db.threads).join([
      leftOuterJoin(
        db.threadTeams,
        db.threadTeams.rootId.equalsExp(db.threads.rootId),
      ),
    ])..where(db.threads.isFollowing.equals(true));
    if (teamId != null) {
      threadQuery.where(db.threadTeams.teamId.isIn([teamId, '']));
    }
    final threads = <String, InboxThread>{};
    for (final row in await threadQuery.get()) {
      final t = row.readTable(db.threads);
      final team = row.readTableOrNull(db.threadTeams)?.teamId;
      final existing = threads[t.rootId];
      if (existing != null && (existing.teamId?.isNotEmpty ?? false)) continue;
      threads[t.rootId] = (
        rootId: t.rootId,
        channelId: t.channelId,
        teamId: team,
        lastReplyAt: t.lastReplyAt,
        unreadReplies: t.unreadReplies,
      );
    }

    final postIds = {...mentionIds, ...savedIds, ...threads.keys};
    final posts = {
      for (final p in await (db.select(
        db.posts,
      )..where((p) => p.id.isIn(postIds))).get())
        p.id: _post(p),
    };

    final latestPosts = <String, InboxPost>{};
    if (teamId == null) {
      for (final MapEntry(key: id, value: c) in channels.entries) {
        final input = c.input;
        if (input.type != 'D' && input.type != 'G') continue;
        if (input.totalMsgCount - input.msgCount <= 0 &&
            input.mentionCount <= 0) {
          continue;
        }
        final latest =
            await (db.select(db.posts)
                  ..where((p) => p.channelId.equals(id) & p.deleteAt.isNull())
                  ..orderBy([(p) => OrderingTerm.desc(p.createAt)])
                  ..limit(1))
                .getSingleOrNull();
        if (latest != null) latestPosts[id] = _post(latest);
      }
    }

    final peopleIds = <String>{
      myId,
      for (final p in [...posts.values, ...latestPosts.values]) p.userId,
      for (final c in channels.values)
        if (c.input.type == 'D')
          for (final id in c.input.name.split('__')) id,
    };
    final users = await (db.select(
      db.users,
    )..where((u) => u.id.isIn(peopleIds))).get();
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
    final pictureUpdates = {for (final u in users) u.id: ?u.lastPictureUpdate};
    final teams = {
      for (final t in await db.select(db.teams).get()) t.id: t.displayName,
    };
    final fetched = {
      for (final s in await (db.select(
        db.syncState,
      )..where((s) => s.key.like('${SyncKeys.listFetchedAt('')}%'))).get())
        s.key.substring(SyncKeys.listFetchedAt('').length),
    };
    return InboxSource(
      serverUrl: serverUrl,
      myId: myId,
      currentTeamId: await db.syncText(SyncKeys.currentTeamId),
      channels: channels,
      teams: teams,
      people: people,
      pictureUpdates: pictureUpdates,
      posts: posts,
      latestPosts: latestPosts,
      mentionIds: mentionIds,
      savedIds: savedIds,
      threads: threads.values.toList(),
      collapsedThreads: crt,
      nameFormat: await db.nameFormat(),
      known: {
        if (await db.syncInt(SyncKeys.lastFullSync) != null) InboxFilter.unread,
        if (fetched.contains(PostListNames.mentions)) InboxFilter.mentions,
        if (fetched.contains(PostListNames.saved)) InboxFilter.saved,
        if (fetched.contains(InboxSync.threadsList)) InboxFilter.threads,
      },
    );
  }

  InboxChannel _channel(ChannelRow c, MyChannelRow m) =>
      (teamId: c.teamId, input: channelInputOf(c, m));

  InboxPost _post(PostRow p) => (
    id: p.id,
    channelId: p.channelId,
    rootId: p.rootId,
    userId: p.userId,
    createAt: p.createAt,
    message: p.message,
    deleted: p.deleteAt != null,
    unreadable: p.decodeProblem != null,
  );
}
