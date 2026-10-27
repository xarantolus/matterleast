// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'api_v4_commands_request_body.g.dart';

@JsonSerializable()
class ApiV4CommandsRequestBody {
  const ApiV4CommandsRequestBody({
    required this.teamId,
    required this.method,
    required this.trigger,
    required this.url,
  });

  factory ApiV4CommandsRequestBody.fromJson(Map<String, Object?> json) =>
      _$ApiV4CommandsRequestBodyFromJson(json);

  @JsonKey(name: 'team_id')
  final String teamId;
  final String method;
  final String trigger;
  final String url;

  Map<String, Object?> toJson() => _$ApiV4CommandsRequestBodyToJson(this);
}
