// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_teams_team_id_patch_request_body.g.dart';

@JsonSerializable()
class ApiV4TeamsTeamIdPatchRequestBody {
  const ApiV4TeamsTeamIdPatchRequestBody({
    this.displayName,
    this.description,
    this.companyName,
    this.inviteId,
    this.allowOpenInvite,
  });

  factory ApiV4TeamsTeamIdPatchRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4TeamsTeamIdPatchRequestBodyFromJson(json);

  @LenientString()
  @JsonKey(name: 'display_name')
  final String? displayName;
  @LenientString()
  final String? description;
  @LenientString()
  @JsonKey(name: 'company_name')
  final String? companyName;
  @LenientString()
  @JsonKey(name: 'invite_id')
  final String? inviteId;
  @LenientBool()
  @JsonKey(name: 'allow_open_invite')
  final bool? allowOpenInvite;

  Map<String, Object?> toJson() =>
      _$ApiV4TeamsTeamIdPatchRequestBodyToJson(this);
}
