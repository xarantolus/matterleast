// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'api_v4_users_user_id_sessions_revoke_request_body.g.dart';

@JsonSerializable()
class ApiV4UsersUserIdSessionsRevokeRequestBody {
  const ApiV4UsersUserIdSessionsRevokeRequestBody({required this.sessionId});

  factory ApiV4UsersUserIdSessionsRevokeRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4UsersUserIdSessionsRevokeRequestBodyFromJson(json);

  @JsonKey(name: 'session_id')
  final String sessionId;

  Map<String, Object?> toJson() =>
      _$ApiV4UsersUserIdSessionsRevokeRequestBodyToJson(this);
}
