// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'api_v4_teams_team_id_request_body.g.dart';

@JsonSerializable()
class ApiV4TeamsTeamIdRequestBody {
  const ApiV4TeamsTeamIdRequestBody({
    required this.id,
    required this.displayName,
    required this.description,
    required this.companyName,
    required this.allowedDomains,
    required this.inviteId,
    required this.allowOpenInvite,
  });

  factory ApiV4TeamsTeamIdRequestBody.fromJson(Map<String, Object?> json) =>
      _$ApiV4TeamsTeamIdRequestBodyFromJson(json);

  final String id;
  @JsonKey(name: 'display_name')
  final String displayName;
  final String description;
  @JsonKey(name: 'company_name')
  final String companyName;
  @JsonKey(name: 'allowed_domains')
  final String allowedDomains;
  @JsonKey(name: 'invite_id')
  final String inviteId;
  @JsonKey(name: 'allow_open_invite')
  final String allowOpenInvite;

  Map<String, Object?> toJson() => _$ApiV4TeamsTeamIdRequestBodyToJson(this);
}
