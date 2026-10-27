// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_users_search_request_body.g.dart';

@JsonSerializable()
class ApiV4UsersSearchRequestBody {
  const ApiV4UsersSearchRequestBody({
    required this.term,
    this.limit = 100,
    this.teamId,
    this.notInTeamId,
    this.inChannelId,
    this.notInChannelId,
    this.inGroupId,
    this.groupConstrained,
    this.allowInactive,
    this.withoutTeam,
  });

  factory ApiV4UsersSearchRequestBody.fromJson(Map<String, Object?> json) =>
      _$ApiV4UsersSearchRequestBodyFromJson(json);

  final String term;
  @LenientString()
  @JsonKey(name: 'team_id')
  final String? teamId;
  @LenientString()
  @JsonKey(name: 'not_in_team_id')
  final String? notInTeamId;
  @LenientString()
  @JsonKey(name: 'in_channel_id')
  final String? inChannelId;
  @LenientString()
  @JsonKey(name: 'not_in_channel_id')
  final String? notInChannelId;
  @LenientString()
  @JsonKey(name: 'in_group_id')
  final String? inGroupId;
  @LenientBool()
  @JsonKey(name: 'group_constrained')
  final bool? groupConstrained;
  @LenientBool()
  @JsonKey(name: 'allow_inactive')
  final bool? allowInactive;
  @LenientBool()
  @JsonKey(name: 'without_team')
  final bool? withoutTeam;
  final int limit;

  Map<String, Object?> toJson() => _$ApiV4UsersSearchRequestBodyToJson(this);
}
