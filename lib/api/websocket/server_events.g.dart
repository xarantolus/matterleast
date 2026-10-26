// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_events.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SocketFrame _$SocketFrameFromJson(Map<String, dynamic> json) => SocketFrame(
  event: const LenientString().fromJson(json['event']),
  data: json['data'] == null
      ? const {}
      : const JsonMapOrEmpty().fromJson(json['data']),
  broadcast: json['broadcast'] == null
      ? const {}
      : const JsonMapOrEmpty().fromJson(json['broadcast']),
  seq: const LenientInt().fromJson(json['seq']),
  status: const LenientString().fromJson(json['status']),
  seqReply: const LenientInt().fromJson(json['seq_reply']),
);

Broadcast _$BroadcastFromJson(Map<String, dynamic> json) => Broadcast(
  userId: const LenientString().fromJson(json['user_id']),
  channelId: const LenientString().fromJson(json['channel_id']),
  teamId: const LenientString().fromJson(json['team_id']),
);

HelloEvent _$HelloEventFromJson(Map<String, dynamic> json) => HelloEvent(
  connectionId: const LenientString().fromJson(json['connection_id']),
  serverVersion: const LenientString().fromJson(json['server_version']),
);

PostedEvent _$PostedEventFromJson(Map<String, dynamic> json) => PostedEvent(
  post: const EncodedPost().fromJson(json['post']),
  mentions: json['mentions'] == null
      ? const []
      : const EncodedStringList().fromJson(json['mentions']),
);

PostEditedEvent _$PostEditedEventFromJson(Map<String, dynamic> json) =>
    PostEditedEvent(post: const EncodedPost().fromJson(json['post']));

PostDeletedEvent _$PostDeletedEventFromJson(Map<String, dynamic> json) =>
    PostDeletedEvent(post: const EncodedPost().fromJson(json['post']));

ReactionEvent _$ReactionEventFromJson(Map<String, dynamic> json) =>
    ReactionEvent(reaction: const EncodedReaction().fromJson(json['reaction']));

EmojiAddedEvent _$EmojiAddedEventFromJson(Map<String, dynamic> json) =>
    EmojiAddedEvent(emoji: const EncodedEmoji().fromJson(json['emoji']));

ChannelViewedEvent _$ChannelViewedEventFromJson(Map<String, dynamic> json) =>
    ChannelViewedEvent(
      channelId: const LenientString().fromJson(json['channel_id']),
      channelTimes: json['channel_times'] == null
          ? const {}
          : const TimesById().fromJson(json['channel_times']),
    );

ChannelUpdatedEvent _$ChannelUpdatedEventFromJson(Map<String, dynamic> json) =>
    ChannelUpdatedEvent(
      channel: const EncodedChannel().fromJson(json['channel']),
    );

ChannelArchivedEvent _$ChannelArchivedEventFromJson(
  Map<String, dynamic> json,
) => ChannelArchivedEvent(
  channelId: const LenientString().fromJson(json['channel_id']),
  deleteAt: const MillisDateTime().fromJson(json['delete_at']),
);

ChannelChangedEvent _$ChannelChangedEventFromJson(Map<String, dynamic> json) =>
    ChannelChangedEvent(
      channelId: const LenientString().fromJson(json['channel_id']),
      userId: const LenientString().fromJson(json['user_id']),
      broadcast: json['broadcast'] == null
          ? null
          : Broadcast.fromJson(json['broadcast'] as Map<String, dynamic>),
    );

ChannelMemberUpdatedEvent _$ChannelMemberUpdatedEventFromJson(
  Map<String, dynamic> json,
) => ChannelMemberUpdatedEvent(
  channelMember: const EncodedChannelMember().fromJson(json['channelMember']),
);

RoleUpdatedEvent _$RoleUpdatedEventFromJson(Map<String, dynamic> json) =>
    RoleUpdatedEvent(role: const EncodedRole().fromJson(json['role']));

UserRolesEvent _$UserRolesEventFromJson(Map<String, dynamic> json) =>
    UserRolesEvent(
      userId: const LenientString().fromJson(json['user_id']),
      roles: const LenientString().fromJson(json['roles']),
    );

