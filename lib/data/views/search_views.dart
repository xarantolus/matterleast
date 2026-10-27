import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:matterleast/data/db/throttled_watch.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/views/channel_input.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/domain/inbox.dart';
import 'package:matterleast/domain/message_search.dart';

/// The search screens' reads from one server database.
class SearchViews {
  SearchViews(this.db, {required this.serverUrl});

  final ServerDatabase db;
  final String serverUrl;

  static const _interval = Duration(milliseconds: 500);

  /// Message previews for the posts [ids], in that order.
  Stream<List<InboxItem>> postItems(List<String> ids) => throttledWatch(
    db.tableUpdates(
      TableUpdateQuery.onAllTables([
        db.posts,
        db.channels,
        db.myChannels,
        db.users,
        db.teams,
        db.config,
        db.preferences,
      ]),
    ),
    () => _postItems(ids),
    interval: _interval,
  ).distinct(listEquals);

  Future<List<InboxItem>> _postItems(List<String> ids) async {
    final myId = await db.syncText(SyncKeys.currentUserId) ?? '';
    final posts = await (db.select(
      db.posts,
    )..where((p) => p.id.isIn(ids))).get();
    final channels = await _channels({for (final p in posts) p.channelId});
    final people = await _people({
      myId,
      for (final p in posts) p.userId,
      for (final c in channels.values)
        if (c.input.type == 'D') ...c.input.name.split('__'),
    });
    final inbox = buildServerInbox(
      InboxSource(
        serverUrl: serverUrl,
        myId: myId,
        currentTeamId: await db.syncText(SyncKeys.currentTeamId),
        channels: channels,
        teams: {
          for (final t in await db.select(db.teams).get()) t.id: t.displayName,
        },
        people: people.names,
        pictureUpdates: people.pictures,
        posts: {
          for (final p in posts)
            p.id: (
              id: p.id,
              channelId: p.channelId,
              rootId: p.rootId,
              userId: p.userId,
              createAt: p.createAt,
              message: p.message,
              deleted: p.deleteAt != null,
              unreadable: p.decodeProblem != null,
            ),
        },
        savedIds: ids,
        nameFormat: await db.nameFormat(),
      ),
    );
    // Results keep the server's order, which is newest first anyway.
    final byId = {for (final item in inbox.saved) item.postId: item};
    return [for (final id in ids) ?byId[id]];
  }

  /// Stored channels by id, joined or not; a channel the user is not in
  /// counts as read.
  Future<Map<String, InboxChannel>> _channels(Set<String> ids) async {
    final rows = await (db.select(db.channels)..where((c) => c.id.isIn(ids)))
        .join([
          leftOuterJoin(
            db.myChannels,
            db.myChannels.channelId.equalsExp(db.channels.id),
          ),
        ])
        .get();
    return {
      for (final row in rows)
        row.readTable(db.channels).id: (
          teamId: row.readTable(db.channels).teamId,
          input: channelInputOf(
            row.readTable(db.channels),
            row.readTableOrNull(db.myChannels) ??
                MyChannelRow(
                  channelId: row.readTable(db.channels).id,
                  roles: '',
                  msgCount: row.readTable(db.channels).totalMsgCount,
                  msgCountRoot: row.readTable(db.channels).totalMsgCountRoot,
                  mentionCount: 0,
                  mentionCountRoot: 0,
                  urgentMentionCount: 0,
                  manuallyUnread: false,
                ),
          ),
        ),
    };
  }

  Future<({Map<String, PersonInput> names, Map<String, int> pictures})> _people(
    Set<String> ids,
  ) async {
    final users = await (db.select(
      db.users,
    )..where((u) => u.id.isIn(ids))).get();
    return (
      names: {
        for (final u in users)
          u.id: (
            username: u.username,
            firstName: u.firstName,
            lastName: u.lastName,
            nickname: u.nickname,
            status: u.status,
          ),
      },
      pictures: {for (final u in users) u.id: ?u.lastPictureUpdate},
    );
  }

  /// Ids of stored posts in [scope] containing every one of [words], newest
  /// first.
  Future<List<String>> localPostIds(
    SearchScope scope,
    List<String> words, {
    int limit = 60,
  }) async {
    if (words.isEmpty) return const [];
    final query = db.select(db.posts)
      ..where((p) => p.deleteAt.isNull() & p.type.equals(''))
      ..orderBy([(p) => OrderingTerm.desc(p.createAt)])
      ..limit(limit);
    for (final word in words) {
      query.where((p) => p.message.lower().like('%${_escape(word)}%'));
    }
    _narrow(
      scope,
      channelOf: (where) => query.where((p) => where(p.channelId)),
      userOf: (where) => query.where((p) => where(p.userId)),
      timeOf: (where) => query.where((p) => where(p.createAt)),
    );
    return [for (final p in await query.get()) p.id];
  }

