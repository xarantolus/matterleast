// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_commands_execute_request_body.g.dart';

@JsonSerializable()
class ApiV4CommandsExecuteRequestBody {
  const ApiV4CommandsExecuteRequestBody({
    required this.channelId,
    required this.command,
    this.teamId,
    this.rootId,
    this.parentId,
  });

  factory ApiV4CommandsExecuteRequestBody.fromJson(Map<String, Object?> json) =>
      _$ApiV4CommandsExecuteRequestBodyFromJson(json);

  @JsonKey(name: 'channel_id')
  final String channelId;
  final String command;
  @LenientString()
  @JsonKey(name: 'team_id')
  final String? teamId;
  @LenientString()
  @JsonKey(name: 'root_id')
  final String? rootId;
  @LenientString()
  @JsonKey(name: 'parent_id')
  final String? parentId;

  Map<String, Object?> toJson() =>
      _$ApiV4CommandsExecuteRequestBodyToJson(this);
}
