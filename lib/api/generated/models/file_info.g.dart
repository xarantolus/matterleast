// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileInfo _$FileInfoFromJson(Map<String, dynamic> json) => FileInfo(
  id: const LenientString().fromJson(json['id']),
  userId: const LenientString().fromJson(json['user_id']),
  postId: const LenientString().fromJson(json['post_id']),
  createAt: const MillisDateTime().fromJson(json['create_at']),
  updateAt: const MillisDateTime().fromJson(json['update_at']),
  deleteAt: const MillisDateTime().fromJson(json['delete_at']),
  name: const LenientString().fromJson(json['name']),
  extensionValue: const LenientString().fromJson(json['extension']),
  size: const LenientInt().fromJson(json['size']),
  mimeType: const LenientString().fromJson(json['mime_type']),
  width: const LenientInt().fromJson(json['width']),
  height: const LenientInt().fromJson(json['height']),
  hasPreviewImage: const LenientBool().fromJson(json['has_preview_image']),
  miniPreview: const LenientString().fromJson(json['mini_preview']),
  archived: const LenientBool().fromJson(json['archived']),
  channelId: const LenientString().fromJson(json['channel_id']),
  remoteId: const LenientString().fromJson(json['remote_id']),
);

Map<String, dynamic> _$FileInfoToJson(FileInfo instance) => <String, dynamic>{
  'id': const LenientString().toJson(instance.id),
  'user_id': const LenientString().toJson(instance.userId),
  'post_id': const LenientString().toJson(instance.postId),
  'create_at': const MillisDateTime().toJson(instance.createAt),
  'update_at': const MillisDateTime().toJson(instance.updateAt),
  'delete_at': const MillisDateTime().toJson(instance.deleteAt),
  'name': const LenientString().toJson(instance.name),
  'extension': const LenientString().toJson(instance.extensionValue),
  'size': const LenientInt().toJson(instance.size),
  'mime_type': const LenientString().toJson(instance.mimeType),
  'width': const LenientInt().toJson(instance.width),
  'height': const LenientInt().toJson(instance.height),
  'has_preview_image': const LenientBool().toJson(instance.hasPreviewImage),
  'mini_preview': const LenientString().toJson(instance.miniPreview),
  'archived': const LenientBool().toJson(instance.archived),
  'channel_id': const LenientString().toJson(instance.channelId),
  'remote_id': const LenientString().toJson(instance.remoteId),
};
