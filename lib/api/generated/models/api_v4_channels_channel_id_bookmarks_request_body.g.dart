// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_channels_channel_id_bookmarks_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4ChannelsChannelIdBookmarksRequestBody
_$ApiV4ChannelsChannelIdBookmarksRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4ChannelsChannelIdBookmarksRequestBody(
  displayName: json['display_name'] as String,
  type: Type.fromJson(json['type'] as String),
  fileId: const LenientString().fromJson(json['file_id']),
  linkUrl: const LenientString().fromJson(json['link_url']),
  imageUrl: const LenientString().fromJson(json['image_url']),
  emoji: const LenientString().fromJson(json['emoji']),
);

Map<String, dynamic> _$ApiV4ChannelsChannelIdBookmarksRequestBodyToJson(
  ApiV4ChannelsChannelIdBookmarksRequestBody instance,
) => <String, dynamic>{
  'file_id': const LenientString().toJson(instance.fileId),
  'display_name': instance.displayName,
  'link_url': const LenientString().toJson(instance.linkUrl),
  'image_url': const LenientString().toJson(instance.imageUrl),
  'emoji': const LenientString().toJson(instance.emoji),
  'type': instance.type,
};
