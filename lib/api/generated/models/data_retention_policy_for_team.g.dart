// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_retention_policy_for_team.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataRetentionPolicyForTeam _$DataRetentionPolicyForTeamFromJson(
  Map<String, dynamic> json,
) => DataRetentionPolicyForTeam(
  teamId: const LenientString().fromJson(json['team_id']),
  postDuration: const LenientInt().fromJson(json['post_duration']),
);

Map<String, dynamic> _$DataRetentionPolicyForTeamToJson(
  DataRetentionPolicyForTeam instance,
) => <String, dynamic>{
  'team_id': const LenientString().toJson(instance.teamId),
  'post_duration': const LenientInt().toJson(instance.postDuration),
};
