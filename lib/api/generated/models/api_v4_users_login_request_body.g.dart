// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_users_login_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4UsersLoginRequestBody _$ApiV4UsersLoginRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4UsersLoginRequestBody(
  id: const LenientString().fromJson(json['id']),
  loginId: const LenientString().fromJson(json['login_id']),
  token: const LenientString().fromJson(json['token']),
  deviceId: const LenientString().fromJson(json['device_id']),
  voipDeviceId: const LenientString().fromJson(json['voip_device_id']),
  ldapOnly: const LenientBool().fromJson(json['ldap_only']),
  password: const LenientString().fromJson(json['password']),
  magicLinkToken: const LenientString().fromJson(json['magic_link_token']),
);

Map<String, dynamic> _$ApiV4UsersLoginRequestBodyToJson(
  ApiV4UsersLoginRequestBody instance,
) => <String, dynamic>{
  'id': const LenientString().toJson(instance.id),
  'login_id': const LenientString().toJson(instance.loginId),
  'token': const LenientString().toJson(instance.token),
  'device_id': const LenientString().toJson(instance.deviceId),
  'voip_device_id': const LenientString().toJson(instance.voipDeviceId),
  'ldap_only': const LenientBool().toJson(instance.ldapOnly),
  'password': const LenientString().toJson(instance.password),
  'magic_link_token': const LenientString().toJson(instance.magicLinkToken),
};
