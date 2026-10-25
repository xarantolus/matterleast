// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_teams_team_id_members_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4TeamsTeamIdMembersRequestBody _$ApiV4TeamsTeamIdMembersRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4TeamsTeamIdMembersRequestBody(
  teamId: const LenientString().fromJson(json['team_id']),
  userId: const LenientString().fromJson(json['user_id']),
);

Map<String, dynamic> _$ApiV4TeamsTeamIdMembersRequestBodyToJson(
  ApiV4TeamsTeamIdMembersRequestBody instance,
) => <String, dynamic>{
  'team_id': const LenientString().toJson(instance.teamId),
  'user_id': const LenientString().toJson(instance.userId),
};
