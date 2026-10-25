// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_field.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PropertyField _$PropertyFieldFromJson(Map<String, dynamic> json) =>
    PropertyField(
      id: const LenientString().fromJson(json['id']),
      groupId: const LenientString().fromJson(json['group_id']),
      name: const LenientString().fromJson(json['name']),
      type: json['type'] == null
          ? null
          : PropertyFieldType.fromJson(json['type'] as String),
      objectType: json['object_type'] == null
          ? null
          : PropertyFieldObjectType.fromJson(json['object_type'] as String),
      attrs: const JsonMap().fromJson(json['attrs']),
      targetId: const LenientString().fromJson(json['target_id']),
      targetType: const LenientString().fromJson(json['target_type']),
      protected: const LenientBool().fromJson(json['protected']),
      permissionField: json['permission_field'] == null
          ? null
          : PropertyFieldPermissionField.fromJson(
              json['permission_field'] as String,
            ),
      permissionValues: json['permission_values'] == null
          ? null
          : PropertyFieldPermissionValues.fromJson(
              json['permission_values'] as String,
            ),
      permissionOptions: json['permission_options'] == null
          ? null
          : PropertyFieldPermissionOptions.fromJson(
              json['permission_options'] as String,
            ),
      linkedFieldId: const LenientString().fromJson(json['linked_field_id']),
      createAt: const MillisDateTime().fromJson(json['create_at']),
      updateAt: const MillisDateTime().fromJson(json['update_at']),
      deleteAt: const MillisDateTime().fromJson(json['delete_at']),
      createdBy: const LenientString().fromJson(json['created_by']),
      updatedBy: const LenientString().fromJson(json['updated_by']),
    );

Map<String, dynamic> _$PropertyFieldToJson(PropertyField instance) =>
    <String, dynamic>{
      'id': const LenientString().toJson(instance.id),
      'group_id': const LenientString().toJson(instance.groupId),
      'name': const LenientString().toJson(instance.name),
      'type': instance.type,
      'object_type': instance.objectType,
      'attrs': const JsonMap().toJson(instance.attrs),
      'target_id': const LenientString().toJson(instance.targetId),
      'target_type': const LenientString().toJson(instance.targetType),
      'protected': const LenientBool().toJson(instance.protected),
      'permission_field': instance.permissionField,
      'permission_values': instance.permissionValues,
      'permission_options': instance.permissionOptions,
      'linked_field_id': const LenientString().toJson(instance.linkedFieldId),
      'create_at': const MillisDateTime().toJson(instance.createAt),
      'update_at': const MillisDateTime().toJson(instance.updateAt),
      'delete_at': const MillisDateTime().toJson(instance.deleteAt),
      'created_by': const LenientString().toJson(instance.createdBy),
      'updated_by': const LenientString().toJson(instance.updatedBy),
    };
