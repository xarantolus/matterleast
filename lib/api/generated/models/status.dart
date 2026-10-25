// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'status.g.dart';

@JsonSerializable()
class Status {
  const Status({
    this.userId,
    this.status,
    this.manual,
    this.lastActivityAt,
    this.dndEndTime,
    this.activeChannel,
  });

  factory Status.fromJson(Map<String, Object?> json) => _$StatusFromJson(json);

  @LenientString()
  @JsonKey(name: 'user_id')
  final String? userId;
  @LenientString()
  final String? status;
  @LenientBool()
  final bool? manual;
  @MillisDateTime()
  @JsonKey(name: 'last_activity_at')
  final DateTime? lastActivityAt;

  @LenientInt()
  @JsonKey(name: 'dnd_end_time')
  final int? dndEndTime;
  @LenientString()
  @JsonKey(name: 'active_channel')
  final String? activeChannel;

  Map<String, Object?> toJson() => _$StatusToJson(this);
}
