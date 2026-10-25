// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/api_v4_posts_post_id_patch_request_body.dart';
import '../models/api_v4_posts_post_id_request_body.dart';
import '../models/api_v4_posts_request_body.dart';
import '../models/channel_unread_at.dart';
import '../models/file_info.dart';
import '../models/post.dart';
import '../models/post_acknowledgement.dart';
import '../models/post_info.dart';
import '../models/post_list.dart';
import '../models/status_ok.dart';

part 'posts_client.g.dart';

@RestApi()
abstract class PostsClient {
  factory PostsClient(Dio dio, {String? baseUrl}) = _PostsClient;

  @POST('/api/v4/posts')
  Future<Post> createPost({
    @Body() required ApiV4PostsRequestBody body,
    @Query('set_online') bool? setOnline,
    @Query('silent') bool? silent,
  });

  @GET('/api/v4/posts/{post_id}')
  Future<Post> getPost({
    @Path('post_id') required String postId,
    @Query('include_deleted') bool? includeDeleted = false,
  });

  @DELETE('/api/v4/posts/{post_id}')
  Future<StatusOk> deletePost({@Path('post_id') required String postId});

  @PUT('/api/v4/posts/{post_id}')
  Future<Post> updatePost({
    @Path('post_id') required String postId,
    @Body() required ApiV4PostsPostIdRequestBody body,
  });

  @POST('/api/v4/users/{user_id}/posts/{post_id}/set_unread')
  Future<ChannelUnreadAt> setPostUnread({
    @Path('user_id') required String userId,
    @Path('post_id') required String postId,
  });

  @PUT('/api/v4/posts/{post_id}/patch')
  Future<Post> patchPost({
    @Path('post_id') required String postId,
    @Body() required ApiV4PostsPostIdPatchRequestBody body,
  });

  @GET('/api/v4/posts/{post_id}/thread')
  Future<PostList> getPostThread({
    @Path('post_id') required String postId,
    @Query('perPage') int? perPage = 0,
    @Query('fromPost') String? fromPost = '',
    @Query('fromCreateAt') int? fromCreateAt = 0,
    @Query('fromUpdateAt') int? fromUpdateAt = 0,
    @Query('direction') String? direction = '',
    @Query('skipFetchThreads') bool? skipFetchThreads = false,
    @Query('collapsedThreads') bool? collapsedThreads = false,
    @Query('collapsedThreadsExtended') bool? collapsedThreadsExtended = false,
    @Query('updatesOnly') bool? updatesOnly = false,
  });

  @GET('/api/v4/users/{user_id}/posts/flagged')
  Future<List<PostList>> getFlaggedPostsForUser({
    @Path('user_id') required String userId,
    @Query('page') int? page = 0,
    @Query('per_page') int? perPage = 60,
    @Query('team_id') String? teamId,
    @Query('channel_id') String? channelId,
  });

  @GET('/api/v4/posts/{post_id}/files/info')
  Future<List<FileInfo>> getFileInfosForPost({
    @Path('post_id') required String postId,
    @Query('include_deleted') bool? includeDeleted = false,
  });

  @GET('/api/v4/posts/{post_id}/info')
  Future<PostInfo> getPostInfo({@Path('post_id') required String postId});

  @GET('/api/v4/channels/{channel_id}/posts')
  Future<PostList> getPostsForChannel({
    @Path('channel_id') required String channelId,
    @Query('since') int? since,
    @Query('before') String? before,
    @Query('after') String? after,
    @Query('type') String? type,
    @Query('page') int? page = 0,
    @Query('per_page') int? perPage = 60,
    @Query('include_deleted') bool? includeDeleted = false,
  });

  @POST('/api/v4/posts/{post_id}/pin')
  Future<StatusOk> pinPost({@Path('post_id') required String postId});

  @POST('/api/v4/posts/{post_id}/unpin')
  Future<StatusOk> unpinPost({@Path('post_id') required String postId});

  @POST('/api/v4/posts/{post_id}/actions/{action_id}')
  Future<StatusOk> doPostAction({
    @Path('post_id') required String postId,
    @Path('action_id') required String actionId,
  });

  @POST('/api/v4/users/{user_id}/posts/{post_id}/ack')
  Future<PostAcknowledgement> saveAcknowledgementForPost({
    @Path('user_id') required String userId,
    @Path('post_id') required String postId,
  });

  @DELETE('/api/v4/users/{user_id}/posts/{post_id}/ack')
  Future<StatusOk> deleteAcknowledgementForPost({
    @Path('user_id') required String userId,
    @Path('post_id') required String postId,
  });

  @GET('/api/v4/posts/{post_id}/reveal')
  Future<Post> revealPost({@Path('post_id') required String postId});

  @DELETE('/api/v4/posts/{post_id}/burn')
  Future<StatusOk> burnPost({@Path('post_id') required String postId});
}
