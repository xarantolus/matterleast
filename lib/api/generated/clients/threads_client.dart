// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/user_threads.dart';

part 'threads_client.g.dart';

@RestApi()
abstract class ThreadsClient {
  factory ThreadsClient(Dio dio, {String? baseUrl}) = _ThreadsClient;

  @GET('/api/v4/users/{user_id}/teams/{team_id}/threads')
  Future<UserThreads> getUserThreads({
    @Path('user_id') required String userId,
    @Path('team_id') required String teamId,
    @Query('deleted') bool? deleted = false,
    @Query('extended') bool? extended = false,
    @Query('page') int? page = 0,
    @Query('per_page') int? perPage = 60,
    @Query('totalsOnly') bool? totalsOnly = false,
    @Query('threadsOnly') bool? threadsOnly = false,
    @Query('unread') bool? unread = false,
    @Query('since') int? since,
  });

  @GET('/api/v4/users/{user_id}/teams/{team_id}/threads/{thread_id}')
  Future<void> getUserThread({
    @Path('user_id') required String userId,
    @Path('team_id') required String teamId,
    @Path('thread_id') required String threadId,
  });
}
