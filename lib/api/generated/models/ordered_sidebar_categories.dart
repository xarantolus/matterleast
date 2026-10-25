// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'sidebar_category_with_channels.dart';

import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/json/lenient_models.dart';
part 'ordered_sidebar_categories.g.dart';

@JsonSerializable()
class OrderedSidebarCategories {
  const OrderedSidebarCategories({
    this.order = const [],
    this.categories = const [],
  });

  factory OrderedSidebarCategories.fromJson(Map<String, Object?> json) =>
      _$OrderedSidebarCategoriesFromJson(json);

  @LenientStringList()
  final List<String> order;
  @LenientListOfSidebarCategoryWithChannels()
  final List<SidebarCategoryWithChannels> categories;

  Map<String, Object?> toJson() => _$OrderedSidebarCategoriesToJson(this);
}
