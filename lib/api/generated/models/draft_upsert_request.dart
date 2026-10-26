// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'post_priority.dart';

import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/json/lenient_models.dart';
part 'draft_upsert_request.g.dart';

@JsonSerializable()
class DraftUpsertRequest {
  const DraftUpsertRequest({
    this.fileIds = const [],
    this.channelId,
    this.rootId,
    this.message,
    this.type,
    this.props,
    this.priority,
  });

  factory DraftUpsertRequest.fromJson(Map<String, Object?> json) =>
      _$DraftUpsertRequestFromJson(json);

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
  @LenientPostPriority()
  final PostPriority? priority;

  Map<String, Object?> toJson() => _$DraftUpsertRequestToJson(this);
}
