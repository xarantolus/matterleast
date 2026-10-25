// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/reaction.dart';
import '../models/status_ok.dart';

part 'reactions_client.g.dart';

@RestApi()
abstract class ReactionsClient {
  factory ReactionsClient(Dio dio, {String? baseUrl}) = _ReactionsClient;

  @POST('/api/v4/reactions')
  Future<Reaction> saveReaction({@Body() required Reaction body});

  @GET('/api/v4/posts/{post_id}/reactions')
  Future<List<Reaction>> getReactions({
    @Path('post_id') required String postId,
  });

  @DELETE('/api/v4/users/{user_id}/posts/{post_id}/reactions/{emoji_name}')
  Future<StatusOk> deleteReaction({
    @Path('user_id') required String userId,
    @Path('post_id') required String postId,
    @Path('emoji_name') required String emojiName,
  });
}
