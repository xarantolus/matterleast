// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'user_terms_of_service.g.dart';

@JsonSerializable()
class UserTermsOfService {
  const UserTermsOfService({this.userId, this.termsOfServiceId, this.createAt});

  factory UserTermsOfService.fromJson(Map<String, Object?> json) =>
      _$UserTermsOfServiceFromJson(json);

  @LenientString()
  @JsonKey(name: 'user_id')
  final String? userId;

  @LenientString()
  @JsonKey(name: 'terms_of_service_id')
  final String? termsOfServiceId;

  @MillisDateTime()
  @JsonKey(name: 'create_at')
  final DateTime? createAt;

  Map<String, Object?> toJson() => _$UserTermsOfServiceToJson(this);
}
