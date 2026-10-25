// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_posts_schedule_scheduled_post_id_request_body.g.dart';

@JsonSerializable()
class ApiV4PostsScheduleScheduledPostIdRequestBody {
  const ApiV4PostsScheduleScheduledPostIdRequestBody({
    required this.id,
    required this.channelId,
    required this.userId,
    required this.scheduledAt,
    required this.message,
    this.repeatType,
    this.repeatTimezone,
  });

  factory ApiV4PostsScheduleScheduledPostIdRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4PostsScheduleScheduledPostIdRequestBodyFromJson(json);

  final String id;

  @JsonKey(name: 'channel_id')
  final String channelId;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'scheduled_at')
  final DateTime scheduledAt;

  final String message;

  @LenientString()
  @JsonKey(name: 'repeat_type')
  final String? repeatType;

  @LenientString()
  @JsonKey(name: 'repeat_timezone')
  final String? repeatTimezone;

  Map<String, Object?> toJson() =>
      _$ApiV4PostsScheduleScheduledPostIdRequestBodyToJson(this);
}
