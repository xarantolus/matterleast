// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'options.g.dart';

@JsonSerializable()
class Options {
  const Options({this.text, this.value});

  factory Options.fromJson(Map<String, Object?> json) =>
      _$OptionsFromJson(json);

  @LenientString()
  final String? text;
  @LenientString()
  final String? value;

  Map<String, Object?> toJson() => _$OptionsToJson(this);
}
