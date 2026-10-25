// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'preference.g.dart';

@JsonSerializable()
class Preference {
  const Preference({this.userId, this.category, this.name, this.value});

  factory Preference.fromJson(Map<String, Object?> json) =>
      _$PreferenceFromJson(json);

  @LenientString()
  @JsonKey(name: 'user_id')
  final String? userId;
  @LenientString()
  final String? category;
  @LenientString()
  final String? name;
  @LenientString()
  final String? value;

  Map<String, Object?> toJson() => _$PreferenceToJson(this);
}
