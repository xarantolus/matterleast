import 'dart:async';

import 'package:drift/drift.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/data/views/switch_views.dart';
import 'package:matterleast/data/wait_limited.dart';
import 'package:matterleast/domain/category_moves.dart';
import 'package:matterleast/domain/preference_keys.dart';
import 'package:matterleast/domain/teams.dart';
import 'package:matterleast/log.dart';

/// What the user does to channels in the list. Each action talks to the
/// server and writes the result through the store; the list follows from
/// the database.
class ChannelActions {
  ChannelActions(this.session, {DateTime Function()? clock})
    : _clock = clock ?? (() => DateTime.now().toUtc());

  final ServerSession session;
  final DateTime Function() _clock;

  ServerDatabase get _db => session.db;
  api.MattermostClient get _client => session.api.client;

  /// The user opened a channel: it is remembered as the team's last one.
  /// The channel screen marks it read once it has noted what was unread.
  Future<void> open(String channelId, {String? teamId}) async {
    unawaited(
      setConversationShown(
        session.api,
        session.store,
        channelId,
        show: true,
      ).catchError(
        (Object e) => Log.warn('channels', 'Showing a conversation failed', e),
      ),
    );
    if (teamId != null && teamId.isNotEmpty) {
      await session.store.setLastChannel(teamId, channelId);
    }
  }

  /// Marks the channel read here at once and tells the server, which also
  /// clears it on the user's other devices.
  Future<void> view(String channelId) async {
    await session.store.markViewed(channelId, at: _clock());
    unawaited(
      _tellViewed(channelId).catchError((Object e) {
        Log.warn('channels', 'Marking a channel read failed', e);
      }),
    );
  }

  /// As [view], but completes once the server was told, e.g. from a
  /// notification's Mark as read with no app around to retry.
  Future<void> markRead(String channelId) async {
    await session.store.markViewed(channelId, at: _clock());
    await _tellViewed(channelId);
  }

  Future<void> _tellViewed(String channelId) => session.runner.enqueue(
    SyncJob(
      key: 'view:$channelId',
      priority: SyncPriority.p0,
      run: () => session.api.call(
        () => _client.channels.viewChannel(
          userId: 'me',
          // Without the flag the server treats the client as not
          // knowing threads and marks the channel's threads read.
          body: api.ApiV4ChannelsMembersUserIdViewRequestBody(
            channelId: channelId,
            collapsedThreadsSupported: true,
          ),
        ),
      ),
    ),
  );

  /// Moves the channel into Favourites, or back to Channels (Direct
  /// Messages for a conversation), as the official app does.
  Future<void> setFavorite(
    String teamId,
    String channelId, {
    required bool favorite,
  }) async {
    final channel = await (_db.select(
      _db.channels,
    )..where((c) => c.id.equals(channelId))).getSingle();
    var team = await _teamCategories(teamId);
    final type = favoriteTargetType(channel.type, favorite: favorite);
    if (!team.categories.any((c) => c.type == type)) {
      await session.connection.entry.refreshTeam(teamId);
      team = await _teamCategories(teamId);
    }
    final current = team.categories
        .where((c) => team.idsOf(c).contains(channelId))
        .firstOrNull;
    final move = favoriteMove(
      categories: [for (final c in team.categories) (id: c.id, type: c.type)],
      currentCategoryId: current?.id,
      channelType: channel.type,
      favorite: favorite,
    );
    if (move == null) return;
    final target = team.byId(move.to)!;
    final updated = await session.api.call(
      () => _client.channels.updateSidebarCategoriesForTeamForUser(
        userId: 'me',
        teamId: teamId,
        body: [
          if (current != null)
            team.body(current, [
              for (final id in team.idsOf(current))
                if (id != channelId) id,
            ]),
          team.body(target, [channelId, ...team.idsOf(target)]),
        ],
      ),
    );
    await session.store.applyCategoryUpdates(updated);
  }

