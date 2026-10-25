import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/store/mappers.dart';
import 'package:matterleast/domain/autocomplete.dart';
import 'package:matterleast/domain/inbox.dart';
import 'package:matterleast/domain/outbox.dart';
import 'package:matterleast/domain/post_ranges.dart';
import 'package:matterleast/domain/preference_keys.dart';

/// How a page of posts was fetched, which decides how it joins the cached
/// history (see [PostRange]).
enum PageKind {
  /// Newest page of a channel or thread (`page=0`).
  page,

  /// Older than an anchor post (`before=`).
  before,

  /// Newer than an anchor post (`after=`).
  after,

  /// Everything changed since a watermark (`since=`), on the newest range.
  since,

  /// The window around a permalinked post.
  around,
}

/// Outcome of applying a page: whether a `since` answer hit the server's
/// cap, in which case the newest range was not extended and the caller
/// fetches a fresh first page.
class PageOutcome {
  const PageOutcome({required this.stored, required this.capped});

  final int stored;
  final bool capped;
}

const sinceCap = 1000;

abstract final class PostListNames {
  static const mentions = 'mentions';
  static const saved = 'saved';
}

/// The only write path into a server database. Each method is one
/// transaction, so a watcher wakes once per logical change.
class ServerStore {
  ServerStore(this.db);

  final ServerDatabase db;

  Future<void> applyMe(api.User me) => db.transaction(() async {
    await db.into(db.users).insertOnConflictUpdate(userCompanion(me));
    await db.setSyncText(SyncKeys.currentUserId, me.id);
    if (me.username case final username? when username.isNotEmpty) {
      await db.setSyncText(
        SyncKeys.mentionTerms,
        mentionTerms(
          username: username,
          firstName: me.firstName ?? '',
          mentionKeys: me.notifyProps?.mentionKeys,
          firstNameKey: me.notifyProps?.firstName,
        ),
      );
    }
  });

  Future<void> applyUsers(Iterable<api.User> users) => db.batch((b) {
    b.insertAllOnConflictUpdate(db.users, [
      for (final u in users)
        if (u.id != null) userCompanion(u),
    ]);
  });

  Future<void> applyConfig(String key, Map<String, Object?> json) => db
      .into(db.config)
      .insertOnConflictUpdate(
        ConfigCompanion.insert(
          key: key,
          json: jsonEncode(json),
          fetchedAt: DateTime.now().toUtc(),
        ),
      );

  Future<void> applyTeams(
    Iterable<api.Team> teams,
    Iterable<api.TeamMember> members,
  ) => db.batch((b) {
    b.insertAllOnConflictUpdate(db.teams, [
      for (final t in teams)
        if (t.id != null) teamCompanion(t),
    ]);
    b.insertAllOnConflictUpdate(db.myTeams, [
      for (final m in members)
        if (m.teamId != null) myTeamCompanion(m),
    ]);
  });

  /// Channels and memberships of one team (or the server's DMs when
  /// [categories] is null). Local-only columns such as the posts watermark
  /// and the collapse state survive because absent values are not written.
  Future<void> applyChannels({
    required Iterable<api.Channel> channels,
    required Iterable<api.ChannelMember> members,
    api.OrderedSidebarCategories? categories,
  }) => db.transaction(() async {
    await db.batch((b) {
      b.insertAllOnConflictUpdate(db.channels, [
        for (final c in channels)
          if (c.id != null) channelCompanion(c),
      ]);
      b.insertAllOnConflictUpdate(db.myChannels, [
        for (final m in members)
          if (m.channelId != null) myChannelCompanion(m),
      ]);
    });
    if (categories != null) await _applyCategories(categories);
  });

  Future<void> _applyCategories(api.OrderedSidebarCategories ordered) async {
    final order = ordered.order;
    final teamIds = ordered.categories.map((c) => c.teamId).nonNulls.toSet();
    final ids = ordered.categories.map((c) => c.id).nonNulls.toList();
    await db.batch((b) {
      b.insertAllOnConflictUpdate(db.categories, [
        for (final c in ordered.categories)
          if (c.id != null) categoryCompanion(c, order.indexOf(c.id!)),
      ]);
    });
    for (final teamId in teamIds) {
      await (db.delete(
        db.categories,
      )..where((c) => c.teamId.equals(teamId) & c.id.isNotIn(ids))).go();
    }
    await (db.delete(
      db.categoryChannels,
    )..where((cc) => cc.categoryId.isIn(ids))).go();
    await db.batch((b) {
      b.insertAll(db.categoryChannels, [
        for (final c in ordered.categories)
          if (c.id != null)
            for (final (i, channelId) in c.channelIds.indexed)
              CategoryChannelsCompanion.insert(
                categoryId: c.id!,
                channelId: channelId,
                sortOrder: Value(i),
              ),
      ], mode: InsertMode.insertOrIgnore);
    });
  }

  Future<void> applyPreferences(Iterable<api.Preference> preferences) =>
      db.batch((b) {
        b.insertAllOnConflictUpdate(db.preferences, [
          for (final p in preferences)
            if (p.category != null) preferenceCompanion(p),
        ]);
      });

  Future<void> applyCustomEmoji(Iterable<api.Emoji> emoji) =>
      db.batch((b) => _upsertEmoji(b, emoji));

  void _upsertEmoji(Batch b, Iterable<api.Emoji> emoji) {
    final usable = [
      for (final e in emoji)
        if (e.id != null && e.name != null && e.deleteAt == null) e,
    ];
    if (usable.isEmpty) return;
    // A name freed by a deleted emoji can come back under a new id; the
    // old row would otherwise clash with the unique name.
    b.deleteWhere(
      db.customEmoji,
      (row) =>
          row.name.isIn([for (final e in usable) e.name!]) &
          row.id.isNotIn([for (final e in usable) e.id!]),
    );
    b.insertAllOnConflictUpdate(db.customEmoji, [
      for (final e in usable) emojiCompanion(e),
    ]);
  }

