// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/api_v4_content_flagging_post_post_id_flag_request_body.dart';
import '../models/get_api_v4_content_flagging_flag_config_response.dart';
import '../models/get_api_v4_content_flagging_team_team_id_status_response.dart';
import '../models/status_ok.dart';

part 'content_flagging_client.g.dart';

@RestApi()
abstract class ContentFlaggingClient {
  factory ContentFlaggingClient(Dio dio, {String? baseUrl}) =
      _ContentFlaggingClient;

  @GET('/api/v4/content_flagging/flag/config')
  Future<GetApiV4ContentFlaggingFlagConfigResponse> getCfFlagConfig();

  @GET('/api/v4/content_flagging/team/{team_id}/status')
  Future<GetApiV4ContentFlaggingTeamTeamIdStatusResponse> getCfTeamStatus({
    @Path('team_id') required String teamId,
  });

  @POST('/api/v4/content_flagging/post/{post_id}/flag')
  Future<StatusOk> postCfPostFlag({
    @Path('post_id') required String postId,
    @Body() required ApiV4ContentFlaggingPostPostIdFlagRequestBody body,
  });
}
