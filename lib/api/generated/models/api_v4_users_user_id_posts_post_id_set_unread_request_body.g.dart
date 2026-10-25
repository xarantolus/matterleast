// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_users_user_id_posts_post_id_set_unread_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4UsersUserIdPostsPostIdSetUnreadRequestBody
_$ApiV4UsersUserIdPostsPostIdSetUnreadRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4UsersUserIdPostsPostIdSetUnreadRequestBody(
  collapsedThreadsSupported: const LenientBool().fromJson(
    json['collapsed_threads_supported'],
  ),
);

Map<String, dynamic> _$ApiV4UsersUserIdPostsPostIdSetUnreadRequestBodyToJson(
  ApiV4UsersUserIdPostsPostIdSetUnreadRequestBody instance,
) => <String, dynamic>{
  'collapsed_threads_supported': const LenientBool().toJson(
    instance.collapsedThreadsSupported,
  ),
};
