// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/api_v4_channels_channel_id_bookmarks_bookmark_id_request_body.dart';
import '../models/api_v4_channels_channel_id_bookmarks_request_body.dart';
import '../models/channel_bookmark_with_file_info.dart';
import '../models/update_channel_bookmark_response.dart';

part 'bookmarks_client.g.dart';

@RestApi()
abstract class BookmarksClient {
  factory BookmarksClient(Dio dio, {String? baseUrl}) = _BookmarksClient;

  @GET('/api/v4/channels/{channel_id}/bookmarks')
  Future<List<ChannelBookmarkWithFileInfo>> listChannelBookmarksForChannel({
    @Path('channel_id') required String channelId,
    @Query('bookmarks_since') num? bookmarksSince,
  });

  @POST('/api/v4/channels/{channel_id}/bookmarks')
  Future<ChannelBookmarkWithFileInfo> createChannelBookmark({
    @Path('channel_id') required String channelId,
    @Body() required ApiV4ChannelsChannelIdBookmarksRequestBody body,
  });

  @PATCH('/api/v4/channels/{channel_id}/bookmarks/{bookmark_id}')
  Future<UpdateChannelBookmarkResponse> updateChannelBookmark({
    @Path('channel_id') required String channelId,
    @Path('bookmark_id') required String bookmarkId,
    @Body() required ApiV4ChannelsChannelIdBookmarksBookmarkIdRequestBody body,
  });

  @DELETE('/api/v4/channels/{channel_id}/bookmarks/{bookmark_id}')
  Future<ChannelBookmarkWithFileInfo> deleteChannelBookmark({
    @Path('channel_id') required String channelId,
    @Path('bookmark_id') required String bookmarkId,
  });

  @POST('/api/v4/channels/{channel_id}/bookmarks/{bookmark_id}/sort_order')
  Future<List<ChannelBookmarkWithFileInfo>> updateChannelBookmarkSortOrder({
    @Path('channel_id') required String channelId,
    @Path('bookmark_id') required String bookmarkId,
    @Body() num? body,
  });
}
