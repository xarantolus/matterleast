import 'package:json_annotation/json_annotation.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/json/agents.dart';
import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/websocket/dialog.dart';
import 'package:matterleast/api/websocket/encoded.dart';

part 'server_events.g.dart';

/// One message from the server: an event (`event`, `data`, `broadcast`,
/// `seq`) or the reply to one of our actions (`status`, `seq_reply`).
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class SocketFrame {
  const SocketFrame({
    this.event,
    this.data = const {},
    this.broadcast = const {},
    this.seq,
    this.status,
    this.seqReply,
  });

  factory SocketFrame.fromJson(Map<String, Object?> json) =>
      _$SocketFrameFromJson(json);

  @LenientString()
  final String? event;
  @JsonMapOrEmpty()
  final Map<String, Object?> data;
  @JsonMapOrEmpty()
  final Map<String, Object?> broadcast;
  @LenientInt()
  final int? seq;
  @LenientString()
  final String? status;
  @LenientInt()
  final int? seqReply;

  bool get isReply => seqReply != null;

  bool get isPong => isReply && data['text'] == 'pong';
}

/// Who an event was sent to; the channel or team it is about.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class Broadcast {
  const Broadcast({this.userId, this.channelId, this.teamId});

  factory Broadcast.fromJson(Map<String, Object?> json) =>
      _$BroadcastFromJson(json);

  @LenientString()
  final String? userId;
  @LenientString()
  final String? channelId;
  @LenientString()
  final String? teamId;
}

