// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'post_metadata.dart';
import 'post_priority.dart';

import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/json/lenient_models.dart';
part 'draft.g.dart';

@JsonSerializable()
class Draft {
  const Draft({
    this.fileIds = const [],
    this.createAt,
    this.updateAt,
    this.deleteAt,
    this.userId,
    this.channelId,
    this.rootId,
    this.message,
    this.type,
    this.props,
    this.metadata,
    this.priority,
  });

  factory Draft.fromJson(Map<String, Object?> json) => _$DraftFromJson(json);

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
  @JsonKey(name: 'user_id')
  final String? userId;
  @LenientString()
  @JsonKey(name: 'channel_id')
  final String? channelId;
  @LenientString()
  @JsonKey(name: 'root_id')
  final String? rootId;
  @LenientString()
  final String? message;
  @LenientString()
  final String? type;
  final Object? props;
  @LenientStringList()
  @JsonKey(name: 'file_ids')
  final List<String> fileIds;
  @LenientPostMetadata()
  final PostMetadata? metadata;
  @LenientPostPriority()
  final PostPriority? priority;

  Map<String, Object?> toJson() => _$DraftToJson(this);
}
