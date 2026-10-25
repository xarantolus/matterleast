// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/api_v4_users_user_id_status_custom_recent_delete_request_body.dart';
import '../models/api_v4_users_user_id_status_custom_request_body.dart';
import '../models/api_v4_users_user_id_status_request_body.dart';
import '../models/status.dart';

part 'status_client.g.dart';

@RestApi()
abstract class StatusClient {
  factory StatusClient(Dio dio, {String? baseUrl}) = _StatusClient;

  @GET('/api/v4/users/{user_id}/status')
  Future<Status> getUserStatus({@Path('user_id') required String userId});

  @PUT('/api/v4/users/{user_id}/status')
  Future<Status> updateUserStatus({
    @Path('user_id') required String userId,
    @Body() required ApiV4UsersUserIdStatusRequestBody body,
  });

  @POST('/api/v4/users/status/ids')
  Future<List<Status>> getUsersStatusesByIds({
    @Body() required List<String> body,
  });

  @PUT('/api/v4/users/{user_id}/status/custom')
  Future<void> updateUserCustomStatus({
    @Path('user_id') required String userId,
    @Body() required ApiV4UsersUserIdStatusCustomRequestBody body,
  });

  @DELETE('/api/v4/users/{user_id}/status/custom')
  Future<void> unsetUserCustomStatus({@Path('user_id') required String userId});

  @POST('/api/v4/users/{user_id}/status/custom/recent/delete')
  Future<void> postUserRecentCustomStatusDelete({
    @Path('user_id') required String userId,
    @Body() required ApiV4UsersUserIdStatusCustomRecentDeleteRequestBody body,
  });
}
