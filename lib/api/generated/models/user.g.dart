// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: const LenientString().fromJson(json['id']),
  createAt: const MillisDateTime().fromJson(json['create_at']),
  updateAt: const MillisDateTime().fromJson(json['update_at']),
  deleteAt: const MillisDateTime().fromJson(json['delete_at']),
  username: const LenientString().fromJson(json['username']),
  firstName: const LenientString().fromJson(json['first_name']),
  lastName: const LenientString().fromJson(json['last_name']),
  nickname: const LenientString().fromJson(json['nickname']),
  email: const LenientString().fromJson(json['email']),
  emailVerified: const LenientBool().fromJson(json['email_verified']),
  authService: const LenientString().fromJson(json['auth_service']),
  roles: const LenientString().fromJson(json['roles']),
  locale: const LenientString().fromJson(json['locale']),
  notifyProps: const LenientUserNotifyProps().fromJson(json['notify_props']),
  props: const JsonMap().fromJson(json['props']),
  lastPasswordUpdate: const MillisDateTime().fromJson(
    json['last_password_update'],
  ),
  lastPictureUpdate: const MillisDateTime().fromJson(
    json['last_picture_update'],
  ),
  failedAttempts: const LenientInt().fromJson(json['failed_attempts']),
  mfaActive: const LenientBool().fromJson(json['mfa_active']),
  timezone: const LenientTimezone().fromJson(json['timezone']),
  termsOfServiceId: const LenientString().fromJson(json['terms_of_service_id']),
  termsOfServiceCreateAt: const MillisDateTime().fromJson(
    json['terms_of_service_create_at'],
  ),
  isBot: const LenientBool().fromJson(json['is_bot']),
  botDescription: const LenientString().fromJson(json['bot_description']),
  botLastIconUpdate: const MillisDateTime().fromJson(
    json['bot_last_icon_update'],
  ),
  lastActivityAt: const MillisDateTime().fromJson(json['last_activity_at']),
  position: const LenientString().fromJson(json['position']),
  remoteId: const LenientString().fromJson(json['remote_id']),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': const LenientString().toJson(instance.id),
  'create_at': const MillisDateTime().toJson(instance.createAt),
  'update_at': const MillisDateTime().toJson(instance.updateAt),
  'delete_at': const MillisDateTime().toJson(instance.deleteAt),
  'username': const LenientString().toJson(instance.username),
  'first_name': const LenientString().toJson(instance.firstName),
  'last_name': const LenientString().toJson(instance.lastName),
  'nickname': const LenientString().toJson(instance.nickname),
  'email': const LenientString().toJson(instance.email),
  'email_verified': const LenientBool().toJson(instance.emailVerified),
  'auth_service': const LenientString().toJson(instance.authService),
  'roles': const LenientString().toJson(instance.roles),
  'locale': const LenientString().toJson(instance.locale),
  'notify_props': const LenientUserNotifyProps().toJson(instance.notifyProps),
  'props': const JsonMap().toJson(instance.props),
  'last_password_update': const MillisDateTime().toJson(
    instance.lastPasswordUpdate,
  ),
  'last_picture_update': const MillisDateTime().toJson(
    instance.lastPictureUpdate,
  ),
  'failed_attempts': const LenientInt().toJson(instance.failedAttempts),
  'mfa_active': const LenientBool().toJson(instance.mfaActive),
  'timezone': const LenientTimezone().toJson(instance.timezone),
  'terms_of_service_id': const LenientString().toJson(
    instance.termsOfServiceId,
  ),
  'terms_of_service_create_at': const MillisDateTime().toJson(
    instance.termsOfServiceCreateAt,
  ),
  'is_bot': const LenientBool().toJson(instance.isBot),
  'bot_description': const LenientString().toJson(instance.botDescription),
  'bot_last_icon_update': const MillisDateTime().toJson(
    instance.botLastIconUpdate,
  ),
  'last_activity_at': const MillisDateTime().toJson(instance.lastActivityAt),
  'position': const LenientString().toJson(instance.position),
  'remote_id': const LenientString().toJson(instance.remoteId),
};
