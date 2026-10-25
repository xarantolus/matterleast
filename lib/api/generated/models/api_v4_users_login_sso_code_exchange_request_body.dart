// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'api_v4_users_login_sso_code_exchange_request_body.g.dart';

@JsonSerializable()
class ApiV4UsersLoginSsoCodeExchangeRequestBody {
  const ApiV4UsersLoginSsoCodeExchangeRequestBody({
    required this.loginCode,
    required this.codeVerifier,
    required this.state,
  });

  factory ApiV4UsersLoginSsoCodeExchangeRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4UsersLoginSsoCodeExchangeRequestBodyFromJson(json);

  @JsonKey(name: 'login_code')
  final String loginCode;

  @JsonKey(name: 'code_verifier')
  final String codeVerifier;

  final String state;

  Map<String, Object?> toJson() =>
      _$ApiV4UsersLoginSsoCodeExchangeRequestBodyToJson(this);
}
