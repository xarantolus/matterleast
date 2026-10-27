// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'access_control_resource.g.dart';

@JsonSerializable()
class AccessControlResource {
  const AccessControlResource({this.type, this.id});

  factory AccessControlResource.fromJson(Map<String, Object?> json) =>
      _$AccessControlResourceFromJson(json);

  @LenientString()
  final String? type;
  @LenientString()
  final String? id;

  Map<String, Object?> toJson() => _$AccessControlResourceToJson(this);
}