/// A server event we act on. Payloads are decoded once here, including the
/// fields the server sends as JSON inside a string.
sealed class ServerEvent {
  const ServerEvent();
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class HelloEvent extends ServerEvent {
  const HelloEvent({this.connectionId, this.serverVersion});
  factory HelloEvent.fromJson(Map<String, Object?> json) =>
      _$HelloEventFromJson(json);

  @LenientString()
  final String? connectionId;
  @LenientString()
  final String? serverVersion;
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class PostedEvent extends ServerEvent {
  const PostedEvent({this.post, this.mentions = const []});
  factory PostedEvent.fromJson(Map<String, Object?> json) =>
      _$PostedEventFromJson(json);

  @EncodedPost()
  final api.Post? post;

  /// Ids of the users the post mentions (or notifies, in a direct message).
  @EncodedStringList()
  final List<String> mentions;
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class PostEditedEvent extends ServerEvent {
  const PostEditedEvent({this.post});
  factory PostEditedEvent.fromJson(Map<String, Object?> json) =>
      _$PostEditedEventFromJson(json);

  @EncodedPost()
  final api.Post? post;
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class PostDeletedEvent extends ServerEvent {
  const PostDeletedEvent({this.post});
  factory PostDeletedEvent.fromJson(Map<String, Object?> json) =>
      _$PostDeletedEventFromJson(json);

  @EncodedPost()
  final api.Post? post;
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class ReactionEvent extends ServerEvent {
  const ReactionEvent({this.reaction, this.added = true});
  factory ReactionEvent.fromJson(Map<String, Object?> json) =>
      _$ReactionEventFromJson(json);

  @EncodedReaction()
  final api.Reaction? reaction;
  @JsonKey(includeFromJson: false)
  final bool added;
}

/// `post_acknowledgement_added` and `post_acknowledgement_removed`.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class AcknowledgementEvent extends ServerEvent {
  const AcknowledgementEvent({this.acknowledgement, this.added = true});
  factory AcknowledgementEvent.fromJson(Map<String, Object?> json) =>
      _$AcknowledgementEventFromJson(json);

  @EncodedAcknowledgement()
  final api.PostAcknowledgement? acknowledgement;
  @JsonKey(includeFromJson: false)
  final bool added;
}

/// `emoji_added`: someone created a custom emoji.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class EmojiAddedEvent extends ServerEvent {
  const EmojiAddedEvent({this.emoji});
  factory EmojiAddedEvent.fromJson(Map<String, Object?> json) =>
      _$EmojiAddedEventFromJson(json);

  @EncodedEmoji()
  final api.Emoji? emoji;
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class ChannelViewedEvent extends ServerEvent {
  const ChannelViewedEvent({this.channelId, this.channelTimes = const {}});
  factory ChannelViewedEvent.fromJson(Map<String, Object?> json) =>
      _$ChannelViewedEventFromJson(json);

  @LenientString()
  final String? channelId;

  /// Set for `multiple_channels_viewed` instead of [channelId].
  @TimesById()
  final Map<String, DateTime> channelTimes;
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class ChannelUpdatedEvent extends ServerEvent {
  const ChannelUpdatedEvent({this.channel});
  factory ChannelUpdatedEvent.fromJson(Map<String, Object?> json) =>
      _$ChannelUpdatedEventFromJson(json);

  @EncodedChannel()
  final api.Channel? channel;
}

/// `channel_deleted` (archived) and `channel_restored`.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class ChannelArchivedEvent extends ServerEvent {
  const ChannelArchivedEvent({this.channelId, this.deleteAt});
  factory ChannelArchivedEvent.fromJson(Map<String, Object?> json) =>
      _$ChannelArchivedEventFromJson(json);

  @LenientString()
  final String? channelId;

  /// Null when restored.
  @MillisDateTime()
  final DateTime? deleteAt;
}

/// The user's membership or a channel's shape changed in a way the payload
/// doesn't carry (`post_unread`, `channel_created`, `channel_converted`,
/// `direct_added`, `group_added`, `user_added`): refetch the channel.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class ChannelChangedEvent extends ServerEvent {
  const ChannelChangedEvent({this.channelId, this.userId, this.broadcast});
  factory ChannelChangedEvent.fromJson(Map<String, Object?> json) =>
      _$ChannelChangedEventFromJson(json);

  @LenientString()
  final String? channelId;

  /// For `user_added`, who was added.
  @LenientString()
  final String? userId;
  final Broadcast? broadcast;

  String? get channel =>
      (channelId?.isNotEmpty ?? false) ? channelId : broadcast?.channelId;
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class ChannelMemberUpdatedEvent extends ServerEvent {
  const ChannelMemberUpdatedEvent({this.channelMember});
  factory ChannelMemberUpdatedEvent.fromJson(Map<String, Object?> json) =>
      _$ChannelMemberUpdatedEventFromJson(json);

  @EncodedChannelMember()
  @JsonKey(name: 'channelMember')
  final api.ChannelMember? channelMember;
}

/// `role_updated`: a role's permissions changed.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class RoleUpdatedEvent extends ServerEvent {
  const RoleUpdatedEvent({this.role});
  factory RoleUpdatedEvent.fromJson(Map<String, Object?> json) =>
      _$RoleUpdatedEventFromJson(json);

  @EncodedRole()
  final api.Role? role;
}

/// `user_role_updated`: a user's system roles changed.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class UserRolesEvent extends ServerEvent {
  const UserRolesEvent({this.userId, this.roles});
  factory UserRolesEvent.fromJson(Map<String, Object?> json) =>
      _$UserRolesEventFromJson(json);

  @LenientString()
  final String? userId;

  /// Space-separated role names.
  @LenientString()
  final String? roles;
}

/// `memberrole_updated`: a team membership's roles changed.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class TeamMemberRolesEvent extends ServerEvent {
  const TeamMemberRolesEvent({this.member});
  factory TeamMemberRolesEvent.fromJson(Map<String, Object?> json) =>
      _$TeamMemberRolesEventFromJson(json);

  @EncodedTeamMember()
  final api.TeamMember? member;
}

/// `user_removed`: sent to the removed user (with [Broadcast.userId]) and to
/// the channel (with [userId]).
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class UserRemovedEvent extends ServerEvent {
  const UserRemovedEvent({this.userId, this.channelId, this.broadcast});
  factory UserRemovedEvent.fromJson(Map<String, Object?> json) =>
      _$UserRemovedEventFromJson(json);

  @LenientString()
  final String? userId;
  @LenientString()
  final String? channelId;
  final Broadcast? broadcast;

  String? get removedUser =>
      (userId?.isNotEmpty ?? false) ? userId : broadcast?.userId;

  String? get channel =>
      (channelId?.isNotEmpty ?? false) ? channelId : broadcast?.channelId;
}

/// `sidebar_category_updated` carries the categories;
/// created/deleted/order_updated only name the team, which is refetched.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class CategoriesEvent extends ServerEvent {
  const CategoriesEvent({this.updatedCategories = const [], this.broadcast});
  factory CategoriesEvent.fromJson(Map<String, Object?> json) =>
      _$CategoriesEventFromJson(json);

