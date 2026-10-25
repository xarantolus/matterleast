// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_custom_profile_attributes_fields_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4CustomProfileAttributesFieldsRequestBody
_$ApiV4CustomProfileAttributesFieldsRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4CustomProfileAttributesFieldsRequestBody(
  name: json['name'] as String,
  type: json['type'] as String,
  attrs: const LenientAttrs().fromJson(json['attrs']),
);

Map<String, dynamic> _$ApiV4CustomProfileAttributesFieldsRequestBodyToJson(
  ApiV4CustomProfileAttributesFieldsRequestBody instance,
) => <String, dynamic>{
  'name': instance.name,
  'type': instance.type,
  'attrs': const LenientAttrs().toJson(instance.attrs),
};