  /// Puts a channel at the dropped place among the [shown] channels of its
  /// new category, which from then on keeps the user's order. Shows at once
  /// and is put back when the server refuses it.
  Future<void> moveChannel(
    String teamId,
    ChannelDrop drop, {
    required List<String> shown,
  }) async {
    final team = await _teamCategories(teamId);
    final from = team.byId(drop.fromCategory);
    final to = team.byId(drop.toCategory);
    if (from == null || to == null) return;
    final before = [
      team.body(from, team.idsOf(from)),
      if (to.id != from.id) team.body(to, team.idsOf(to)),
    ];
    final after = [
      if (to.id != from.id)
        team.body(from, [
          for (final id in team.idsOf(from))
            if (id != drop.channelId) id,
        ]),
      team.body(
        to,
        placeChannel(
          stored: team.idsOf(to),
          shown: shown,
          channelId: drop.channelId,
          index: drop.index,
        ),
        sorting: 'manual',
      ),
    ];
    await _updateCategories(teamId, before: before, after: after);
  }

  /// Moves a category to where the user dropped it among the shown ones.
  Future<void> moveCategory(String teamId, CategoryDrop drop) async {
    final team = await _teamCategories(teamId);
    final stored = [for (final c in team.categories) c.id];
    final order = placeCategory(
      stored: stored,
      shown: drop.shownOrder,
      categoryId: drop.categoryId,
    );
    await session.store.applyCategoryOrder(order);
    try {
      final saved = await session.api.call(
        () => _client.channels.updateSidebarCategoryOrderForTeamForUser(
          userId: 'me',
          teamId: teamId,
          body: order,
        ),
      );
      await session.store.applyCategoryOrder(saved);
    } on Object {
      await session.store.applyCategoryOrder(stored);
      rethrow;
    }
  }

  /// A new empty custom category; the server puts it at the top.
  Future<void> createCategory(String teamId, String name) async {
    final me = await _db.syncText(SyncKeys.currentUserId);
    await session.api.call(
      () => _client.channels.createSidebarCategoryForTeamForUser(
        userId: 'me',
        teamId: teamId,
        body: api.SidebarCategory(
          userId: me,
          teamId: teamId,
          displayName: name,
          type: api.SidebarCategoryType.custom,
        ),
      ),
    );
    await session.connection.entry.refreshTeam(teamId);
  }

  Future<void> renameCategory(
    String teamId,
    String categoryId,
    String name,
  ) async {
    final team = await _teamCategories(teamId);
    final category = team.byId(categoryId);
    if (category == null) return;
    final updated = await session.api.call(
      () => _client.channels.updateSidebarCategoriesForTeamForUser(
        userId: 'me',
        teamId: teamId,
        body: [team.body(category, team.idsOf(category), displayName: name)],
      ),
    );
    await session.store.applyCategoryUpdates(updated);
  }

  /// Deletes a custom category; the server moves its channels back to
  /// Channels and Direct Messages.
  Future<void> deleteCategory(String teamId, String categoryId) async {
    await session.api.call(
      () => _client.channels.removeSidebarCategoryForTeamForUser(
        userId: 'me',
        teamId: teamId,
        categoryId: categoryId,
      ),
    );
    await session.connection.entry.refreshTeam(teamId);
  }

  Future<void> _updateCategories(
    String teamId, {
    required List<api.SidebarCategoryWithChannels> before,
    required List<api.SidebarCategoryWithChannels> after,
  }) async {
    await session.store.applyCategoryUpdates(after);
    try {
      final updated = await session.api.call(
        () => _client.channels.updateSidebarCategoriesForTeamForUser(
          userId: 'me',
          teamId: teamId,
          body: after,
        ),
      );
      await session.store.applyCategoryUpdates(updated);
    } on Object {
      await session.store.applyCategoryUpdates(before);
      rethrow;
    }
  }

