// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_users_user_id_status_request_body.g.dart';

@JsonSerializable()
class ApiV4UsersUserIdStatusRequestBody {
  const ApiV4UsersUserIdStatusRequestBody({
    required this.userId,
    required this.status,
    this.dndEndTime,
  });

  factory ApiV4UsersUserIdStatusRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4UsersUserIdStatusRequestBodyFromJson(json);

  @JsonKey(name: 'user_id')
  final String userId;
  final String status;
  @LenientInt()
  @JsonKey(name: 'dnd_end_time')
  final int? dndEndTime;

  Map<String, Object?> toJson() =>
      _$ApiV4UsersUserIdStatusRequestBodyToJson(this);
}
