// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attrs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attrs _$AttrsFromJson(Map<String, dynamic> json) => Attrs(
  sortOrder: json['sort_order'] as num?,
  valueType: json['value_type'] == null
      ? null
      : ValueType.fromJson(json['value_type'] as String),
  ldap: const LenientString().fromJson(json['ldap']),
  saml: const LenientString().fromJson(json['saml']),
  protected: const LenientBool().fromJson(json['protected']),
  sourcePluginId: const LenientString().fromJson(json['source_plugin_id']),
  accessMode: json['access_mode'] == null
      ? null
      : AccessMode.fromJson(json['access_mode'] as String),
  displayName: const LenientString().fromJson(json['display_name']),
  visibility: json['visibility'] == null
      ? Visibility.whenSet
      : Visibility.fromJson(json['visibility'] as String),
  options: json['options'] == null
      ? const []
      : const LenientListOfOptions2().fromJson(json['options']),
);

Map<String, dynamic> _$AttrsToJson(Attrs instance) => <String, dynamic>{
  'visibility': instance.visibility,
  'sort_order': instance.sortOrder,
  'options': const LenientListOfOptions2().toJson(instance.options),
  'value_type': instance.valueType,
  'ldap': const LenientString().toJson(instance.ldap),
  'saml': const LenientString().toJson(instance.saml),
  'protected': const LenientBool().toJson(instance.protected),
  'source_plugin_id': const LenientString().toJson(instance.sourcePluginId),
  'access_mode': instance.accessMode,
  'display_name': const LenientString().toJson(instance.displayName),
};
