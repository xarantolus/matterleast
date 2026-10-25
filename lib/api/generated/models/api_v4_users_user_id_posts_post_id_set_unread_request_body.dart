// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_users_user_id_posts_post_id_set_unread_request_body.g.dart';

@JsonSerializable()
class ApiV4UsersUserIdPostsPostIdSetUnreadRequestBody {
  const ApiV4UsersUserIdPostsPostIdSetUnreadRequestBody({
    this.collapsedThreadsSupported,
  });

  factory ApiV4UsersUserIdPostsPostIdSetUnreadRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4UsersUserIdPostsPostIdSetUnreadRequestBodyFromJson(json);

  @LenientBool()
  @JsonKey(name: 'collapsed_threads_supported')
  final bool? collapsedThreadsSupported;

  Map<String, Object?> toJson() =>
      _$ApiV4UsersUserIdPostsPostIdSetUnreadRequestBodyToJson(this);
}
