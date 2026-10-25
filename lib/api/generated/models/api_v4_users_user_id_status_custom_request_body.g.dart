// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_users_user_id_status_custom_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4UsersUserIdStatusCustomRequestBody
_$ApiV4UsersUserIdStatusCustomRequestBodyFromJson(Map<String, dynamic> json) =>
    ApiV4UsersUserIdStatusCustomRequestBody(
      emoji: json['emoji'] as String,
      text: json['text'] as String,
      duration: const LenientString().fromJson(json['duration']),
      expiresAt: const LenientString().fromJson(json['expires_at']),
    );

Map<String, dynamic> _$ApiV4UsersUserIdStatusCustomRequestBodyToJson(
  ApiV4UsersUserIdStatusCustomRequestBody instance,
) => <String, dynamic>{
  'emoji': instance.emoji,
  'text': instance.text,
  'duration': const LenientString().toJson(instance.duration),
  'expires_at': const LenientString().toJson(instance.expiresAt),
};
