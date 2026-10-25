// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'file_info.g.dart';

@JsonSerializable()
class FileInfo {
  const FileInfo({
    this.id,
    this.userId,
    this.postId,
    this.createAt,
    this.updateAt,
    this.deleteAt,
    this.name,
    this.extensionValue,
    this.size,
    this.mimeType,
    this.width,
    this.height,
    this.hasPreviewImage,
    this.miniPreview,
    this.archived,
    this.channelId,
    this.remoteId,
  });

  factory FileInfo.fromJson(Map<String, Object?> json) =>
      _$FileInfoFromJson(json);

  @LenientString()
  final String? id;

  @LenientString()
  @JsonKey(name: 'user_id')
  final String? userId;

  @LenientString()
  @JsonKey(name: 'post_id')
  final String? postId;

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
  final String? name;

  @LenientString()
  @JsonKey(name: 'extension')
  final String? extensionValue;

  @LenientInt()
  final int? size;

  @LenientString()
  @JsonKey(name: 'mime_type')
  final String? mimeType;

  @LenientInt()
  final int? width;

  @LenientInt()
  final int? height;

  @LenientBool()
  @JsonKey(name: 'has_preview_image')
  final bool? hasPreviewImage;

  @LenientString()
  @JsonKey(name: 'mini_preview')
  final String? miniPreview;
  @LenientBool()
  final bool? archived;
  @LenientString()
  @JsonKey(name: 'channel_id')
  final String? channelId;
  @LenientString()
  @JsonKey(name: 'remote_id')
  final String? remoteId;

  Map<String, Object?> toJson() => _$FileInfoToJson(this);
}
