// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'channel_bookmark_with_file_info.dart';

import 'package:matterleast/api/json/lenient_models.dart';
part 'update_channel_bookmark_response.g.dart';

@JsonSerializable()
class UpdateChannelBookmarkResponse {
  const UpdateChannelBookmarkResponse({this.updated, this.deleted});

  factory UpdateChannelBookmarkResponse.fromJson(Map<String, Object?> json) =>
      _$UpdateChannelBookmarkResponseFromJson(json);

  @LenientChannelBookmarkWithFileInfo()
  final ChannelBookmarkWithFileInfo? updated;
  @LenientChannelBookmarkWithFileInfo()
  final ChannelBookmarkWithFileInfo? deleted;

  Map<String, Object?> toJson() => _$UpdateChannelBookmarkResponseToJson(this);
}
