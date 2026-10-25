// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'post_api_v4_users_login_sso_code_exchange_response.g.dart';

@JsonSerializable()
class PostApiV4UsersLoginSsoCodeExchangeResponse {
  const PostApiV4UsersLoginSsoCodeExchangeResponse({this.token, this.csrf});

  factory PostApiV4UsersLoginSsoCodeExchangeResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV4UsersLoginSsoCodeExchangeResponseFromJson(json);

  @LenientString()
  final String? token;

  @LenientString()
  final String? csrf;

  Map<String, Object?> toJson() =>
      _$PostApiV4UsersLoginSsoCodeExchangeResponseToJson(this);
}
