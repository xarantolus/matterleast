// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'api_v4_users_user_id_status_custom_recent_delete_request_body.g.dart';

@JsonSerializable()
class ApiV4UsersUserIdStatusCustomRecentDeleteRequestBody {
  const ApiV4UsersUserIdStatusCustomRecentDeleteRequestBody({
    required this.emoji,
    required this.text,
    required this.duration,
    required this.expiresAt,
  });

  factory ApiV4UsersUserIdStatusCustomRecentDeleteRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4UsersUserIdStatusCustomRecentDeleteRequestBodyFromJson(json);

  final String emoji;

  final String text;

  final String duration;

  @JsonKey(name: 'expires_at')
  final String expiresAt;

  Map<String, Object?> toJson() =>
      _$ApiV4UsersUserIdStatusCustomRecentDeleteRequestBodyToJson(this);
}