  /// The first part of an entry sync: config, licence, preferences, the
  /// user and their teams. Teams the user is no longer in go, with
  /// everything in them.
  Future<void> applyEntry({
    required Map<String, Object?>? config,
    required Map<String, Object?>? license,
    required List<api.Preference> preferences,
    required api.User me,
    required List<api.Team> teams,
    required List<api.TeamMember> members,
  }) => db.transaction(() async {
    if (config != null) await applyConfig('client_config', config);
    if (license != null) await applyConfig('license', license);
    await db.delete(db.preferences).go();
    await applyPreferences(preferences);
    await applyMe(me);
    final joined = {
      for (final m in members)
        if (m.teamId != null && m.deleteAt == null) m.teamId!,
    };
    for (final mine in await db.select(db.myTeams).get()) {
      if (!joined.contains(mine.teamId)) await removeTeam(mine.teamId);
    }
    await applyTeams(
      teams.where((t) => joined.contains(t.id)),
      members.where((m) => joined.contains(m.teamId)),
    );
  });

  /// Channels, memberships and categories of one team as the server listed
  /// them, which includes the user's direct and group messages. Channels no
  /// longer listed are gone (left elsewhere); archived ones stay, since the
  /// server only lists those archived after [since].
  Future<void> applyTeamChannels({
    required String teamId,
    required List<api.Channel> channels,
    required List<api.ChannelMember> members,
    required api.OrderedSidebarCategories categories,
    required DateTime syncedAt,
  }) => db.transaction(() async {
    final memberOf = {for (final m in members) ?m.channelId};
    final listed = [
      for (final c in channels)
        if (memberOf.contains(c.id)) c,
    ];
    final listedIds = [for (final c in listed) c.id!];
    final stale =
        await (db.select(db.channels)..where(
              (c) =>
                  (c.teamId.equals(teamId) | c.teamId.equals('')) &
                  c.deleteAt.isNull() &
                  c.id.isNotIn(listedIds),
            ))
            .get();
    for (final channel in stale) {
      await removeChannel(channel.id);
    }
    await applyChannels(
      channels: listed,
      members: members.where((m) => listedIds.contains(m.channelId)),
      categories: categories,
    );
    await db.setSyncInt(
      SyncKeys.channelsSince(teamId),
      syncedAt.millisecondsSinceEpoch,
    );
  });

  Future<void> applyTeamUnreads(Iterable<api.TeamUnread> unreads) =>
      db.batch((b) {
        for (final u in unreads) {
          if (u.teamId == null) continue;
          b.update(
            db.myTeams,
            MyTeamsCompanion(
              msgCount: Value(u.msgCount ?? 0),
              mentionCount: Value(u.mentionCount ?? 0),
              msgCountRoot: Value(u.msgCountRoot ?? 0),
              mentionCountRoot: Value(u.mentionCountRoot ?? 0),
            ),
            where: (t) => t.teamId.equals(u.teamId!),
          );
        }
      });

  Future<Set<String>> roleNames() async => {
    for (final r in await db.select(db.roles).get()) r.name,
  };

  Future<void> applyRoles(Iterable<api.Role> roles) => db.batch((b) {
    b.insertAllOnConflictUpdate(db.roles, [
      for (final r in roles)
        if (r.name != null) roleCompanion(r),
    ]);
  });

  /// Presence by user id; users not stored yet are skipped.
  Future<void> applyStatuses(Map<String, String> statusByUser) => db.batch((b) {
    for (final MapEntry(key: userId, value: status) in statusByUser.entries) {
      b.update(
        db.users,
        UsersCompanion(status: Value(status)),
        where: (u) => u.id.equals(userId) & u.status.equals(status).not(),
      );
    }
  });

  Future<void> applyChannel(api.Channel channel) async {
    if (channel.id == null) return;
    await db
        .into(db.channels)
        .insertOnConflictUpdate(channelCompanion(channel));
  }

  Future<void> applyChannelMember(api.ChannelMember member) async {
    if (member.channelId == null) return;
    await db
        .into(db.myChannels)
        .insertOnConflictUpdate(myChannelCompanion(member));
  }

  /// The user's notification settings for a channel, as JSON.
  Future<void> applyNotifyProps(String channelId, String? json) =>
      (db.update(db.myChannels)..where((m) => m.channelId.equals(channelId)))
          .write(MyChannelsCompanion(notifyPropsJson: Value(json)));

  /// Archives the channel, or restores it when [at] is null.
  Future<void> applyChannelArchived(String channelId, DateTime? at) =>
      (db.update(db.channels)..where((c) => c.id.equals(channelId))).write(
        ChannelsCompanion(deleteAt: Value(at)),
      );

  /// The user left the channel or was removed from it.
  Future<void> removeChannel(String channelId) => db.transaction(() async {
    await (db.delete(db.channels)..where((c) => c.id.equals(channelId))).go();
    await (db.delete(
      db.myChannels,
    )..where((m) => m.channelId.equals(channelId))).go();
    await (db.delete(
      db.categoryChannels,
    )..where((cc) => cc.channelId.equals(channelId))).go();
  });

  /// The user left the team, or it was archived.
  Future<void> removeTeam(String teamId) => db.transaction(() async {
    final channels = await (db.select(
      db.channels,
    )..where((c) => c.teamId.equals(teamId))).get();
    for (final c in channels) {
      await removeChannel(c.id);
    }
    final categoryIds = [
      for (final c in await (db.select(
        db.categories,
      )..where((c) => c.teamId.equals(teamId))).get())
        c.id,
    ];
    await (db.delete(
      db.categoryChannels,
    )..where((cc) => cc.categoryId.isIn(categoryIds))).go();
    await (db.delete(
      db.categories,
    )..where((c) => c.teamId.equals(teamId))).go();
    await (db.delete(
      db.threadTeams,
    )..where((t) => t.teamId.equals(teamId))).go();
    await (db.delete(db.myTeams)..where((t) => t.teamId.equals(teamId))).go();
    await (db.delete(db.teams)..where((t) => t.id.equals(teamId))).go();
    await (db.delete(
      db.syncState,
    )..where((s) => s.key.equals(SyncKeys.channelsSince(teamId)))).go();
  });

