// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'terms_of_service.g.dart';

@JsonSerializable()
class TermsOfService {
  const TermsOfService({this.id, this.createAt, this.userId, this.text});

  factory TermsOfService.fromJson(Map<String, Object?> json) =>
      _$TermsOfServiceFromJson(json);

  @LenientString()
  final String? id;

  @MillisDateTime()
  @JsonKey(name: 'create_at')
  final DateTime? createAt;

  @LenientString()
  @JsonKey(name: 'user_id')
  final String? userId;

  @LenientString()
  final String? text;

  Map<String, Object?> toJson() => _$TermsOfServiceToJson(this);
}
