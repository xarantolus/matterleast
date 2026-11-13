// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_actions_dialogs_execute_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4ActionsDialogsExecuteRequestBody
_$ApiV4ActionsDialogsExecuteRequestBodyFromJson(Map<String, dynamic> json) =>
    ApiV4ActionsDialogsExecuteRequestBody(
      url: json['url'] as String,
      channelId: json['channel_id'] as String,
      context: const JsonMap().fromJson(json['context']),
      teamId: const LenientString().fromJson(json['team_id']),
    );

Map<String, dynamic> _$ApiV4ActionsDialogsExecuteRequestBodyToJson(
  ApiV4ActionsDialogsExecuteRequestBody instance,
) => <String, dynamic>{
  'url': instance.url,
  'context': const JsonMap().toJson(instance.context),
  'channel_id': instance.channelId,
  'team_id': const LenientString().toJson(instance.teamId),
};
