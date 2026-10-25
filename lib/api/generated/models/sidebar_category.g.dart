// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sidebar_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SidebarCategory _$SidebarCategoryFromJson(Map<String, dynamic> json) =>
    SidebarCategory(
      id: const LenientString().fromJson(json['id']),
      userId: const LenientString().fromJson(json['user_id']),
      teamId: const LenientString().fromJson(json['team_id']),
      displayName: const LenientString().fromJson(json['display_name']),
      type: json['type'] == null
          ? null
          : SidebarCategoryType.fromJson(json['type'] as String),
    );

Map<String, dynamic> _$SidebarCategoryToJson(SidebarCategory instance) =>
    <String, dynamic>{
      'id': const LenientString().toJson(instance.id),
      'user_id': const LenientString().toJson(instance.userId),
      'team_id': const LenientString().toJson(instance.teamId),
      'display_name': const LenientString().toJson(instance.displayName),
      'type': instance.type,
    };
