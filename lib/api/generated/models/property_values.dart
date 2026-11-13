// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'property_values.g.dart';

@JsonSerializable()
class PropertyValues {
  const PropertyValues({required this.fieldId, required this.value});

  factory PropertyValues.fromJson(Map<String, Object?> json) =>
      _$PropertyValuesFromJson(json);

  @JsonKey(name: 'field_id')
  final String fieldId;
  final Object? value;

  Map<String, Object?> toJson() => _$PropertyValuesToJson(this);
}
