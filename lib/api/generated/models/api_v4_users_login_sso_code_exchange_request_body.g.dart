// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_users_login_sso_code_exchange_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4UsersLoginSsoCodeExchangeRequestBody
_$ApiV4UsersLoginSsoCodeExchangeRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4UsersLoginSsoCodeExchangeRequestBody(
  loginCode: json['login_code'] as String,
  codeVerifier: json['code_verifier'] as String,
  state: json['state'] as String,
);

Map<String, dynamic> _$ApiV4UsersLoginSsoCodeExchangeRequestBodyToJson(
  ApiV4UsersLoginSsoCodeExchangeRequestBody instance,
) => <String, dynamic>{
  'login_code': instance.loginCode,
  'code_verifier': instance.codeVerifier,
  'state': instance.state,
};
