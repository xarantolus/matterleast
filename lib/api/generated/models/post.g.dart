// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
  fileIds: json['file_ids'] == null
      ? const []
      : const LenientStringList().fromJson(json['file_ids']),
  participants: json['participants'] == null
      ? const []
      : const LenientListOfUser().fromJson(json['participants']),
  id: const LenientString().fromJson(json['id']),
  createAt: const MillisDateTime().fromJson(json['create_at']),
  updateAt: const MillisDateTime().fromJson(json['update_at']),
  deleteAt: const MillisDateTime().fromJson(json['delete_at']),
  editAt: const MillisDateTime().fromJson(json['edit_at']),
  userId: const LenientString().fromJson(json['user_id']),
  channelId: const LenientString().fromJson(json['channel_id']),
  rootId: const LenientString().fromJson(json['root_id']),
  originalId: const LenientString().fromJson(json['original_id']),
  message: const LenientString().fromJson(json['message']),
  type: const LenientString().fromJson(json['type']),
  props: const JsonMap().fromJson(json['props']),
  pendingPostId: const LenientString().fromJson(json['pending_post_id']),
  metadata: const LenientPostMetadata().fromJson(json['metadata']),
  hashtags: const LenientString().fromJson(json['hashtags']),
  isPinned: const LenientBool().fromJson(json['is_pinned']),
  messageSource: const LenientString().fromJson(json['message_source']),
  hasReactions: const LenientBool().fromJson(json['has_reactions']),
  remoteId: const LenientString().fromJson(json['remote_id']),
  replyCount: const LenientInt().fromJson(json['reply_count']),
  lastReplyAt: const MillisDateTime().fromJson(json['last_reply_at']),
  isFollowing: const LenientBool().fromJson(json['is_following']),
);

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
  'id': const LenientString().toJson(instance.id),
  'create_at': const MillisDateTime().toJson(instance.createAt),
  'update_at': const MillisDateTime().toJson(instance.updateAt),
  'delete_at': const MillisDateTime().toJson(instance.deleteAt),
  'edit_at': const MillisDateTime().toJson(instance.editAt),
  'user_id': const LenientString().toJson(instance.userId),
  'channel_id': const LenientString().toJson(instance.channelId),
  'root_id': const LenientString().toJson(instance.rootId),
  'original_id': const LenientString().toJson(instance.originalId),
  'message': const LenientString().toJson(instance.message),
  'type': const LenientString().toJson(instance.type),
  'props': const JsonMap().toJson(instance.props),
  'file_ids': const LenientStringList().toJson(instance.fileIds),
  'pending_post_id': const LenientString().toJson(instance.pendingPostId),
  'metadata': const LenientPostMetadata().toJson(instance.metadata),
  'hashtags': const LenientString().toJson(instance.hashtags),
  'is_pinned': const LenientBool().toJson(instance.isPinned),
  'message_source': const LenientString().toJson(instance.messageSource),
  'has_reactions': const LenientBool().toJson(instance.hasReactions),
  'remote_id': const LenientString().toJson(instance.remoteId),
  'reply_count': const LenientInt().toJson(instance.replyCount),
  'last_reply_at': const MillisDateTime().toJson(instance.lastReplyAt),
  'participants': const LenientListOfUser().toJson(instance.participants),
  'is_following': const LenientBool().toJson(instance.isFollowing),
};
