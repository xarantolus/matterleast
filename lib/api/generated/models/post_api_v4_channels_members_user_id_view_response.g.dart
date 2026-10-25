// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v4_channels_members_user_id_view_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV4ChannelsMembersUserIdViewResponse
_$PostApiV4ChannelsMembersUserIdViewResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV4ChannelsMembersUserIdViewResponse(
  status: const LenientString().fromJson(json['status']),
  lastViewedAtTimes: const JsonMap().fromJson(json['last_viewed_at_times']),
);

Map<String, dynamic> _$PostApiV4ChannelsMembersUserIdViewResponseToJson(
  PostApiV4ChannelsMembersUserIdViewResponse instance,
) => <String, dynamic>{
  'status': const LenientString().toJson(instance.status),
  'last_viewed_at_times': const JsonMap().toJson(instance.lastViewedAtTimes),
};
