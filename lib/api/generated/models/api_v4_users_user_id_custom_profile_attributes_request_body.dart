// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_users_user_id_custom_profile_attributes_request_body.g.dart';

@JsonSerializable()
class ApiV4UsersUserIdCustomProfileAttributesRequestBody {
  const ApiV4UsersUserIdCustomProfileAttributesRequestBody({
    this.id,
    this.value,
  });

  factory ApiV4UsersUserIdCustomProfileAttributesRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4UsersUserIdCustomProfileAttributesRequestBodyFromJson(json);

  @LenientString()
  final String? id;
  final Object? value;

  Map<String, Object?> toJson() =>
      _$ApiV4UsersUserIdCustomProfileAttributesRequestBodyToJson(this);
}
