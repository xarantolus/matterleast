// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/api_v4_properties_groups_group_name_object_type_fields_request_body.dart';
import '../models/api_v4_properties_groups_group_name_object_type_values_target_id_request_body.dart';
import '../models/property_field.dart';
import '../models/property_value.dart';
import '../models/target_type.dart';

part 'properties_client.g.dart';

@RestApi()
abstract class PropertiesClient {
  factory PropertiesClient(Dio dio, {String? baseUrl}) = _PropertiesClient;

  @POST('/api/v4/properties/groups/{group_name}/{object_type}/fields')
  Future<PropertyField> createPropertyField({
    @Path('group_name') required String groupName,
    @Path('object_type') required String objectType,
    @Body()
    required ApiV4PropertiesGroupsGroupNameObjectTypeFieldsRequestBody body,
  });

  @GET('/api/v4/properties/groups/{group_name}/{object_type}/fields')
  Future<List<PropertyField>> getPropertyFields({
    @Path('group_name') required String groupName,
    @Path('object_type') required String objectType,
    @Query('per_page') int? perPage = 60,
    @Query('channel_id') String? channelId,
    @Query('team_id') String? teamId,
    @Query('target_type') TargetType? targetType,
    @Query('target_id') String? targetId,
    @Query('since') int? since,
    @Query('cursor_id') String? cursorId,
    @Query('cursor_create_at') int? cursorCreateAt,
    @Query('cursor_update_at') int? cursorUpdateAt,
  });

  @GET(
    '/api/v4/properties/groups/{group_name}/{object_type}/values/{target_id}',
  )
  Future<List<PropertyValue>> getPropertyValues({
    @Path('group_name') required String groupName,
    @Path('object_type') required String objectType,
    @Path('target_id') required String targetId,
    @Query('per_page') int? perPage = 60,
    @Query('since') int? since,
    @Query('cursor_id') String? cursorId,
    @Query('cursor_create_at') int? cursorCreateAt,
    @Query('cursor_update_at') int? cursorUpdateAt,
  });

  @PATCH(
    '/api/v4/properties/groups/{group_name}/{object_type}/values/{target_id}',
  )
  Future<List<PropertyValue>> updatePropertyValues({
    @Path('group_name') required String groupName,
    @Path('object_type') required String objectType,
    @Path('target_id') required String targetId,
    @Body()
    required List<
      ApiV4PropertiesGroupsGroupNameObjectTypeValuesTargetIdRequestBody
    >
    body,
  });
}