TeamMemberRolesEvent _$TeamMemberRolesEventFromJson(
  Map<String, dynamic> json,
) => TeamMemberRolesEvent(
  member: const EncodedTeamMember().fromJson(json['member']),
);

UserRemovedEvent _$UserRemovedEventFromJson(Map<String, dynamic> json) =>
    UserRemovedEvent(
      userId: const LenientString().fromJson(json['user_id']),
      channelId: const LenientString().fromJson(json['channel_id']),
      broadcast: json['broadcast'] == null
          ? null
          : Broadcast.fromJson(json['broadcast'] as Map<String, dynamic>),
    );

CategoriesEvent _$CategoriesEventFromJson(Map<String, dynamic> json) =>
    CategoriesEvent(
      updatedCategories: json['updatedCategories'] == null
          ? const []
          : const EncodedCategories().fromJson(json['updatedCategories']),
      broadcast: json['broadcast'] == null
          ? null
          : Broadcast.fromJson(json['broadcast'] as Map<String, dynamic>),
    );

TeamEvent _$TeamEventFromJson(Map<String, dynamic> json) => TeamEvent(
  teamId: const LenientString().fromJson(json['team_id']),
  userId: const LenientString().fromJson(json['user_id']),
  team: const EncodedTeam().fromJson(json['team']),
);

UserUpdatedEvent _$UserUpdatedEventFromJson(Map<String, dynamic> json) =>
    UserUpdatedEvent(user: const UserObject().fromJson(json['user']));

StatusChangedEvent _$StatusChangedEventFromJson(Map<String, dynamic> json) =>
    StatusChangedEvent(
      userId: const LenientString().fromJson(json['user_id']),
      status: const LenientString().fromJson(json['status']),
    );

PreferencesEvent _$PreferencesEventFromJson(Map<String, dynamic> json) =>
    PreferencesEvent(
      preference: json['preference'] == null
          ? const []
          : const EncodedPreferences().fromJson(json['preference']),
      preferences: json['preferences'] == null
          ? const []
          : const EncodedPreferences().fromJson(json['preferences']),
    );

ThreadUpdatedEvent _$ThreadUpdatedEventFromJson(Map<String, dynamic> json) =>
    ThreadUpdatedEvent(
      thread: const EncodedThread().fromJson(json['thread']),
      broadcast: json['broadcast'] == null
          ? null
          : Broadcast.fromJson(json['broadcast'] as Map<String, dynamic>),
    );

ThreadReadEvent _$ThreadReadEventFromJson(Map<String, dynamic> json) =>
    ThreadReadEvent(
      threadId: const LenientString().fromJson(json['thread_id']),
      timestamp: const MillisDateTime().fromJson(json['timestamp']),
      unreadReplies: const LenientInt().fromJson(json['unread_replies']),
      unreadMentions: const LenientInt().fromJson(json['unread_mentions']),
      broadcast: json['broadcast'] == null
          ? null
          : Broadcast.fromJson(json['broadcast'] as Map<String, dynamic>),
    );

ThreadFollowEvent _$ThreadFollowEventFromJson(Map<String, dynamic> json) =>
    ThreadFollowEvent(
      threadId: const LenientString().fromJson(json['thread_id']),
      state: const LenientBool().fromJson(json['state']),
      replyCount: const LenientInt().fromJson(json['reply_count']),
    );

EphemeralMessageEvent _$EphemeralMessageEventFromJson(
  Map<String, dynamic> json,
) => EphemeralMessageEvent(post: const EncodedPost().fromJson(json['post']));

OpenDialogEvent _$OpenDialogEventFromJson(Map<String, dynamic> json) =>
    OpenDialogEvent(dialog: const EncodedDialog().fromJson(json['dialog']));

TypingEvent _$TypingEventFromJson(Map<String, dynamic> json) => TypingEvent(
  userId: const LenientString().fromJson(json['user_id']),
  parentId: const LenientString().fromJson(json['parent_id']),
  broadcast: json['broadcast'] == null
      ? null
      : Broadcast.fromJson(json['broadcast'] as Map<String, dynamic>),
);
