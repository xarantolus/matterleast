// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/action_search_request.dart';
import '../models/action_search_response.dart';

part 'access_control_client.g.dart';

@RestApi()
abstract class AccessControlClient {
  factory AccessControlClient(Dio dio, {String? baseUrl}) =
      _AccessControlClient;

  @GET('/api/v4/channels/{channel_id}/access_control/attributes')
  Future<dynamic> getChannelAccessControlAttributes({
    @Path('channel_id') required String channelId,
  });

  @POST('/api/v4/access_control/decisions/actions/search')
  Future<ActionSearchResponse> searchAccessControlDecisionActions({
    @Body() required ActionSearchRequest body,
  });
}
