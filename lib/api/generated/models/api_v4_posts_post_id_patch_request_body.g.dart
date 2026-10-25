// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_posts_post_id_patch_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4PostsPostIdPatchRequestBody _$ApiV4PostsPostIdPatchRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4PostsPostIdPatchRequestBody(
  fileIds: json['file_ids'] == null
      ? const []
      : const LenientStringList().fromJson(json['file_ids']),
  isPinned: const LenientBool().fromJson(json['is_pinned']),
  message: const LenientString().fromJson(json['message']),
  hasReactions: const LenientBool().fromJson(json['has_reactions']),
  props: const LenientString().fromJson(json['props']),
);

Map<String, dynamic> _$ApiV4PostsPostIdPatchRequestBodyToJson(
  ApiV4PostsPostIdPatchRequestBody instance,
) => <String, dynamic>{
  'is_pinned': const LenientBool().toJson(instance.isPinned),
  'message': const LenientString().toJson(instance.message),
  'file_ids': const LenientStringList().toJson(instance.fileIds),
  'has_reactions': const LenientBool().toJson(instance.hasReactions),
  'props': const LenientString().toJson(instance.props),
};
