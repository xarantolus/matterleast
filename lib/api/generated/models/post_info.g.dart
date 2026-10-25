// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostInfo _$PostInfoFromJson(Map<String, dynamic> json) => PostInfo(
  channelId: const LenientString().fromJson(json['channel_id']),
  channelType: const LenientString().fromJson(json['channel_type']),
  channelDisplayName: const LenientString().fromJson(
    json['channel_display_name'],
  ),
  hasJoinedChannel: const LenientBool().fromJson(json['has_joined_channel']),
  teamId: const LenientString().fromJson(json['team_id']),
  teamType: const LenientString().fromJson(json['team_type']),
  teamDisplayName: const LenientString().fromJson(json['team_display_name']),
  hasJoinedTeam: const LenientBool().fromJson(json['has_joined_team']),
);

Map<String, dynamic> _$PostInfoToJson(PostInfo instance) => <String, dynamic>{
  'channel_id': const LenientString().toJson(instance.channelId),
  'channel_type': const LenientString().toJson(instance.channelType),
  'channel_display_name': const LenientString().toJson(
    instance.channelDisplayName,
  ),
  'has_joined_channel': const LenientBool().toJson(instance.hasJoinedChannel),
  'team_id': const LenientString().toJson(instance.teamId),
  'team_type': const LenientString().toJson(instance.teamType),
  'team_display_name': const LenientString().toJson(instance.teamDisplayName),
  'has_joined_team': const LenientBool().toJson(instance.hasJoinedTeam),
};