  @EncodedCategories()
  @JsonKey(name: 'updatedCategories')
  final List<api.SidebarCategoryWithChannels> updatedCategories;
  final Broadcast? broadcast;
}

/// `added_to_team`, `leave_team`, `update_team`, `delete_team`.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class TeamEvent extends ServerEvent {
  const TeamEvent({
    this.teamId,
    this.userId,
    this.team,
    this.kind = TeamChange.updated,
  });
  factory TeamEvent.fromJson(Map<String, Object?> json) =>
      _$TeamEventFromJson(json);

  @LenientString()
  final String? teamId;
  @LenientString()
  final String? userId;
  @EncodedTeam()
  final api.Team? team;
  @JsonKey(includeFromJson: false)
  final TeamChange kind;

  String? get id => team?.id ?? teamId;
}

enum TeamChange { joined, left, updated, deleted }

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class UserUpdatedEvent extends ServerEvent {
  const UserUpdatedEvent({this.user});
  factory UserUpdatedEvent.fromJson(Map<String, Object?> json) =>
      _$UserUpdatedEventFromJson(json);

  @UserObject()
  final api.User? user;
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class StatusChangedEvent extends ServerEvent {
  const StatusChangedEvent({this.userId, this.status});
  factory StatusChangedEvent.fromJson(Map<String, Object?> json) =>
      _$StatusChangedEventFromJson(json);

  @LenientString()
  final String? userId;
  @LenientString()
  final String? status;
}

/// `preference_changed` (one) and `preferences_changed`/`_deleted` (many).
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class PreferencesEvent extends ServerEvent {
  const PreferencesEvent({
    this.preference = const [],
    this.preferences = const [],
    this.deleted = false,
  });
  factory PreferencesEvent.fromJson(Map<String, Object?> json) =>
      _$PreferencesEventFromJson(json);

  @EncodedPreferences()
  final List<api.Preference> preference;
  @EncodedPreferences()
  final List<api.Preference> preferences;
  @JsonKey(includeFromJson: false)
  final bool deleted;

  List<api.Preference> get all => [...preference, ...preferences];
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class ThreadUpdatedEvent extends ServerEvent {
  const ThreadUpdatedEvent({this.thread, this.broadcast});
  factory ThreadUpdatedEvent.fromJson(Map<String, Object?> json) =>
      _$ThreadUpdatedEventFromJson(json);

  @EncodedThread()
  final api.UserThread? thread;
  final Broadcast? broadcast;
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class ThreadReadEvent extends ServerEvent {
  const ThreadReadEvent({
    this.threadId,
    this.timestamp,
    this.unreadReplies,
    this.unreadMentions,
    this.broadcast,
  });
  factory ThreadReadEvent.fromJson(Map<String, Object?> json) =>
      _$ThreadReadEventFromJson(json);

  /// Empty when all of the team's threads were marked read.
  @LenientString()
  final String? threadId;
  @MillisDateTime()
  final DateTime? timestamp;
  @LenientInt()
  final int? unreadReplies;
  @LenientInt()
  final int? unreadMentions;
  final Broadcast? broadcast;
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class ThreadFollowEvent extends ServerEvent {
  const ThreadFollowEvent({this.threadId, this.state, this.replyCount});
  factory ThreadFollowEvent.fromJson(Map<String, Object?> json) =>
      _$ThreadFollowEventFromJson(json);

  @LenientString()
  final String? threadId;
  @LenientBool()
  final bool? state;
  @LenientInt()
  final int? replyCount;
}

/// A message only this user sees, such as a command's reply.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class EphemeralMessageEvent extends ServerEvent {
  const EphemeralMessageEvent({this.post});
  factory EphemeralMessageEvent.fromJson(Map<String, Object?> json) =>
      _$EphemeralMessageEventFromJson(json);

  @EncodedPost()
  final api.Post? post;
}

/// An integration asks this user to fill in a dialog.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class OpenDialogEvent extends ServerEvent {
  const OpenDialogEvent({this.dialog});
  factory OpenDialogEvent.fromJson(Map<String, Object?> json) =>
      _$OpenDialogEventFromJson(json);

  @EncodedDialog()
  final OpenDialog? dialog;
}

/// Someone is writing in a channel, or in a thread when [parentId] is set.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class TypingEvent extends ServerEvent {
  const TypingEvent({this.userId, this.parentId, this.broadcast});
  factory TypingEvent.fromJson(Map<String, Object?> json) =>
      _$TypingEventFromJson(json);

  @LenientString()
  final String? userId;
  @LenientString()
  final String? parentId;
  final Broadcast? broadcast;
}

/// `scheduled_post_created`, `scheduled_post_updated` and
/// `scheduled_post_deleted`.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.none)
final class ScheduledPostEvent extends ServerEvent {
  const ScheduledPostEvent({this.scheduledPost, this.deleted = false});
  factory ScheduledPostEvent.fromJson(Map<String, Object?> json) =>
      _$ScheduledPostEventFromJson(json);

  @EncodedScheduledPost()
  final api.ScheduledPost? scheduledPost;
  @JsonKey(includeFromJson: false)
  final bool deleted;
}

/// `draft_created`, `draft_updated` and `draft_deleted`.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class DraftEvent extends ServerEvent {
  const DraftEvent({this.draft, this.deleted = false});
  factory DraftEvent.fromJson(Map<String, Object?> json) =>
      _$DraftEventFromJson(json);

  @EncodedDraft()
  final api.Draft? draft;
  @JsonKey(includeFromJson: false)
  final bool deleted;
}

