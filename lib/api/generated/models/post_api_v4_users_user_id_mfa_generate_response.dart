// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'post_api_v4_users_user_id_mfa_generate_response.g.dart';

@JsonSerializable()
class PostApiV4UsersUserIdMfaGenerateResponse {
  const PostApiV4UsersUserIdMfaGenerateResponse({this.secret, this.qrCode});

  factory PostApiV4UsersUserIdMfaGenerateResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV4UsersUserIdMfaGenerateResponseFromJson(json);

  @LenientString()
  final String? secret;
  @LenientString()
  @JsonKey(name: 'qr_code')
  final String? qrCode;

  Map<String, Object?> toJson() =>
      _$PostApiV4UsersUserIdMfaGenerateResponseToJson(this);
}
