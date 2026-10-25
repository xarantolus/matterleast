// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v4_custom_profile_attributes_values_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV4CustomProfileAttributesValuesResponse
_$PatchApiV4CustomProfileAttributesValuesResponseFromJson(
  Map<String, dynamic> json,
) => PatchApiV4CustomProfileAttributesValuesResponse(
  id: const LenientString().fromJson(json['id']),
  value: json['value'],
);

Map<String, dynamic> _$PatchApiV4CustomProfileAttributesValuesResponseToJson(
  PatchApiV4CustomProfileAttributesValuesResponse instance,
) => <String, dynamic>{
  'id': const LenientString().toJson(instance.id),
  'value': instance.value,
};
