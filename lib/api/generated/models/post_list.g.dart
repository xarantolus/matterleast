// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostList _$PostListFromJson(Map<String, dynamic> json) => PostList(
  posts: const LenientMapOfPost().fromJson(json['posts']),
  nextPostId: const LenientString().fromJson(json['next_post_id']),
  prevPostId: const LenientString().fromJson(json['prev_post_id']),
  hasNext: const LenientBool().fromJson(json['has_next']),
  firstInaccessiblePostTime: const MillisDateTime().fromJson(
    json['first_inaccessible_post_time'],
  ),
  order: json['order'] == null
      ? const []
      : const LenientStringList().fromJson(json['order']),
);

Map<String, dynamic> _$PostListToJson(PostList instance) => <String, dynamic>{
  'order': const LenientStringList().toJson(instance.order),
  'posts': const LenientMapOfPost().toJson(instance.posts),
  'next_post_id': const LenientString().toJson(instance.nextPostId),
  'prev_post_id': const LenientString().toJson(instance.prevPostId),
  'has_next': const LenientBool().toJson(instance.hasNext),
  'first_inaccessible_post_time': const MillisDateTime().toJson(
    instance.firstInaccessiblePostTime,
  ),
};
