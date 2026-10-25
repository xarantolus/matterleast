// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_channels_members_user_id_view_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4ChannelsMembersUserIdViewRequestBody
_$ApiV4ChannelsMembersUserIdViewRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4ChannelsMembersUserIdViewRequestBody(
  channelId: json['channel_id'] as String,
  prevChannelId: const LenientString().fromJson(json['prev_channel_id']),
);

Map<String, dynamic> _$ApiV4ChannelsMembersUserIdViewRequestBodyToJson(
  ApiV4ChannelsMembersUserIdViewRequestBody instance,
) => <String, dynamic>{
  'channel_id': instance.channelId,
  'prev_channel_id': const LenientString().toJson(instance.prevChannelId),
};
