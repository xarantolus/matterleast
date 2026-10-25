// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_remotecluster_request_body.g.dart';

@JsonSerializable()
class ApiV4RemoteclusterRequestBody {
  const ApiV4RemoteclusterRequestBody({
    required this.name,
    required this.defaultTeamId,
    this.displayName,
    this.password,
  });

  factory ApiV4RemoteclusterRequestBody.fromJson(Map<String, Object?> json) =>
      _$ApiV4RemoteclusterRequestBodyFromJson(json);

  final String name;
  @LenientString()
  @JsonKey(name: 'display_name')
  final String? displayName;
  @JsonKey(name: 'default_team_id')
  final String defaultTeamId;

  @LenientString()
  final String? password;

  Map<String, Object?> toJson() => _$ApiV4RemoteclusterRequestBodyToJson(this);
}
