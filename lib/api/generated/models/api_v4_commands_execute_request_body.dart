// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'api_v4_commands_execute_request_body.g.dart';

@JsonSerializable()
class ApiV4CommandsExecuteRequestBody {
  const ApiV4CommandsExecuteRequestBody({
    required this.channelId,
    required this.command,
  });

  factory ApiV4CommandsExecuteRequestBody.fromJson(Map<String, Object?> json) =>
      _$ApiV4CommandsExecuteRequestBodyFromJson(json);

  @JsonKey(name: 'channel_id')
  final String channelId;

  final String command;

  Map<String, Object?> toJson() =>
      _$ApiV4CommandsExecuteRequestBodyToJson(this);
}
