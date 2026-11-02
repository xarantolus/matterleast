// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_users_user_id_mfa_request_body.g.dart';

@JsonSerializable()
class ApiV4UsersUserIdMfaRequestBody {
  const ApiV4UsersUserIdMfaRequestBody({required this.activate, this.code});

  factory ApiV4UsersUserIdMfaRequestBody.fromJson(Map<String, Object?> json) =>
      _$ApiV4UsersUserIdMfaRequestBodyFromJson(json);

  final bool activate;
  @LenientString()
  final String? code;

  Map<String, Object?> toJson() => _$ApiV4UsersUserIdMfaRequestBodyToJson(this);
}
