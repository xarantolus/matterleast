// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'retention_policy_for_team_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RetentionPolicyForTeamList _$RetentionPolicyForTeamListFromJson(
  Map<String, dynamic> json,
) => RetentionPolicyForTeamList(
  totalCount: const LenientInt().fromJson(json['total_count']),
  policies: json['policies'] == null
      ? const []
      : const LenientListOfDataRetentionPolicyForTeam().fromJson(
          json['policies'],
        ),
);

Map<String, dynamic> _$RetentionPolicyForTeamListToJson(
  RetentionPolicyForTeamList instance,
) => <String, dynamic>{
  'policies': const LenientListOfDataRetentionPolicyForTeam().toJson(
    instance.policies,
  ),
  'total_count': const LenientInt().toJson(instance.totalCount),
};
