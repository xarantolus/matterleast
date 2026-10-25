// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/api_v4_posts_schedule_scheduled_post_id_request_body.dart';
import '../models/scheduled_post.dart';

part 'scheduled_post_client.g.dart';

@RestApi()
abstract class ScheduledPostClient {
  factory ScheduledPostClient(Dio dio, {String? baseUrl}) =
      _ScheduledPostClient;

  @GET('/api/v4/posts/scheduled/team/{team_id}')
  Future<Map<String, List<ScheduledPost>>> getUserScheduledPosts({
    @Path('team_id') required String teamId,
    @Query('includeDirectChannels') bool? includeDirectChannels = false,
  });

  @PUT('/api/v4/posts/schedule/{scheduled_post_id}')
  Future<dynamic> updateScheduledPost({
    @Path('scheduled_post_id') required String scheduledPostId,
    @Body() ApiV4PostsScheduleScheduledPostIdRequestBody? body,
  });

  @DELETE('/api/v4/posts/schedule/{scheduled_post_id}')
  Future<dynamic> deleteScheduledPost({
    @Path('scheduled_post_id') required String scheduledPostId,
  });
}
