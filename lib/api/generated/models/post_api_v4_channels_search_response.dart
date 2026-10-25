// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'channel.dart';

import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/json/lenient_models.dart';
part 'post_api_v4_channels_search_response.g.dart';

@JsonSerializable()
class PostApiV4ChannelsSearchResponse {
  const PostApiV4ChannelsSearchResponse({
    this.totalCount,
    this.channels = const [],
  });

  factory PostApiV4ChannelsSearchResponse.fromJson(Map<String, Object?> json) =>
      _$PostApiV4ChannelsSearchResponseFromJson(json);

  @LenientListOfChannel()
  final List<Channel> channels;

  @LenientDouble()
  @JsonKey(name: 'total_count')
  final num? totalCount;

  Map<String, Object?> toJson() =>
      _$PostApiV4ChannelsSearchResponseToJson(this);
}
