// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'patch_api_v4_users_user_id_custom_profile_attributes_response.g.dart';

@JsonSerializable()
class PatchApiV4UsersUserIdCustomProfileAttributesResponse {
  const PatchApiV4UsersUserIdCustomProfileAttributesResponse({
    this.id,
    this.value,
  });

  factory PatchApiV4UsersUserIdCustomProfileAttributesResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PatchApiV4UsersUserIdCustomProfileAttributesResponseFromJson(json);

  @LenientString()
  final String? id;
  final Object? value;

  Map<String, Object?> toJson() =>
      _$PatchApiV4UsersUserIdCustomProfileAttributesResponseToJson(this);
}
