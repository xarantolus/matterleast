// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Session _$SessionFromJson(Map<String, dynamic> json) => Session(
  teamMembers: json['team_members'] == null
      ? const []
      : const LenientListOfTeamMember().fromJson(json['team_members']),
  createAt: const MillisDateTime().fromJson(json['create_at']),
  deviceId: const LenientString().fromJson(json['device_id']),
  voipDeviceId: const LenientString().fromJson(json['voip_device_id']),
  expiresAt: const MillisDateTime().fromJson(json['expires_at']),
  id: const LenientString().fromJson(json['id']),
  isOauth: const LenientBool().fromJson(json['is_oauth']),
  lastActivityAt: const MillisDateTime().fromJson(json['last_activity_at']),
  props: const JsonMap().fromJson(json['props']),
  roles: const LenientString().fromJson(json['roles']),
  token: const LenientString().fromJson(json['token']),
  userId: const LenientString().fromJson(json['user_id']),
);

Map<String, dynamic> _$SessionToJson(Session instance) => <String, dynamic>{
  'create_at': const MillisDateTime().toJson(instance.createAt),
  'device_id': const LenientString().toJson(instance.deviceId),
  'voip_device_id': const LenientString().toJson(instance.voipDeviceId),
  'expires_at': const MillisDateTime().toJson(instance.expiresAt),
  'id': const LenientString().toJson(instance.id),
  'is_oauth': const LenientBool().toJson(instance.isOauth),
  'last_activity_at': const MillisDateTime().toJson(instance.lastActivityAt),
  'props': const JsonMap().toJson(instance.props),
  'roles': const LenientString().toJson(instance.roles),
  'team_members': const LenientListOfTeamMember().toJson(instance.teamMembers),
  'token': const LenientString().toJson(instance.token),
  'user_id': const LenientString().toJson(instance.userId),
};
