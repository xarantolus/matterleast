// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_posts_schedule_scheduled_post_id_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4PostsScheduleScheduledPostIdRequestBody
_$ApiV4PostsScheduleScheduledPostIdRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4PostsScheduleScheduledPostIdRequestBody(
  id: json['id'] as String,
  channelId: json['channel_id'] as String,
  userId: json['user_id'] as String,
  scheduledAt: DateTime.parse(json['scheduled_at'] as String),
  message: json['message'] as String,
  repeatType: const LenientString().fromJson(json['repeat_type']),
  repeatTimezone: const LenientString().fromJson(json['repeat_timezone']),
);

Map<String, dynamic> _$ApiV4PostsScheduleScheduledPostIdRequestBodyToJson(
  ApiV4PostsScheduleScheduledPostIdRequestBody instance,
) => <String, dynamic>{
  'id': instance.id,
  'channel_id': instance.channelId,
  'user_id': instance.userId,
  'scheduled_at': instance.scheduledAt.toIso8601String(),
  'message': instance.message,
  'repeat_type': const LenientString().toJson(instance.repeatType),
  'repeat_timezone': const LenientString().toJson(instance.repeatTimezone),
};
