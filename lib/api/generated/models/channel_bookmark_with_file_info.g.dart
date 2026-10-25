// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_bookmark_with_file_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelBookmarkWithFileInfo _$ChannelBookmarkWithFileInfoFromJson(
  Map<String, dynamic> json,
) => ChannelBookmarkWithFileInfo(
  id: const LenientString().fromJson(json['id']),
  createAt: const MillisDateTime().fromJson(json['create_at']),
  updateAt: const MillisDateTime().fromJson(json['update_at']),
  deleteAt: const MillisDateTime().fromJson(json['delete_at']),
  channelId: const LenientString().fromJson(json['channel_id']),
  ownerId: const LenientString().fromJson(json['owner_id']),
  fileId: const LenientString().fromJson(json['file_id']),
  displayName: const LenientString().fromJson(json['display_name']),
  sortOrder: const LenientInt().fromJson(json['sort_order']),
  linkUrl: const LenientString().fromJson(json['link_url']),
  imageUrl: const LenientString().fromJson(json['image_url']),
  emoji: const LenientString().fromJson(json['emoji']),
  type: json['type'] == null
      ? null
      : ChannelBookmarkType.fromJson(json['type'] as String),
  targetId: const LenientString().fromJson(json['target_id']),
  originalId: const LenientString().fromJson(json['original_id']),
  parentId: const LenientString().fromJson(json['parent_id']),
  file: const LenientFileInfo().fromJson(json['file']),
);

Map<String, dynamic> _$ChannelBookmarkWithFileInfoToJson(
  ChannelBookmarkWithFileInfo instance,
) => <String, dynamic>{
  'id': const LenientString().toJson(instance.id),
  'create_at': const MillisDateTime().toJson(instance.createAt),
  'update_at': const MillisDateTime().toJson(instance.updateAt),
  'delete_at': const MillisDateTime().toJson(instance.deleteAt),
  'channel_id': const LenientString().toJson(instance.channelId),
  'owner_id': const LenientString().toJson(instance.ownerId),
  'file_id': const LenientString().toJson(instance.fileId),
  'display_name': const LenientString().toJson(instance.displayName),
  'sort_order': const LenientInt().toJson(instance.sortOrder),
  'link_url': const LenientString().toJson(instance.linkUrl),
  'image_url': const LenientString().toJson(instance.imageUrl),
  'emoji': const LenientString().toJson(instance.emoji),
  'type': instance.type,
  'target_id': const LenientString().toJson(instance.targetId),
  'original_id': const LenientString().toJson(instance.originalId),
  'parent_id': const LenientString().toJson(instance.parentId),
  'file': const LenientFileInfo().toJson(instance.file),
};
