// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'post_metadata.dart';

import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/json/lenient_models.dart';
part 'scheduled_post.g.dart';

@JsonSerializable()
class ScheduledPost {
  const ScheduledPost({
    this.fileIds = const [],
    this.id,
    this.createAt,
    this.updateAt,
    this.userId,
    this.channelId,
    this.rootId,
    this.message,
    this.props,
    this.scheduledAt,
    this.processedAt,
    this.errorCode,
    this.repeatType,
    this.repeatTimezone,
    this.metadata,
  });

  factory ScheduledPost.fromJson(Map<String, Object?> json) =>
      _$ScheduledPostFromJson(json);

  @LenientString()
  final String? id;
  @MillisDateTime()
  @JsonKey(name: 'create_at')
  final DateTime? createAt;
  @MillisDateTime()
  @JsonKey(name: 'update_at')
  final DateTime? updateAt;
  @LenientString()
  @JsonKey(name: 'user_id')
  final String? userId;
  @LenientString()
  @JsonKey(name: 'channel_id')
  final String? channelId;
  @LenientString()
  @JsonKey(name: 'root_id')
  final String? rootId;
  @LenientString()
  final String? message;
  @JsonMap()
  final Map<String, Object?>? props;
  @LenientStringList()
  @JsonKey(name: 'file_ids')
  final List<String> fileIds;
  @MillisDateTime()
  @JsonKey(name: 'scheduled_at')
  final DateTime? scheduledAt;
  @MillisDateTime()
  @JsonKey(name: 'processed_at')
  final DateTime? processedAt;
  @LenientString()
  @JsonKey(name: 'error_code')
  final String? errorCode;
  @LenientString()
  @JsonKey(name: 'repeat_type')
  final String? repeatType;
  @LenientString()
  @JsonKey(name: 'repeat_timezone')
  final String? repeatTimezone;
  @LenientPostMetadata()
  final PostMetadata? metadata;

  Map<String, Object?> toJson() => _$ScheduledPostToJson(this);
}
