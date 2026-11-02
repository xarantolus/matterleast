// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v4_content_flagging_flag_config_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV4ContentFlaggingFlagConfigResponse
_$GetApiV4ContentFlaggingFlagConfigResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV4ContentFlaggingFlagConfigResponse(
  reporterCommentRequired: const LenientBool().fromJson(
    json['reporter_comment_required'],
  ),
  reasons: json['reasons'] == null
      ? const []
      : const LenientStringList().fromJson(json['reasons']),
);

Map<String, dynamic> _$GetApiV4ContentFlaggingFlagConfigResponseToJson(
  GetApiV4ContentFlaggingFlagConfigResponse instance,
) => <String, dynamic>{
  'reasons': const LenientStringList().toJson(instance.reasons),
  'reporter_comment_required': const LenientBool().toJson(
    instance.reporterCommentRequired,
  ),
};
