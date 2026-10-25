// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_posts_post_id_patch_request_body.g.dart';

@JsonSerializable()
class ApiV4PostsPostIdPatchRequestBody {
  const ApiV4PostsPostIdPatchRequestBody({
    this.fileIds = const [],
    this.isPinned,
    this.message,
    this.hasReactions,
    this.props,
  });

  factory ApiV4PostsPostIdPatchRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4PostsPostIdPatchRequestBodyFromJson(json);

  @LenientBool()
  @JsonKey(name: 'is_pinned')
  final bool? isPinned;

  @LenientString()
  final String? message;

  @LenientStringList()
  @JsonKey(name: 'file_ids')
  final List<String> fileIds;

  @LenientBool()
  @JsonKey(name: 'has_reactions')
  final bool? hasReactions;

  @LenientString()
  final String? props;

  Map<String, Object?> toJson() =>
      _$ApiV4PostsPostIdPatchRequestBodyToJson(this);
}
