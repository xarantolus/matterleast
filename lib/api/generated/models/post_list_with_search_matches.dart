// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'post.dart';

import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/json/lenient_models.dart';
part 'post_list_with_search_matches.g.dart';

@JsonSerializable()
class PostListWithSearchMatches {
  const PostListWithSearchMatches({
    this.posts,
    this.matches,
    this.order = const [],
  });

  factory PostListWithSearchMatches.fromJson(Map<String, Object?> json) =>
      _$PostListWithSearchMatchesFromJson(json);

  @LenientStringList()
  final List<String> order;
  @LenientMapOfPost()
  final Map<String, Post>? posts;
  final Map<String, List<String>>? matches;

  Map<String, Object?> toJson() => _$PostListWithSearchMatchesToJson(this);
}
