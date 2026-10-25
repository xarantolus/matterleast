// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_ephemeral_mode_purge_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4EphemeralModePurgeRequestBody _$ApiV4EphemeralModePurgeRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4EphemeralModePurgeRequestBody(
  offlineTimeMinutes: const LenientInt().fromJson(json['offline_time_minutes']),
  purgeAt: const MillisDateTime().fromJson(json['purge_at']),
  errorReason: const LenientString().fromJson(json['error_reason']),
);

Map<String, dynamic> _$ApiV4EphemeralModePurgeRequestBodyToJson(
  ApiV4EphemeralModePurgeRequestBody instance,
) => <String, dynamic>{
  'offline_time_minutes': const LenientInt().toJson(
    instance.offlineTimeMinutes,
  ),
  'purge_at': const MillisDateTime().toJson(instance.purgeAt),
  'error_reason': const LenientString().toJson(instance.errorReason),
};