  /// Channels read elsewhere (another device or tab).
  Future<void> applyChannelsViewed(Map<String, DateTime> viewedAt) =>
      db.transaction(() async {
        for (final MapEntry(key: channelId, value: at) in viewedAt.entries) {
          await markViewed(channelId, at: at);
        }
      });

  /// Categories changed elsewhere; their order among the others and the
  /// local collapse state stay.
  Future<void> applyCategoryUpdates(
    Iterable<api.SidebarCategoryWithChannels> categories,
  ) => db.transaction(() async {
    final updated = [
      for (final c in categories)
        if (c.id != null) c,
    ];
    if (updated.isEmpty) return;
    final ids = [for (final c in updated) c.id!];
    await db.batch((b) {
      for (final c in updated) {
        b.insert(
          db.categories,
          categoryCompanion(c, 0),
          onConflict: DoUpdate(
            (_) => categoryCompanion(
              c,
              0,
            ).copyWith(sortOrder: const Value.absent()),
          ),
        );
      }
      b.deleteWhere(db.categoryChannels, (cc) => cc.categoryId.isIn(ids));
      b.insertAll(db.categoryChannels, [
        for (final c in updated)
          for (final (i, channelId) in c.channelIds.indexed)
            CategoryChannelsCompanion.insert(
              categoryId: c.id!,
              channelId: channelId,
              sortOrder: Value(i),
            ),
      ], mode: InsertMode.insertOrIgnore);
    });
  });

  Future<void> deletePreferences(Iterable<api.Preference> preferences) =>
      db.batch((b) {
        for (final p in preferences) {
          if (p.category == null) continue;
          b.deleteWhere(
            db.preferences,
            (row) =>
                row.category.equals(p.category!) &
                row.name.equals(p.name ?? ''),
          );
        }
      });

  /// Followed threads of a team. With [allUnread], [threads] are all its
  /// unread threads, so any other stored thread of the team counts as read.
  Future<void> applyThreads(
    String teamId,
    Iterable<api.UserThread> threads, {
    bool allUnread = false,
  }) => db.transaction(() async {
    final usable = [
      for (final t in threads)
        if (t.id != null && t.post?.channelId != null) t,
    ];
    if (allUnread) {
      final teamThreads = db.selectOnly(db.threadTeams)
        ..addColumns([db.threadTeams.rootId])
        ..where(db.threadTeams.teamId.equals(teamId));
      await (db.update(db.threads)..where(
            (t) =>
                t.rootId.isInQuery(teamThreads) &
                t.rootId.isNotIn([for (final t in usable) t.id!]),
          ))
          .write(
            const ThreadsCompanion(
              unreadReplies: Value(0),
              unreadMentions: Value(0),
            ),
          );
    }
    await _upsertPosts([for (final t in usable) t.post!]);
    await db.batch((b) {
      // A thread's post comes without its reply count; the thread has it.
      for (final t in usable) {
        b.update(
          db.posts,
          PostsCompanion(
            replyCount: Value(t.replyCount ?? 0),
            participantIdsJson: Value(
              jsonEncode([for (final u in t.participants) ?u.id]),
            ),
          ),
          where: (p) => p.id.equals(t.id!),
        );
      }
      b.insertAllOnConflictUpdate(db.threads, [
        for (final t in usable) threadCompanion(t, t.post!.channelId!),
      ]);
      b.insertAll(db.threadTeams, [
        for (final t in usable)
          ThreadTeamsCompanion.insert(teamId: teamId, rootId: t.id!),
      ], mode: InsertMode.insertOrIgnore);
    });
  });

  /// A thread was read elsewhere; a null [threadId] means all of the team's.
  Future<void> applyThreadRead({
    required String teamId,
    String? threadId,
    DateTime? lastViewedAt,
    int unreadReplies = 0,
    int unreadMentions = 0,
  }) {
    final update = db.update(db.threads);
    if (threadId != null) {
      update.where((t) => t.rootId.equals(threadId));
    } else {
      final teamThreads = db.selectOnly(db.threadTeams)
        ..addColumns([db.threadTeams.rootId])
        ..where(db.threadTeams.teamId.equals(teamId));
      update.where((t) => t.rootId.isInQuery(teamThreads));
    }
    return update.write(
      ThreadsCompanion(
        lastViewedAt: lastViewedAt == null
            ? const Value.absent()
            : Value(lastViewedAt),
        unreadReplies: Value(unreadReplies),
        unreadMentions: Value(unreadMentions),
      ),
    );
  }

  /// With [channelId], a thread not stored yet is added, as following one
  /// from its screen does.
  Future<void> applyThreadFollow(
    String threadId, {
    required bool following,
    int? replyCount,
    String? channelId,
  }) {
    final changes = ThreadsCompanion(
      isFollowing: Value(following),
      replyCount: replyCount == null ? const Value.absent() : Value(replyCount),
    );
    if (channelId == null) {
      return (db.update(
        db.threads,
      )..where((t) => t.rootId.equals(threadId))).write(changes);
    }
    return db
        .into(db.threads)
        .insert(
          changes.copyWith(
            rootId: Value(threadId),
            channelId: Value(channelId),
          ),
          onConflict: DoUpdate((_) => changes),
        );
  }

  Future<void> setCategoryCollapsed(
    String categoryId, {
    required bool collapsed,
  }) => (db.update(db.categories)..where((c) => c.id.equals(categoryId))).write(
    CategoriesCompanion(collapsed: Value(collapsed)),
  );

