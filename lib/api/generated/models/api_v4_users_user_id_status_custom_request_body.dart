// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_users_user_id_status_custom_request_body.g.dart';

@JsonSerializable()
class ApiV4UsersUserIdStatusCustomRequestBody {
  const ApiV4UsersUserIdStatusCustomRequestBody({
    required this.emoji,
    required this.text,
    this.duration,
    this.expiresAt,
  });

  factory ApiV4UsersUserIdStatusCustomRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4UsersUserIdStatusCustomRequestBodyFromJson(json);

  final String emoji;
  final String text;
  @LenientString()
  final String? duration;
  @LenientString()
  @JsonKey(name: 'expires_at')
  final String? expiresAt;

  Map<String, Object?> toJson() =>
      _$ApiV4UsersUserIdStatusCustomRequestBodyToJson(this);
}
