// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Status _$StatusFromJson(Map<String, dynamic> json) => Status(
  userId: const LenientString().fromJson(json['user_id']),
  status: const LenientString().fromJson(json['status']),
  manual: const LenientBool().fromJson(json['manual']),
  lastActivityAt: const MillisDateTime().fromJson(json['last_activity_at']),
  dndEndTime: const MillisDateTime().fromJson(json['dnd_end_time']),
  activeChannel: const LenientString().fromJson(json['active_channel']),
);

Map<String, dynamic> _$StatusToJson(Status instance) => <String, dynamic>{
  'user_id': const LenientString().toJson(instance.userId),
  'status': const LenientString().toJson(instance.status),
  'manual': const LenientBool().toJson(instance.manual),
  'last_activity_at': const MillisDateTime().toJson(instance.lastActivityAt),
  'dnd_end_time': const MillisDateTime().toJson(instance.dndEndTime),
  'active_channel': const LenientString().toJson(instance.activeChannel),
};
