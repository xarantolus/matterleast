// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_ephemeral_mode_wipe_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4EphemeralModeWipeRequestBody _$ApiV4EphemeralModeWipeRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4EphemeralModeWipeRequestBody(
  signature: json['signature'] as String,
  wipeAt: const MillisDateTime().fromJson(json['wipe_at']),
  errorReason: const LenientString().fromJson(json['error_reason']),
);

Map<String, dynamic> _$ApiV4EphemeralModeWipeRequestBodyToJson(
  ApiV4EphemeralModeWipeRequestBody instance,
) => <String, dynamic>{
  'signature': instance.signature,
  'wipe_at': const MillisDateTime().toJson(instance.wipeAt),
  'error_reason': const LenientString().toJson(instance.errorReason),
};
