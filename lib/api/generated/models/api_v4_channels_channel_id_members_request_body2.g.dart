// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_channels_channel_id_members_request_body2.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4ChannelsChannelIdMembersRequestBody2
_$ApiV4ChannelsChannelIdMembersRequestBody2FromJson(
  Map<String, dynamic> json,
) => ApiV4ChannelsChannelIdMembersRequestBody2(
  members: json['members'] == null
      ? const []
      : const LenientStringList().fromJson(json['members']),
  channelAdmins:
      (json['channel_admins'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$ApiV4ChannelsChannelIdMembersRequestBody2ToJson(
  ApiV4ChannelsChannelIdMembersRequestBody2 instance,
) => <String, dynamic>{
  'members': const LenientStringList().toJson(instance.members),
  'channel_admins': instance.channelAdmins,
};
