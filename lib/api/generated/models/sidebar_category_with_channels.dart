// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'sidebar_category_with_channels_type.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'sidebar_category_with_channels.g.dart';

@JsonSerializable()
class SidebarCategoryWithChannels {
  const SidebarCategoryWithChannels({
    this.channelIds = const [],
    this.id,
    this.userId,
    this.teamId,
    this.displayName,
    this.type,
    this.sorting,
    this.muted,
    this.collapsed,
    this.sortOrder,
  });

  factory SidebarCategoryWithChannels.fromJson(Map<String, Object?> json) =>
      _$SidebarCategoryWithChannelsFromJson(json);

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
  final SidebarCategoryWithChannelsType? type;
  @LenientStringList()
  @JsonKey(name: 'channel_ids')
  final List<String> channelIds;
  @LenientString()
  final String? sorting;
  @LenientBool()
  final bool? muted;
  @LenientBool()
  final bool? collapsed;
  @LenientInt()
  @JsonKey(name: 'sort_order')
  final int? sortOrder;

  Map<String, Object?> toJson() => _$SidebarCategoryWithChannelsToJson(this);
}
