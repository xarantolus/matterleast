// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_users_user_id_custom_profile_attributes_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4UsersUserIdCustomProfileAttributesRequestBody
_$ApiV4UsersUserIdCustomProfileAttributesRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4UsersUserIdCustomProfileAttributesRequestBody(
  id: const LenientString().fromJson(json['id']),
  value: json['value'],
);

Map<String, dynamic> _$ApiV4UsersUserIdCustomProfileAttributesRequestBodyToJson(
  ApiV4UsersUserIdCustomProfileAttributesRequestBody instance,
) => <String, dynamic>{
  'id': const LenientString().toJson(instance.id),
  'value': instance.value,
};
