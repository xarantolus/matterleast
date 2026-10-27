import 'package:drift/drift.dart';
import 'package:matterleast/data/db/throttled_watch.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/store/server_store.dart' show ephemeralType;
import 'package:matterleast/data/views/permission_views.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/domain/conversation_open.dart';
import 'package:matterleast/domain/permissions.dart';
import 'package:matterleast/domain/post_details.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/domain/post_ranges.dart';
import 'package:matterleast/domain/preference_keys.dart';
import 'package:matterleast/domain/server_link.dart';
import 'package:matterleast/domain/teams.dart';

/// What the message menu needs to know beyond the post itself.
typedef PostMenuFacts = ({
  String myId,
  bool saved,

  /// Null when threads can't be followed (no collapsed threads).
  bool? following,

  /// For permalinks; empty when no team is known.
  String teamName,
  MessageRights rights,

  /// The server can remind the user of the message later.
  bool reminders,
});

/// The reads of an open channel or thread: one batched query each, re-run
/// at most every 100 ms while writes land, passed on only when changed.
class ConversationViews {
  ConversationViews(this.db, {this.server});

  final ServerDatabase db;

  /// Links to messages on this server show a card of a stored message.
  final Uri? server;

  static const _interval = Duration(milliseconds: 100);

  /// What the message menu needs to know about [post] beyond the post
  /// itself; [teamId] is the open channel's team, empty when unknown.
  Future<PostMenuFacts> menuFacts(
    PostItem post,
    String teamId, {
    required DateTime now,
  }) async {
    final me = await db.syncText(SyncKeys.currentUserId) ?? '';
    final saved =
        await (db.select(db.preferences)..where(
              (p) =>
                  p.category.equals(Prefs.flaggedPost) & p.name.equals(post.id),
            ))
            .getSingleOrNull();
    final rootId = post.isReply ? post.rootId : post.id;
    bool? following;
    if (await db.collapsedThreads()) {
      final thread = await (db.select(
        db.threads,
      )..where((t) => t.rootId.equals(rootId))).getSingleOrNull();
      following = thread?.isFollowing ?? false;
    }
    final team = teamId.isNotEmpty
        ? teamId
        : await db.syncText(SyncKeys.currentTeamId) ?? '';
    final teamRow = await (db.select(
      db.teams,
    )..where((t) => t.id.equals(team))).getSingleOrNull();
    final channelId = (await (db.select(
      db.posts,
    )..where((p) => p.id.equals(post.id))).getSingleOrNull())?.channelId;
    final channel = channelId == null
        ? noChannelRights
        : await PermissionViews(db).channel(channelId);
    final features = await db.features();
    return (
      myId: me,
      saved: saved != null && saved.value == 'true',
      following: following,
      teamName: teamRow?.name ?? '',
      rights: messageRights(
        channel,
        mine: post.userId == me,
        system: post.isSystem,
        fromWebhook: PostDetails.decode(post.propsJson, null).fromWebhook,
        createAt: post.createAt,
        now: now,
        editTimeLimit: features.editTimeLimit,
        distinctReactions: post.reactions.length,
      ),
      reminders: features.postReminders && !post.isSystem,
    );
  }

  /// What opening a channel or thread (with [rootId]) starts from: the
  /// signed-in user, when it was last read, and the place the reader left
  /// it.
  Future<
    ({
      String? me,
      DateTime? lastViewedAt,
      ({String postId, double offset, DateTime savedAt})? saved,
    })
  >
  openFacts(String channelId, {String? rootId}) async {
    final scope = rootId == null ? 'channel' : 'thread';
    final scopeId = rootId ?? channelId;
    final saved =
        await (db.select(db.viewStates)
              ..where((v) => v.scope.equals(scope) & v.scopeId.equals(scopeId)))
            .getSingleOrNull();
    return (
      me: await db.syncText(SyncKeys.currentUserId),
      lastViewedAt: await _lastViewed(channelId, rootId),
      saved: saved == null
          ? null
          : (
              postId: saved.anchorPostId,
              offset: saved.anchorOffsetPx,
              savedAt: saved.savedAt,
            ),
    );
  }

  Future<DateTime?> _lastViewed(String channelId, String? rootId) async {
    if (rootId == null) {
      return (await (db.select(
            db.myChannels,
          )..where((m) => m.channelId.equals(channelId))).getSingleOrNull())
          ?.lastViewedAt;
    }
    if (!await db.collapsedThreads()) return null;
    return (await (db.select(
      db.threads,
    )..where((t) => t.rootId.equals(rootId))).getSingleOrNull())?.lastViewedAt;
  }

