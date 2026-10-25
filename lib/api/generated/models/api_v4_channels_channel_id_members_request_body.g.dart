// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_channels_channel_id_members_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4ChannelsChannelIdMembersRequestBody
_$ApiV4ChannelsChannelIdMembersRequestBodyFromJson(Map<String, dynamic> json) =>
    ApiV4ChannelsChannelIdMembersRequestBody(
      userIds: json['user_ids'] == null
          ? const []
          : const LenientStringList().fromJson(json['user_ids']),
      userId: const LenientString().fromJson(json['user_id']),
      postRootId: const LenientString().fromJson(json['post_root_id']),
    );

Map<String, dynamic> _$ApiV4ChannelsChannelIdMembersRequestBodyToJson(
  ApiV4ChannelsChannelIdMembersRequestBody instance,
) => <String, dynamic>{
  'user_id': const LenientString().toJson(instance.userId),
  'user_ids': const LenientStringList().toJson(instance.userIds),
  'post_root_id': const LenientString().toJson(instance.postRootId),
};
