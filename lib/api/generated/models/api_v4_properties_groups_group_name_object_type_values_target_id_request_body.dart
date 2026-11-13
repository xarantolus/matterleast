// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'api_v4_properties_groups_group_name_object_type_values_target_id_request_body.g.dart';

@JsonSerializable()
class ApiV4PropertiesGroupsGroupNameObjectTypeValuesTargetIdRequestBody {
  const ApiV4PropertiesGroupsGroupNameObjectTypeValuesTargetIdRequestBody({
    required this.fieldId,
    required this.value,
  });

  factory ApiV4PropertiesGroupsGroupNameObjectTypeValuesTargetIdRequestBody.fromJson(
    Map<String, Object?> json,
  ) =>
      _$ApiV4PropertiesGroupsGroupNameObjectTypeValuesTargetIdRequestBodyFromJson(
        json,
      );

  @JsonKey(name: 'field_id')
  final String fieldId;
  final Object? value;

  Map<String, Object?> toJson() =>
      _$ApiV4PropertiesGroupsGroupNameObjectTypeValuesTargetIdRequestBodyToJson(
        this,
      );
}
