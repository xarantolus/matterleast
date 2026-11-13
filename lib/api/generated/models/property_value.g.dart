// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_value.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PropertyValue _$PropertyValueFromJson(Map<String, dynamic> json) =>
    PropertyValue(
      id: const LenientString().fromJson(json['id']),
      targetId: const LenientString().fromJson(json['target_id']),
      targetType: const LenientString().fromJson(json['target_type']),
      groupId: const LenientString().fromJson(json['group_id']),
      fieldId: const LenientString().fromJson(json['field_id']),
      createAt: const MillisDateTime().fromJson(json['create_at']),
      updateAt: const MillisDateTime().fromJson(json['update_at']),
      deleteAt: const MillisDateTime().fromJson(json['delete_at']),
      createdBy: const LenientString().fromJson(json['created_by']),
      updatedBy: const LenientString().fromJson(json['updated_by']),
      value: json['value'],
    );

Map<String, dynamic> _$PropertyValueToJson(PropertyValue instance) =>
    <String, dynamic>{
      'id': const LenientString().toJson(instance.id),
      'target_id': const LenientString().toJson(instance.targetId),
      'target_type': const LenientString().toJson(instance.targetType),
      'group_id': const LenientString().toJson(instance.groupId),
      'field_id': const LenientString().toJson(instance.fieldId),
      'create_at': const MillisDateTime().toJson(instance.createAt),
      'update_at': const MillisDateTime().toJson(instance.updateAt),
      'delete_at': const MillisDateTime().toJson(instance.deleteAt),
      'created_by': const LenientString().toJson(instance.createdBy),
      'updated_by': const LenientString().toJson(instance.updatedBy),
      'value': instance.value,
    };
