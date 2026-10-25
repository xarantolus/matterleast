// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'status_ok.g.dart';

@JsonSerializable()
class StatusOk {
  const StatusOk({this.status});

  factory StatusOk.fromJson(Map<String, Object?> json) =>
      _$StatusOkFromJson(json);

  @LenientString()
  final String? status;

  Map<String, Object?> toJson() => _$StatusOkToJson(this);
}