  Future<_TeamCategories> _teamCategories(String teamId) async {
    final me = await _db.syncText(SyncKeys.currentUserId);
    final categories =
        await (_db.select(_db.categories)
              ..where((c) => c.teamId.equals(teamId))
              ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
            .get();
    final links =
        await (_db.select(_db.categoryChannels)
              ..where(
                (cc) => cc.categoryId.isIn([for (final c in categories) c.id]),
              )
              ..orderBy([(cc) => OrderingTerm.asc(cc.sortOrder)]))
            .get();
    return _TeamCategories(me, categories, links);
  }

  /// Hides a direct or group message from the list without leaving it, as
  /// the official app does; the next message brings it back.
  Future<void> closeConversation(String channelId) =>
      setConversationShown(session.api, session.store, channelId, show: false);

  /// Muted channels only count mentions as unread.
  Future<void> setMuted(String channelId, {required bool muted}) =>
      updateNotifyProps(channelId, markUnread: muted ? 'mention' : 'all');

  /// Changes how the user is notified about a channel. The change shows at
  /// once and is put back when the server refuses it.
  Future<void> updateNotifyProps(
    String channelId, {
    String? push,
    String? desktop,
    String? markUnread,
    String? ignoreChannelMentions,
    String? pushThreads,
  }) async {
    final mine = await (_db.select(
      _db.myChannels,
    )..where((m) => m.channelId.equals(channelId))).getSingle();
    final before = mine.notifyProps;
    final next = completeNotifyProps(
      before ?? api.ChannelNotifyProps.fromJson(const {}),
      push: push,
      desktop: desktop,
      markUnread: markUnread,
      ignoreChannelMentions: ignoreChannelMentions,
      pushThreads: pushThreads,
    );
    await session.store.applyNotifyProps(channelId, next);
    try {
      await session.api.call(
        () => _client.channels.updateChannelNotifyProps(
          channelId: channelId,
          userId: 'me',
          body: next,
        ),
      );
    } on Object {
      await session.store.applyNotifyProps(channelId, before);
      rethrow;
    }
  }

  Future<void> leave(String channelId) async {
    await session.api.call(
      () => _client.channels.removeUserFromChannel(
        channelId: channelId,
        userId: 'me',
      ),
    );
    await session.store.removeChannel(channelId);
  }

  /// The stored direct message with [userId], if the user is in one.
  Future<String?> storedDirectChannel(String userId) =>
      directChannelWith(_db, userId);

  /// The direct message with [userId], created on the server when there is
  /// none yet; returns its channel id.
  Future<String> directChannel(String userId) async {
    final known = await storedDirectChannel(userId);
    if (known != null) return known;
    final me = await _myId();
    final channel = await session.api.call(
      () => _client.channels.createDirectChannel(body: {me, userId}.toList()),
    );
    await _storeJoined(channel);
    return channel.id!;
  }

  /// A group message with [userIds] and the user; the server returns the
  /// existing one for the same people.
  Future<String> groupChannel(List<String> userIds) async {
    final me = await _myId();
    final channel = await session.api.call(
      () =>
          _client.channels.createGroupChannel(body: {me, ...userIds}.toList()),
    );
    await _storeJoined(channel);
    return channel.id!;
  }

  /// Joins an open team, and stores it with its channels.
  Future<void> joinTeam(String teamId) async {
    final me = await _myId();
    await session.api.call(
      () => _client.teams.addTeamMember(
        teamId: teamId,
        body: api.ApiV4TeamsTeamIdMembersRequestBody(
          teamId: teamId,
          userId: me,
        ),
      ),
    );
    await session.connection.entry.joinedTeam(teamId);
  }

  /// Joins a public channel.
  Future<void> join(String channelId) async {
    final me = await _myId();
    await session.api.call(
      () => _client.channels.addChannelMember(
        channelId: channelId,
        body: _OneMember(me),
      ),
    );
    await _storeJoined(
      await session.api.call(
        () => _client.channels.getChannel(channelId: channelId),
      ),
    );
  }

  /// Creates a channel in [teamId] and returns its id.
  Future<String> create({
    required String teamId,
    required String displayName,
    required String name,
    required bool private,
    String purpose = '',
    String header = '',
  }) async {
    final channel = await session.api.call(
      () => _client.channels.createChannel(
        body: api.ApiV4ChannelsRequestBody(
          teamId: teamId,
          name: name,
          displayName: displayName,
          purpose: purpose,
          header: header,
          type: private ? 'P' : 'O',
        ),
      ),
    );
    await _storeJoined(channel);
    return channel.id!;
  }

  /// Changes a channel's name, purpose or header; null leaves one as is.
  Future<void> patch(
    String channelId, {
    String? displayName,
    String? purpose,
    String? header,
  }) async {
    final channel = await session.api.call(
      () => _client.channels.patchChannel(
        channelId: channelId,
        body: api.ApiV4ChannelsChannelIdPatchRequestBody(
          displayName: displayName,
          purpose: purpose,
          header: header,
        ),
      ),
    );
    await session.store.applyChannel(channel);
  }

  Future<void> archive(String channelId) async {
    await session.api.call(
      () => _client.channels.deleteChannel(channelId: channelId),
    );
    await session.store.applyChannelArchived(channelId, _clock());
  }

  /// Adds people one request each, as the official app does; the first
  /// failure is thrown once all have finished.
  Future<void> addMembers(String channelId, List<String> userIds) async {
    try {
      await waitLimited(
        userIds,
        (userId) => session.api.call(
          () => _client.channels.addChannelMember(
            channelId: channelId,
            body: api.ApiV4ChannelsChannelIdMembersRequestBody(userId: userId),
          ),
        ),
      );
    } finally {
      await refreshStats(channelId);
    }
  }

  /// The channel's member, pinned and file counts; the member count is
  /// stored.
  Future<api.ChannelStats> refreshStats(String channelId) async {
    final stats = await session.api.call(
      () => _client.channels.getChannelStats(channelId: channelId),
    );
    if (stats.memberCount case final count?) {
      await session.store.applyChannelStats(channelId, count);
    }
    return stats;
  }

  /// The channel's pinned messages, stored as the list
  /// `pinned:<channel>`.
  Future<void> refreshPinned(String channelId) async {
    final page = await session.api.call(
      () => _client.channels.getPinnedPosts(channelId: channelId),
    );
    await session.users.ensure([
      for (final p in (page.posts ?? const <String, api.Post>{}).values)
        ?p.userId,
    ]);
    await session.store.applyPostList(
      pinnedList(channelId),
      page,
      fetchedAt: _clock(),
    );
  }

  static String pinnedList(String channelId) => 'pinned:$channelId';

  Future<String> _myId() async {
    final me = await _db.syncText(SyncKeys.currentUserId);
    if (me == null) throw StateError('No signed-in user');
    return me;
  }

  /// Stores a channel the user is now in, with their membership, and
  /// refreshes the team's categories behind it so it lands in the list.
  Future<void> _storeJoined(api.Channel channel) async {
    final member = await session.api.call(
      () => _client.channels.getChannelMember(
        channelId: channel.id!,
        userId: 'me',
      ),
    );
    await session.store.applyChannels(channels: [channel], members: [member]);
    final team = (channel.teamId?.isNotEmpty ?? false)
        ? channel.teamId
        : await _db.syncText(SyncKeys.currentTeamId);
    if (team != null) {
      unawaited(
        session.connection.entry.refreshTeam(team).catchError((Object _) {}),
      );
    }
  }

  Future<void> setCollapsed(String categoryId, {required bool collapsed}) =>
      session.store.setCategoryCollapsed(categoryId, collapsed: collapsed);

  /// The user switched to [teamId]: it is synced first from now on, and
  /// refreshed now.
  Future<void> selectTeam(String teamId) async {
    await session.store.setCurrentTeam(teamId);
    unawaited(
      session.connection.entry.refreshTeam(teamId).catchError((Object _) {}),
    );
  }
}

/// Pure: [current] with the given changes and every other field filled in.
/// The server stores each field it is sent, so a missing one would be
/// saved as empty; the fallbacks are the server's own defaults.
api.ChannelNotifyProps completeNotifyProps(
  api.ChannelNotifyProps current, {
  String? push,
  String? desktop,
  String? markUnread,
  String? ignoreChannelMentions,
  String? pushThreads,
}) => api.ChannelNotifyProps(
  email: current.email ?? 'default',
  push: push ?? current.push ?? 'default',
  desktop: desktop ?? current.desktop ?? 'default',
  markUnread: markUnread ?? current.markUnread ?? 'all',
  ignoreChannelMentions:
      ignoreChannelMentions ?? current.ignoreChannelMentions ?? 'default',
  desktopThreads: current.desktopThreads ?? 'all',
  pushThreads: pushThreads ?? current.pushThreads ?? 'all',
  emailThreads: current.emailThreads ?? 'all',
  channelAutoFollowThreads: current.channelAutoFollowThreads ?? 'off',
);

/// Adds one user. The server takes any `user_ids` key, even an empty list,
/// as a request to add several and then answers `null`.
class _OneMember extends api.ApiV4ChannelsChannelIdMembersRequestBody {
  _OneMember(String userId) : super(userId: userId);

