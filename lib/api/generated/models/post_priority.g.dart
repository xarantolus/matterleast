// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_priority.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostPriority _$PostPriorityFromJson(Map<String, dynamic> json) => PostPriority(
  priority: json['priority'] == null
      ? null
      : PostPriorityPriority.fromJson(json['priority'] as String),
  requestedAck: const LenientBool().fromJson(json['requested_ack']),
  persistentNotifications: const LenientBool().fromJson(
    json['persistent_notifications'],
  ),
);

Map<String, dynamic> _$PostPriorityToJson(PostPriority instance) =>
    <String, dynamic>{
      'priority': instance.priority,
      'requested_ack': const LenientBool().toJson(instance.requestedAck),
      'persistent_notifications': const LenientBool().toJson(
        instance.persistentNotifications,
      ),
    };
