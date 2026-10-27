// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_users_login_request_body.g.dart';

@JsonSerializable()
class ApiV4UsersLoginRequestBody {
  const ApiV4UsersLoginRequestBody({
    this.id,
    this.loginId,
    this.token,
    this.deviceId,
    this.voipDeviceId,
    this.ldapOnly,
    this.password,
    this.magicLinkToken,
  });

  factory ApiV4UsersLoginRequestBody.fromJson(Map<String, Object?> json) =>
      _$ApiV4UsersLoginRequestBodyFromJson(json);

  @LenientString()
  final String? id;
  @LenientString()
  @JsonKey(name: 'login_id')
  final String? loginId;
  @LenientString()
  final String? token;
  @LenientString()
  @JsonKey(name: 'device_id')
  final String? deviceId;
  @LenientString()
  @JsonKey(name: 'voip_device_id')
  final String? voipDeviceId;
  @LenientBool()
  @JsonKey(name: 'ldap_only')
  final bool? ldapOnly;
  @LenientString()
  final String? password;
  @LenientString()
  @JsonKey(name: 'magic_link_token')
  final String? magicLinkToken;

  Map<String, Object?> toJson() => _$ApiV4UsersLoginRequestBodyToJson(this);
}
