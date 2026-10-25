// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_thread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserThread _$UserThreadFromJson(Map<String, dynamic> json) => UserThread(
  participants: json['participants'] == null
      ? const []
      : const LenientListOfUser().fromJson(json['participants']),
  id: const LenientString().fromJson(json['id']),
  replyCount: const LenientInt().fromJson(json['reply_count']),
  lastReplyAt: const MillisDateTime().fromJson(json['last_reply_at']),
  lastViewedAt: const MillisDateTime().fromJson(json['last_viewed_at']),
  post: const LenientPost().fromJson(json['post']),
  unreadReplies: const LenientInt().fromJson(json['unread_replies']),
  unreadMentions: const LenientInt().fromJson(json['unread_mentions']),
  isUrgent: const LenientBool().fromJson(json['is_urgent']),
  deleteAt: const MillisDateTime().fromJson(json['delete_at']),
);

Map<String, dynamic> _$UserThreadToJson(UserThread instance) =>
    <String, dynamic>{
      'id': const LenientString().toJson(instance.id),
      'reply_count': const LenientInt().toJson(instance.replyCount),
      'last_reply_at': const MillisDateTime().toJson(instance.lastReplyAt),
      'last_viewed_at': const MillisDateTime().toJson(instance.lastViewedAt),
      'participants': const LenientListOfUser().toJson(instance.participants),
      'post': const LenientPost().toJson(instance.post),
      'unread_replies': const LenientInt().toJson(instance.unreadReplies),
      'unread_mentions': const LenientInt().toJson(instance.unreadMentions),
      'is_urgent': const LenientBool().toJson(instance.isUrgent),
      'delete_at': const MillisDateTime().toJson(instance.deleteAt),
    };
