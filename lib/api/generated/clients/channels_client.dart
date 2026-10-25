// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/api_v4_channels_channel_id_convert_to_channel_request_body.dart';
import '../models/api_v4_channels_channel_id_members_request_body.dart';
import '../models/api_v4_channels_channel_id_members_request_body2.dart';
import '../models/api_v4_channels_channel_id_members_user_id_autotranslation_request_body.dart';
import '../models/api_v4_channels_channel_id_members_user_id_scheme_roles_request_body.dart';
import '../models/api_v4_channels_channel_id_patch_request_body.dart';
import '../models/api_v4_channels_channel_id_privacy_request_body.dart';
import '../models/api_v4_channels_channel_id_request_body.dart';
import '../models/api_v4_channels_members_user_id_view_request_body.dart';
import '../models/api_v4_channels_request_body.dart';
import '../models/api_v4_channels_search_request_body.dart';
import '../models/api_v4_teams_team_id_channels_search_request_body.dart';
import '../models/channel.dart';
import '../models/channel_list_with_team_data.dart';
import '../models/channel_member.dart';
import '../models/channel_notify_props.dart';
import '../models/channel_stats.dart';
import '../models/ordered_sidebar_categories.dart';
import '../models/post_api_v4_channels_members_user_id_view_response.dart';
import '../models/post_api_v4_channels_search_response.dart';
import '../models/post_list.dart';
import '../models/sidebar_category.dart';
import '../models/sidebar_category_with_channels.dart';
import '../models/status_ok.dart';
import '../models/team.dart';

part 'channels_client.g.dart';

@RestApi()
abstract class ChannelsClient {
  factory ChannelsClient(Dio dio, {String? baseUrl}) = _ChannelsClient;

  @GET('/api/v4/channels')
  Future<ChannelListWithTeamData> getAllChannels({
    @Query('page') int? page = 0,
    @Query('per_page') int? perPage = 0,
    @Query('exclude_default_channels') bool? excludeDefaultChannels = false,
    @Query('include_deleted') bool? includeDeleted = false,
    @Query('include_total_count') bool? includeTotalCount = false,
    @Query('exclude_policy_constrained') bool? excludePolicyConstrained = false,
    @Query('not_associated_to_group') String? notAssociatedToGroup,
  });

  @POST('/api/v4/channels')
  Future<Channel> createChannel({
    @Body() required ApiV4ChannelsRequestBody body,
  });

  @POST('/api/v4/channels/direct')
  Future<Channel> createDirectChannel({@Body() required List<String> body});

  @POST('/api/v4/channels/group')
  Future<Channel> createGroupChannel({@Body() required List<String> body});

  @POST('/api/v4/channels/search')
  Future<PostApiV4ChannelsSearchResponse> searchAllChannels({
    @Body() required ApiV4ChannelsSearchRequestBody body,
    @Query('system_console') bool? systemConsole = true,
  });

  @GET('/api/v4/channels/{channel_id}/timezones')
  Future<List<String>> getChannelMembersTimezones({
    @Path('channel_id') required String channelId,
  });

  @GET('/api/v4/channels/{channel_id}')
  Future<Channel> getChannel({@Path('channel_id') required String channelId});

  @PUT('/api/v4/channels/{channel_id}')
  Future<Channel> updateChannel({
    @Path('channel_id') required String channelId,
    @Body() required ApiV4ChannelsChannelIdRequestBody body,
  });

  @DELETE('/api/v4/channels/{channel_id}')
  Future<StatusOk> deleteChannel({
    @Path('channel_id') required String channelId,
  });

  @PUT('/api/v4/channels/{channel_id}/patch')
  Future<Channel> patchChannel({
    @Path('channel_id') required String channelId,
    @Body() required ApiV4ChannelsChannelIdPatchRequestBody body,
  });

  @PUT('/api/v4/channels/{channel_id}/privacy')
  Future<Channel> updateChannelPrivacy({
    @Path('channel_id') required String channelId,
    @Body() required ApiV4ChannelsChannelIdPrivacyRequestBody body,
  });

  @POST('/api/v4/channels/{channel_id}/restore')
  Future<Channel> restoreChannel({
    @Path('channel_id') required String channelId,
  });

  @GET('/api/v4/channels/{channel_id}/stats')
  Future<ChannelStats> getChannelStats({
    @Path('channel_id') required String channelId,
  });

  @GET('/api/v4/channels/{channel_id}/pinned')
  Future<PostList> getPinnedPosts({
    @Path('channel_id') required String channelId,
  });

