// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'sidebar_category_type.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'sidebar_category.g.dart';

@JsonSerializable()
class SidebarCategory {
  const SidebarCategory({
    this.id,
    this.userId,
    this.teamId,
    this.displayName,
    this.type,
  });

  factory SidebarCategory.fromJson(Map<String, Object?> json) =>
      _$SidebarCategoryFromJson(json);

  @LenientString()
  final String? id;
  @LenientString()
  @JsonKey(name: 'user_id')
  final String? userId;
  @LenientString()
  @JsonKey(name: 'team_id')
  final String? teamId;
  @LenientString()
  @JsonKey(name: 'display_name')
  final String? displayName;
  final SidebarCategoryType? type;

  Map<String, Object?> toJson() => _$SidebarCategoryToJson(this);
}
