// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_api_v4_users_user_id_teams_team_id_read_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PutApiV4UsersUserIdTeamsTeamIdReadResponse
_$PutApiV4UsersUserIdTeamsTeamIdReadResponseFromJson(
  Map<String, dynamic> json,
) => PutApiV4UsersUserIdTeamsTeamIdReadResponse(
  status: const LenientString().fromJson(json['status']),
  lastViewedAtTimes: (json['last_viewed_at_times'] as Map<String, dynamic>?)
      ?.map((k, e) => MapEntry(k, (e as num).toInt())),
);

Map<String, dynamic> _$PutApiV4UsersUserIdTeamsTeamIdReadResponseToJson(
  PutApiV4UsersUserIdTeamsTeamIdReadResponse instance,
) => <String, dynamic>{
  'status': const LenientString().toJson(instance.status),
  'last_viewed_at_times': instance.lastViewedAtTimes,
};