  @GET('/api/v4/teams/{team_id}/channels')
  Future<List<Channel>> getPublicChannelsForTeam({
    @Path('team_id') required String teamId,
    @Query('page') int? page = 0,
    @Query('per_page') int? perPage = 60,
  });

  @GET('/api/v4/teams/{team_id}/channels/deleted')
  Future<List<Channel>> getDeletedChannelsForTeam({
    @Path('team_id') required String teamId,
    @Query('page') int? page = 0,
    @Query('per_page') int? perPage = 60,
  });

  @GET('/api/v4/teams/{team_id}/channels/autocomplete')
  Future<List<Channel>> autocompleteChannelsForTeam({
    @Path('team_id') required String teamId,
    @Query('name') required String name,
  });

  @GET('/api/v4/teams/{team_id}/channels/search_autocomplete')
  Future<List<Channel>> autocompleteChannelsForTeamForSearch({
    @Path('team_id') required String teamId,
    @Query('name') required String name,
  });

  @GET('/api/v4/teams/{team_id}/channels/managed_categories')
  Future<Map<String, String>> getManagedCategories({
    @Path('team_id') required String teamId,
  });

  @POST('/api/v4/teams/{team_id}/channels/search')
  Future<List<Channel>> searchChannels({
    @Path('team_id') required String teamId,
    @Body() required ApiV4TeamsTeamIdChannelsSearchRequestBody body,
  });

  @GET('/api/v4/teams/{team_id}/channels/name/{channel_name}')
  Future<Channel> getChannelByName({
    @Path('team_id') required String teamId,
    @Path('channel_name') required String channelName,
    @Query('include_deleted') bool? includeDeleted = false,
  });

  @GET('/api/v4/teams/name/{team_name}/channels/name/{channel_name}')
  Future<Channel> getChannelByNameForTeamName({
    @Path('team_name') required String teamName,
    @Path('channel_name') required String channelName,
    @Query('include_deleted') bool? includeDeleted = false,
  });

  @GET('/api/v4/channels/{channel_id}/members')
  Future<List<ChannelMember>> getChannelMembers({
    @Path('channel_id') required String channelId,
    @Query('page') int? page = 0,
    @Query('per_page') int? perPage = 60,
  });

  @POST('/api/v4/channels/{channel_id}/members')
  Future<ChannelMember> addChannelMember({
    @Path('channel_id') required String channelId,
    @Body() required ApiV4ChannelsChannelIdMembersRequestBody body,
  });

  @PUT('/api/v4/channels/{channel_id}/members')
  Future<String> setChannelMembers({
    @Path('channel_id') required String channelId,
    @Body() required ApiV4ChannelsChannelIdMembersRequestBody2 body,
    @Query('batch_size') int? batchSize = 100,
    @Query('batch_delay_ms') int? batchDelayMs = 500,
  });

  @POST('/api/v4/channels/{channel_id}/members/ids')
  Future<List<ChannelMember>> getChannelMembersByIds({
    @Path('channel_id') required String channelId,
    @Body() required List<String> body,
  });

  @GET('/api/v4/channels/{channel_id}/members/{user_id}')
  Future<ChannelMember> getChannelMember({
    @Path('channel_id') required String channelId,
    @Path('user_id') required String userId,
  });

  @DELETE('/api/v4/channels/{channel_id}/members/{user_id}')
  Future<StatusOk> removeUserFromChannel({
    @Path('channel_id') required String channelId,
    @Path('user_id') required String userId,
  });

  @PUT('/api/v4/channels/{channel_id}/members/{user_id}/schemeRoles')
  Future<StatusOk> updateChannelMemberSchemeRoles({
    @Path('channel_id') required String channelId,
    @Path('user_id') required String userId,
    @Body()
    required ApiV4ChannelsChannelIdMembersUserIdSchemeRolesRequestBody body,
  });

  @PUT('/api/v4/channels/{channel_id}/members/{user_id}/notify_props')
  Future<StatusOk> updateChannelNotifyProps({
    @Path('channel_id') required String channelId,
    @Path('user_id') required String userId,
    @Body() required ChannelNotifyProps body,
  });

  @PUT('/api/v4/channels/{channel_id}/members/{user_id}/autotranslation')
  Future<StatusOk> updateChannelMemberAutotranslation({
    @Path('channel_id') required String channelId,
    @Path('user_id') required String userId,
    @Body()
    required ApiV4ChannelsChannelIdMembersUserIdAutotranslationRequestBody body,
  });

