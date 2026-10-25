// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'post_info.g.dart';

@JsonSerializable()
class PostInfo {
  const PostInfo({
    this.channelId,
    this.channelType,
    this.channelDisplayName,
    this.hasJoinedChannel,
    this.teamId,
    this.teamType,
    this.teamDisplayName,
    this.hasJoinedTeam,
  });

  factory PostInfo.fromJson(Map<String, Object?> json) =>
      _$PostInfoFromJson(json);

  @LenientString()
  @JsonKey(name: 'channel_id')
  final String? channelId;

  @LenientString()
  @JsonKey(name: 'channel_type')
  final String? channelType;

  @LenientString()
  @JsonKey(name: 'channel_display_name')
  final String? channelDisplayName;

  @LenientBool()
  @JsonKey(name: 'has_joined_channel')
  final bool? hasJoinedChannel;

  @LenientString()
  @JsonKey(name: 'team_id')
  final String? teamId;

  @LenientString()
  @JsonKey(name: 'team_type')
  final String? teamType;

  @LenientString()
  @JsonKey(name: 'team_display_name')
  final String? teamDisplayName;

  @LenientBool()
  @JsonKey(name: 'has_joined_team')
  final bool? hasJoinedTeam;

  Map<String, Object?> toJson() => _$PostInfoToJson(this);
}
