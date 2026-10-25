// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emoji.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Emoji _$EmojiFromJson(Map<String, dynamic> json) => Emoji(
  id: const LenientString().fromJson(json['id']),
  creatorId: const LenientString().fromJson(json['creator_id']),
  name: const LenientString().fromJson(json['name']),
  createAt: const MillisDateTime().fromJson(json['create_at']),
  updateAt: const MillisDateTime().fromJson(json['update_at']),
  deleteAt: const MillisDateTime().fromJson(json['delete_at']),
);

Map<String, dynamic> _$EmojiToJson(Emoji instance) => <String, dynamic>{
  'id': const LenientString().toJson(instance.id),
  'creator_id': const LenientString().toJson(instance.creatorId),
  'name': const LenientString().toJson(instance.name),
  'create_at': const MillisDateTime().toJson(instance.createAt),
  'update_at': const MillisDateTime().toJson(instance.updateAt),
  'delete_at': const MillisDateTime().toJson(instance.deleteAt),
};
