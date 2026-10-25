// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v4_users_login_sso_code_exchange_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV4UsersLoginSsoCodeExchangeResponse
_$PostApiV4UsersLoginSsoCodeExchangeResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV4UsersLoginSsoCodeExchangeResponse(
  token: const LenientString().fromJson(json['token']),
  csrf: const LenientString().fromJson(json['csrf']),
);

Map<String, dynamic> _$PostApiV4UsersLoginSsoCodeExchangeResponseToJson(
  PostApiV4UsersLoginSsoCodeExchangeResponse instance,
) => <String, dynamic>{
  'token': const LenientString().toJson(instance.token),
  'csrf': const LenientString().toJson(instance.csrf),
};
