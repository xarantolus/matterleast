// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_teams_team_id_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4TeamsTeamIdRequestBody _$ApiV4TeamsTeamIdRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4TeamsTeamIdRequestBody(
  id: json['id'] as String,
  displayName: json['display_name'] as String,
  description: json['description'] as String,
  companyName: json['company_name'] as String,
  allowedDomains: json['allowed_domains'] as String,
  inviteId: json['invite_id'] as String,
  allowOpenInvite: json['allow_open_invite'] as String,
);

Map<String, dynamic> _$ApiV4TeamsTeamIdRequestBodyToJson(
  ApiV4TeamsTeamIdRequestBody instance,
) => <String, dynamic>{
  'id': instance.id,
  'display_name': instance.displayName,
  'description': instance.description,
  'company_name': instance.companyName,
  'allowed_domains': instance.allowedDomains,
  'invite_id': instance.inviteId,
  'allow_open_invite': instance.allowOpenInvite,
};
