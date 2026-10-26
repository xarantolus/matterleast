import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:matterleast/data/db/throttled_watch.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/store/server_store.dart' show ephemeralType;
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/domain/permissions.dart';
import 'package:matterleast/domain/post_details.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/domain/post_ranges.dart';
import 'package:matterleast/domain/preference_keys.dart';
import 'package:matterleast/domain/server_link.dart';
import 'package:matterleast/domain/teams.dart';

/// The reads of an open channel or thread: one batched query each, re-run
/// at most every 100 ms while writes land, passed on only when changed.
class ConversationViews {
  ConversationViews(this.db, {this.server});

  final ServerDatabase db;

  /// Links to messages on this server show a card of a stored message.
  final Uri? server;

  static const _interval = Duration(milliseconds: 100);

  /// How many stored replies of [rootId] are newer than [postId]; null
  /// when that message isn't stored.
  Future<int?> repliesAfter(String rootId, String postId) async {
    final target = await (db.select(
      db.posts,
    )..where((p) => p.id.equals(postId))).getSingleOrNull();
    if (target == null) return null;
    final count = db.posts.id.count();
    return (db.selectOnly(db.posts)
          ..addColumns([count])
          ..where(
            db.posts.rootId.equals(rootId) &
                db.posts.createAt.isBiggerThanValue(
                  target.createAt.millisecondsSinceEpoch,
                ),
          ))
        .map((row) => row.read(count) ?? 0)
        .getSingle();
  }

  /// The newest [limit] messages of the loaded range containing [rangeAt]
  /// (the newest range when null), and at least those after [unreadAfter],
  /// so the new-messages line is in the window. Messages deleted before
  /// [openedAt] are left out; those deleted since stay as placeholders.
  Stream<ConversationWindow> channel(
    String channelId, {
    required int limit,
    required DateTime openedAt,
    DateTime? rangeAt,
    DateTime? unreadAfter,
  }) => throttledWatch(
    _changes(),
    () => _channel(channelId, limit, openedAt, rangeAt, unreadAfter),
    interval: _interval,
  ).distinct();

  /// The thread of [rootId]: its first message and the newest [limit]
  /// stored replies of the loaded range.
  Stream<ConversationWindow> thread(
    String rootId, {
    required int limit,
    required DateTime openedAt,
  }) => throttledWatch(
    _changes(),
    () => _thread(rootId, limit, openedAt),
    interval: _interval,
  ).distinct();

  Stream<Object?> _changes() => db.tableUpdates(
    TableUpdateQuery.onAllTables([
      db.posts,
      db.postRanges,
      db.users,
      db.channels,
      db.preferences,
      db.config,
      db.threads,
      db.reactions,
    ]),
  );

  Future<List<PostRange>> _ranges(String scope, String scopeId) async => [
    for (final r in await (db.select(
      db.postRanges,
    )..where((r) => r.scope.equals(scope) & r.scopeId.equals(scopeId))).get())
      PostRange(
        earliest: r.earliest,
        latest: r.latest,
        reachesStart: r.reachesStart,
      ),
  ];

  Future<ConversationWindow> _channel(
    String channelId,
    int limit,
    DateTime openedAt,
    DateTime? rangeAt,
    DateTime? unreadAfter,
  ) async {
    final channel = await (db.select(
      db.channels,
    )..where((c) => c.id.equals(channelId))).getSingleOrNull();
    final ranges = await _ranges('channel', channelId);
    final newest = newestRange(ranges);
    final range = rangeAt == null
        ? newest
        : rangeContaining(ranges, rangeAt) ?? newest;
    final header = (
      channelName: channel?.displayName ?? '',
      channelType: channel?.type ?? '',
      partnerId: channel?.type == 'D'
          ? directPartnerId(
              channel!.name,
              await db.syncText(SyncKeys.currentUserId) ?? '',
            )
          : null,
      teamId: channel?.teamId ?? '',
      memberCount: channel?.memberCount,
      archived: channel?.deleteAt != null,
    );
    if (range == null) {
      return ConversationWindow(
        posts: const [],
        loaded: false,
        channelName: header.channelName,
        channelType: header.channelType,
        partnerId: header.partnerId,
        teamId: header.teamId,
        memberCount: header.memberCount,
        archived: header.archived,
      );
    }
    final crt = await db.collapsedThreads();
    Expression<bool> inRange($PostsTable p) =>
        p.channelId.equals(channelId) &
        p.createAt.isBetweenValues(
          range.earliest.millisecondsSinceEpoch,
          range.latest.millisecondsSinceEpoch,
        ) &
        // An integration's ephemeral answer to an action names the post
        // as its root; it must show where the action was taken.
        (crt
            ? p.rootId.equals('') | p.type.equals(ephemeralType)
            : const Constant(true)) &
        _notDeletedBefore(p, openedAt);

    var window = limit;
    if (unreadAfter != null) {
      final count = db.posts.id.count();
      final unread =
          await (db.selectOnly(db.posts)
                ..addColumns([count])
                ..where(
                  inRange(db.posts) &
                      db.posts.createAt.isBiggerThanValue(
                        unreadAfter.millisecondsSinceEpoch,
                      ),
                ))
              .map((row) => row.read(count) ?? 0)
              .getSingle();
      window = window < unread + 20 ? (unread + 20).clamp(0, 500) : window;
    }
    final rows =
        await (db.select(db.posts)
              ..where(inRange)
              ..orderBy([(p) => OrderingTerm.desc(p.createAt)])
              ..limit(window + 1))
            .get();
    final shown = rows.take(window).toList();
    return ConversationWindow(
      posts: await _items(shown),
      loaded: true,
      reachesStart: range.reachesStart && rows.length <= window,
      moreStored: rows.length > window,
      newerApart: newest != null && newest.latest.isAfter(range.latest),
      channelName: header.channelName,
      channelType: header.channelType,
      partnerId: header.partnerId,
      teamId: header.teamId,
      memberCount: header.memberCount,
      archived: header.archived,
    );
  }

