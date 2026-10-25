// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CustomStatus _$CustomStatusFromJson(Map<String, dynamic> json) =>
    _CustomStatus(
      emoji: json['emoji'] as String? ?? '',
      text: json['text'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      expiresAt: _date(json['expires_at']),
    );

Map<String, dynamic> _$CustomStatusToJson(_CustomStatus instance) =>
    <String, dynamic>{
      'emoji': instance.emoji,
      'text': instance.text,
      'duration': instance.duration,
      'expires_at': _dateJson(instance.expiresAt),
    };
