// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'post.dart';

import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/json/lenient_models.dart';
part 'post_list.g.dart';

@JsonSerializable()
class PostList {
  const PostList({
    this.posts,
    this.nextPostId,
    this.prevPostId,
    this.hasNext,
    this.firstInaccessiblePostTime,
    this.order = const [],
  });

  factory PostList.fromJson(Map<String, Object?> json) =>
      _$PostListFromJson(json);

  @LenientStringList()
  final List<String> order;
  @LenientMapOfPost()
  final Map<String, Post>? posts;
  @LenientString()
  @JsonKey(name: 'next_post_id')
  final String? nextPostId;
  @LenientString()
  @JsonKey(name: 'prev_post_id')
  final String? prevPostId;
  @LenientBool()
  @JsonKey(name: 'has_next')
  final bool? hasNext;
  @MillisDateTime()
  @JsonKey(name: 'first_inaccessible_post_time')
  final DateTime? firstInaccessiblePostTime;

  Map<String, Object?> toJson() => _$PostListToJson(this);
}
