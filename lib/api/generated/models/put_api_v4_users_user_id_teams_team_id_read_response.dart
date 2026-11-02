// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'put_api_v4_users_user_id_teams_team_id_read_response.g.dart';

@JsonSerializable()
class PutApiV4UsersUserIdTeamsTeamIdReadResponse {
  const PutApiV4UsersUserIdTeamsTeamIdReadResponse({
    this.status,
    this.lastViewedAtTimes,
  });

  factory PutApiV4UsersUserIdTeamsTeamIdReadResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PutApiV4UsersUserIdTeamsTeamIdReadResponseFromJson(json);

  @LenientString()
  final String? status;
  @JsonKey(name: 'last_viewed_at_times')
  final Map<String, int>? lastViewedAtTimes;

  Map<String, Object?> toJson() =>
      _$PutApiV4UsersUserIdTeamsTeamIdReadResponseToJson(this);
}
