// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'post_api_v4_users_login_type_response.g.dart';

@JsonSerializable()
class PostApiV4UsersLoginTypeResponse {
  const PostApiV4UsersLoginTypeResponse({this.authService});

  factory PostApiV4UsersLoginTypeResponse.fromJson(Map<String, Object?> json) =>
      _$PostApiV4UsersLoginTypeResponseFromJson(json);

  @LenientString()
  @JsonKey(name: 'auth_service')
  final String? authService;

  Map<String, Object?> toJson() =>
      _$PostApiV4UsersLoginTypeResponseToJson(this);
}