/// A recipient opened a burn-on-read message; [recipients] are those who
/// have so far.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class PostRevealedEvent extends ServerEvent {
  const PostRevealedEvent({this.post, this.recipients = const []});
  factory PostRevealedEvent.fromJson(Map<String, Object?> json) =>
      _$PostRevealedEventFromJson(json);

  @EncodedPost()
  final api.Post? post;
  @EncodedStringList()
  final List<String> recipients;
}

/// A burn-on-read message burned: its sender burned it, or it expired for
/// this user.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class PostBurnedEvent extends ServerEvent {
  const PostBurnedEvent({this.postId});
  factory PostBurnedEvent.fromJson(Map<String, Object?> json) =>
      _$PostBurnedEventFromJson(json);

  @LenientString()
  final String? postId;
}

/// Every recipient opened the user's burn-on-read message; it burns for the
/// sender at [senderExpireAt].
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
final class BurnAllRevealedEvent extends ServerEvent {
  const BurnAllRevealedEvent({this.postId, this.senderExpireAt});
  factory BurnAllRevealedEvent.fromJson(Map<String, Object?> json) =>
      _$BurnAllRevealedEventFromJson(json);

  @LenientString()
  final String? postId;
  @MillisDateTime()
  final DateTime? senderExpireAt;
}

enum ConfigKind { clientConfig, license }

/// `config_changed` and `license_changed`; the snapshot replaces the stored
/// one.
final class ConfigEvent extends ServerEvent {
  const ConfigEvent(this.kind, this.values);
  final ConfigKind kind;
  final Map<String, Object?> values;
}

/// `plugin_enabled`, `plugin_disabled` and `plugin_statuses_changed`.
final class PluginsChangedEvent extends ServerEvent {
  const PluginsChangedEvent();
}

/// `custom_mattermost-ai_postupdate` and
/// `custom_mattermost-ai_tool_call_status_updated`: an agent answer streams.
final class AgentPostEvent extends ServerEvent {
  const AgentPostEvent(this.update);
  final AgentPostUpdate update;
}

/// `custom_mattermost-ai_conversation_updated`.
final class AgentConversationEvent extends ServerEvent {
  const AgentConversationEvent(this.conversationId);
  final String conversationId;
}

final class UnknownEvent extends ServerEvent {
  const UnknownEvent(this.name);
  final String name;
}