  /// Stored files of stored posts in [scope] whose name contains every one
  /// of [words].
  Future<List<FileHit>> localFiles(
    SearchScope scope,
    List<String> words, {
    int limit = 60,
  }) async {
    if (words.isEmpty) return const [];
    final query =
        db.select(db.files).join([
            innerJoin(db.posts, db.posts.id.equalsExp(db.files.postId)),
          ])
          ..where(db.files.deleteAt.isNull() & db.posts.deleteAt.isNull())
          ..orderBy([OrderingTerm.desc(db.posts.createAt)])
          ..limit(limit);
    for (final word in words) {
      query.where(db.files.name.lower().like('%${_escape(word)}%'));
    }
    if (scope.fileKind case final kind?) {
      query.where(db.files.extension.lower().isIn(kind.extensions));
    }
    _narrow(
      scope,
      channelOf: (where) => query.where(where(db.posts.channelId)),
      userOf: (where) => query.where(where(db.posts.userId)),
      timeOf: (where) => query.where(where(db.posts.createAt)),
    );
    final rows = await query.get();
    final places = await placesOf({
      for (final row in rows) row.readTable(db.posts).channelId,
    });
    return [
      for (final row in rows)
        () {
          final f = row.readTable(db.files);
          final p = row.readTable(db.posts);
          return FileHit(
            id: f.id,
            name: f.name,
            extension: f.extension,
            mimeType: f.mimeType,
            size: f.size,
            postId: p.id,
            channelId: p.channelId,
            place: places[p.channelId] ?? '',
            createAt: p.createAt,
            width: f.width,
            height: f.height,
            hasPreview: f.hasPreview,
          );
        }(),
    ];
  }

  void _narrow(
    SearchScope scope, {
    required void Function(Expression<bool> Function(Expression<String>))
    channelOf,
    required void Function(Expression<bool> Function(Expression<String>))
    userOf,
    required void Function(Expression<bool> Function(GeneratedColumn<int>))
    timeOf,
  }) {
    if (scope.channelId case final id?) {
      channelOf((c) => c.equals(id));
    } else if (!scope.allTeams) {
      final inTeam = db.selectOnly(db.channels)
        ..addColumns([db.channels.id])
        ..where(db.channels.teamId.isIn([scope.teamId, '']));
      channelOf((c) => c.isInQuery(inTeam));
    }
    if (scope.userId case final id?) userOf((u) => u.equals(id));
    int day(DateTime d, {int plus = 0}) =>
        DateTime(d.year, d.month, d.day + plus).millisecondsSinceEpoch;
    if (scope.on case final d?) {
      timeOf((t) => t.isBetweenValues(day(d), day(d, plus: 1) - 1));
    }
    if (scope.before case final d?) timeOf((t) => t.isSmallerThanValue(day(d)));
    if (scope.after case final d?) {
      timeOf((t) => t.isBiggerOrEqualValue(day(d, plus: 1)));
    }
  }

  /// Where messages in [channelIds] were posted, as people read it.
  Future<Map<String, String>> placesOf(Set<String> channelIds) async {
    final myId = await db.syncText(SyncKeys.currentUserId) ?? '';
    final channels = await _channels(channelIds);
    final people = await _people({
      myId,
      for (final c in channels.values)
        if (c.input.type == 'D') ...c.input.name.split('__'),
    });
    final format = await db.nameFormat();
    return {
      for (final MapEntry(key: id, value: c) in channels.entries)
        id: c.input.type == 'D' || c.input.type == 'G'
            ? conversationName(
                c.input,
                myId: myId,
                people: people.names,
                nameFormat: format,
              ).title
            : '#${c.input.displayName}',
    };
  }

  /// The team's recent searches, newest first.
  Stream<List<String>> recentSearches(String teamId) =>
      (db.select(db.searchHistory)
            ..where((s) => s.teamId.equals(teamId))
            ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]))
          .watch()
          .map((rows) => [for (final r in rows) r.term])
          .distinct(listEquals);

  static String _escape(String word) => word.replaceAll(RegExp('[%_]'), '');
}
