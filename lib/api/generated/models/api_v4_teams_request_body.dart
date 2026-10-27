// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'api_v4_teams_request_body.g.dart';

@JsonSerializable()
class ApiV4TeamsRequestBody {
  const ApiV4TeamsRequestBody({
    required this.name,
    required this.displayName,
    required this.type,
  });

  factory ApiV4TeamsRequestBody.fromJson(Map<String, Object?> json) =>
      _$ApiV4TeamsRequestBodyFromJson(json);

  final String name;
  @JsonKey(name: 'display_name')
  final String displayName;
  final String type;

  Map<String, Object?> toJson() => _$ApiV4TeamsRequestBodyToJson(this);
}
