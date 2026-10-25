// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v4_channels_search_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV4ChannelsSearchResponse _$PostApiV4ChannelsSearchResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV4ChannelsSearchResponse(
  totalCount: json['total_count'] as num?,
  channels: json['channels'] == null
      ? const []
      : const LenientListOfChannel().fromJson(json['channels']),
);

Map<String, dynamic> _$PostApiV4ChannelsSearchResponseToJson(
  PostApiV4ChannelsSearchResponse instance,
) => <String, dynamic>{
  'channels': const LenientListOfChannel().toJson(instance.channels),
  'total_count': instance.totalCount,
};
