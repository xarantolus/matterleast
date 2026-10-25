// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_teams_team_id_patch_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4TeamsTeamIdPatchRequestBody _$ApiV4TeamsTeamIdPatchRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4TeamsTeamIdPatchRequestBody(
  displayName: const LenientString().fromJson(json['display_name']),
  description: const LenientString().fromJson(json['description']),
  companyName: const LenientString().fromJson(json['company_name']),
  inviteId: const LenientString().fromJson(json['invite_id']),
  allowOpenInvite: const LenientBool().fromJson(json['allow_open_invite']),
);

Map<String, dynamic> _$ApiV4TeamsTeamIdPatchRequestBodyToJson(
  ApiV4TeamsTeamIdPatchRequestBody instance,
) => <String, dynamic>{
  'display_name': const LenientString().toJson(instance.displayName),
  'description': const LenientString().toJson(instance.description),
  'company_name': const LenientString().toJson(instance.companyName),
  'invite_id': const LenientString().toJson(instance.inviteId),
  'allow_open_invite': const LenientBool().toJson(instance.allowOpenInvite),
};
