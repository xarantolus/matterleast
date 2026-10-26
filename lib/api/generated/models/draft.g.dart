// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Draft _$DraftFromJson(Map<String, dynamic> json) => Draft(
  fileIds: json['file_ids'] == null
      ? const []
      : const LenientStringList().fromJson(json['file_ids']),
  createAt: const MillisDateTime().fromJson(json['create_at']),
  updateAt: const MillisDateTime().fromJson(json['update_at']),
  deleteAt: const MillisDateTime().fromJson(json['delete_at']),
  userId: const LenientString().fromJson(json['user_id']),
  channelId: const LenientString().fromJson(json['channel_id']),
  rootId: const LenientString().fromJson(json['root_id']),
  message: const LenientString().fromJson(json['message']),
  type: const LenientString().fromJson(json['type']),
  props: json['props'],
  metadata: const LenientPostMetadata().fromJson(json['metadata']),
  priority: const LenientPostPriority().fromJson(json['priority']),
);

Map<String, dynamic> _$DraftToJson(Draft instance) => <String, dynamic>{
  'create_at': const MillisDateTime().toJson(instance.createAt),
  'update_at': const MillisDateTime().toJson(instance.updateAt),
  'delete_at': const MillisDateTime().toJson(instance.deleteAt),
  'user_id': const LenientString().toJson(instance.userId),
  'channel_id': const LenientString().toJson(instance.channelId),
  'root_id': const LenientString().toJson(instance.rootId),
  'message': const LenientString().toJson(instance.message),
  'type': const LenientString().toJson(instance.type),
  'props': instance.props,
  'file_ids': const LenientStringList().toJson(instance.fileIds),
  'metadata': const LenientPostMetadata().toJson(instance.metadata),
  'priority': const LenientPostPriority().toJson(instance.priority),
};
