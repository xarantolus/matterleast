// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'priority.g.dart';

@JsonSerializable()
class Priority {
  const Priority({this.priority, this.requestedAck});

  factory Priority.fromJson(Map<String, Object?> json) =>
      _$PriorityFromJson(json);

  @LenientString()
  final String? priority;

  @LenientBool()
  @JsonKey(name: 'requested_ack')
  final bool? requestedAck;

  Map<String, Object?> toJson() => _$PriorityToJson(this);
}