/// Pure: decodes a server event frame. Events we don't handle are
/// [UnknownEvent]s.
ServerEvent decodeEvent(SocketFrame frame) {
  final json = {...frame.data, 'broadcast': frame.broadcast};
  return switch (frame.event) {
    'hello' => HelloEvent.fromJson(json),
    'posted' => PostedEvent.fromJson(json),
    'post_edited' => PostEditedEvent.fromJson(json),
    'post_deleted' => PostDeletedEvent.fromJson(json),
    'reaction_added' => ReactionEvent.fromJson(json),
    'reaction_removed' => ReactionEvent(
      reaction: ReactionEvent.fromJson(json).reaction,
      added: false,
    ),
    'post_acknowledgement_added' => AcknowledgementEvent.fromJson(json),
    'post_acknowledgement_removed' => AcknowledgementEvent(
      acknowledgement: AcknowledgementEvent.fromJson(json).acknowledgement,
      added: false,
    ),
    'emoji_added' => EmojiAddedEvent.fromJson(json),
    'ephemeral_message' => EphemeralMessageEvent.fromJson(json),
    'open_dialog' => OpenDialogEvent.fromJson(json),
    'typing' => TypingEvent.fromJson(json),
    'channel_viewed' ||
    'multiple_channels_viewed' => ChannelViewedEvent.fromJson(json),
    'channel_updated' => ChannelUpdatedEvent.fromJson(json),
    'channel_deleted' => ChannelArchivedEvent.fromJson(json),
    'channel_restored' => ChannelArchivedEvent(
      channelId: ChannelArchivedEvent.fromJson(json).channelId,
    ),
    'post_unread' ||
    'channel_created' ||
    'channel_converted' ||
    'direct_added' ||
    'group_added' ||
    'user_added' => ChannelChangedEvent.fromJson(json),
    'channel_member_updated' => ChannelMemberUpdatedEvent.fromJson(json),
    'user_removed' => UserRemovedEvent.fromJson(json),
    'role_updated' => RoleUpdatedEvent.fromJson(json),
    'user_role_updated' => UserRolesEvent.fromJson(json),
    'memberrole_updated' => TeamMemberRolesEvent.fromJson(json),
    'sidebar_category_created' ||
    'sidebar_category_updated' ||
    'sidebar_category_deleted' ||
    'sidebar_category_order_updated' => CategoriesEvent.fromJson(json),
    'added_to_team' => _team(json, TeamChange.joined),
    'leave_team' => _team(json, TeamChange.left),
    'update_team' => _team(json, TeamChange.updated),
    'delete_team' => _team(json, TeamChange.deleted),
    'user_updated' => UserUpdatedEvent.fromJson(json),
    'status_change' => StatusChangedEvent.fromJson(json),
    'preference_changed' ||
    'preferences_changed' => PreferencesEvent.fromJson(json),
    'preferences_deleted' => PreferencesEvent(
      preferences: PreferencesEvent.fromJson(json).all,
      deleted: true,
    ),
    'thread_updated' => ThreadUpdatedEvent.fromJson(json),
    'thread_read_changed' => ThreadReadEvent.fromJson(json),
    'thread_follow_changed' => ThreadFollowEvent.fromJson(json),
    'config_changed' => ConfigEvent(
      ConfigKind.clientConfig,
      const JsonMapOrEmpty().fromJson(frame.data['config']),
    ),
    'license_changed' => ConfigEvent(
      ConfigKind.license,
      const JsonMapOrEmpty().fromJson(frame.data['license']),
    ),
    'scheduled_post_created' ||
    'scheduled_post_updated' => ScheduledPostEvent.fromJson(json),
    'scheduled_post_deleted' => ScheduledPostEvent(
      scheduledPost: ScheduledPostEvent.fromJson(json).scheduledPost,
      deleted: true,
    ),
    'draft_created' || 'draft_updated' => DraftEvent.fromJson(json),
    'draft_deleted' => DraftEvent(
      draft: DraftEvent.fromJson(json).draft,
      deleted: true,
    ),
    'post_revealed' => PostRevealedEvent.fromJson(json),
    'post_burned' => PostBurnedEvent.fromJson(json),
    'burn_on_read_all_revealed' => BurnAllRevealedEvent.fromJson(json),
    'plugin_enabled' ||
    'plugin_disabled' ||
    'plugin_statuses_changed' => const PluginsChangedEvent(),
    'custom_mattermost-ai_postupdate' ||
    'custom_mattermost-ai_tool_call_status_updated' => AgentPostEvent(
      AgentPostUpdate.fromJson(frame.data),
    ),
    'custom_mattermost-ai_conversation_updated' => AgentConversationEvent(
      const LenientString().fromJson(frame.data['conversation_id']) ?? '',
    ),
    final name => UnknownEvent(name ?? ''),
  };
}

TeamEvent _team(Map<String, Object?> json, TeamChange kind) {
  final decoded = TeamEvent.fromJson(json);
  return TeamEvent(
    teamId: decoded.teamId,
    userId: decoded.userId,
    team: decoded.team,
    kind: kind,
  );
}