  /// Replaces the id list [list] (`mentions`, `saved`) with [page]'s order
  /// and stores its posts. They stay outside any channel range, so they
  /// never show up as channel history.
  Future<void> applyPostList(
    String list,
    api.PostList page, {
    required DateTime fetchedAt,
  }) => db.transaction(() async {
    final posts = [
      for (final p in (page.posts ?? const <String, api.Post>{}).values)
        if (p.id != null && p.createAt != null && p.channelId != null) p,
    ];
    await _upsertPosts(posts);
    final stored = {for (final p in posts) p.id!};
    await (db.delete(db.postLists)..where((l) => l.list.equals(list))).go();
    await db.batch((b) {
      b.insertAll(db.postLists, [
        for (final (rank, id) in page.order.where(stored.contains).indexed)
          PostListsCompanion.insert(list: list, postId: id, rank: rank),
      ], mode: InsertMode.insertOrIgnore);
    });
    await db.setSyncInt(
      SyncKeys.listFetchedAt(list),
      fetchedAt.millisecondsSinceEpoch,
    );
  });

  /// Puts a stored post at the top of [list].
  Future<void> _prependToList(String list, String postId) async {
    final top = db.postLists.rank.min();
    final current =
        await (db.selectOnly(db.postLists)
              ..addColumns([top])
              ..where(db.postLists.list.equals(list)))
            .map((row) => row.read(top))
            .getSingle();
    await db
        .into(db.postLists)
        .insert(
          PostListsCompanion.insert(
            list: list,
            postId: postId,
            rank: (current ?? 0) - 1,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  /// Messages saved or unsaved elsewhere, from `flagged_post` preferences.
  /// Returns the ids of newly saved posts that are not stored yet, which
  /// need the saved list fetched again.
  Future<List<String>> applySavedChanges(
    Iterable<api.Preference> preferences, {
    required bool deleted,
  }) => db.transaction(() async {
    final missing = <String>[];
    for (final p in preferences) {
      if (p.category != Prefs.flaggedPost || p.name == null) continue;
      final postId = p.name!;
      if (deleted || p.value != 'true') {
        await (db.delete(db.postLists)..where(
              (l) =>
                  l.list.equals(PostListNames.saved) & l.postId.equals(postId),
            ))
            .go();
        continue;
      }
      final known = await (db.select(
        db.posts,
      )..where((row) => row.id.equals(postId))).getSingleOrNull();
      if (known == null) {
        missing.add(postId);
      } else {
        await _prependToList(PostListNames.saved, postId);
      }
    }
    return missing;
  });

  /// Remembers the channel opened last in [teamId].
  Future<void> setLastChannel(String teamId, String channelId) =>
      db.setSyncText(SyncKeys.lastChannel(teamId), channelId);

  Future<void> setCurrentTeam(String teamId) =>
      db.setSyncText(SyncKeys.currentTeamId, teamId);

  Future<List<PostRange>> rangesFor(String scope, String scopeId) async {
    final rows = await (db.select(
      db.postRanges,
    )..where((r) => r.scope.equals(scope) & r.scopeId.equals(scopeId))).get();
    return [
      for (final r in rows)
        PostRange(
          earliest: r.earliest,
          latest: r.latest,
          reachesStart: r.reachesStart,
        ),
    ];
  }

  Future<void> _writeRanges(
    String scope,
    String scopeId,
    List<PostRange> ranges,
  ) async {
    await (db.delete(
      db.postRanges,
    )..where((r) => r.scope.equals(scope) & r.scopeId.equals(scopeId))).go();
    await db.batch((b) {
      b.insertAll(db.postRanges, [
        for (final r in ranges)
          PostRangesCompanion.insert(
            scope: scope,
            scopeId: scopeId,
            earliest: r.earliest,
            latest: r.latest,
            reachesStart: Value(r.reachesStart),
          ),
      ]);
    });
  }

  /// Stores a page of channel posts and joins it to the cached history.
  /// [anchor] is the create time of the `before`/`after` anchor post;
  /// [requested] the page size asked for.
  Future<PageOutcome> applyChannelPage({
    required String channelId,
    required api.PostList page,
    required PageKind kind,
    DateTime? anchor,
    int requested = 60,
  }) => db.transaction(() async {
    final posts = [
      for (final id in page.order)
        if (page.posts?[id] case final api.Post p
            when p.id != null && p.createAt != null && p.channelId != null)
          p,
    ];
    final others = [
      for (final e in (page.posts ?? const {}).entries)
        if (!page.order.contains(e.key) &&
            e.value.id != null &&
            e.value.createAt != null &&
            e.value.channelId != null)
          e.value,
    ];
    await _upsertPosts([...posts, ...others]);

    final times = posts.map((p) => p.createAt!).toList()..sort();
    final earliest = times.isEmpty ? null : times.first;
    final latest = times.isEmpty ? null : times.last;
    final ranges = await rangesFor('channel', channelId);
    var capped = false;
    final updated = switch (kind) {
      PageKind.page => withPage(
        ranges,
        earliest: earliest,
        latest: latest,
        reachesStart: posts.length < requested,
      ),
      PageKind.around => withPage(
        ranges,
        earliest: earliest,
        latest: latest,
        reachesStart: false,
      ),
      PageKind.before => withOlder(
        ranges,
        anchor: anchor!,
        earliest: earliest,
        reachesStart: posts.length < requested,
      ),
      PageKind.after => withNewer(ranges, anchor: anchor!, latest: latest),
      PageKind.since => () {
        if (posts.length >= sinceCap) {
          capped = true;
          return ranges;
        }
        final newest = newestRange(ranges);
        if (newest == null) {
          return withPage(
            ranges,
            earliest: earliest,
            latest: latest,
            reachesStart: false,
          );
        }
        return withNewer(ranges, anchor: newest.latest, latest: latest);
      }(),
    };
    await _writeRanges('channel', channelId, updated);

    if (kind == PageKind.since) {
      await _advanceWatermark(channelId, [...posts, ...others]);
    }
    return PageOutcome(stored: posts.length + others.length, capped: capped);
  });

  /// Stores a thread (root plus replies) and records its loaded range: the
  /// newest replies for [PageKind.page], older ones for [PageKind.before].
  /// [reachesStart] says the oldest reply is among them.
  Future<void> applyThreadPage({
    required String rootId,
    required api.PostList page,
    PageKind kind = PageKind.page,
    bool reachesStart = false,
  }) => db.transaction(() async {
    final posts = [
      for (final p in (page.posts ?? const {}).values)
        if (p.id != null && p.createAt != null && p.channelId != null) p,
    ];
    await _upsertPosts(posts);
    final replyTimes =
        posts.where((p) => p.rootId == rootId).map((p) => p.createAt!).toList()
          ..sort();
    final ranges = await rangesFor('thread', rootId);
    final earliest = replyTimes.firstOrNull;
    final latest = replyTimes.lastOrNull;
    await _writeRanges('thread', rootId, switch (kind) {
      PageKind.before when ranges.isNotEmpty => withOlder(
        ranges,
        anchor: newestRange(ranges)!.earliest,
        earliest: earliest,
        reachesStart: reachesStart,
      ),
      _ => withPage(
        ranges,
        earliest: earliest,
        latest: latest,
        reachesStart: reachesStart,
      ),
    });
  });

  Future<void> applyChannelStats(String channelId, int memberCount) =>
      (db.update(db.channels)..where((c) => c.id.equals(channelId))).write(
        ChannelsCompanion(memberCount: Value(memberCount)),
      );

  /// Where the reader left a channel (`channel`) or thread (`thread`).
  Future<void> saveViewState(
    String scope,
    String scopeId, {
    required String postId,
    required double offset,
    required DateTime at,
  }) => db
      .into(db.viewStates)
      .insertOnConflictUpdate(
        ViewStatesCompanion.insert(
          scope: scope,
          scopeId: scopeId,
          anchorPostId: postId,
          anchorOffsetPx: Value(offset),
          savedAt: at,
        ),
      );

  Future<void> clearViewState(String scope, String scopeId) => (db.delete(
    db.viewStates,
  )..where((v) => v.scope.equals(scope) & v.scopeId.equals(scopeId))).go();

  Future<void> _advanceWatermark(String channelId, List<api.Post> posts) async {
    DateTime? newest;
    for (final p in posts) {
      for (final t in [p.createAt, p.updateAt, p.deleteAt]) {
        if (t != null && (newest == null || t.isAfter(newest))) newest = t;
      }
    }
    if (newest == null) return;
    final current = await (db.select(
      db.myChannels,
    )..where((m) => m.channelId.equals(channelId))).getSingleOrNull();
    final before = current?.postsFetchedAt;
    if (before != null && !newest.isAfter(before)) return;
    await (db.update(db.myChannels)
          ..where((m) => m.channelId.equals(channelId)))
        .write(MyChannelsCompanion(postsFetchedAt: Value(newest)));
  }

  Future<void> _upsertPosts(List<api.Post> posts) async {
    if (posts.isEmpty) return;
    final pendingIds = posts
        .map((p) => p.pendingPostId)
        .where((id) => id != null && id.isNotEmpty)
        .cast<String>()
        .toList();
    await db.batch((b) {
      // Our own optimistic rows are keyed by pending id; the server's copy
      // replaces them under the server id.
      if (pendingIds.isNotEmpty) {
        b.deleteWhere(db.posts, (p) => p.id.isIn(pendingIds));
        b.deleteWhere(db.outbox, (o) => o.pendingPostId.isIn(pendingIds));
      }
      b.insertAllOnConflictUpdate(db.posts, [
        for (final p in posts) postCompanion(p),
      ]);
      b.insertAllOnConflictUpdate(db.users, [
        for (final p in posts)
          for (final u in p.participants)
            if (u.id != null && (u.username?.isNotEmpty ?? false))
              userCompanion(u),
      ]);
      final withFiles = posts.where(
        (p) => p.metadata?.files.isNotEmpty ?? false,
      );
      b.insertAllOnConflictUpdate(db.files, [
        for (final p in withFiles)
          for (final f in p.metadata!.files)
            if (f.id != null) fileCompanion(f, p.id!),
      ]);
      _upsertEmoji(b, [for (final p in posts) ...?p.metadata?.emojis]);
      b.deleteWhere(
        db.reactions,
        (r) => r.postId.isIn([
          for (final p in posts)
            if (p.metadata != null) p.id!,
        ]),
      );
      b.insertAll(db.reactions, [
        for (final p in posts)
          for (final r in p.metadata?.reactions ?? const <api.Reaction>[])
            if (r.postId != null && r.userId != null && r.emojiName != null)
              reactionCompanion(r),
      ], mode: InsertMode.insertOrIgnore);
    });
    final deleted = posts.where((p) => p.deleteAt != null).toList();
    if (deleted.isNotEmpty) {
      await (db.update(
        db.posts,
      )..where((p) => p.id.isIn(deleted.map((p) => p.id!).toList()))).write(
        const PostsCompanion(
          message: Value(''),
          propsJson: Value(null),
          metadataJson: Value(null),
          fileCount: Value(0),
          reactionCount: Value(0),
        ),
      );
    }
  }

  /// A post arrived over the WebSocket (or our own send was confirmed).
  Future<void> applyLivePost(
    api.Post post, {
    required bool fromSelf,
    required bool mentionsMe,
  }) => db.transaction(() async {
    if (post.id == null || post.createAt == null || post.channelId == null) {
      return;
    }
    final channelId = post.channelId!;
    final known = await (db.select(
      db.posts,
    )..where((p) => p.id.equals(post.id!))).getSingleOrNull();
    await _upsertPosts([post]);
    if (mentionsMe && !fromSelf) {
      await _prependToList(PostListNames.mentions, post.id!);
    }
    // A replayed event (after a resumed connection) is already counted.
    if (known != null) return;
    final ranges = await rangesFor('channel', channelId);
    await _writeRanges(
      'channel',
      channelId,
      withLivePost(ranges, post.createAt!),
    );
    final isRoot = post.rootId == null || post.rootId!.isEmpty;
    final channel = await (db.select(
      db.channels,
    )..where((c) => c.id.equals(channelId))).getSingleOrNull();
    if (channel != null) {
      await (db.update(
        db.channels,
      )..where((c) => c.id.equals(channelId))).write(
        ChannelsCompanion(
          totalMsgCount: Value(channel.totalMsgCount + 1),
          totalMsgCountRoot: Value(
            channel.totalMsgCountRoot + (isRoot ? 1 : 0),
          ),
          lastPostAt: Value(post.createAt),
          lastRootPostAt: isRoot ? Value(post.createAt) : const Value.absent(),
        ),
      );
    }
    final mine = await (db.select(
      db.myChannels,
    )..where((m) => m.channelId.equals(channelId))).getSingleOrNull();
    if (mine == null) return;
    if (fromSelf) {
      await markViewed(channelId, at: post.createAt!);
    } else if (mentionsMe) {
      await (db.update(
        db.myChannels,
      )..where((m) => m.channelId.equals(channelId))).write(
        MyChannelsCompanion(
          mentionCount: Value(mine.mentionCount + 1),
          mentionCountRoot: Value(mine.mentionCountRoot + (isRoot ? 1 : 0)),
        ),
      );
    }
    if (post.rootId case final rootId? when rootId.isNotEmpty) {
      final threadRanges = await rangesFor('thread', rootId);
      if (threadRanges.isNotEmpty) {
        await _writeRanges(
          'thread',
          rootId,
          withLivePost(threadRanges, post.createAt!),
        );
      }
    }
  });

  /// Posts a search found, with the channels and people needed to show
  /// them. They stay outside any channel's loaded history.
  Future<void> applySearchResults(
    Iterable<api.Post> posts, {
    Iterable<api.Channel> channels = const [],
    Iterable<api.User> users = const [],
  }) => db.transaction(() async {
    await _upsertPosts([
      for (final p in posts)
        if (p.id != null && p.createAt != null && p.channelId != null) p,
    ]);
    await db.batch((b) {
      // Channels the user is not in are kept only as far as their names.
      b.insertAll(db.channels, [
        for (final c in channels)
          if (c.id != null) channelCompanion(c),
      ], mode: InsertMode.insertOrIgnore);
      b.insertAllOnConflictUpdate(db.users, [
        for (final u in users)
          if (u.id != null) userCompanion(u),
      ]);
    });
  });

  /// Remembers a search in [teamId], newest first, keeping [keep] of them.
  Future<void> addRecentSearch(
    String teamId,
    String term, {
    required DateTime at,
    int keep = 20,
  }) => db.transaction(() async {
    await db
        .into(db.searchHistory)
        .insertOnConflictUpdate(
          SearchHistoryCompanion.insert(
            teamId: teamId,
            term: term,
            createdAt: at,
          ),
        );
    final old =
        await (db.select(db.searchHistory)
              ..where((s) => s.teamId.equals(teamId))
              ..orderBy([(s) => OrderingTerm.desc(s.createdAt)])
              ..limit(1000, offset: keep))
            .get();
    for (final row in old) {
      await removeRecentSearch(teamId, row.term);
    }
  });

  Future<void> removeRecentSearch(String teamId, String term) => (db.delete(
    db.searchHistory,
  )..where((s) => s.teamId.equals(teamId) & s.term.equals(term))).go();

  Future<void> applyEdit(api.Post post) async {
    if (post.id == null || post.createAt == null || post.channelId == null) {
      return;
    }
    await db.transaction(() => _upsertPosts([post]));
  }

  /// Keeps the row as a placeholder until the channel is reopened.
  Future<void> applyDelete(String postId, {required DateTime at}) =>
      (db.update(db.posts)..where((p) => p.id.equals(postId))).write(
        PostsCompanion(
          deleteAt: Value(at),
          message: const Value(''),
          propsJson: const Value(null),
          metadataJson: const Value(null),
          fileCount: const Value(0),
          reactionCount: const Value(0),
        ),
      );

  Future<void> applyReaction(api.Reaction reaction, {required bool added}) =>
      db.transaction(() async {
        if (reaction.postId == null ||
            reaction.userId == null ||
            reaction.emojiName == null) {
          return;
        }
        if (added) {
          await db
              .into(db.reactions)
              .insert(
                reactionCompanion(reaction),
                mode: InsertMode.insertOrIgnore,
              );
        } else {
          await (db.delete(db.reactions)..where(
                (r) =>
                    r.postId.equals(reaction.postId!) &
                    r.userId.equals(reaction.userId!) &
                    r.emojiName.equals(reaction.emojiName!),
              ))
              .go();
        }
        final count =
            await (db.selectOnly(db.reactions)
                  ..addColumns([db.reactions.postId.count()])
                  ..where(db.reactions.postId.equals(reaction.postId!)))
                .map((row) => row.read(db.reactions.postId.count())!)
                .getSingle();
        await (db.update(db.posts)..where((p) => p.id.equals(reaction.postId!)))
            .write(PostsCompanion(reactionCount: Value(count)));
      });

  /// The channel counts as read up to [at]: the member counters catch up with
  /// the channel's, which is what the server does on `view`.
  Future<void> markViewed(String channelId, {required DateTime at}) =>
      db.transaction(() async {
        final channel = await (db.select(
          db.channels,
        )..where((c) => c.id.equals(channelId))).getSingleOrNull();
        if (channel == null) return;
        await (db.update(
          db.myChannels,
        )..where((m) => m.channelId.equals(channelId))).write(
          MyChannelsCompanion(
            lastViewedAt: Value(at),
            msgCount: Value(channel.totalMsgCount),
            msgCountRoot: Value(channel.totalMsgCountRoot),
            mentionCount: const Value(0),
            mentionCountRoot: const Value(0),
            urgentMentionCount: const Value(0),
            manuallyUnread: const Value(false),
          ),
        );
      });

  /// Our own new post: an ordinary post row keyed by its pending id, so the
  /// list shows it at once, plus its delivery state in `outbox`. The
  /// conversation's draft goes in the same transaction.
  Future<void> queuePost({
    required String pendingPostId,
    required String channelId,
    required String rootId,
    required String userId,
    required String message,
    required DateTime createAt,
    List<api.FileInfo> files = const [],
    api.PostPriority? priority,
  }) => db.transaction(() async {
    final metadata = files.isEmpty && priority == null
        ? null
        : api.PostMetadata(files: files, priority: priority);
    await db
        .into(db.posts)
        .insert(
          PostsCompanion.insert(
            id: pendingPostId,
            channelId: channelId,
            rootId: Value(rootId),
            userId: userId,
            createAt: createAt,
            updateAt: Value(createAt),
            message: Value(message),
            pendingPostId: Value(pendingPostId),
            sendState: const Value(SendStates.pending),
            metadataJson: Value(
              metadata == null ? null : jsonEncode(metadata.toJson()),
            ),
            fileCount: Value(files.length),
          ),
        );
    await db.batch((b) {
      b.insertAllOnConflictUpdate(db.files, [
        for (final f in files)
          if (f.id != null) fileCompanion(f, pendingPostId),
      ]);
    });
    await db
        .into(db.outbox)
        .insert(
          OutboxCompanion.insert(
            pendingPostId: pendingPostId,
            channelId: channelId,
            rootId: Value(rootId),
            queuedAt: createAt,
          ),
        );
    await deleteDraft(channelId, rootId);
    await _showLocalPost(channelId, rootId, createAt);
  });

  /// Makes a post that only exists here (unsent or ephemeral) part of the
  /// loaded history, like a live post. The fetch watermark is pinned first:
  /// the next refresh must still ask from the newest post the server gave
  /// us, not from this one's time.
  Future<void> _showLocalPost(
    String channelId,
    String rootId,
    DateTime at,
  ) async {
    final ranges = await rangesFor('channel', channelId);
    final newest = newestRange(ranges);
    if (newest != null && newest != PostRange.empty) {
      await (db.update(db.myChannels)..where(
            (m) => m.channelId.equals(channelId) & m.postsFetchedAt.isNull(),
          ))
          .write(MyChannelsCompanion(postsFetchedAt: Value(newest.latest)));
    }
    await _writeRanges('channel', channelId, withLivePost(ranges, at));
    if (rootId.isEmpty) return;
    final threadRanges = await rangesFor('thread', rootId);
    if (threadRanges.isNotEmpty) {
      await _writeRanges('thread', rootId, withLivePost(threadRanges, at));
    }
  }

  Future<List<OutboxRow>> outboxRows() => db.select(db.outbox).get();

  /// Posts that were being sent when the app stopped go back in the line.
  Future<void> resetSending() =>
      (db.update(db.outbox)..where((o) => o.state.equals(OutboxStates.sending)))
          .write(const OutboxCompanion(state: Value(OutboxStates.queued)));

  /// The connection is back: waiting posts go now instead of after their
  /// backoff.
  Future<void> sendWaitingNow() =>
      (db.update(db.outbox)..where((o) => o.state.equals(OutboxStates.queued)))
          .write(const OutboxCompanion(nextAttemptAt: Value(null)));

  Future<void> markSending(String pendingPostId) =>
      (db.update(db.outbox)
            ..where((o) => o.pendingPostId.equals(pendingPostId)))
          .write(const OutboxCompanion(state: Value(OutboxStates.sending)));

  Future<void> markSendRetry(
    String pendingPostId, {
    required int attempts,
    required DateTime nextAttemptAt,
    String? error,
  }) =>
      (db.update(
        db.outbox,
      )..where((o) => o.pendingPostId.equals(pendingPostId))).write(
        OutboxCompanion(
          state: const Value(OutboxStates.queued),
          attempts: Value(attempts),
          nextAttemptAt: Value(nextAttemptAt),
          lastError: Value(error),
        ),
      );

  /// The post stays, shown as not sent, until the user retries or deletes
  /// it.
  Future<void> markSendFailed(
    String pendingPostId, {
    required int attempts,
    String? error,
  }) => db.transaction(() async {
    await (db.update(
      db.outbox,
    )..where((o) => o.pendingPostId.equals(pendingPostId))).write(
      OutboxCompanion(
        state: const Value(OutboxStates.failed),
        attempts: Value(attempts),
        nextAttemptAt: const Value(null),
        lastError: Value(error),
      ),
    );
    await (db.update(db.posts)..where((p) => p.id.equals(pendingPostId))).write(
      const PostsCompanion(sendState: Value(SendStates.failed)),
    );
  });

  /// Puts a failed post back in the line; returns false when it is gone.
  Future<bool> requeuePost(String pendingPostId) => db.transaction(() async {
    final updated =
        await (db.update(
          db.outbox,
        )..where((o) => o.pendingPostId.equals(pendingPostId))).write(
          const OutboxCompanion(
            state: Value(OutboxStates.queued),
            attempts: Value(0),
            nextAttemptAt: Value(null),
            lastError: Value(null),
          ),
        );
    if (updated == 0) return false;
    await (db.update(db.posts)..where((p) => p.id.equals(pendingPostId))).write(
      const PostsCompanion(sendState: Value(SendStates.pending)),
    );
    return true;
  });

  /// Removes an unsent post and its delivery state.
  Future<void> discardPost(String pendingPostId) => db.transaction(() async {
    await (db.delete(
      db.outbox,
    )..where((o) => o.pendingPostId.equals(pendingPostId))).go();
    await (db.delete(
      db.posts,
    )..where((p) => p.id.equals(pendingPostId) & p.sendState.isNotNull())).go();
    await (db.delete(
      db.files,
    )..where((f) => f.postId.equals(pendingPostId))).go();
  });

  /// The server created our post: its row replaces the pending one under the
  /// same list key, whether or not the `posted` event got here first.
  Future<void> applySent(
    String pendingPostId,
    api.Post post,
  ) => db.transaction(() async {
    if (post.id == null) return;
    await (db.delete(
      db.outbox,
    )..where((o) => o.pendingPostId.equals(pendingPostId))).go();
    await (db.delete(db.posts)..where((p) => p.id.equals(pendingPostId))).go();
    await applyLivePost(post, fromSelf: true, mentionsMe: false);
    await (db.update(db.posts)
          ..where((p) => p.id.equals(post.id!) & p.pendingPostId.equals('')))
        .write(PostsCompanion(pendingPostId: Value(pendingPostId)));
  });

  /// A message only this user sees (a command's reply, a bot's hint). The
  /// server keeps no copy, so it is a local row of type `system_ephemeral`:
  /// no unread count, no fetch watermark, shown until dismissed or until
  /// the server is opened again (see [removeEphemeralPosts]).
  ///
  /// A command's reply arrives twice when the socket is up, from the
  /// command's answer (made here, id prefixed [localEphemeralPrefix]) and
  /// as `ephemeral_message`; the same text in the same place within a
  /// minute is one message, and the server's copy takes over the local
  /// one's list key.
  Future<void> applyEphemeralPost(api.Post post) => db.transaction(() async {
    if (post.id == null || post.createAt == null || post.channelId == null) {
      return;
    }
    final rootId = post.rootId ?? '';
    final window = const Duration(minutes: 1).inMilliseconds;
    final at = post.createAt!.millisecondsSinceEpoch;
    final twin =
        await (db.select(db.posts)
              ..where(
                (p) =>
                    p.channelId.equals(post.channelId!) &
                    p.rootId.equals(rootId) &
                    p.type.equals(ephemeralType) &
                    p.message.equals(post.message ?? '') &
                    p.createAt.isBetweenValues(at - window, at + window) &
                    p.id.equals(post.id!).not(),
              )
              ..limit(1))
            .getSingleOrNull();
    final local = post.id!.startsWith(localEphemeralPrefix);
    if (twin != null && local) return;
    if (twin != null && twin.id.startsWith(localEphemeralPrefix)) {
      await (db.delete(db.posts)..where((p) => p.id.equals(twin.id))).go();
    }
    await _upsertPosts([post]);
    await (db.update(db.posts)..where((p) => p.id.equals(post.id!))).write(
      PostsCompanion(
        type: const Value(ephemeralType),
        pendingPostId: twin != null && twin.id.startsWith(localEphemeralPrefix)
            ? Value(twin.pendingPostId.isEmpty ? twin.id : twin.pendingPostId)
            : const Value.absent(),
      ),
    );
    await _showLocalPost(post.channelId!, rootId, post.createAt!);
  });

  /// Ephemeral messages last one run of the app, as nothing can bring them
  /// back after a refresh either.
  Future<void> removeEphemeralPosts() =>
      (db.delete(db.posts)..where((p) => p.type.equals(ephemeralType))).go();

  Future<void> dismissEphemeral(String postId) => (db.delete(
    db.posts,
  )..where((p) => p.id.equals(postId) & p.type.equals(ephemeralType))).go();

  Future<PostRow?> post(String postId) => (db.select(
    db.posts,
  )..where((p) => p.id.equals(postId))).getSingleOrNull();

  /// The user's own edit, shown before the server confirms it; [editAt]
  /// null puts back the text from before an edit that failed.
  Future<void> setPostMessage(
    String postId,
    String message, {
    required DateTime? editAt,
  }) => (db.update(db.posts)..where((p) => p.id.equals(postId))).write(
    PostsCompanion(message: Value(message), editAt: Value(editAt)),
  );

  Future<void> setPinned(String postId, {required bool pinned}) =>
      (db.update(db.posts)..where((p) => p.id.equals(postId))).write(
        PostsCompanion(isPinned: Value(pinned)),
      );

  /// The user deleted their post: it goes at once, without the placeholder
  /// others' deletions leave.
  Future<void> removePost(String postId) => db.transaction(() async {
    await (db.delete(db.posts)..where((p) => p.id.equals(postId))).go();
    await (db.delete(db.reactions)..where((r) => r.postId.equals(postId))).go();
    await (db.delete(db.files)..where((f) => f.postId.equals(postId))).go();
    await (db.delete(db.postLists)..where((l) => l.postId.equals(postId))).go();
  });

  /// After "Mark as unread": the server's counts, and no automatic read
  /// until the channel is opened again.
  Future<void> applyMarkedUnread(api.ChannelMember member) =>
      db.transaction(() async {
        if (member.channelId == null) return;
        await applyChannelMember(member);
        await (db.update(db.myChannels)
              ..where((m) => m.channelId.equals(member.channelId!)))
            .write(const MyChannelsCompanion(manuallyUnread: Value(true)));
      });

  static const _recentEmojiKey = 'recent_emoji';

  /// Emoji the user picked lately, most recent first.
  Future<List<String>> recentEmoji() async {
    final stored = await db.syncText(_recentEmojiKey);
    return stored == null || stored.isEmpty ? const [] : stored.split(',');
  }

  Future<void> addRecentEmoji(Iterable<String> names) async {
    // Emoji names never contain commas.
    final updated = withRecentEmoji(await recentEmoji(), names);
    await db.setSyncText(_recentEmojiKey, updated.join(','));
  }

  Future<DraftRow?> draft(String channelId, String rootId) =>
      (db.select(db.drafts)..where(
            (d) => d.channelId.equals(channelId) & d.rootId.equals(rootId),
          ))
          .getSingleOrNull();

  Future<void> saveDraft(DraftsCompanion draft) =>
      db.into(db.drafts).insertOnConflictUpdate(draft);

  Future<void> deleteDraft(String channelId, String rootId) =>
      (db.delete(db.drafts)..where(
            (d) => d.channelId.equals(channelId) & d.rootId.equals(rootId),
          ))
          .go();
}

const ephemeralType = 'system_ephemeral';

/// Ids of ephemeral messages made here from a command's answer.
const localEphemeralPrefix = 'local-ephemeral:';

/// `posts.send_state` of our own unsent posts.
abstract final class SendStates {
  static const pending = 'pending';
  static const failed = 'failed';
}
