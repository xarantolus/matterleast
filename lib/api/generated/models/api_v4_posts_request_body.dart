// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'metadata.dart';

import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/json/lenient_models.dart';
part 'api_v4_posts_request_body.g.dart';

@JsonSerializable()
class ApiV4PostsRequestBody {
  const ApiV4PostsRequestBody({
    required this.channelId,
    required this.message,
    this.fileIds = const [],
    this.rootId,
    this.props,
    this.metadata,
    this.pendingPostId,
    this.type,
  });

  factory ApiV4PostsRequestBody.fromJson(Map<String, Object?> json) =>
      _$ApiV4PostsRequestBodyFromJson(json);

  @JsonKey(name: 'channel_id')
  final String channelId;
  final String message;
  @LenientString()
  @JsonKey(name: 'root_id')
  final String? rootId;
  @LenientStringList()
  @JsonKey(name: 'file_ids')
  final List<String> fileIds;
  @JsonMap()
  final Map<String, Object?>? props;
  @LenientMetadata()
  final Metadata? metadata;
  @LenientString()
  @JsonKey(name: 'pending_post_id')
  final String? pendingPostId;
  @LenientString()
  final String? type;

  Map<String, Object?> toJson() => _$ApiV4PostsRequestBodyToJson(this);
}
