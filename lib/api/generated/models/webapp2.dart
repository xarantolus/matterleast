// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'webapp2.g.dart';

@JsonSerializable()
class Webapp2 {
  const Webapp2({this.bundlePath});

  factory Webapp2.fromJson(Map<String, Object?> json) =>
      _$Webapp2FromJson(json);

  @LenientString()
  @JsonKey(name: 'bundle_path')
  final String? bundlePath;

  Map<String, Object?> toJson() => _$Webapp2ToJson(this);
}
