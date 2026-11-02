// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_users_user_id_mfa_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4UsersUserIdMfaRequestBody _$ApiV4UsersUserIdMfaRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4UsersUserIdMfaRequestBody(
  activate: json['activate'] as bool,
  code: const LenientString().fromJson(json['code']),
);

Map<String, dynamic> _$ApiV4UsersUserIdMfaRequestBodyToJson(
  ApiV4UsersUserIdMfaRequestBody instance,
) => <String, dynamic>{
  'activate': instance.activate,
  'code': const LenientString().toJson(instance.code),
};
