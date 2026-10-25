// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_users_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4UsersRequestBody _$ApiV4UsersRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4UsersRequestBody(
  email: json['email'] as String,
  username: json['username'] as String,
  firstName: const LenientString().fromJson(json['first_name']),
  lastName: const LenientString().fromJson(json['last_name']),
  nickname: const LenientString().fromJson(json['nickname']),
  position: const LenientString().fromJson(json['position']),
  timezone: const LenientTimezone().fromJson(json['timezone']),
  authData: const LenientString().fromJson(json['auth_data']),
  authService: const LenientString().fromJson(json['auth_service']),
  password: const LenientString().fromJson(json['password']),
  locale: const LenientString().fromJson(json['locale']),
  props: const JsonMap().fromJson(json['props']),
  notifyProps: const LenientUserNotifyProps().fromJson(json['notify_props']),
);

Map<String, dynamic> _$ApiV4UsersRequestBodyToJson(
  ApiV4UsersRequestBody instance,
) => <String, dynamic>{
  'email': instance.email,
  'username': instance.username,
  'first_name': const LenientString().toJson(instance.firstName),
  'last_name': const LenientString().toJson(instance.lastName),
  'nickname': const LenientString().toJson(instance.nickname),
  'position': const LenientString().toJson(instance.position),
  'timezone': const LenientTimezone().toJson(instance.timezone),
  'auth_data': const LenientString().toJson(instance.authData),
  'auth_service': const LenientString().toJson(instance.authService),
  'password': const LenientString().toJson(instance.password),
  'locale': const LenientString().toJson(instance.locale),
  'props': const JsonMap().toJson(instance.props),
  'notify_props': const LenientUserNotifyProps().toJson(instance.notifyProps),
};
