// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_actions_dialogs_lookup_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4ActionsDialogsLookupRequestBody
_$ApiV4ActionsDialogsLookupRequestBodyFromJson(Map<String, dynamic> json) =>
    ApiV4ActionsDialogsLookupRequestBody(
      url: json['url'] as String,
      channelId: json['channel_id'] as String,
      submission: const JsonMapOrEmpty().fromJson(json['submission']),
      teamId: const LenientString().fromJson(json['team_id']),
      callbackId: const LenientString().fromJson(json['callback_id']),
      state: const LenientString().fromJson(json['state']),
    );

Map<String, dynamic> _$ApiV4ActionsDialogsLookupRequestBodyToJson(
  ApiV4ActionsDialogsLookupRequestBody instance,
) => <String, dynamic>{
  'url': instance.url,
  'channel_id': instance.channelId,
  'team_id': const LenientString().toJson(instance.teamId),
  'submission': const JsonMapOrEmpty().toJson(instance.submission),
  'callback_id': const LenientString().toJson(instance.callbackId),
  'state': const LenientString().toJson(instance.state),
};
