// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Role _$RoleFromJson(Map<String, dynamic> json) => Role(
  permissions: json['permissions'] == null
      ? const []
      : const LenientStringList().fromJson(json['permissions']),
  id: const LenientString().fromJson(json['id']),
  name: const LenientString().fromJson(json['name']),
  displayName: const LenientString().fromJson(json['display_name']),
  description: const LenientString().fromJson(json['description']),
  schemeManaged: const LenientBool().fromJson(json['scheme_managed']),
);

Map<String, dynamic> _$RoleToJson(Role instance) => <String, dynamic>{
  'id': const LenientString().toJson(instance.id),
  'name': const LenientString().toJson(instance.name),
  'display_name': const LenientString().toJson(instance.displayName),
  'description': const LenientString().toJson(instance.description),
  'permissions': const LenientStringList().toJson(instance.permissions),
  'scheme_managed': const LenientBool().toJson(instance.schemeManaged),
};
