// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_custom_profile_attributes_values_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4CustomProfileAttributesValuesRequestBody
_$ApiV4CustomProfileAttributesValuesRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4CustomProfileAttributesValuesRequestBody(
  id: const LenientString().fromJson(json['id']),
  value: json['value'],
);

Map<String, dynamic> _$ApiV4CustomProfileAttributesValuesRequestBodyToJson(
  ApiV4CustomProfileAttributesValuesRequestBody instance,
) => <String, dynamic>{
  'id': const LenientString().toJson(instance.id),
  'value': instance.value,
};
