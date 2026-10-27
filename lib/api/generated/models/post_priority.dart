// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'post_priority_priority.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'post_priority.g.dart';

@JsonSerializable()
class PostPriority {
  const PostPriority({
    this.priority,
    this.requestedAck,
    this.persistentNotifications,
  });

  factory PostPriority.fromJson(Map<String, Object?> json) =>
      _$PostPriorityFromJson(json);

  final PostPriorityPriority? priority;
  @LenientBool()
  @JsonKey(name: 'requested_ack')
  final bool? requestedAck;
  @LenientBool()
  @JsonKey(name: 'persistent_notifications')
  final bool? persistentNotifications;

  Map<String, Object?> toJson() => _$PostPriorityToJson(this);
}