  Expression<bool> _notDeletedBefore($PostsTable p, DateTime at) =>
      p.deleteAt.isNull() |
      p.deleteAt.isBiggerThanValue(at.millisecondsSinceEpoch);

  Future<ConversationWindow> _thread(
    String rootId,
    int limit,
    DateTime openedAt,
  ) async {
    final root = await (db.select(
      db.posts,
    )..where((p) => p.id.equals(rootId))).getSingleOrNull();
    final channel = root == null
        ? null
        : await (db.select(
            db.channels,
          )..where((c) => c.id.equals(root.channelId))).getSingleOrNull();
    final range = newestRange(await _ranges('thread', rootId));
    final rows = range == null
        ? <PostRow>[]
        : await (db.select(db.posts)
                ..where(
                  (p) =>
                      p.rootId.equals(rootId) &
                      _notDeletedBefore(p, openedAt) &
                      p.createAt.isBetweenValues(
                        range.earliest.millisecondsSinceEpoch,
                        range.latest.millisecondsSinceEpoch,
                      ),
                )
                ..orderBy([(p) => OrderingTerm.desc(p.createAt)])
                ..limit(limit + 1))
              .get();
    final shown = rows.take(limit).toList();
    final items = await _items([?root, ...shown]);
    return ConversationWindow(
      posts: root == null ? items : items.skip(1).toList(),
      root: root == null ? null : items.first,
      loaded: range != null,
      reachesStart: (range?.reachesStart ?? false) && rows.length <= limit,
      moreStored: rows.length > limit,
      channelName: channel?.displayName ?? '',
      teamId: channel?.teamId ?? '',
      archived: channel?.deleteAt != null,
    );
  }

