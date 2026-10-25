// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Team _$TeamFromJson(Map<String, dynamic> json) => Team(
  id: const LenientString().fromJson(json['id']),
  createAt: const MillisDateTime().fromJson(json['create_at']),
  updateAt: const MillisDateTime().fromJson(json['update_at']),
  deleteAt: const MillisDateTime().fromJson(json['delete_at']),
  displayName: const LenientString().fromJson(json['display_name']),
  name: const LenientString().fromJson(json['name']),
  description: const LenientString().fromJson(json['description']),
  email: const LenientString().fromJson(json['email']),
  type: const LenientString().fromJson(json['type']),
  allowedDomains: const LenientString().fromJson(json['allowed_domains']),
  inviteId: const LenientString().fromJson(json['invite_id']),
  allowOpenInvite: const LenientBool().fromJson(json['allow_open_invite']),
  policyId: const LenientString().fromJson(json['policy_id']),
);

Map<String, dynamic> _$TeamToJson(Team instance) => <String, dynamic>{
  'id': const LenientString().toJson(instance.id),
  'create_at': const MillisDateTime().toJson(instance.createAt),
  'update_at': const MillisDateTime().toJson(instance.updateAt),
  'delete_at': const MillisDateTime().toJson(instance.deleteAt),
  'display_name': const LenientString().toJson(instance.displayName),
  'name': const LenientString().toJson(instance.name),
  'description': const LenientString().toJson(instance.description),
  'email': const LenientString().toJson(instance.email),
  'type': const LenientString().toJson(instance.type),
  'allowed_domains': const LenientString().toJson(instance.allowedDomains),
  'invite_id': const LenientString().toJson(instance.inviteId),
  'allow_open_invite': const LenientBool().toJson(instance.allowOpenInvite),
  'policy_id': const LenientString().toJson(instance.policyId),
};
