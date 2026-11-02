// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'get_api_v4_teams_invite_invite_id_response.g.dart';

@JsonSerializable()
class GetApiV4TeamsInviteInviteIdResponse {
  const GetApiV4TeamsInviteInviteIdResponse({
    this.id,
    this.name,
    this.displayName,
    this.description,
  });

  factory GetApiV4TeamsInviteInviteIdResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV4TeamsInviteInviteIdResponseFromJson(json);

  @LenientString()
  final String? id;
  @LenientString()
  final String? name;
  @LenientString()
  @JsonKey(name: 'display_name')
  final String? displayName;
  @LenientString()
  final String? description;

  Map<String, Object?> toJson() =>
      _$GetApiV4TeamsInviteInviteIdResponseToJson(this);
}
