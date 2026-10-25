import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/data/views/switch_views.dart';
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
    if (teamId != null && teamId.isNotEmpty) {
      await session.store.setLastChannel(teamId, channelId);
    }
  }

  /// Marks the channel read here at once and tells the server, which also
  /// clears it on the user's other devices.
  Future<void> view(String channelId) async {
    await session.store.markViewed(channelId, at: _clock());
    unawaited(
      session.runner
          .enqueue(
            SyncJob(
              key: 'view:$channelId',
              priority: SyncPriority.p0,
              run: () => session.api.call(
                () => _client.channels.viewChannel(
                  userId: 'me',
                  body: api.ApiV4ChannelsMembersUserIdViewRequestBody(
                    channelId: channelId,
                  ),
                ),
              ),
            ),
          )
          .catchError((Object e) {
            Log.warn('channels', 'Marking a channel read failed', e);
          }),
    );
  }

  /// Moves the channel into Favourites, or back to Channels (Direct
  /// Messages for a conversation), as the official app does.
  Future<void> setFavorite(
    String teamId,
    String channelId, {
    required bool favorite,
  }) async {
    final me = await _db.syncText(SyncKeys.currentUserId);
    final categories = await (_db.select(
      _db.categories,
    )..where((c) => c.teamId.equals(teamId))).get();
    final links =
        await (_db.select(_db.categoryChannels)
              ..where(
                (cc) => cc.categoryId.isIn([for (final c in categories) c.id]),
              )
              ..orderBy([(cc) => OrderingTerm.asc(cc.sortOrder)]))
            .get();
    final channel = await (_db.select(
      _db.channels,
    )..where((c) => c.id.equals(channelId))).getSingle();
    List<String> idsOf(CategoryRow c) => [
      for (final l in links)
        if (l.categoryId == c.id) l.channelId,
    ];
    final current = categories.firstWhere((c) => idsOf(c).contains(channelId));
    final targetType = favorite
        ? 'favorites'
        : (channel.type == 'D' || channel.type == 'G')
        ? 'direct_messages'
        : 'channels';
    final target = categories.firstWhere((c) => c.type == targetType);
    if (target.id == current.id) return;

    api.SidebarCategoryWithChannels body(CategoryRow c, List<String> ids) =>
        api.SidebarCategoryWithChannels(
          id: c.id,
          userId: me,
          teamId: c.teamId,
          displayName: c.displayName,
          type: api.SidebarCategoryWithChannelsType.fromJson(c.type),
          sorting: c.sorting,
          muted: c.muted,
          collapsed: c.collapsed,
          channelIds: ids,
        );
    final updated = await session.api.call(
      () => _client.channels.updateSidebarCategoriesForTeamForUser(
        userId: 'me',
        teamId: teamId,
        body: [
          body(current, [
            for (final id in idsOf(current))
              if (id != channelId) id,
          ]),
          body(target, [channelId, ...idsOf(target)]),
        ],
      ),
    );
    await session.store.applyCategoryUpdates(updated);
  }

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
    final before = mine.notifyPropsJson;
    final stored = jsonDecode(before ?? '{}');
    final next = completeNotifyProps(
      api.ChannelNotifyProps.fromJson(
        stored is Map<String, Object?> ? stored : const {},
      ),
      push: push,
      desktop: desktop,
      markUnread: markUnread,
      ignoreChannelMentions: ignoreChannelMentions,
      pushThreads: pushThreads,
    );
    await session.store.applyNotifyProps(channelId, jsonEncode(next.toJson()));
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

  /// The direct message with [userId], created on the server when there is
  /// none yet; returns its channel id.
  Future<String> directChannel(String userId) async {
    final known = await directChannelWith(_db, userId);
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

  /// Joins a public channel.
  Future<void> join(String channelId) async {
    final me = await _myId();
    await session.api.call(
      () => _client.channels.addChannelMember(
        channelId: channelId,
        body: api.ApiV4ChannelsChannelIdMembersRequestBody(userId: me),
      ),
    );
    await _storeJoined(
      await session.api.call(
        () => _client.channels.getChannel(channelId: channelId),
      ),
    );
  }

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
