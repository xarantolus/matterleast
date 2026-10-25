// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/api_v4_teams_request_body.dart';
import '../models/api_v4_teams_team_id_invite_guests_email_request_body.dart';
import '../models/api_v4_teams_team_id_members_request_body.dart';
import '../models/api_v4_teams_team_id_patch_request_body.dart';
import '../models/api_v4_teams_team_id_request_body.dart';
import '../models/status_ok.dart';
import '../models/team.dart';
import '../models/team_member.dart';
import '../models/team_stats.dart';
import '../models/team_unread.dart';

part 'teams_client.g.dart';

@RestApi()
abstract class TeamsClient {
  factory TeamsClient(Dio dio, {String? baseUrl}) = _TeamsClient;

  @POST('/api/v4/teams')
  Future<Team> createTeam({@Body() required ApiV4TeamsRequestBody body});

  @GET('/api/v4/teams')
  Future<List<Team>> getAllTeams({
    @Query('page') int? page = 0,
    @Query('per_page') int? perPage = 60,
    @Query('include_total_count') bool? includeTotalCount = false,
    @Query('exclude_policy_constrained') bool? excludePolicyConstrained = false,
  });

  @GET('/api/v4/teams/{team_id}')
  Future<Team> getTeam({@Path('team_id') required String teamId});

  @PUT('/api/v4/teams/{team_id}')
  Future<Team> updateTeam({
    @Path('team_id') required String teamId,
    @Body() required ApiV4TeamsTeamIdRequestBody body,
  });

  @DELETE('/api/v4/teams/{team_id}')
  Future<StatusOk> softDeleteTeam({
    @Path('team_id') required String teamId,
    @Query('permanent') bool? permanent = false,
  });

  @PUT('/api/v4/teams/{team_id}/patch')
  Future<Team> patchTeam({
    @Path('team_id') required String teamId,
    @Body() required ApiV4TeamsTeamIdPatchRequestBody body,
  });

  @GET('/api/v4/users/{user_id}/teams')
  Future<List<Team>> getTeamsForUser({@Path('user_id') required String userId});

  @GET('/api/v4/teams/{team_id}/members')
  Future<List<TeamMember>> getTeamMembers({
    @Path('team_id') required String teamId,
    @Query('page') int? page = 0,
    @Query('per_page') int? perPage = 60,
    @Query('sort') String? sort = '',
    @Query('exclude_deleted_users') bool? excludeDeletedUsers = false,
  });

  @POST('/api/v4/teams/{team_id}/members')
  Future<TeamMember> addTeamMember({
    @Path('team_id') required String teamId,
    @Body() required ApiV4TeamsTeamIdMembersRequestBody body,
  });

  @POST('/api/v4/teams/{team_id}/members/batch')
  Future<List<TeamMember>> addTeamMembers({
    @Path('team_id') required String teamId,
    @Body() required List<TeamMember> body,
    @Query('graceful') bool? graceful,
  });

  @GET('/api/v4/users/{user_id}/teams/members')
  Future<List<TeamMember>> getTeamMembersForUser({
    @Path('user_id') required String userId,
  });

  @GET('/api/v4/teams/{team_id}/members/{user_id}')
  Future<TeamMember> getTeamMember({
    @Path('team_id') required String teamId,
    @Path('user_id') required String userId,
  });

  @DELETE('/api/v4/teams/{team_id}/members/{user_id}')
  Future<StatusOk> removeTeamMember({
    @Path('team_id') required String teamId,
    @Path('user_id') required String userId,
  });

  @POST('/api/v4/teams/{team_id}/members/ids')
  Future<List<TeamMember>> getTeamMembersByIds({
    @Path('team_id') required String teamId,
    @Body() required List<String> body,
  });

  @GET('/api/v4/teams/{team_id}/stats')
  Future<TeamStats> getTeamStats({@Path('team_id') required String teamId});

  @GET('/api/v4/users/{user_id}/teams/unread')
  Future<List<TeamUnread>> getTeamsUnreadForUser({
    @Path('user_id') required String userId,
    @Query('include_collapsed_threads') bool? includeCollapsedThreads = false,
    @Query('exclude_team') String? excludeTeam,
  });

  @POST('/api/v4/teams/{team_id}/invite/email')
  Future<StatusOk> inviteUsersToTeam({
    @Path('team_id') required String teamId,
    @Body() required dynamic body,
    @Query('graceful') bool? graceful,
  });

  @POST('/api/v4/teams/{team_id}/invite-guests/email')
  Future<StatusOk> inviteGuestsToTeam({
    @Path('team_id') required String teamId,
    @Body() required ApiV4TeamsTeamIdInviteGuestsEmailRequestBody body,
    @Query('graceful') bool? graceful,
    @Query('guest_magic_link') bool? guestMagicLink,
  });
}
