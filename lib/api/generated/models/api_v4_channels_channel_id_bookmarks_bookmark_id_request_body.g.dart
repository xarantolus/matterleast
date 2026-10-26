// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_channels_channel_id_bookmarks_bookmark_id_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4ChannelsChannelIdBookmarksBookmarkIdRequestBody
_$ApiV4ChannelsChannelIdBookmarksBookmarkIdRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4ChannelsChannelIdBookmarksBookmarkIdRequestBody(
  fileId: const LenientString().fromJson(json['file_id']),
  displayName: const LenientString().fromJson(json['display_name']),
  sortOrder: const LenientInt().fromJson(json['sort_order']),
  linkUrl: const LenientString().fromJson(json['link_url']),
  imageUrl: const LenientString().fromJson(json['image_url']),
  emoji: const LenientString().fromJson(json['emoji']),
  type: json['type'] == null ? null : Type.fromJson(json['type'] as String),
);

Map<String, dynamic>
_$ApiV4ChannelsChannelIdBookmarksBookmarkIdRequestBodyToJson(
  ApiV4ChannelsChannelIdBookmarksBookmarkIdRequestBody instance,
) => <String, dynamic>{
  'file_id': const LenientString().toJson(instance.fileId),
  'display_name': const LenientString().toJson(instance.displayName),
  'sort_order': const LenientInt().toJson(instance.sortOrder),
  'link_url': const LenientString().toJson(instance.linkUrl),
  'image_url': const LenientString().toJson(instance.imageUrl),
  'emoji': const LenientString().toJson(instance.emoji),
  'type': instance.type,
};
