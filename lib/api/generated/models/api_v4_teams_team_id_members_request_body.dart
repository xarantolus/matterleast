// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_teams_team_id_members_request_body.g.dart';

@JsonSerializable()
class ApiV4TeamsTeamIdMembersRequestBody {
  const ApiV4TeamsTeamIdMembersRequestBody({this.teamId, this.userId});

  factory ApiV4TeamsTeamIdMembersRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4TeamsTeamIdMembersRequestBodyFromJson(json);

  @LenientString()
  @JsonKey(name: 'team_id')
  final String? teamId;
  @LenientString()
  @JsonKey(name: 'user_id')
  final String? userId;

  Map<String, Object?> toJson() =>
      _$ApiV4TeamsTeamIdMembersRequestBodyToJson(this);
}
