// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_users_user_id_password_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4UsersUserIdPasswordRequestBody
_$ApiV4UsersUserIdPasswordRequestBodyFromJson(Map<String, dynamic> json) =>
    ApiV4UsersUserIdPasswordRequestBody(
      newPassword: json['new_password'] as String,
      currentPassword: const LenientString().fromJson(json['current_password']),
    );

Map<String, dynamic> _$ApiV4UsersUserIdPasswordRequestBodyToJson(
  ApiV4UsersUserIdPasswordRequestBody instance,
) => <String, dynamic>{
  'current_password': const LenientString().toJson(instance.currentPassword),
  'new_password': instance.newPassword,
};
