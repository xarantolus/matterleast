// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'api_v4_users_password_reset_send_request_body.g.dart';

@JsonSerializable()
class ApiV4UsersPasswordResetSendRequestBody {
  const ApiV4UsersPasswordResetSendRequestBody({required this.email});

  factory ApiV4UsersPasswordResetSendRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4UsersPasswordResetSendRequestBodyFromJson(json);

  final String email;

  Map<String, Object?> toJson() =>
      _$ApiV4UsersPasswordResetSendRequestBodyToJson(this);
}
