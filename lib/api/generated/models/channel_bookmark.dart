// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'channel_bookmark_type.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'channel_bookmark.g.dart';

@JsonSerializable()
class ChannelBookmark {
  const ChannelBookmark({
    this.id,
    this.createAt,
    this.updateAt,
    this.deleteAt,
    this.channelId,
    this.ownerId,
    this.fileId,
    this.displayName,
    this.sortOrder,
    this.linkUrl,
    this.imageUrl,
    this.emoji,
    this.type,
    this.targetId,
    this.originalId,
    this.parentId,
  });

  factory ChannelBookmark.fromJson(Map<String, Object?> json) =>
      _$ChannelBookmarkFromJson(json);

  @LenientString()
  final String? id;

  @MillisDateTime()
  @JsonKey(name: 'create_at')
  final DateTime? createAt;

  @MillisDateTime()
  @JsonKey(name: 'update_at')
  final DateTime? updateAt;

  @MillisDateTime()
  @JsonKey(name: 'delete_at')
  final DateTime? deleteAt;
  @LenientString()
  @JsonKey(name: 'channel_id')
  final String? channelId;

  @LenientString()
  @JsonKey(name: 'owner_id')
  final String? ownerId;

  @LenientString()
  @JsonKey(name: 'file_id')
  final String? fileId;
  @LenientString()
  @JsonKey(name: 'display_name')
  final String? displayName;

  @LenientInt()
  @JsonKey(name: 'sort_order')
  final int? sortOrder;

  @LenientString()
  @JsonKey(name: 'link_url')
  final String? linkUrl;

  @LenientString()
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @LenientString()
  final String? emoji;
  final ChannelBookmarkType? type;

  @LenientString()
  @JsonKey(name: 'target_id')
  final String? targetId;

  @LenientString()
  @JsonKey(name: 'original_id')
  final String? originalId;

  @LenientString()
  @JsonKey(name: 'parent_id')
  final String? parentId;

  Map<String, Object?> toJson() => _$ChannelBookmarkToJson(this);
}
