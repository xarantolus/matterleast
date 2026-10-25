// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/global_data_retention_policy.dart';
import '../models/retention_policy_for_channel_list.dart';
import '../models/retention_policy_for_team_list.dart';

part 'data_retention_client.g.dart';

@RestApi()
abstract class DataRetentionClient {
  factory DataRetentionClient(Dio dio, {String? baseUrl}) =
      _DataRetentionClient;

  @GET('/api/v4/users/{user_id}/data_retention/team_policies')
  Future<RetentionPolicyForTeamList> getTeamPoliciesForUser({
    @Path('user_id') required String userId,
    @Query('page') int? page = 0,
    @Query('per_page') int? perPage = 60,
  });

  @GET('/api/v4/users/{user_id}/data_retention/channel_policies')
  Future<RetentionPolicyForChannelList> getChannelPoliciesForUser({
    @Path('user_id') required String userId,
    @Query('page') int? page = 0,
    @Query('per_page') int? perPage = 60,
  });

  @GET('/api/v4/data_retention/policy')
  Future<GlobalDataRetentionPolicy> getDataRetentionPolicy();
}
