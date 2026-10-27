// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'type.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_channels_channel_id_bookmarks_request_body.g.dart';

@JsonSerializable()
class ApiV4ChannelsChannelIdBookmarksRequestBody {
  const ApiV4ChannelsChannelIdBookmarksRequestBody({
    required this.displayName,
    required this.type,
    this.fileId,
    this.linkUrl,
    this.imageUrl,
    this.emoji,
  });

  factory ApiV4ChannelsChannelIdBookmarksRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4ChannelsChannelIdBookmarksRequestBodyFromJson(json);

  @LenientString()
  @JsonKey(name: 'file_id')
  final String? fileId;
  @JsonKey(name: 'display_name')
  final String displayName;
  @LenientString()
  @JsonKey(name: 'link_url')
  final String? linkUrl;
  @LenientString()
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @LenientString()
  final String? emoji;
  final Type type;

  Map<String, Object?> toJson() =>
      _$ApiV4ChannelsChannelIdBookmarksRequestBodyToJson(this);
}
