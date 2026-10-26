// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/api_v4_users_login_request_body.dart';
import '../models/api_v4_users_login_sso_code_exchange_request_body.dart';
import '../models/api_v4_users_login_type_request_body.dart';
import '../models/api_v4_users_password_reset_send_request_body.dart';
import '../models/api_v4_users_request_body.dart';
import '../models/api_v4_users_search_request_body.dart';
import '../models/api_v4_users_sessions_device_request_body.dart';
import '../models/api_v4_users_user_id_password_request_body.dart';
import '../models/api_v4_users_user_id_patch_request_body.dart';
import '../models/api_v4_users_user_id_request_body.dart';
import '../models/api_v4_users_user_id_terms_of_service_request_body.dart';
import '../models/channel_member_with_team_data.dart';
import '../models/draft.dart';
import '../models/draft_upsert_request.dart';
import '../models/get_api_v4_users_sessions_attributes_manifest_response.dart';
import '../models/post_api_v4_users_group_channels_response.dart';
import '../models/post_api_v4_users_login_sso_code_exchange_response.dart';
import '../models/post_api_v4_users_login_type_response.dart';
import '../models/session.dart';
import '../models/status_ok.dart';
import '../models/user.dart';
import '../models/user_autocomplete.dart';
import '../models/user_terms_of_service.dart';

part 'users_client.g.dart';

@RestApi()
abstract class UsersClient {
  factory UsersClient(Dio dio, {String? baseUrl}) = _UsersClient;

  @POST('/api/v4/users/login')
  Future<User> login({@Body() required ApiV4UsersLoginRequestBody body});

  @Deprecated('This method is marked as deprecated')
  @POST('/api/v4/users/login/sso/code-exchange')
  Future<PostApiV4UsersLoginSsoCodeExchangeResponse> loginSsoCodeExchange({
    @Body() required ApiV4UsersLoginSsoCodeExchangeRequestBody body,
  });

  @POST('/api/v4/users/logout')
  Future<StatusOk> logout();

  @POST('/api/v4/users')
  Future<User> createUser({
    @Body() required ApiV4UsersRequestBody body,
    @Query('t') String? t,
    @Query('iid') String? iid,
  });

  @GET('/api/v4/users')
  Future<List<User>> getUsers({
    @Query('in_team') String? inTeam,
    @Query('not_in_team') String? notInTeam,
    @Query('in_channel') String? inChannel,
    @Query('not_in_channel') String? notInChannel,
    @Query('in_group') String? inGroup,
    @Query('group_constrained') bool? groupConstrained,
    @Query('abac_match_only') bool? abacMatchOnly,
    @Query('without_team') bool? withoutTeam,
    @Query('active') bool? active,
    @Query('inactive') bool? inactive,
    @Query('role') String? role,
    @Query('sort') String? sort,
    @Query('roles') String? roles,
    @Query('channel_roles') String? channelRoles,
    @Query('team_roles') String? teamRoles,
    @Query('page') int? page = 0,
    @Query('per_page') int? perPage = 60,
  });

  @DELETE('/api/v4/users')
  Future<void> permanentDeleteAllUsers();

  @POST('/api/v4/users/ids')
  Future<List<User>> getUsersByIds({
    @Body() required List<String> body,
    @Query('since') int? since,
  });

  @POST('/api/v4/users/group_channels')
  Future<PostApiV4UsersGroupChannelsResponse> getUsersByGroupChannelIds({
    @Body() required List<String> body,
  });

  @POST('/api/v4/users/usernames')
  Future<List<User>> getUsersByUsernames({@Body() required List<String> body});

  @POST('/api/v4/users/search')
  Future<List<User>> searchUsers({
    @Body() required ApiV4UsersSearchRequestBody body,
  });

  @GET('/api/v4/users/autocomplete')
  Future<UserAutocomplete> autocompleteUsers({
    @Query('name') required String name,
    @Query('limit') int? limit = 100,
    @Query('in_team') String? inTeam,
    @Query('in_channel') String? inChannel,
  });

  @GET('/api/v4/users/known')
  Future<dynamic> getKnownUsers();

  @GET('/api/v4/users/{user_id}')
  Future<User> getUser({@Path('user_id') required String userId});