  Future<List<PostItem>> _items(List<PostRow> posts) async {
    final participants = {
      for (final p in posts) p.id: _ids(p.participantIdsJson),
    };
    final details = {
      for (final p in posts)
        p.id: detailsFor(p.id, p.propsJson, p.metadataJson),
    };
    final features = await db.features();
    final links = features.permalinkPreviews
        ? await _linkedPosts(posts, details)
        : const <String, _Linked>{};
    final ids = {
      for (final p in posts) p.userId,
      for (final list in participants.values) ...list,
      for (final d in details.values)
        for (final a in d.acknowledgements) a.userId,
      for (final l in links.values) l.authorId,
    };
    final saved = {
      for (final pref
          in await (db.select(db.preferences)..where(
                (pref) =>
                    pref.category.equals(Prefs.flaggedPost) &
                    pref.name.isIn([for (final p in posts) p.id]) &
                    pref.value.equals('true'),
              ))
              .get())
        pref.name,
    };
    final people = {
      for (final u in await (db.select(
        db.users,
      )..where((u) => u.id.isIn(ids))).get())
        u.id: (
          username: u.username,
          firstName: u.firstName,
          lastName: u.lastName,
          nickname: u.nickname,
          status: u.status,
          isBot: u.isBot,
          isGuest: isGuest(u.roles),
          pictureAt: u.lastPictureUpdate,
        ),
    };
    final format = await db.nameFormat();
    final me = await db.syncText(SyncKeys.currentUserId);
    final reacted = [
      for (final p in posts)
        if (p.reactionCount > 0) p.id,
    ];
    final reactionRows = reacted.isEmpty
        ? const <ReactionRow>[]
        : await (db.select(
            db.reactions,
          )..where((r) => r.postId.isIn(reacted))).get();
    final reactors = {for (final r in reactionRows) r.userId}
      ..removeAll(people.keys);
    if (reactors.isNotEmpty) {
      for (final u in await (db.select(
        db.users,
      )..where((u) => u.id.isIn(reactors))).get()) {
        people[u.id] = (
          username: u.username,
          firstName: u.firstName,
          lastName: u.lastName,
          nickname: u.nickname,
          status: u.status,
          isBot: u.isBot,
          isGuest: isGuest(u.roles),
          pictureAt: u.lastPictureUpdate,
        );
      }
    }
    final reactionsByPost =
        <String, List<({String userId, String emojiName, DateTime? at})>>{};
    for (final r in reactionRows) {
      reactionsByPost.putIfAbsent(r.postId, () => []).add((
        userId: r.userId,
        emojiName: r.emojiName,
        at: r.createAt,
      ));
    }
    final roots = [
      for (final p in posts)
        if (p.replyCount > 0) p.id,
    ];
    final unread = {
      for (final t in await (db.select(
        db.threads,
      )..where((t) => t.rootId.isIn(roots))).get())
        t.rootId: t.unreadReplies,
    };
    String nameOf(String id) {
      final person = people[id];
      if (person == null) return 'Someone';
      return personName((
        username: person.username,
        firstName: person.firstName,
        lastName: person.lastName,
        nickname: person.nickname,
        status: person.status,
      ), format);
    }

    PostPerson personOf(String id) => (
      id: id,
      name: nameOf(id),
      username: people[id]?.username ?? '',
      pictureAt: people[id]?.pictureAt,
    );

    return [
      for (final p in posts)
        PostItem(
          id: p.id,
          key: p.pendingPostId.isNotEmpty ? p.pendingPostId : p.id,
          userId: p.userId,
          authorName: nameOf(p.userId),
          createAt: p.createAt,
          message: p.message,
          type: p.type,
          rootId: p.rootId,
          editAt: p.editAt,
          deleted: p.deleteAt != null,
          sendState: p.sendState,
          pinned: p.isPinned,
          saved: saved.contains(p.id),
          linked: switch (links[p.id]) {
            final l? => LinkedPostPreview(
              postId: l.postId,
              teamName: l.teamName,
              authorId: l.authorId,
              authorName: nameOf(l.authorId),
              authorPictureAt: people[l.authorId]?.pictureAt,
              channelName: l.direct ? nameOf(l.authorId) : l.channelName,
              createAt: l.createAt,
              message: l.message,
            ),
            null => null,
          },
          acknowledgedBy: [
            for (final a in details[p.id]!.acknowledgements) personOf(a.userId),
          ],
          acknowledgedAt: details[p.id]!.acknowledgements
              .where((a) => a.userId == me)
              .firstOrNull
              ?.at,
          replyCount: p.replyCount,
          lastReplyAt: p.lastReplyAt,
          authorUsername: people[p.userId]?.username ?? '',
          authorIsBot: people[p.userId]?.isBot ?? false,
          authorIsGuest: people[p.userId]?.isGuest ?? false,
          authorPictureAt: people[p.userId]?.pictureAt,
          propsJson: p.propsJson,
          metadataJson: p.metadataJson,
          decodeProblem: p.decodeProblem,
          reactions: groupReactions(
            reactionsByPost[p.id] ?? const [],
            myUserId: me,
            personOf: personOf,
          ),
          unreadReplies: unread[p.id] ?? 0,
          participants: [
            for (final id in participants[p.id]!)
              if (people.containsKey(id)) personOf(id),
          ],
        ),
    ];
  }

  /// The message each post links to: as the server embedded it, else a
  /// stored one a link in the text points to.
  Future<Map<String, _Linked>> _linkedPosts(
    List<PostRow> posts,
    Map<String, PostDetails> details,
  ) async {
    final linked = <String, _Linked>{};
    final wanted = <String, PostLink>{};
    for (final p in posts) {
      if (p.deleteAt != null) continue;
      final embed = details[p.id]!.permalink;
      final post = embed?.post;
      if (embed != null && post != null) {
        linked[p.id] = (
          postId: embed.postId!,
          teamName: embed.teamName ?? '',
          authorId: post.userId ?? '',
          channelName: embed.channelDisplayName ?? '',
          direct: embed.channelType == 'D',
          createAt: post.createAt ?? DateTime.fromMillisecondsSinceEpoch(0),
          message: post.message ?? '',
        );
        continue;
      }
      final server = this.server;
      if (server == null) continue;
      if (firstPostLink(p.message, server) case final link?
          when link.postId != p.id) {
        wanted[p.id] = link;
      }
    }
    if (wanted.isEmpty) return linked;
    final targets = {for (final link in wanted.values) link.postId};
    final rows = {
      for (final r in await (db.select(
        db.posts,
      )..where((r) => r.id.isIn(targets) & r.deleteAt.isNull())).get())
        r.id: r,
    };
    final channels = {
      for (final c
          in await (db.select(db.channels)..where(
                (c) => c.id.isIn([for (final r in rows.values) r.channelId]),
              ))
              .get())
        c.id: c,
    };
    for (final MapEntry(key: id, value: link) in wanted.entries) {
      final row = rows[link.postId];
      final channel = row == null ? null : channels[row.channelId];
      if (row == null || channel == null) continue;
      linked[id] = (
        postId: link.postId,
        teamName: link.team,
        authorId: row.userId,
        channelName: channel.displayName,
        direct: channel.type == 'D',
        createAt: row.createAt,
        message: row.message,
      );
    }
    return linked;
  }

  List<String> _ids(String? json) {
    if (json == null) return const [];
    final decoded = jsonDecode(json);
    return decoded is List ? decoded.whereType<String>().toList() : const [];
  }
}

typedef _Linked = ({
  String postId,
  String teamName,
  String authorId,
  String channelName,
  bool direct,
  DateTime createAt,
  String message,
});
