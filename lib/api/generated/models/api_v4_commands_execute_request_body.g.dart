// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_commands_execute_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4CommandsExecuteRequestBody _$ApiV4CommandsExecuteRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4CommandsExecuteRequestBody(
  channelId: json['channel_id'] as String,
  command: json['command'] as String,
  teamId: const LenientString().fromJson(json['team_id']),
  rootId: const LenientString().fromJson(json['root_id']),
  parentId: const LenientString().fromJson(json['parent_id']),
);

Map<String, dynamic> _$ApiV4CommandsExecuteRequestBodyToJson(
  ApiV4CommandsExecuteRequestBody instance,
) => <String, dynamic>{
  'channel_id': instance.channelId,
  'command': instance.command,
  'team_id': const LenientString().toJson(instance.teamId),
  'root_id': const LenientString().toJson(instance.rootId),
  'parent_id': const LenientString().toJson(instance.parentId),
};
