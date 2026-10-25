// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'attrs.dart';

import 'package:matterleast/api/json/lenient_models.dart';
part 'api_v4_custom_profile_attributes_fields_request_body.g.dart';

@JsonSerializable()
class ApiV4CustomProfileAttributesFieldsRequestBody {
  const ApiV4CustomProfileAttributesFieldsRequestBody({
    required this.name,
    required this.type,
    this.attrs,
  });

  factory ApiV4CustomProfileAttributesFieldsRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4CustomProfileAttributesFieldsRequestBodyFromJson(json);

  final String name;
  final String type;
  @LenientAttrs()
  final Attrs? attrs;

  Map<String, Object?> toJson() =>
      _$ApiV4CustomProfileAttributesFieldsRequestBodyToJson(this);
}
