// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/api_v4_groups_request_body.dart';
import '../models/group.dart';

part 'groups_client.g.dart';

@RestApi()
abstract class GroupsClient {
  factory GroupsClient(Dio dio, {String? baseUrl}) = _GroupsClient;

  @GET('/api/v4/groups')
  Future<List<Group>> getGroups({
    @Query('q') String? q,
    @Query('include_member_count') bool? includeMemberCount,
    @Query('not_associated_to_team') String? notAssociatedToTeam,
    @Query('not_associated_to_channel') String? notAssociatedToChannel,
    @Query('since') int? since,
    @Query('page') int? page = 0,
    @Query('per_page') int? perPage = 60,
    @Query('filter_allow_reference') bool? filterAllowReference = false,
  });

  @POST('/api/v4/groups')
  Future<void> createGroup({@Body() required ApiV4GroupsRequestBody body});

  @GET('/api/v4/channels/{channel_id}/groups')
  Future<List<Group>> getGroupsByChannel({
    @Path('channel_id') required String channelId,
    @Query('page') int? page = 0,
    @Query('per_page') int? perPage = 60,
    @Query('filter_allow_reference') bool? filterAllowReference = false,
  });

  @GET('/api/v4/teams/{team_id}/groups')
  Future<List<Group>> getGroupsByTeam({
    @Path('team_id') required String teamId,
    @Query('filter_has_member') String? filterHasMember,
    @Query('page') int? page = 0,
    @Query('per_page') int? perPage = 60,
    @Query('filter_allow_reference') bool? filterAllowReference = false,
    @Query('include_member_count') bool? includeMemberCount = false,
    @Query('include_timezones') bool? includeTimezones = false,
    @Query('include_total_count') bool? includeTotalCount = false,
    @Query('include_archived') bool? includeArchived = false,
    @Query('filter_archived') bool? filterArchived = false,
    @Query('filter_parent_team_permitted')
    bool? filterParentTeamPermitted = false,
    @Query('include_member_ids') bool? includeMemberIds = false,
    @Query('only_syncable_sources') bool? onlySyncableSources = false,
  });

  @GET('/api/v4/users/{user_id}/groups')
  Future<List<Group>> getGroupsByUserId({
    @Path('user_id') required String userId,
  });
}
