// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'patch_api_v4_custom_profile_attributes_values_response.g.dart';

@JsonSerializable()
class PatchApiV4CustomProfileAttributesValuesResponse {
  const PatchApiV4CustomProfileAttributesValuesResponse({this.id, this.value});

  factory PatchApiV4CustomProfileAttributesValuesResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PatchApiV4CustomProfileAttributesValuesResponseFromJson(json);

  @LenientString()
  final String? id;
  final Object? value;

  Map<String, Object?> toJson() =>
      _$PatchApiV4CustomProfileAttributesValuesResponseToJson(this);
}
