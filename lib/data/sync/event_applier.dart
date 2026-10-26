import 'dart:async';

import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/data/actions/channel_actions.dart';
import 'package:matterleast/data/live/dialogs.dart';
import 'package:matterleast/data/live/typing.dart';
import 'package:matterleast/data/server_db/server_config.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/store/extras_store.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/data/sync/draft_sync.dart';
import 'package:matterleast/data/sync/entry_sync.dart';
import 'package:matterleast/data/sync/inbox_sync.dart';
import 'package:matterleast/data/sync/scheduled_sync.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/data/users/user_loader.dart';
import 'package:matterleast/domain/burn_on_read.dart';
import 'package:matterleast/domain/teams.dart';

/// Applies WebSocket events to the database, one at a time and in order.
/// Events whose payload is not enough (a new channel, a team joined) fetch
/// what is missing through the sync runner.
class EventApplier {
  EventApplier({
    required this.server,
    required this.store,
    required this.runner,
    required this.users,
    required this.entry,
    required this.inbox,
    TypingTracker? typing,
    DialogInbox? dialogs,
    this.drafts,
    this.scheduled,
    DateTime Function()? clock,
  }) : typing = typing ?? TypingTracker(),
       dialogs = dialogs ?? DialogInbox(),
       _clock = clock ?? (() => DateTime.now().toUtc());

  final ServerApi server;
  final ServerStore store;
  final SyncRunner runner;
  final UserLoader users;
  final EntrySync entry;
  final InboxSync inbox;
  final TypingTracker typing;
  final DialogInbox dialogs;
  final DraftSync? drafts;
  final ScheduledSync? scheduled;
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
        if (post.userId case final userId?) {
          typing.stopped(post.channelId!, post.rootId ?? '', userId);
        }
        await store.applyLivePost(
          post,
          fromSelf: post.userId == me && !_isAutomatic(post),
          mentionsMe: me != null && mentions.contains(me),
        );
        if (post.userId case final author?) _later(users.ensure([author]));
        await setConversationShown(server, store, post.channelId!, show: true);
      case EphemeralMessageEvent(:final post?)
          when post.channelId != null && await _knownChannel(post.channelId!):
        await store.applyEphemeralPost(post);
      case OpenDialogEvent(:final dialog?):
        dialogs.offer(dialog);
      case TypingEvent(:final userId?, :final broadcast?)
          when userId != me && (broadcast.channelId?.isNotEmpty ?? false):
        typing.expiry = await _typingExpiry();
        typing.typing(broadcast.channelId!, event.parentId ?? '', userId);
        _later(users.ensure([userId]));
      case PostEditedEvent(:final post?):
        await store.applyEdit(post);
      case PostDeletedEvent(:final post?) when post.id != null:
        await store.applyDelete(post.id!, at: post.deleteAt ?? _clock());
      case ReactionEvent(:final reaction?, :final added):
        await store.applyReaction(reaction, added: added);
      case AcknowledgementEvent(:final acknowledgement?, :final added):
        await store.applyAcknowledgement(acknowledgement, added: added);
        if (acknowledgement.userId case final userId?) {
          _later(users.ensure([userId]));
        }
      case EmojiAddedEvent(:final emoji?):
        await store.applyCustomEmoji([emoji]);
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
        _later(entry.ensureRoles([channelMember.roles ?? '']));
      case RoleUpdatedEvent(:final role?):
        if ((await store.roleNames()).contains(role.name)) {
          await store.applyRoles([role]);
        }
      case UserRolesEvent(:final roles?) when event.userId == me:
        await store.applyMyRoles(roles);
        _later(entry.ensureRoles([roles]));
      case TeamMemberRolesEvent(:final member?)
          when member.userId == me && member.deleteAt == null:
        await store.applyTeams(const [], [member]);
        _later(entry.ensureRoles([member.roles ?? '']));
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
        _later(entry.joinedTeam(teamId));
      case TeamEvent(kind: TeamChange.left || TeamChange.deleted)
          when event.id != null && (event.userId == null || event.userId == me):
        await store.removeTeam(event.id!);
      case TeamEvent(kind: TeamChange.updated, :final team?):
        await store.applyTeams([team], const []);
      case UserUpdatedEvent(:final user?) when user.id == me:
        await store.applyMe(user);
        _later(entry.ensureRoles([user.roles ?? '']));
      case UserUpdatedEvent(:final user?):
        await store.applyUsers([user]);
      case StatusChangedEvent(:final userId?, :final status?):
        await store.applyStatuses({userId: status});
      case PreferencesEvent(:final deleted):
        final threadsFlipped = await store.applyPreferencesCheckingThreads(
          event.all,
          deleted: deleted,
        );
        if (threadsFlipped) {
          _later(entry.run().then((_) => inbox.refresh(force: true)));
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
      case ConfigEvent(:final kind, :final values) when values.isNotEmpty:
        switch (kind) {
          case ConfigKind.clientConfig:
            await store.applyConfig(ConfigKeys.clientConfig, values);
            _later(entry.refreshPlugins());
          case ConfigKind.license:
            await store.applyConfig(ConfigKeys.license, values);
        }
      case ScheduledPostEvent(:final scheduledPost?, :final deleted):
        await scheduled?.applyEvent(scheduledPost, deleted: deleted);
      case DraftEvent(:final draft?, :final deleted):
        await drafts?.applyEvent(draft, deleted: deleted);
      case PostRevealedEvent(:final post?):
        await store.applyEdit(post);
      case PostBurnedEvent(:final postId?):
        if ((await store.post(postId))?.type == burnOnReadType) {
          await store.removePost(postId);
        }
      case BurnAllRevealedEvent(:final postId?, :final senderExpireAt?):
        await store.setBurnExpiry(postId, senderExpireAt);
      case PluginsChangedEvent():
        _later(entry.refreshPlugins());
      case BookmarksEvent(:final channelId, :final bookmarks)
          when await _knownChannel(channelId):
        await store.applyBookmarks(channelId, bookmarks);
      case ProfileFieldEvent(:final field?):
        await store.applyProfileField(field);
      case ProfileFieldEvent(:final fieldId):
        await store.removeProfileField(fieldId);
      case ProfileValuesEvent(:final userId, :final values):
        await store.applyProfileValues(userId, values);
      default:
        return;
    }
  }

  Future<Duration> _typingExpiry() async =>
      (await _db.features()).typingInterval;

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
    await users.ensure([partner]);
  }
}
