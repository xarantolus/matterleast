// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_content_flagging_post_post_id_flag_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4ContentFlaggingPostPostIdFlagRequestBody
_$ApiV4ContentFlaggingPostPostIdFlagRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4ContentFlaggingPostPostIdFlagRequestBody(
  reason: const LenientString().fromJson(json['reason']),
  comment: const LenientString().fromJson(json['comment']),
);

Map<String, dynamic> _$ApiV4ContentFlaggingPostPostIdFlagRequestBodyToJson(
  ApiV4ContentFlaggingPostPostIdFlagRequestBody instance,
) => <String, dynamic>{
  'reason': const LenientString().toJson(instance.reason),
  'comment': const LenientString().toJson(instance.comment),
};
