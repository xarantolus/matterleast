// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reaction _$ReactionFromJson(Map<String, dynamic> json) => Reaction(
  userId: const LenientString().fromJson(json['user_id']),
  postId: const LenientString().fromJson(json['post_id']),
  emojiName: const LenientString().fromJson(json['emoji_name']),
  createAt: const MillisDateTime().fromJson(json['create_at']),
  channelId: const LenientString().fromJson(json['channel_id']),
  updateAt: const MillisDateTime().fromJson(json['update_at']),
  deleteAt: const MillisDateTime().fromJson(json['delete_at']),
  remoteId: const LenientString().fromJson(json['remote_id']),
);

Map<String, dynamic> _$ReactionToJson(Reaction instance) => <String, dynamic>{
  'user_id': const LenientString().toJson(instance.userId),
  'post_id': const LenientString().toJson(instance.postId),
  'emoji_name': const LenientString().toJson(instance.emojiName),
  'create_at': const MillisDateTime().toJson(instance.createAt),
  'channel_id': const LenientString().toJson(instance.channelId),
  'update_at': const MillisDateTime().toJson(instance.updateAt),
  'delete_at': const MillisDateTime().toJson(instance.deleteAt),
  'remote_id': const LenientString().toJson(instance.remoteId),
};
