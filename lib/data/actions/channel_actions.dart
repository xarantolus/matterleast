import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
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

  /// The user opened a channel: it is read, and remembered as the team's
  /// last one.
  Future<void> open(String channelId, {String? teamId}) async {
    if (teamId != null && teamId.isNotEmpty) {
      await session.store.setLastChannel(teamId, channelId);
    }
    await view(channelId);
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
  Future<void> setMuted(String channelId, {required bool muted}) async {
    final mine = await (_db.select(
      _db.myChannels,
    )..where((m) => m.channelId.equals(channelId))).getSingle();
    final stored = jsonDecode(mine.notifyPropsJson ?? '{}');
    final props = api.ChannelNotifyProps.fromJson(
      stored is Map<String, Object?> ? stored : const {},
    );
    await session.api.call(
      () => _client.channels.updateChannelNotifyProps(
        channelId: channelId,
        userId: 'me',
        // Every field is sent; missing ones would be stored as empty.
        body: api.ChannelNotifyProps(
          email: props.email ?? 'default',
          push: props.push ?? 'default',
          desktop: props.desktop ?? 'default',
          markUnread: muted ? 'mention' : 'all',
        ),
      ),
    );
    await session.store.applyChannelMember(
      await session.api.call(
        () => _client.channels.getChannelMember(
          channelId: channelId,
          userId: 'me',
        ),
      ),
    );
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
