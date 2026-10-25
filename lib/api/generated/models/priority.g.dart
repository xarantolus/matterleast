// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'priority.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Priority _$PriorityFromJson(Map<String, dynamic> json) => Priority(
  priority: const LenientString().fromJson(json['priority']),
  requestedAck: const LenientBool().fromJson(json['requested_ack']),
);

Map<String, dynamic> _$PriorityToJson(Priority instance) => <String, dynamic>{
  'priority': const LenientString().toJson(instance.priority),
  'requested_ack': const LenientBool().toJson(instance.requestedAck),
};
