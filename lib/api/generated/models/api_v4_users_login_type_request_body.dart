// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_users_login_type_request_body.g.dart';

@JsonSerializable()
class ApiV4UsersLoginTypeRequestBody {
  const ApiV4UsersLoginTypeRequestBody({this.id, this.loginId, this.deviceId});

  factory ApiV4UsersLoginTypeRequestBody.fromJson(Map<String, Object?> json) =>
      _$ApiV4UsersLoginTypeRequestBodyFromJson(json);

  @LenientString()
  final String? id;

  @LenientString()
  @JsonKey(name: 'login_id')
  final String? loginId;

  @LenientString()
  @JsonKey(name: 'device_id')
  final String? deviceId;

  Map<String, Object?> toJson() => _$ApiV4UsersLoginTypeRequestBodyToJson(this);
}
