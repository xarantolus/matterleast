// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_users_sessions_device_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4UsersSessionsDeviceRequestBody
_$ApiV4UsersSessionsDeviceRequestBodyFromJson(Map<String, dynamic> json) =>
    ApiV4UsersSessionsDeviceRequestBody(
      deviceId: const LenientString().fromJson(json['device_id']),
      voipDeviceId: const LenientString().fromJson(json['voip_device_id']),
      deviceNotificationDisabled: const LenientString().fromJson(
        json['deviceNotificationDisabled'],
      ),
      mobileVersion: const LenientString().fromJson(json['mobileVersion']),
    );

Map<String, dynamic> _$ApiV4UsersSessionsDeviceRequestBodyToJson(
  ApiV4UsersSessionsDeviceRequestBody instance,
) => <String, dynamic>{
  'device_id': const LenientString().toJson(instance.deviceId),
  'voip_device_id': const LenientString().toJson(instance.voipDeviceId),
  'deviceNotificationDisabled': const LenientString().toJson(
    instance.deviceNotificationDisabled,
  ),
  'mobileVersion': const LenientString().toJson(instance.mobileVersion),
};
