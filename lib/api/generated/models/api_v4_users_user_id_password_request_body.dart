// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_users_user_id_password_request_body.g.dart';

@JsonSerializable()
class ApiV4UsersUserIdPasswordRequestBody {
  const ApiV4UsersUserIdPasswordRequestBody({
    required this.newPassword,
    this.currentPassword,
  });

  factory ApiV4UsersUserIdPasswordRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4UsersUserIdPasswordRequestBodyFromJson(json);

  @LenientString()
  @JsonKey(name: 'current_password')
  final String? currentPassword;
  @JsonKey(name: 'new_password')
  final String newPassword;

  Map<String, Object?> toJson() =>
      _$ApiV4UsersUserIdPasswordRequestBodyToJson(this);
}
