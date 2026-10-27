// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'type.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_channels_channel_id_bookmarks_bookmark_id_request_body.g.dart';

@JsonSerializable()
class ApiV4ChannelsChannelIdBookmarksBookmarkIdRequestBody {
  const ApiV4ChannelsChannelIdBookmarksBookmarkIdRequestBody({
    this.fileId,
    this.displayName,
    this.sortOrder,
    this.linkUrl,
    this.imageUrl,
    this.emoji,
    this.type,
  });

  factory ApiV4ChannelsChannelIdBookmarksBookmarkIdRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4ChannelsChannelIdBookmarksBookmarkIdRequestBodyFromJson(json);

  @LenientString()
  @JsonKey(name: 'file_id')
  final String? fileId;
  @LenientString()
  @JsonKey(name: 'display_name')
  final String? displayName;
  @LenientInt()
  @JsonKey(name: 'sort_order')
  final int? sortOrder;
  @LenientString()
  @JsonKey(name: 'link_url')
  final String? linkUrl;
  @LenientString()
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @LenientString()
  final String? emoji;
  final Type? type;

  Map<String, Object?> toJson() =>
      _$ApiV4ChannelsChannelIdBookmarksBookmarkIdRequestBodyToJson(this);
}
