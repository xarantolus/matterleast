// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'type2.dart';
import 'permission_field.dart';
import 'permission_values.dart';
import 'permission_options.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_properties_groups_group_name_object_type_fields_request_body.g.dart';

@JsonSerializable()
class ApiV4PropertiesGroupsGroupNameObjectTypeFieldsRequestBody {
  const ApiV4PropertiesGroupsGroupNameObjectTypeFieldsRequestBody({
    required this.name,
    required this.type,
    required this.targetType,
    this.permissionField = PermissionField.member,
    this.permissionValues = PermissionValues.member,
    this.permissionOptions = PermissionOptions.member,
    this.attrs,
    this.targetId,
    this.linkedFieldId,
  });

  factory ApiV4PropertiesGroupsGroupNameObjectTypeFieldsRequestBody.fromJson(
    Map<String, Object?> json,
  ) =>
      _$ApiV4PropertiesGroupsGroupNameObjectTypeFieldsRequestBodyFromJson(json);

  final String name;
  final Type2 type;
  @JsonMap()
  final Map<String, Object?>? attrs;
  @JsonKey(name: 'target_type')
  final String targetType;
  @LenientString()
  @JsonKey(name: 'target_id')
  final String? targetId;
  @JsonKey(name: 'permission_field')
  final PermissionField permissionField;
  @JsonKey(name: 'permission_values')
  final PermissionValues permissionValues;
  @JsonKey(name: 'permission_options')
  final PermissionOptions permissionOptions;
  @LenientString()
  @JsonKey(name: 'linked_field_id')
  final String? linkedFieldId;

  Map<String, Object?> toJson() =>
      _$ApiV4PropertiesGroupsGroupNameObjectTypeFieldsRequestBodyToJson(this);
}
