// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_users_sessions_device_request_body.g.dart';

@JsonSerializable()
class ApiV4UsersSessionsDeviceRequestBody {
  const ApiV4UsersSessionsDeviceRequestBody({
    this.deviceId,
    this.voipDeviceId,
    this.deviceNotificationDisabled,
    this.mobileVersion,
  });

  factory ApiV4UsersSessionsDeviceRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4UsersSessionsDeviceRequestBodyFromJson(json);

  @LenientString()
  @JsonKey(name: 'device_id')
  final String? deviceId;
  @LenientString()
  @JsonKey(name: 'voip_device_id')
  final String? voipDeviceId;
  @LenientString()
  final String? deviceNotificationDisabled;
  @LenientString()
  final String? mobileVersion;

  Map<String, Object?> toJson() =>
      _$ApiV4UsersSessionsDeviceRequestBodyToJson(this);
}
