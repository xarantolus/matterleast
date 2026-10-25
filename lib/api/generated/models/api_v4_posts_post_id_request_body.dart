// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_posts_post_id_request_body.g.dart';

@JsonSerializable()
class ApiV4PostsPostIdRequestBody {
  const ApiV4PostsPostIdRequestBody({
    required this.id,
    this.isPinned,
    this.message,
    this.hasReactions,
    this.props,
  });

  factory ApiV4PostsPostIdRequestBody.fromJson(Map<String, Object?> json) =>
      _$ApiV4PostsPostIdRequestBodyFromJson(json);

  final String id;

  @LenientBool()
  @JsonKey(name: 'is_pinned')
  final bool? isPinned;

  @LenientString()
  final String? message;

  @LenientBool()
  @JsonKey(name: 'has_reactions')
  final bool? hasReactions;

  @LenientString()
  final String? props;

  Map<String, Object?> toJson() => _$ApiV4PostsPostIdRequestBodyToJson(this);
}
