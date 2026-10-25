// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ordered_sidebar_categories.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderedSidebarCategories _$OrderedSidebarCategoriesFromJson(
  Map<String, dynamic> json,
) => OrderedSidebarCategories(
  order: json['order'] == null
      ? const []
      : const LenientStringList().fromJson(json['order']),
  categories: json['categories'] == null
      ? const []
      : const LenientListOfSidebarCategoryWithChannels().fromJson(
          json['categories'],
        ),
);

Map<String, dynamic> _$OrderedSidebarCategoriesToJson(
  OrderedSidebarCategories instance,
) => <String, dynamic>{
  'order': const LenientStringList().toJson(instance.order),
  'categories': const LenientListOfSidebarCategoryWithChannels().toJson(
    instance.categories,
  ),
};