  @PUT('/api/v4/users/{user_id}')
  Future<User> updateUser({
    @Path('user_id') required String userId,
    @Body() required ApiV4UsersUserIdRequestBody body,
  });

  @DELETE('/api/v4/users/{user_id}')
  Future<StatusOk> deleteUser({@Path('user_id') required String userId});

  @PUT('/api/v4/users/{user_id}/patch')
  Future<User> patchUser({
    @Path('user_id') required String userId,
    @Body() required ApiV4UsersUserIdPatchRequestBody body,
  });

  @GET('/api/v4/users/{user_id}/image')
  Future<void> getProfileImage({
    @Path('user_id') required String userId,
    @Query('_') num? private,
  });

  @MultiPart()
  @POST('/api/v4/users/{user_id}/image')
  Future<StatusOk> setProfileImage({
    @Path('user_id') required String userId,
    @Part(name: 'image') required File image,
  });

  @DELETE('/api/v4/users/{user_id}/image')
  Future<StatusOk> setDefaultProfileImage({
    @Path('user_id') required String userId,
  });

  @GET('/api/v4/users/username/{username}')
  Future<User> getUserByUsername({@Path('username') required String username});

  @POST('/api/v4/users/{user_id}/demote')
  Future<StatusOk> demoteUserToGuest({@Path('user_id') required String userId});

  @PUT('/api/v4/users/{user_id}/password')
  Future<StatusOk> updateUserPassword({
    @Path('user_id') required String userId,
    @Body() required ApiV4UsersUserIdPasswordRequestBody body,
  });

  @POST('/api/v4/users/password/reset/send')
  Future<StatusOk> sendPasswordResetEmail({
    @Body() required ApiV4UsersPasswordResetSendRequestBody body,
  });

  @GET('/api/v4/users/email/{email}')
  Future<User> getUserByEmail({@Path('email') required String email});

  @GET('/api/v4/users/{user_id}/sessions')
  Future<List<Session>> getSessions({@Path('user_id') required String userId});

  @PUT('/api/v4/users/sessions/device')
  Future<StatusOk> attachDeviceExtraProps({
    @Body() required ApiV4UsersSessionsDeviceRequestBody body,
  });

  @GET('/api/v4/users/sessions/attributes/manifest')
  Future<List<GetApiV4UsersSessionsAttributesManifestResponse>>
  getSessionAttributesManifest();

  @POST('/api/v4/users/login/type')
  Future<PostApiV4UsersLoginTypeResponse> getLoginType({
    @Body() required ApiV4UsersLoginTypeRequestBody body,
  });

  @POST('/api/v4/users/{user_id}/terms_of_service')
  Future<StatusOk> registerTermsOfServiceAction({
    @Path('user_id') required String userId,
    @Body() required ApiV4UsersUserIdTermsOfServiceRequestBody body,
  });

  @GET('/api/v4/users/{user_id}/terms_of_service')
  Future<UserTermsOfService> getUserTermsOfService({
    @Path('user_id') required String userId,
  });

  @GET('/api/v4/users/{user_id}/channel_members')
  Future<List<ChannelMemberWithTeamData>> getChannelMembersWithTeamDataForUser({
    @Path('user_id') required String userId,
    @Query('per_page') int? perPage = 60,
    @Query('page') int? page,
  });

  @POST('/api/v4/drafts')
  Future<Draft?> upsertDraft({@Body() required DraftUpsertRequest body});

  @GET('/api/v4/users/{user_id}/teams/{team_id}/drafts')
  Future<List<Draft>> getDrafts({
    @Path('user_id') required String userId,
    @Path('team_id') required String teamId,
  });

  @DELETE('/api/v4/users/{user_id}/channels/{channel_id}/drafts')
  Future<StatusOk> deleteDraft({
    @Path('user_id') required String userId,
    @Path('channel_id') required String channelId,
  });

  @DELETE('/api/v4/users/{user_id}/channels/{channel_id}/drafts/{thread_id}')
  Future<StatusOk> deleteDraftForThread({
    @Path('user_id') required String userId,
    @Path('channel_id') required String channelId,
    @Path('thread_id') required String threadId,
  });
}
