// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_users_search_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4UsersSearchRequestBody _$ApiV4UsersSearchRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4UsersSearchRequestBody(
  term: json['term'] as String,
  limit: (json['limit'] as num?)?.toInt() ?? 100,
  teamId: const LenientString().fromJson(json['team_id']),
  notInTeamId: const LenientString().fromJson(json['not_in_team_id']),
  inChannelId: const LenientString().fromJson(json['in_channel_id']),
  notInChannelId: const LenientString().fromJson(json['not_in_channel_id']),
  inGroupId: const LenientString().fromJson(json['in_group_id']),
  groupConstrained: const LenientBool().fromJson(json['group_constrained']),
  allowInactive: const LenientBool().fromJson(json['allow_inactive']),
  withoutTeam: const LenientBool().fromJson(json['without_team']),
);

Map<String, dynamic> _$ApiV4UsersSearchRequestBodyToJson(
  ApiV4UsersSearchRequestBody instance,
) => <String, dynamic>{
  'term': instance.term,
  'team_id': const LenientString().toJson(instance.teamId),
  'not_in_team_id': const LenientString().toJson(instance.notInTeamId),
  'in_channel_id': const LenientString().toJson(instance.inChannelId),
  'not_in_channel_id': const LenientString().toJson(instance.notInChannelId),
  'in_group_id': const LenientString().toJson(instance.inGroupId),
  'group_constrained': const LenientBool().toJson(instance.groupConstrained),
  'allow_inactive': const LenientBool().toJson(instance.allowInactive),
  'without_team': const LenientBool().toJson(instance.withoutTeam),
  'limit': instance.limit,
};