  @override
  Map<String, Object?> toJson() => super.toJson()..remove('user_ids');
}

/// Shows or hides a direct or group message in the channel list through the
/// server's `*_channel_show` preference. Nothing is sent when it already is
/// as asked, or when the channel is not a direct or group message.
Future<void> setConversationShown(
  ServerApi server,
  ServerStore store,
  String channelId, {
  required bool show,
}) async {
  final db = store.db;
  final me = await db.syncText(SyncKeys.currentUserId) ?? '';
  final channel = await (db.select(
    db.channels,
  )..where((c) => c.id.equals(channelId))).getSingleOrNull();
  final (category, name) = switch (channel?.type) {
    'D' => (Prefs.directChannelShow, directPartnerId(channel!.name, me)),
    'G' => (Prefs.groupChannelShow, channelId),
    _ => (null, null),
  };
  if (category == null || name == null) return;
  final stored = await db.preference(category, name);
  if (show ? stored != 'false' : stored == 'false') return;
  final preference = api.Preference(
    userId: me,
    category: category,
    name: name,
    value: '$show',
  );
  await server.call(
    () => server.client.preferences.updatePreferences(
      userId: me,
      body: [preference],
    ),
  );
  await store.applyPreferences([preference]);
}

/// A team's stored categories and their channels, as the server takes them.
class _TeamCategories {
  _TeamCategories(this.me, this.categories, this.links);

  final String? me;
  final List<CategoryRow> categories;
  final List<CategoryChannelRow> links;

  CategoryRow? byId(String id) =>
      categories.where((c) => c.id == id).firstOrNull;

  List<String> idsOf(CategoryRow c) => [
    for (final l in links)
      if (l.categoryId == c.id) l.channelId,
  ];

  api.SidebarCategoryWithChannels body(
    CategoryRow c,
    List<String> ids, {
    String? sorting,
    String? displayName,
  }) => api.SidebarCategoryWithChannels(
    id: c.id,
    userId: me,
    teamId: c.teamId,
    displayName: displayName ?? c.displayName,
    type: api.SidebarCategoryWithChannelsType.fromJson(c.type),
    sorting: sorting ?? c.sorting,
    muted: c.muted,
    collapsed: c.collapsed,
    channelIds: ids,
  );
}
