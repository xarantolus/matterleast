// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_users_user_id_patch_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4UsersUserIdPatchRequestBody _$ApiV4UsersUserIdPatchRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4UsersUserIdPatchRequestBody(
  email: const LenientString().fromJson(json['email']),
  username: const LenientString().fromJson(json['username']),
  firstName: const LenientString().fromJson(json['first_name']),
  lastName: const LenientString().fromJson(json['last_name']),
  nickname: const LenientString().fromJson(json['nickname']),
  locale: const LenientString().fromJson(json['locale']),
  position: const LenientString().fromJson(json['position']),
  timezone: const LenientTimezone().fromJson(json['timezone']),
  props: const JsonMap().fromJson(json['props']),
  notifyProps: const LenientUserNotifyProps().fromJson(json['notify_props']),
);

Map<String, dynamic> _$ApiV4UsersUserIdPatchRequestBodyToJson(
  ApiV4UsersUserIdPatchRequestBody instance,
) => <String, dynamic>{
  'email': const LenientString().toJson(instance.email),
  'username': const LenientString().toJson(instance.username),
  'first_name': const LenientString().toJson(instance.firstName),
  'last_name': const LenientString().toJson(instance.lastName),
  'nickname': const LenientString().toJson(instance.nickname),
  'locale': const LenientString().toJson(instance.locale),
  'position': const LenientString().toJson(instance.position),
  'timezone': const LenientTimezone().toJson(instance.timezone),
  'props': const JsonMap().toJson(instance.props),
  'notify_props': const LenientUserNotifyProps().toJson(instance.notifyProps),
};
