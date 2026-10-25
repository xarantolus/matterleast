// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_users_user_id_status_custom_recent_delete_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4UsersUserIdStatusCustomRecentDeleteRequestBody
_$ApiV4UsersUserIdStatusCustomRecentDeleteRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4UsersUserIdStatusCustomRecentDeleteRequestBody(
  emoji: json['emoji'] as String,
  text: json['text'] as String,
  duration: json['duration'] as String,
  expiresAt: json['expires_at'] as String,
);

Map<String, dynamic>
_$ApiV4UsersUserIdStatusCustomRecentDeleteRequestBodyToJson(
  ApiV4UsersUserIdStatusCustomRecentDeleteRequestBody instance,
) => <String, dynamic>{
  'emoji': instance.emoji,
  'text': instance.text,
  'duration': instance.duration,
  'expires_at': instance.expiresAt,
};
