// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v4_users_user_id_custom_profile_attributes_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV4UsersUserIdCustomProfileAttributesResponse
_$PatchApiV4UsersUserIdCustomProfileAttributesResponseFromJson(
  Map<String, dynamic> json,
) => PatchApiV4UsersUserIdCustomProfileAttributesResponse(
  id: const LenientString().fromJson(json['id']),
  value: json['value'],
);

Map<String, dynamic>
_$PatchApiV4UsersUserIdCustomProfileAttributesResponseToJson(
  PatchApiV4UsersUserIdCustomProfileAttributesResponse instance,
) => <String, dynamic>{
  'id': const LenientString().toJson(instance.id),
  'value': instance.value,
};
