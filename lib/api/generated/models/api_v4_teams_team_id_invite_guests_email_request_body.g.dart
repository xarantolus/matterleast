// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_teams_team_id_invite_guests_email_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4TeamsTeamIdInviteGuestsEmailRequestBody
_$ApiV4TeamsTeamIdInviteGuestsEmailRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4TeamsTeamIdInviteGuestsEmailRequestBody(
  message: const LenientString().fromJson(json['message']),
  emails: json['emails'] == null
      ? const []
      : const LenientStringList().fromJson(json['emails']),
  channels: json['channels'] == null
      ? const []
      : const LenientStringList().fromJson(json['channels']),
);

Map<String, dynamic> _$ApiV4TeamsTeamIdInviteGuestsEmailRequestBodyToJson(
  ApiV4TeamsTeamIdInviteGuestsEmailRequestBody instance,
) => <String, dynamic>{
  'emails': const LenientStringList().toJson(instance.emails),
  'channels': const LenientStringList().toJson(instance.channels),
  'message': const LenientString().toJson(instance.message),
};
