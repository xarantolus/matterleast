// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'data_retention_policy_for_team.g.dart';

@JsonSerializable()
class DataRetentionPolicyForTeam {
  const DataRetentionPolicyForTeam({this.teamId, this.postDuration});

  factory DataRetentionPolicyForTeam.fromJson(Map<String, Object?> json) =>
      _$DataRetentionPolicyForTeamFromJson(json);

  @LenientString()
  @JsonKey(name: 'team_id')
  final String? teamId;
  @LenientInt()
  @JsonKey(name: 'post_duration')
  final int? postDuration;

  Map<String, Object?> toJson() => _$DataRetentionPolicyForTeamToJson(this);
}
