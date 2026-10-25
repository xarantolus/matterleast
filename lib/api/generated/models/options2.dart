// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'options2.g.dart';

@JsonSerializable()
class Options2 {
  const Options2({this.name, this.color});

  factory Options2.fromJson(Map<String, Object?> json) =>
      _$Options2FromJson(json);

  @LenientString()
  final String? name;
  @LenientString()
  final String? color;

  Map<String, Object?> toJson() => _$Options2ToJson(this);
}
