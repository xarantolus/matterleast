// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'get_api_v4_content_flagging_team_team_id_status_response.g.dart';

@JsonSerializable()
class GetApiV4ContentFlaggingTeamTeamIdStatusResponse {
  const GetApiV4ContentFlaggingTeamTeamIdStatusResponse({this.enabled});

  factory GetApiV4ContentFlaggingTeamTeamIdStatusResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV4ContentFlaggingTeamTeamIdStatusResponseFromJson(json);

  @LenientBool()
  final bool? enabled;

  Map<String, Object?> toJson() =>
      _$GetApiV4ContentFlaggingTeamTeamIdStatusResponseToJson(this);
}
