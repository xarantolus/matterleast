// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v4_channels_members_user_id_mark_read_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV4ChannelsMembersUserIdMarkReadResponse
_$PostApiV4ChannelsMembersUserIdMarkReadResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV4ChannelsMembersUserIdMarkReadResponse(
  status: const LenientString().fromJson(json['status']),
  lastViewedAtTimes: const JsonMap().fromJson(json['last_viewed_at_times']),
);

Map<String, dynamic> _$PostApiV4ChannelsMembersUserIdMarkReadResponseToJson(
  PostApiV4ChannelsMembersUserIdMarkReadResponse instance,
) => <String, dynamic>{
  'status': const LenientString().toJson(instance.status),
  'last_viewed_at_times': const JsonMap().toJson(instance.lastViewedAtTimes),
};
