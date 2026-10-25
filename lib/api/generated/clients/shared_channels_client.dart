// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/remote_cluster_info.dart';
import '../models/shared_channel.dart';
import '../models/status_ok.dart';

part 'shared_channels_client.g.dart';

@RestApi()
abstract class SharedChannelsClient {
  factory SharedChannelsClient(Dio dio, {String? baseUrl}) =
      _SharedChannelsClient;

  @GET('/api/v4/sharedchannels/{team_id}')
  Future<List<SharedChannel>> getAllSharedChannels({
    @Path('team_id') required String teamId,
    @Query('page') int? page = 0,
    @Query('per_page') int? perPage = 0,
  });

  @POST('/api/v4/remotecluster/{remote_id}/channels/{channel_id}/invite')
  Future<StatusOk> inviteRemoteClusterToChannel({
    @Path('remote_id') required String remoteId,
    @Path('channel_id') required String channelId,
  });

  @POST('/api/v4/remotecluster/{remote_id}/channels/{channel_id}/uninvite')
  Future<StatusOk> uninviteRemoteClusterToChannel({
    @Path('remote_id') required String remoteId,
    @Path('channel_id') required String channelId,
  });

  @GET('/api/v4/sharedchannels/{channel_id}/remotes')
  Future<List<RemoteClusterInfo>> getSharedChannelRemotes({
    @Path('channel_id') required String channelId,
  });
}
