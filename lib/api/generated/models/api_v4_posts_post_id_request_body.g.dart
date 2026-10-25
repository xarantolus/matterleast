// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_posts_post_id_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4PostsPostIdRequestBody _$ApiV4PostsPostIdRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4PostsPostIdRequestBody(
  id: json['id'] as String,
  isPinned: const LenientBool().fromJson(json['is_pinned']),
  message: const LenientString().fromJson(json['message']),
  hasReactions: const LenientBool().fromJson(json['has_reactions']),
  props: const LenientString().fromJson(json['props']),
);

Map<String, dynamic> _$ApiV4PostsPostIdRequestBodyToJson(
  ApiV4PostsPostIdRequestBody instance,
) => <String, dynamic>{
  'id': instance.id,
  'is_pinned': const LenientBool().toJson(instance.isPinned),
  'message': const LenientString().toJson(instance.message),
  'has_reactions': const LenientBool().toJson(instance.hasReactions),
  'props': const LenientString().toJson(instance.props),
};
