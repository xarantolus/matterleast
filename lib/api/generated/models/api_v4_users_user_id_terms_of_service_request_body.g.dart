// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_users_user_id_terms_of_service_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4UsersUserIdTermsOfServiceRequestBody
_$ApiV4UsersUserIdTermsOfServiceRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4UsersUserIdTermsOfServiceRequestBody(
  serviceTermsId: json['serviceTermsId'] as String,
  accepted: json['accepted'] as String,
);

Map<String, dynamic> _$ApiV4UsersUserIdTermsOfServiceRequestBodyToJson(
  ApiV4UsersUserIdTermsOfServiceRequestBody instance,
) => <String, dynamic>{
  'serviceTermsId': instance.serviceTermsId,
  'accepted': instance.accepted,
};
