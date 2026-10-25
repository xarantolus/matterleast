// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'action.g.dart';

@JsonSerializable()
class Action {
  const Action({this.name});

  factory Action.fromJson(Map<String, Object?> json) => _$ActionFromJson(json);

  @LenientString()
  final String? name;

  Map<String, Object?> toJson() => _$ActionToJson(this);
}
