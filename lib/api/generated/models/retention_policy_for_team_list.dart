// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'data_retention_policy_for_team.dart';

import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/json/lenient_models.dart';
part 'retention_policy_for_team_list.g.dart';

@JsonSerializable()
class RetentionPolicyForTeamList {
  const RetentionPolicyForTeamList({this.totalCount, this.policies = const []});

  factory RetentionPolicyForTeamList.fromJson(Map<String, Object?> json) =>
      _$RetentionPolicyForTeamListFromJson(json);

  @LenientListOfDataRetentionPolicyForTeam()
  final List<DataRetentionPolicyForTeam> policies;

  @LenientInt()
  @JsonKey(name: 'total_count')
  final int? totalCount;

  Map<String, Object?> toJson() => _$RetentionPolicyForTeamListToJson(this);
}
