// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'role.g.dart';

@JsonSerializable()
class Role {
  const Role({
    this.permissions = const [],
    this.id,
    this.name,
    this.displayName,
    this.description,
    this.schemeManaged,
  });

  factory Role.fromJson(Map<String, Object?> json) => _$RoleFromJson(json);

  @LenientString()
  final String? id;
  @LenientString()
  final String? name;
  @LenientString()
  @JsonKey(name: 'display_name')
  final String? displayName;
  @LenientString()
  final String? description;
  @LenientStringList()
  final List<String> permissions;
  @LenientBool()
  @JsonKey(name: 'scheme_managed')
  final bool? schemeManaged;

  Map<String, Object?> toJson() => _$RoleToJson(this);
}