  /// The team a thread's read marks and following are kept in; null
  /// without collapsed threads. [channelTeamId] is the channel's team when
  /// already known.
  Future<String?> threadTeam(
    String channelId, {
    String? channelTeamId,
  }) async => threadReadTeam(
    collapsedThreads: await db.collapsedThreads(),
    channelTeamId:
        channelTeamId ??
        (await (db.select(
          db.channels,
        )..where((c) => c.id.equals(channelId))).getSingleOrNull())?.teamId ??
        '',
    currentTeamId: await db.syncText(SyncKeys.currentTeamId),
  );

  /// Whether the user marked the channel unread and hasn't opened it since.
  Future<bool> markedUnread(String channelId) async =>
      (await (db.select(
            db.myChannels,
          )..where((m) => m.channelId.equals(channelId))).getSingleOrNull())
          ?.manuallyUnread ??
      false;

  /// Whether the user follows the thread; null without collapsed threads,
  /// where there is nothing to follow.
  Stream<bool?> threadFollowing(String rootId) async* {
    if (!await db.collapsedThreads()) {
      yield null;
      return;
    }
    yield* (db.select(db.threads)..where((t) => t.rootId.equals(rootId)))
        .watchSingleOrNull()
        .map((t) => t?.isFollowing ?? false)
        .distinct();
  }

  /// When a stored message was posted; null when it isn't stored.
  Future<DateTime?> postCreatedAt(String postId) async => (await (db.select(
    db.posts,
  )..where((p) => p.id.equals(postId))).getSingleOrNull())?.createAt;

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
      db.drafts,
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
    final crt = await db.collapsedThreads();
    Expression<bool> topLevel($PostsTable p) =>
        // An integration's ephemeral answer to an action names the post
        // as its root; it must show where the action was taken.
        crt
        ? p.rootId.equals('') | p.type.equals(ephemeralType)
        : const Constant(true);
    // Our own posts made here and not yet part of fetched history: queued
    // ones, and sent ones while nothing around them was fetched. They are
    // the newest, so they belong to the newest stretch, loaded or not.
    final showsNewest = range == null || range == newest;
    Expression<bool> ownLocal($PostsTable p) => showsNewest
        ? p.pendingPostId.equals('').not() &
              (range == null
                  ? const Constant(true)
                  : p.createAt.isBiggerThanValue(
                      range.latest.millisecondsSinceEpoch,
                    ))
        : const Constant(false);
    Expression<bool> inRange($PostsTable p) =>
        p.channelId.equals(channelId) &
        topLevel(p) &
        _notDeletedBefore(p, openedAt) &
        ((range == null
                ? const Constant(false)
                : p.createAt.isBetweenValues(
                    range.earliest.millisecondsSinceEpoch,
                    range.latest.millisecondsSinceEpoch,
                  )) |
            ownLocal(p));

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
      loaded: range != null,
      reachesStart: (range?.reachesStart ?? false) && rows.length <= window,
      moreStored: rows.length > window,
      newerApart:
          range != null &&
          newest != null &&
          newest.latest.isAfter(range.latest),
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
    final rows =
        await (db.select(db.posts)
              ..where(
                (p) =>
                    p.rootId.equals(rootId) &
                    _notDeletedBefore(p, openedAt) &
                    ((range == null
                            ? const Constant(false)
                            : p.createAt.isBetweenValues(
                                range.earliest.millisecondsSinceEpoch,
                                range.latest.millisecondsSinceEpoch,
                              )) |
                        // Our own replies made here, as in a channel.
                        (p.pendingPostId.equals('').not() &
                            (range == null
                                ? const Constant(true)
                                : p.createAt.isBiggerThanValue(
                                    range.latest.millisecondsSinceEpoch,
                                  )))),
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
      for (final p in posts) p.id: p.participantIds ?? const [],
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
    final draftRoots = {
      for (final d
          in await (db.select(db.drafts)..where(
                (d) =>
                    d.rootId.isIn([for (final p in posts) p.id]) &
                    (d.message.equals('').not() | d.files.equals('[]').not()),
              ))
              .get())
        d.rootId,
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
          hasDraftReply: draftRoots.contains(p.id),
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
