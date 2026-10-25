import 'dart:async';

import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/data/sync/entry_sync.dart';
import 'package:matterleast/data/sync/inbox_sync.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/domain/teams.dart';

/// Applies WebSocket events to the database, one at a time and in order.
/// Events whose payload is not enough (a new channel, a team joined) fetch
/// what is missing through the sync runner.
class EventApplier {
  EventApplier({
    required this.server,
    required this.store,
    required this.runner,
    required this.entry,
    required this.inbox,
    DateTime Function()? clock,
  }) : _clock = clock ?? (() => DateTime.now().toUtc());

  final ServerApi server;
  final ServerStore store;
  final SyncRunner runner;
  final EntrySync entry;
  final InboxSync inbox;
  final DateTime Function() _clock;

  ServerDatabase get _db => store.db;
  Future<void> _last = Future.value();

  /// Queues [event] behind the ones before it; the future completes once it
  /// is applied. Failures are logged by the caller's runner, never thrown.
  Future<void> add(ServerEvent event) =>
      _last = _last.then((_) => _apply(event)).catchError((Object _) {});

  Future<void> _apply(ServerEvent event) async {
    final me = await _db.syncText(SyncKeys.currentUserId);
    switch (event) {
      case PostedEvent(:final post?, :final mentions):
        if (post.channelId == null) return;
        if (!await _knownChannel(post.channelId!)) {
          await _refreshChannel(post.channelId!);
          return;
        }
        await store.applyLivePost(
          post,
          fromSelf: post.userId == me && !_isAutomatic(post),
          mentionsMe: me != null && mentions.contains(me),
        );
      case PostEditedEvent(:final post?):
        await store.applyEdit(post);
      case PostDeletedEvent(:final post?) when post.id != null:
        await store.applyDelete(post.id!, at: post.deleteAt ?? _clock());
      case ReactionEvent(:final reaction?, :final added):
        await store.applyReaction(reaction, added: added);
      case ChannelViewedEvent(:final channelId?) when channelId.isNotEmpty:
        await store.markViewed(channelId, at: _clock());
      case ChannelViewedEvent(:final channelTimes):
        await store.applyChannelsViewed(channelTimes);
      case ChannelUpdatedEvent(:final channel?):
        await store.applyChannel(channel);
      case ChannelArchivedEvent(:final channelId?):
        await store.applyChannelArchived(channelId, event.deleteAt);
      case ChannelChangedEvent(:final channel?, :final userId)
          when userId == null || userId.isEmpty || userId == me:
        await _refreshChannel(channel);
      case ChannelChangedEvent():
        return;
      case ChannelMemberUpdatedEvent(:final channelMember?)
          when channelMember.userId == me:
        await store.applyChannelMember(channelMember);
      case UserRemovedEvent(:final channel?) when event.removedUser == me:
        await store.removeChannel(channel);
      case CategoriesEvent(:final updatedCategories)
          when updatedCategories.isNotEmpty:
        await store.applyCategoryUpdates(updatedCategories);
      case CategoriesEvent(:final broadcast?)
          when broadcast.teamId?.isNotEmpty ?? false:
        _later(entry.refreshTeam(broadcast.teamId!, priority: SyncPriority.p1));
      case TeamEvent(kind: TeamChange.joined, :final teamId?)
          when event.userId == me:
        _later(_joinTeam(teamId));
      case TeamEvent(kind: TeamChange.left || TeamChange.deleted)
          when event.id != null && (event.userId == null || event.userId == me):
        await store.removeTeam(event.id!);
      case TeamEvent(kind: TeamChange.updated, :final team?):
        await store.applyTeams([team], const []);
      case UserUpdatedEvent(:final user?):
        await store.applyUsers([user]);
      case StatusChangedEvent(:final userId?, :final status?):
        await store.applyStatuses({userId: status});
      case PreferencesEvent(:final deleted):
        if (deleted) {
          await store.deletePreferences(event.all);
        } else {
          await store.applyPreferences(event.all);
        }
        final missing = await store.applySavedChanges(
          event.all,
          deleted: deleted,
        );
        if (missing.isNotEmpty) _later(inbox.refreshSaved());
      case ThreadUpdatedEvent(:final thread?):
        await store.applyThreads(event.broadcast?.teamId ?? '', [thread]);
      case ThreadReadEvent():
        await store.applyThreadRead(
          teamId: event.broadcast?.teamId ?? '',
          threadId: (event.threadId?.isEmpty ?? true) ? null : event.threadId,
          lastViewedAt: event.timestamp,
          unreadReplies: event.unreadReplies ?? 0,
          unreadMentions: event.unreadMentions ?? 0,
        );
      case ThreadFollowEvent(:final threadId?, :final state?):
        await store.applyThreadFollow(
          threadId,
          following: state,
          replyCount: event.replyCount,
        );
      case ConfigEvent(:final key, :final values) when values.isNotEmpty:
        await store.applyConfig(key, values);
      default:
        return;
    }
  }

  /// System messages and webhook posts don't count as the user reading.
  bool _isAutomatic(api.Post post) =>
      (post.type ?? '').startsWith('system_') ||
      post.props?['from_webhook'] == 'true';

  Future<bool> _knownChannel(String channelId) async =>
      await (_db.select(
        _db.myChannels,
      )..where((m) => m.channelId.equals(channelId))).getSingleOrNull() !=
      null;

  void _later(Future<void> work) => unawaited(work.catchError((Object _) {}));

  /// Fetches a channel and the user's membership, e.g. a new direct message
  /// or a channel the user was added to, and its team's categories.
  Future<void> _refreshChannel(String channelId) => runner.enqueue(
    SyncJob(
      key: 'channel:$channelId',
      priority: SyncPriority.p0,
      run: () async {
        final channel = server.call(
          () => server.client.channels.getChannel(channelId: channelId),
        );
        final member = server.call(
          () => server.client.channels.getChannelMember(
            channelId: channelId,
            userId: 'me',
          ),
        );
        await Future.wait<Object?>([channel, member]);
        await store.applyChannels(
          channels: [await channel],
          members: [await member],
        );
        await _partnerProfile(await channel);
        final team = (await channel).teamId;
        final current = await _db.syncText(SyncKeys.currentTeamId);
        final categoriesOf = (team?.isNotEmpty ?? false) ? team : current;
        if (categoriesOf != null) {
          _later(entry.refreshTeam(categoriesOf, priority: SyncPriority.p1));
        }
      },
    ),
  );

  Future<void> _partnerProfile(api.Channel channel) async {
    final me = await _db.syncText(SyncKeys.currentUserId);
    if (channel.type != 'D' || me == null || channel.name == null) return;
    final partner = directPartnerId(channel.name!, me);
    if (partner == null) return;
    await store.applyUsers(
      await server.call(
        () => server.client.users.getUsersByIds(body: [partner]),
      ),
    );
  }

  Future<void> _joinTeam(String teamId) => runner.enqueue(
    SyncJob(
      key: 'join:$teamId',
      run: () async {
        final team = server.call(
          () => server.client.teams.getTeam(teamId: teamId),
        );
        final member = server.call(
          () => server.client.teams.getTeamMember(teamId: teamId, userId: 'me'),
        );
        await Future.wait<Object?>([team, member]);
        await store.applyTeams([await team], [await member]);
        _later(entry.refreshTeam(teamId, priority: SyncPriority.p1));
      },
    ),
  );
}
