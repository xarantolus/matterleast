// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sidebar_category_with_channels.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SidebarCategoryWithChannels _$SidebarCategoryWithChannelsFromJson(
  Map<String, dynamic> json,
) => SidebarCategoryWithChannels(
  channelIds: json['channel_ids'] == null
      ? const []
      : const LenientStringList().fromJson(json['channel_ids']),
  id: const LenientString().fromJson(json['id']),
  userId: const LenientString().fromJson(json['user_id']),
  teamId: const LenientString().fromJson(json['team_id']),
  displayName: const LenientString().fromJson(json['display_name']),
  type: json['type'] == null
      ? null
      : SidebarCategoryWithChannelsType.fromJson(json['type'] as String),
);

Map<String, dynamic> _$SidebarCategoryWithChannelsToJson(
  SidebarCategoryWithChannels instance,
) => <String, dynamic>{
  'id': const LenientString().toJson(instance.id),
  'user_id': const LenientString().toJson(instance.userId),
  'team_id': const LenientString().toJson(instance.teamId),
  'display_name': const LenientString().toJson(instance.displayName),
  'type': instance.type,
  'channel_ids': const LenientStringList().toJson(instance.channelIds),
};
