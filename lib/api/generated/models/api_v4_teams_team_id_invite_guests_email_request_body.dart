// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_teams_team_id_invite_guests_email_request_body.g.dart';

@JsonSerializable()
class ApiV4TeamsTeamIdInviteGuestsEmailRequestBody {
  const ApiV4TeamsTeamIdInviteGuestsEmailRequestBody({
    this.message,
    this.emails = const [],
    this.channels = const [],
  });

  factory ApiV4TeamsTeamIdInviteGuestsEmailRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4TeamsTeamIdInviteGuestsEmailRequestBodyFromJson(json);

  @LenientStringList()
  final List<String> emails;
  @LenientStringList()
  final List<String> channels;
  @LenientString()
  final String? message;

  Map<String, Object?> toJson() =>
      _$ApiV4TeamsTeamIdInviteGuestsEmailRequestBodyToJson(this);
}
