// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_member_with_team_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelMemberWithTeamData _$ChannelMemberWithTeamDataFromJson(
  Map<String, dynamic> json,
) => ChannelMemberWithTeamData(
  channelId: const LenientString().fromJson(json['channel_id']),
  userId: const LenientString().fromJson(json['user_id']),
  roles: const LenientString().fromJson(json['roles']),
  lastViewedAt: const MillisDateTime().fromJson(json['last_viewed_at']),
  msgCount: const LenientInt().fromJson(json['msg_count']),
  mentionCount: const LenientInt().fromJson(json['mention_count']),
  notifyProps: const LenientChannelNotifyProps().fromJson(json['notify_props']),
  lastUpdateAt: const MillisDateTime().fromJson(json['last_update_at']),
  msgCountRoot: const LenientInt().fromJson(json['msg_count_root']),
  mentionCountRoot: const LenientInt().fromJson(json['mention_count_root']),
  urgentMentionCount: const LenientInt().fromJson(json['urgent_mention_count']),
  schemeUser: const LenientBool().fromJson(json['scheme_user']),
  schemeAdmin: const LenientBool().fromJson(json['scheme_admin']),
  schemeGuest: const LenientBool().fromJson(json['scheme_guest']),
  teamDisplayName: const LenientString().fromJson(json['team_display_name']),
  teamName: const LenientString().fromJson(json['team_name']),
  teamUpdateAt: const MillisDateTime().fromJson(json['team_update_at']),
);

Map<String, dynamic> _$ChannelMemberWithTeamDataToJson(
  ChannelMemberWithTeamData instance,
) => <String, dynamic>{
  'channel_id': const LenientString().toJson(instance.channelId),
  'user_id': const LenientString().toJson(instance.userId),
  'roles': const LenientString().toJson(instance.roles),
  'last_viewed_at': const MillisDateTime().toJson(instance.lastViewedAt),
  'msg_count': const LenientInt().toJson(instance.msgCount),
  'mention_count': const LenientInt().toJson(instance.mentionCount),
  'notify_props': const LenientChannelNotifyProps().toJson(
    instance.notifyProps,
  ),
  'last_update_at': const MillisDateTime().toJson(instance.lastUpdateAt),
  'msg_count_root': const LenientInt().toJson(instance.msgCountRoot),
  'mention_count_root': const LenientInt().toJson(instance.mentionCountRoot),
  'urgent_mention_count': const LenientInt().toJson(
    instance.urgentMentionCount,
  ),
  'scheme_user': const LenientBool().toJson(instance.schemeUser),
  'scheme_admin': const LenientBool().toJson(instance.schemeAdmin),
  'scheme_guest': const LenientBool().toJson(instance.schemeGuest),
  'team_display_name': const LenientString().toJson(instance.teamDisplayName),
  'team_name': const LenientString().toJson(instance.teamName),
  'team_update_at': const MillisDateTime().toJson(instance.teamUpdateAt),
};
