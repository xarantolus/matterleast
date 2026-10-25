// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_unread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeamUnread _$TeamUnreadFromJson(Map<String, dynamic> json) => TeamUnread(
  teamId: const LenientString().fromJson(json['team_id']),
  msgCount: const LenientInt().fromJson(json['msg_count']),
  mentionCount: const LenientInt().fromJson(json['mention_count']),
  msgCountRoot: const LenientInt().fromJson(json['msg_count_root']),
  mentionCountRoot: const LenientInt().fromJson(json['mention_count_root']),
  threadCount: const LenientInt().fromJson(json['thread_count']),
  threadMentionCount: const LenientInt().fromJson(json['thread_mention_count']),
  threadUrgentMentionCount: const LenientInt().fromJson(
    json['thread_urgent_mention_count'],
  ),
);

Map<String, dynamic> _$TeamUnreadToJson(
  TeamUnread instance,
) => <String, dynamic>{
  'team_id': const LenientString().toJson(instance.teamId),
  'msg_count': const LenientInt().toJson(instance.msgCount),
  'mention_count': const LenientInt().toJson(instance.mentionCount),
  'msg_count_root': const LenientInt().toJson(instance.msgCountRoot),
  'mention_count_root': const LenientInt().toJson(instance.mentionCountRoot),
  'thread_count': const LenientInt().toJson(instance.threadCount),
  'thread_mention_count': const LenientInt().toJson(
    instance.threadMentionCount,
  ),
  'thread_urgent_mention_count': const LenientInt().toJson(
    instance.threadUrgentMentionCount,
  ),
};
