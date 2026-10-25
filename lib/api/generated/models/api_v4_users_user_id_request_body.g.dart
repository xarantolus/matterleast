// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_users_user_id_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4UsersUserIdRequestBody _$ApiV4UsersUserIdRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4UsersUserIdRequestBody(
  id: json['id'] as String,
  email: json['email'] as String,
  username: json['username'] as String,
  firstName: const LenientString().fromJson(json['first_name']),
  lastName: const LenientString().fromJson(json['last_name']),
  nickname: const LenientString().fromJson(json['nickname']),
  locale: const LenientString().fromJson(json['locale']),
  position: const LenientString().fromJson(json['position']),
  timezone: const LenientTimezone().fromJson(json['timezone']),
  props: const JsonMap().fromJson(json['props']),
  notifyProps: const LenientUserNotifyProps().fromJson(json['notify_props']),
);

Map<String, dynamic> _$ApiV4UsersUserIdRequestBodyToJson(
  ApiV4UsersUserIdRequestBody instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'username': instance.username,
  'first_name': const LenientString().toJson(instance.firstName),
  'last_name': const LenientString().toJson(instance.lastName),
  'nickname': const LenientString().toJson(instance.nickname),
  'locale': const LenientString().toJson(instance.locale),
  'position': const LenientString().toJson(instance.position),
  'timezone': const LenientTimezone().toJson(instance.timezone),
  'props': const JsonMap().toJson(instance.props),
  'notify_props': const LenientUserNotifyProps().toJson(instance.notifyProps),
};
