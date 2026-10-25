// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/api_v4_remotecluster_request_body.dart';
import '../models/post_api_v4_remotecluster_response.dart';
import '../models/remote_cluster.dart';

part 'remote_clusters_client.g.dart';

@RestApi()
abstract class RemoteClustersClient {
  factory RemoteClustersClient(Dio dio, {String? baseUrl}) =
      _RemoteClustersClient;

  @GET('/api/v4/remotecluster')
  Future<List<RemoteCluster>> getRemoteClusters({
    @Query('page') int? page,
    @Query('per_page') int? perPage,
    @Query('exclude_offline') bool? excludeOffline,
    @Query('in_channel') String? inChannel,
    @Query('not_in_channel') String? notInChannel,
    @Query('only_confirmed') bool? onlyConfirmed,
    @Query('only_plugins') bool? onlyPlugins,
    @Query('exclude_plugins') bool? excludePlugins,
    @Query('include_deleted') bool? includeDeleted,
  });

  @POST('/api/v4/remotecluster')
  Future<PostApiV4RemoteclusterResponse> createRemoteCluster({
    @Body() ApiV4RemoteclusterRequestBody? body,
  });
}
