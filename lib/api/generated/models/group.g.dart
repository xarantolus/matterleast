// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Group _$GroupFromJson(Map<String, dynamic> json) => Group(
  id: const LenientString().fromJson(json['id']),
  name: const LenientString().fromJson(json['name']),
  displayName: const LenientString().fromJson(json['display_name']),
  description: const LenientString().fromJson(json['description']),
  source: const LenientString().fromJson(json['source']),
  remoteId: const LenientString().fromJson(json['remote_id']),
  createAt: const MillisDateTime().fromJson(json['create_at']),
  updateAt: const MillisDateTime().fromJson(json['update_at']),
  deleteAt: const MillisDateTime().fromJson(json['delete_at']),
  hasSyncables: const LenientBool().fromJson(json['has_syncables']),
  memberCount: const LenientInt().fromJson(json['member_count']),
  allowReference: const LenientBool().fromJson(json['allow_reference']),
);

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
  'id': const LenientString().toJson(instance.id),
  'name': const LenientString().toJson(instance.name),
  'display_name': const LenientString().toJson(instance.displayName),
  'description': const LenientString().toJson(instance.description),
  'source': const LenientString().toJson(instance.source),
  'remote_id': const LenientString().toJson(instance.remoteId),
  'create_at': const MillisDateTime().toJson(instance.createAt),
  'update_at': const MillisDateTime().toJson(instance.updateAt),
  'delete_at': const MillisDateTime().toJson(instance.deleteAt),
  'has_syncables': const LenientBool().toJson(instance.hasSyncables),
  'member_count': const LenientInt().toJson(instance.memberCount),
  'allow_reference': const LenientBool().toJson(instance.allowReference),
};
