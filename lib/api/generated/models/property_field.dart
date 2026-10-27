// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'property_field_object_type.dart';
import 'property_field_permission_field.dart';
import 'property_field_permission_options.dart';
import 'property_field_permission_values.dart';
import 'property_field_type.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'property_field.g.dart';

@JsonSerializable()
class PropertyField {
  const PropertyField({
    this.id,
    this.groupId,
    this.name,
    this.type,
    this.objectType,
    this.attrs,
    this.targetId,
    this.targetType,
    this.protected,
    this.permissionField,
    this.permissionValues,
    this.permissionOptions,
    this.linkedFieldId,
    this.createAt,
    this.updateAt,
    this.deleteAt,
    this.createdBy,
    this.updatedBy,
  });

  factory PropertyField.fromJson(Map<String, Object?> json) =>
      _$PropertyFieldFromJson(json);

  @LenientString()
  final String? id;
  @LenientString()
  @JsonKey(name: 'group_id')
  final String? groupId;
  @LenientString()
  final String? name;
  final PropertyFieldType? type;
  @JsonKey(name: 'object_type')
  final PropertyFieldObjectType? objectType;
  @JsonMap()
  final Map<String, Object?>? attrs;
  @LenientString()
  @JsonKey(name: 'target_id')
  final String? targetId;
  @LenientString()
  @JsonKey(name: 'target_type')
  final String? targetType;
  @LenientBool()
  final bool? protected;
  @JsonKey(name: 'permission_field')
  final PropertyFieldPermissionField? permissionField;
  @JsonKey(name: 'permission_values')
  final PropertyFieldPermissionValues? permissionValues;
  @JsonKey(name: 'permission_options')
  final PropertyFieldPermissionOptions? permissionOptions;
  @LenientString()
  @JsonKey(name: 'linked_field_id')
  final String? linkedFieldId;
  @MillisDateTime()
  @JsonKey(name: 'create_at')
  final DateTime? createAt;
  @MillisDateTime()
  @JsonKey(name: 'update_at')
  final DateTime? updateAt;
  @MillisDateTime()
  @JsonKey(name: 'delete_at')
  final DateTime? deleteAt;
  @LenientString()
  @JsonKey(name: 'created_by')
  final String? createdBy;
  @LenientString()
  @JsonKey(name: 'updated_by')
  final String? updatedBy;

  Map<String, Object?> toJson() => _$PropertyFieldToJson(this);
}
