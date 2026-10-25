// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_users_login_type_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4UsersLoginTypeRequestBody _$ApiV4UsersLoginTypeRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4UsersLoginTypeRequestBody(
  id: const LenientString().fromJson(json['id']),
  loginId: const LenientString().fromJson(json['login_id']),
  deviceId: const LenientString().fromJson(json['device_id']),
);

Map<String, dynamic> _$ApiV4UsersLoginTypeRequestBodyToJson(
  ApiV4UsersLoginTypeRequestBody instance,
) => <String, dynamic>{
  'id': const LenientString().toJson(instance.id),
  'login_id': const LenientString().toJson(instance.loginId),
  'device_id': const LenientString().toJson(instance.deviceId),
};
