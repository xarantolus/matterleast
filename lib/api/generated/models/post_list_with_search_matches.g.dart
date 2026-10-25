// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_list_with_search_matches.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostListWithSearchMatches _$PostListWithSearchMatchesFromJson(
  Map<String, dynamic> json,
) => PostListWithSearchMatches(
  posts: const LenientMapOfPost().fromJson(json['posts']),
  matches: (json['matches'] as Map<String, dynamic>?)?.map(
    (k, e) =>
        MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
  ),
  order: json['order'] == null
      ? const []
      : const LenientStringList().fromJson(json['order']),
);

Map<String, dynamic> _$PostListWithSearchMatchesToJson(
  PostListWithSearchMatches instance,
) => <String, dynamic>{
  'order': const LenientStringList().toJson(instance.order),
  'posts': const LenientMapOfPost().toJson(instance.posts),
  'matches': instance.matches,
};
