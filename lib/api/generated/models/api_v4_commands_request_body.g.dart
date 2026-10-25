// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_commands_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4CommandsRequestBody _$ApiV4CommandsRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4CommandsRequestBody(
  teamId: json['team_id'] as String,
  method: json['method'] as String,
  trigger: json['trigger'] as String,
  url: json['url'] as String,
);

Map<String, dynamic> _$ApiV4CommandsRequestBodyToJson(
  ApiV4CommandsRequestBody instance,
) => <String, dynamic>{
  'team_id': instance.teamId,
  'method': instance.method,
  'trigger': instance.trigger,
  'url': instance.url,
};
