// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_actions_dialogs_submit_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4ActionsDialogsSubmitRequestBody
_$ApiV4ActionsDialogsSubmitRequestBodyFromJson(Map<String, dynamic> json) =>
    ApiV4ActionsDialogsSubmitRequestBody(
      url: json['url'] as String,
      channelId: json['channel_id'] as String,
      submission: const JsonMapOrEmpty().fromJson(json['submission']),
      fileIds: json['file_ids'] == null
          ? const []
          : const LenientStringList().fromJson(json['file_ids']),
      teamId: const LenientString().fromJson(json['team_id']),
      callbackId: const LenientString().fromJson(json['callback_id']),
      state: const LenientString().fromJson(json['state']),
      cancelled: const LenientBool().fromJson(json['cancelled']),
    );

Map<String, dynamic> _$ApiV4ActionsDialogsSubmitRequestBodyToJson(
  ApiV4ActionsDialogsSubmitRequestBody instance,
) => <String, dynamic>{
  'url': instance.url,
  'channel_id': instance.channelId,
  'team_id': const LenientString().toJson(instance.teamId),
  'submission': const JsonMapOrEmpty().toJson(instance.submission),
  'callback_id': const LenientString().toJson(instance.callbackId),
  'state': const LenientString().toJson(instance.state),
  'cancelled': const LenientBool().toJson(instance.cancelled),
  'file_ids': const LenientStringList().toJson(instance.fileIds),
};
