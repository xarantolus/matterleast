// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_properties_groups_group_name_object_type_fields_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4PropertiesGroupsGroupNameObjectTypeFieldsRequestBody
_$ApiV4PropertiesGroupsGroupNameObjectTypeFieldsRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4PropertiesGroupsGroupNameObjectTypeFieldsRequestBody(
  name: json['name'] as String,
  type: Type2.fromJson(json['type'] as String),
  targetType: json['target_type'] as String,
  permissionField: json['permission_field'] == null
      ? PermissionField.member
      : PermissionField.fromJson(json['permission_field'] as String),
  permissionValues: json['permission_values'] == null
      ? PermissionValues.member
      : PermissionValues.fromJson(json['permission_values'] as String),
  permissionOptions: json['permission_options'] == null
      ? PermissionOptions.member
      : PermissionOptions.fromJson(json['permission_options'] as String),
  attrs: const JsonMap().fromJson(json['attrs']),
  targetId: const LenientString().fromJson(json['target_id']),
  linkedFieldId: const LenientString().fromJson(json['linked_field_id']),
);

Map<String, dynamic>
_$ApiV4PropertiesGroupsGroupNameObjectTypeFieldsRequestBodyToJson(
  ApiV4PropertiesGroupsGroupNameObjectTypeFieldsRequestBody instance,
) => <String, dynamic>{
  'name': instance.name,
  'type': instance.type,
  'attrs': const JsonMap().toJson(instance.attrs),
  'target_type': instance.targetType,
  'target_id': const LenientString().toJson(instance.targetId),
  'permission_field': instance.permissionField,
  'permission_values': instance.permissionValues,
  'permission_options': instance.permissionOptions,
  'linked_field_id': const LenientString().toJson(instance.linkedFieldId),
};
