// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'property_value.g.dart';

@JsonSerializable()
class PropertyValue {
  const PropertyValue({
    this.id,
    this.targetId,
    this.targetType,
    this.groupId,
    this.fieldId,
    this.createAt,
    this.updateAt,
    this.deleteAt,
    this.createdBy,
    this.updatedBy,
    this.value,
  });

  factory PropertyValue.fromJson(Map<String, Object?> json) =>
      _$PropertyValueFromJson(json);

  @LenientString()
  final String? id;
  @LenientString()
  @JsonKey(name: 'target_id')
  final String? targetId;
  @LenientString()
  @JsonKey(name: 'target_type')
  final String? targetType;
  @LenientString()
  @JsonKey(name: 'group_id')
  final String? groupId;
  @LenientString()
  @JsonKey(name: 'field_id')
  final String? fieldId;
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
  final Object? value;

  Map<String, Object?> toJson() => _$PropertyValueToJson(this);
}
