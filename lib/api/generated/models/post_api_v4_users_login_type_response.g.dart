// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v4_users_login_type_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV4UsersLoginTypeResponse _$PostApiV4UsersLoginTypeResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV4UsersLoginTypeResponse(
  authService: const LenientString().fromJson(json['auth_service']),
);

Map<String, dynamic> _$PostApiV4UsersLoginTypeResponseToJson(
  PostApiV4UsersLoginTypeResponse instance,
) => <String, dynamic>{
  'auth_service': const LenientString().toJson(instance.authService),
};
