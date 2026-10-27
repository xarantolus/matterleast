// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'api_v4_users_user_id_terms_of_service_request_body.g.dart';

@JsonSerializable()
class ApiV4UsersUserIdTermsOfServiceRequestBody {
  const ApiV4UsersUserIdTermsOfServiceRequestBody({
    required this.serviceTermsId,
    required this.accepted,
  });

  factory ApiV4UsersUserIdTermsOfServiceRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4UsersUserIdTermsOfServiceRequestBodyFromJson(json);

  final String serviceTermsId;
  final String accepted;

  Map<String, Object?> toJson() =>
      _$ApiV4UsersUserIdTermsOfServiceRequestBodyToJson(this);
}