  @POST('/api/v4/channels/members/{user_id}/view')
  Future<PostApiV4ChannelsMembersUserIdViewResponse> viewChannel({
    @Path('user_id') required String userId,
    @Body() required ApiV4ChannelsMembersUserIdViewRequestBody body,
  });

  @GET('/api/v4/users/{user_id}/teams/{team_id}/channels/members')
  Future<List<ChannelMember>> getChannelMembersForUser({
    @Path('user_id') required String userId,
    @Path('team_id') required String teamId,
  });

  @GET('/api/v4/users/{user_id}/teams/{team_id}/channels')
  Future<List<Channel>> getChannelsForTeamForUser({
    @Path('user_id') required String userId,
    @Path('team_id') required String teamId,
    @Query('include_deleted') bool? includeDeleted = false,
    @Query('last_delete_at') int? lastDeleteAt = 0,
  });

  @GET('/api/v4/users/{user_id}/channels')
  Future<List<Channel>> getChannelsForUser({
    @Path('user_id') required String userId,
    @Query('last_delete_at') int? lastDeleteAt = 0,
    @Query('include_deleted') bool? includeDeleted = false,
  });

  @GET('/api/v4/channels/{channel_id}/member_counts_by_group')
  Future<void> getChannelMemberCountsByGroup({
    @Path('channel_id') required String channelId,
    @Query('include_timezones') bool? includeTimezones = false,
  });

  @GET('/api/v4/users/{user_id}/teams/{team_id}/channels/categories')
  Future<OrderedSidebarCategories> getSidebarCategoriesForTeamForUser({
    @Path('team_id') required String teamId,
    @Path('user_id') required String userId,
  });

  @POST('/api/v4/users/{user_id}/teams/{team_id}/channels/categories')
  Future<SidebarCategory> createSidebarCategoryForTeamForUser({
    @Path('team_id') required String teamId,
    @Path('user_id') required String userId,
    @Body() required SidebarCategory body,
  });

  @PUT('/api/v4/users/{user_id}/teams/{team_id}/channels/categories')
  Future<List<SidebarCategoryWithChannels>>
  updateSidebarCategoriesForTeamForUser({
    @Path('team_id') required String teamId,
    @Path('user_id') required String userId,
    @Body() required List<SidebarCategoryWithChannels> body,
  });

  @GET('/api/v4/users/{user_id}/teams/{team_id}/channels/categories/order')
  Future<List<String>> getSidebarCategoryOrderForTeamForUser({
    @Path('team_id') required String teamId,
    @Path('user_id') required String userId,
  });

  @PUT('/api/v4/users/{user_id}/teams/{team_id}/channels/categories/order')
  Future<List<String>> updateSidebarCategoryOrderForTeamForUser({
    @Path('team_id') required String teamId,
    @Path('user_id') required String userId,
    @Body() required List<String> body,
  });

  @GET(
    '/api/v4/users/{user_id}/teams/{team_id}/channels/categories/{category_id}',
  )
  Future<SidebarCategory> getSidebarCategoryForTeamForUser({
    @Path('team_id') required String teamId,
    @Path('user_id') required String userId,
    @Path('category_id') required String categoryId,
  });

  @PUT(
    '/api/v4/users/{user_id}/teams/{team_id}/channels/categories/{category_id}',
  )
  Future<SidebarCategory> updateSidebarCategoryForTeamForUser({
    @Path('team_id') required String teamId,
    @Path('user_id') required String userId,
    @Path('category_id') required String categoryId,
    @Body() required SidebarCategory body,
  });

  @DELETE(
    '/api/v4/users/{user_id}/teams/{team_id}/channels/categories/{category_id}',
  )
  Future<SidebarCategory> removeSidebarCategoryForTeamForUser({
    @Path('team_id') required String teamId,
    @Path('user_id') required String userId,
    @Path('category_id') required String categoryId,
  });

  @GET('/api/v4/channels/{channel_id}/common_teams')
  Future<List<Team>> getGroupMessageMembersCommonTeams({
    @Path('channel_id') required String channelId,
  });

  @POST('/api/v4/channels/{channel_id}/convert_to_channel')
  Future<Channel> convertGroupMessageToChannel({
    @Path('channel_id') required String channelId,
    @Body() required ApiV4ChannelsChannelIdConvertToChannelRequestBody body,
  });
}
